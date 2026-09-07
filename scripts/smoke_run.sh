#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $0 /path/to/Typing\\ Quest[.app]" >&2
  exit 2
fi

app_path="$1"
repo_root="$(cd "$(dirname "$0")/.." && pwd)"

python3 - <<'PY' "$app_path" "$repo_root"
import glob
import json
import os
import plistlib
import subprocess
import sys
import tempfile
import time

app_path = sys.argv[1]
repo_root = sys.argv[2] if len(sys.argv) > 2 else os.getcwd()
timeout_seconds = int(os.environ.get("SMOKE_TIMEOUT", "12"))
test_timeout_seconds = int(os.environ.get("SMOKE_TEST_TIMEOUT", "300"))
ready_token = "SMOKE_TEST_READY"
launch_method = os.environ.get("SMOKE_LAUNCH_METHOD", "auto")
tests_mode = os.environ.get("SMOKE_TESTS", "unit").strip().lower()


def is_executable(path):
    return os.path.isfile(path) and os.access(path, os.X_OK)


def bundle_executable(bundle):
    plist_path = os.path.join(bundle, "Contents", "Info.plist")
    if not os.path.isfile(plist_path):
        return None
    try:
        with open(plist_path, "rb") as handle:
            plist = plistlib.load(handle)
        executable = plist.get("CFBundleExecutable")
        if not executable:
            return None
        candidate = os.path.join(bundle, "Contents", "MacOS", executable)
        return candidate if os.path.isfile(candidate) else None
    except Exception:
        return None


def resolve_paths(path):
    bundle = None
    binary = path
    if path.endswith(".app") and os.path.isdir(path):
        bundle = path
    elif "/Contents/MacOS/" in path:
        bundle = path.split("/Contents/MacOS/")[0]
    if bundle and os.path.isdir(bundle):
        binary = bundle_executable(bundle) or binary
    return bundle, binary


def summarize_ips(path):
    lines = []
    try:
        with open(path, "r", encoding="utf-8", errors="replace") as handle:
            content = handle.read()
        header_line, rest = (content.split("\n", 1) + [""])[:2]
        header = json.loads(header_line)
        lines.append(f"crash timestamp: {header.get('timestamp', 'unknown')}")
        lines.append(f"crash app version: {header.get('app_version', 'unknown')}")
        if rest.strip():
            try:
                details = json.loads(rest)
                exception = details.get("exception", {})
                termination = details.get("termination", {})
                if exception:
                    lines.append(
                        f"exception: {exception.get('type', 'unknown')} {exception.get('signal', '')}".rstrip()
                    )
                if termination:
                    lines.append(f"termination: {termination.get('indicator', 'unknown')}")
                frames = []
                for thread in details.get("threads", []):
                    if thread.get("triggered"):
                        frames = [
                            frame.get("symbol", "?")
                            for frame in thread.get("frames", [])[:5]
                        ]
                        break
                if frames:
                    lines.append("top frames:")
                    lines.extend(f"  {frame}" for frame in frames)
            except json.JSONDecodeError:
                lines.append("warning: could not parse crash details")
    except Exception:
        lines.append("warning: failed to read crash report")
    return lines


def summarize_text(path):
    lines = []
    try:
        with open(path, "r", encoding="utf-8", errors="replace") as handle:
            for _, line in zip(range(40), handle):
                lines.append(line.rstrip())
    except Exception:
        lines.append("warning: failed to read crash report")
    return lines


def report_crash(app_name, start_time):
    report_dir = os.path.expanduser("~/Library/Logs/DiagnosticReports")
    if not os.path.isdir(report_dir):
        return
    pattern = os.path.join(report_dir, f"{app_name}*")
    deadline = time.time() + 2.0
    candidates = []
    while time.time() < deadline and not candidates:
        candidates = [
            path
            for path in glob.glob(pattern)
            if os.path.isfile(path) and os.path.getmtime(path) >= start_time - 2
        ]
        if not candidates:
            time.sleep(0.2)
    if not candidates:
        return
    path = max(candidates, key=os.path.getmtime)
    print(f"smoke: crash report: {path}", file=sys.stderr)
    summary = summarize_ips(path) if path.endswith(".ips") else summarize_text(path)
    for line in summary:
        print(f"smoke: {line}", file=sys.stderr)


