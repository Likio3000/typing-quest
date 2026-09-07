#!/usr/bin/env python3
"""Run explicitly selected UI cases serially against an isolated build; stop on failure.

Build first with:
  xcodebuild -project TypingGame.xcodeproj -scheme TypingGame -derivedDataPath build/ui-isolated TYPINGGAME_APP_ID=com.typinggame.app.uitesting build-for-testing
This command controls the isolated app's UI. Announce its scope before running.
"""
import argparse
import os
from pathlib import Path
import signal
import subprocess
import sys

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('tests', nargs='+', help='TypingGameUITests method names; no full-suite default')
parser.add_argument('--timeout', type=int, default=55, choices=range(20, 91), metavar='20..90')
args = parser.parse_args()
root = Path(__file__).resolve().parent.parent
logs = root / 'build' / 'ui-isolated' / 'bounded-logs'
logs.mkdir(parents=True, exist_ok=True)
for case in args.tests:
    if not case.startswith('test') or not case.isidentifier():
        parser.error('Each case must be a Swift test method name')
    cmd = ['xcodebuild', '-project', 'TypingGame.xcodeproj', '-scheme', 'TypingGame',
           '-configuration', 'Debug', '-derivedDataPath', 'build/ui-isolated',
           'TYPINGGAME_APP_ID=com.typinggame.app.uitesting', 'test-without-building',
           '-destination', 'platform=macOS,arch=arm64',
           '-only-testing:TypingGameUITests/TypingGameUITests/' + case,
           '-parallel-testing-enabled', 'NO', '-test-timeouts-enabled', 'YES',
           '-default-test-execution-time-allowance', '25', '-maximum-test-execution-time-allowance', '30']
    with (logs / (case + '.log')).open('w') as log:
        process = subprocess.Popen(cmd, cwd=root, stdout=log, stderr=subprocess.STDOUT, start_new_session=True)
        try:
            code = process.wait(timeout=args.timeout)
        except (subprocess.TimeoutExpired, KeyboardInterrupt):
            # Only this invocation's process group, never any app selected by name/bundle ID.
            os.killpg(process.pid, signal.SIGTERM)
            try:
                process.wait(timeout=3)
            except subprocess.TimeoutExpired:
                os.killpg(process.pid, signal.SIGKILL)
            code = 124
    print(f'{case}: exit {code}; log {logs / (case + ".log")}', flush=True)
    if code:
        sys.exit(code)