def run_smoke(command, env):
    start_time = time.time()
    proc = subprocess.Popen(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        env=env,
    )
    try:
        output, _ = proc.communicate(timeout=timeout_seconds)
        timed_out = False
    except subprocess.TimeoutExpired:
        proc.kill()
        output, _ = proc.communicate()
        timed_out = True
    return proc.returncode, output, timed_out, start_time


def ready_seen(path):
    if not os.path.exists(path):
        return False
    with open(path, "r", encoding="utf-8", errors="replace") as handle:
        return ready_token in handle.read()


def attempt_open(bundle_path):
    ready_fd, ready_path = tempfile.mkstemp(prefix="typinggame_smoke_", suffix=".log")
    os.close(ready_fd)
    command = [
        "open",
        "-n",
        "-W",
        bundle_path,
        "--args",
        "--smoke-test",
        "--smoke-test-output",
        ready_path,
    ]
    code, output, timed_out, start_time = run_smoke(command, None)
    ready = ready_seen(ready_path)
    return {
        "name": "open",
        "code": code,
        "output": output,
        "timed_out": timed_out,
        "ready": ready,
        "start_time": start_time,
    }


def attempt_direct(binary_path):
    ready_fd, ready_path = tempfile.mkstemp(prefix="typinggame_smoke_", suffix=".log")
    os.close(ready_fd)
    env = os.environ.copy()
    env["SMOKE_TEST"] = "1"
    env["SMOKE_TEST_OUTPUT"] = ready_path
    code, output, timed_out, start_time = run_smoke([binary_path], env)
    ready = ready_seen(ready_path)
    return {
        "name": "direct",
        "code": code,
        "output": output,
        "timed_out": timed_out,
        "ready": ready,
        "start_time": start_time,
    }


def resolve_path(root, path):
    if not path:
        return None
    return path if os.path.isabs(path) else os.path.join(root, path)


def xcodebuild_args(root):
    workspace = os.environ.get("SMOKE_WORKSPACE", "").strip()
    project = os.environ.get("SMOKE_PROJECT", "").strip()
    scheme = os.environ.get("SMOKE_SCHEME", "TypingGame").strip()
    destination = os.environ.get("SMOKE_DESTINATION", "platform=macOS").strip()
    derived_data = os.environ.get("SMOKE_DERIVED_DATA", os.path.join(root, "build", "ui-isolated")).strip()

    if workspace:
        workspace_path = resolve_path(root, workspace)
        if not os.path.exists(workspace_path):
            return None, f"workspace not found: {workspace_path}"
        base_args = ["-workspace", workspace_path]
    else:
        project_path = resolve_path(root, project or "TypingGame.xcodeproj")
        if not os.path.exists(project_path):
            return None, f"project not found: {project_path}"
        base_args = ["-project", project_path]

    cmd = [
        "xcodebuild",
        *base_args,
        "-scheme",
        scheme,
        "-destination",
        destination,
        "-derivedDataPath",
        derived_data,
        "TYPINGGAME_APP_ID=com.typinggame.app.uitesting",
        "test",
    ]

    if tests_mode == "unit":
        cmd.append("-only-testing:TypingGameTests")
    elif tests_mode in ("ui", "all"):
        return None, "interactive UI tests require the isolated workflow: make ui-test UI_TESTS='testAppLaunchShowsCalibrate ...'"

    only_testing = os.environ.get("SMOKE_ONLY_TESTING", "").strip()
    if only_testing:
        for token in only_testing.split(","):
            token = token.strip()
            if token:
                cmd.append(f"-only-testing:{token}")

    skip_testing = os.environ.get("SMOKE_SKIP_TESTING", "").strip()
    if skip_testing:
        for token in skip_testing.split(","):
            token = token.strip()
            if token:
                cmd.append(f"-skip-testing:{token}")

    return cmd, None


def run_xcodebuild_tests(root):
    if tests_mode in ("0", "false", "no", "off", "none", "skip"):
        return {"skipped": True}

    command, error = xcodebuild_args(root)
    if error:
        return {"error": error}

    log_fd, log_path = tempfile.mkstemp(prefix="typinggame_xcodebuild_", suffix=".log")
    os.close(log_fd)
    start_time = time.time()
    proc = subprocess.Popen(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        cwd=root,
    )
    try:
        output, _ = proc.communicate(timeout=test_timeout_seconds)
        timed_out = False
    except subprocess.TimeoutExpired:
        proc.kill()
        output, _ = proc.communicate()
        timed_out = True

    with open(log_path, "w", encoding="utf-8", errors="replace") as handle:
        handle.write(output)

    tail = output.splitlines()[-60:] if output else []
    highlights = []
    if output:
        keywords = (
            "error",
            "failed",
            "fail",
            "exception",
            "crash",
            "assert",
            "xcodebuild: error",
            "test case",
        )
        for line in output.splitlines():
            lowered = line.lower()
            if any(token in lowered for token in keywords):
                highlights.append(line)
        if len(highlights) > 40:
            highlights = highlights[-40:]
    return {
        "skipped": False,
        "command": command,
        "code": proc.returncode,
        "timed_out": timed_out,
        "log_path": log_path,
        "tail": tail,
        "highlights": highlights,
        "start_time": start_time,
    }


bundle, binary = resolve_paths(app_path)
if not is_executable(binary):
    print(f"smoke: binary not found or not executable: {binary}", file=sys.stderr)
    sys.exit(2)

app_name = os.path.splitext(os.path.basename(bundle or binary))[0]
fallback_result = None
result = None

if launch_method in ("auto", "open"):
    if not bundle:
        if launch_method == "open":
            print("smoke: open requested but app bundle not found", file=sys.stderr)
            sys.exit(2)
    else:
        result = attempt_open(bundle)
        if launch_method == "auto":
            if result["code"] != 0 or result["timed_out"] or not result["ready"]:
                fallback_result = result
                result = None

if result is None:
    result = attempt_direct(binary)

print(result["output"], end="")

if result["timed_out"]:
    print(f"smoke: timeout after {timeout_seconds}s ({result['name']})", file=sys.stderr)
    report_crash(app_name, result["start_time"])
    if fallback_result:
        print(f"smoke: open attempt exit {fallback_result['code']}", file=sys.stderr)
        print(fallback_result["output"], end="", file=sys.stderr)
    sys.exit(1)

if result["code"] != 0:
    print(f"smoke: non-zero exit {result['code']} ({result['name']})", file=sys.stderr)
    report_crash(app_name, result["start_time"])
    if fallback_result:
        print(f"smoke: open attempt exit {fallback_result['code']}", file=sys.stderr)
        print(fallback_result["output"], end="", file=sys.stderr)
    sys.exit(1)

if not result["ready"]:
    print(f"smoke: missing {ready_token} output ({result['name']})", file=sys.stderr)
    report_crash(app_name, result["start_time"])
    if fallback_result:
        print(f"smoke: open attempt exit {fallback_result['code']}", file=sys.stderr)
        print(fallback_result["output"], end="", file=sys.stderr)
    sys.exit(1)

if tests_mode not in ("0", "false", "no", "off", "none", "skip"):
    print("smoke: running xcodebuild tests")
test_result = run_xcodebuild_tests(repo_root)
if test_result.get("skipped"):
    print("smoke: tests skipped (SMOKE_TESTS=none)")
elif test_result.get("error"):
    print(f"smoke: test configuration error: {test_result['error']}", file=sys.stderr)
    sys.exit(2)
else:
    if test_result["timed_out"]:
        print(f"smoke: tests timed out after {test_timeout_seconds}s", file=sys.stderr)
        print(f"smoke: test log: {test_result['log_path']}", file=sys.stderr)
        for line in test_result["highlights"] or test_result["tail"]:
            print(f"smoke: {line}", file=sys.stderr)
        sys.exit(1)
    if test_result["code"] != 0:
        print(f"smoke: tests failed with exit {test_result['code']}", file=sys.stderr)
        print(f"smoke: test log: {test_result['log_path']}", file=sys.stderr)
        for line in test_result["highlights"] or test_result["tail"]:
            print(f"smoke: {line}", file=sys.stderr)
        sys.exit(1)
    print("smoke: tests passed")
PY
