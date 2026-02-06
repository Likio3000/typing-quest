#!/usr/bin/env python3
import argparse
import json
import random
import re
import sys
from pathlib import Path
from typing import Optional

ROOT = Path(__file__).resolve().parents[1]
SPEC_PATH = ROOT / "LevelsSource" / "spec.json"
TEMPLATES_DIR = ROOT / "LevelsSource" / "templates"
WORDLISTS_DIR = ROOT / "LevelsSource" / "wordlists"
DATA_DIR = ROOT / "LevelsSource" / "data"
OUTPUT_PATH = ROOT / "TypingGame" / "levels.json"

TOKEN_RE = re.compile(r"{{\s*([A-Z_]+)\s*}}")


def load_text_list(path: Path) -> list[str]:
    lines = []
    for raw in path.read_text().splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        lines.append(line)
    return lines


def load_data_lists(data_dir: Path) -> dict[str, list[str]]:
    data = {}
    for path in sorted(data_dir.glob("*.txt")):
        data[path.stem.upper()] = load_text_list(path)
    return data


def pick(rng: random.Random, items: list[str]) -> str:
    if not items:
        raise ValueError("Cannot pick from empty list")
    return rng.choice(items)


def random_date(rng: random.Random) -> str:
    year = rng.choice([2025, 2026])
    month = rng.randint(1, 12)
    day = rng.randint(1, 28)
    return f"{year:04d}-{month:02d}-{day:02d}"


def random_time(rng: random.Random) -> str:
    hour = rng.randint(0, 23)
    minute = rng.choice([0, 5, 10, 12, 15, 20, 25, 30, 35, 40, 45, 50, 55])
    return f"{hour:02d}:{minute:02d}"


def random_amount(rng: random.Random) -> str:
    dollars = rng.randint(4, 420)
    cents = rng.choice([0, 25, 50, 75, 95, 99])
    return f"${dollars}.{cents:02d}"


def random_percent(rng: random.Random) -> str:
    value = rng.uniform(1.5, 12.5)
    return f"{value:.2f}%"


def random_qty(rng: random.Random) -> str:
    return str(rng.randint(1, 9))


def random_zip(rng: random.Random) -> str:
    return f"{rng.randint(10000, 99999)}"


def random_phone(rng: random.Random) -> str:
    return f"555-{rng.randint(100, 999)}-{rng.randint(1000, 9999)}"


def random_code(rng: random.Random) -> str:
    letters = "ABCDEFGHJKLMNPQRSTUVWXYZ"
    return f"{rng.choice(letters)}{rng.choice(letters)}-{rng.randint(10, 99)}"


def random_id(rng: random.Random, prefix: str) -> str:
    return f"{prefix}-{rng.randint(1000, 99999)}"


def random_sku(rng: random.Random) -> str:
    letters = "ABCDEFGHJKLMNPQRSTUVWXYZ"
    return f"{rng.choice(letters)}{rng.choice(letters)}-{rng.randint(100, 9999)}"


def random_model(rng: random.Random) -> str:
    letters = "ABCDEFGHJKLMNPQRSTUVWXYZ"
    return f"{rng.choice(letters)}{rng.randint(10, 99)}-{rng.randint(100, 999)}"


def random_serial(rng: random.Random) -> str:
    letters = "ABCDEFGHJKLMNPQRSTUVWXYZ"
    return f"SN-{rng.randint(1000, 9999)}-{rng.choice(letters)}{rng.choice(letters)}"


def random_hours(rng: random.Random) -> str:
    hours = rng.choice([6.5, 7.0, 7.5, 8.0, 8.5, 9.0])
    return f"{hours:.1f}"


def random_weight(rng: random.Random) -> str:
    value = rng.uniform(1.2, 98.7)
    return f"{value:.1f}"


def random_temperature(rng: random.Random) -> str:
    value = rng.uniform(12.0, 98.0)
    return f"{value:.1f}"


def random_speed(rng: random.Random) -> str:
    value = rng.uniform(0.5, 12.5)
    return f"{value:.1f}"


def build_note(rng: random.Random, data: dict[str, list[str]]) -> str:
    action = pick(rng, data.get("ACTIONS", ["checked"]))
    obj = pick(rng, data.get("OBJECTS", ["panel"]))
    adjective = pick(rng, data.get("ADJECTIVES", ["steady"]))
    return f"{action} the {adjective} {obj}"


def build_name(rng: random.Random, data: dict[str, list[str]]) -> tuple[str, str, str]:
    first = pick(rng, data.get("FIRST_NAMES", ["Ava"]))
    last = pick(rng, data.get("LAST_NAMES", ["Rivera"]))
    return first, last, f"{first} {last}"


def render_template(template: str, rng: random.Random, data: dict[str, list[str]]) -> str:
    first, last, full = build_name(rng, data)

    def replace(match: re.Match) -> str:
        key = match.group(1)
        if key == "FIRST_NAME":
            return first
        if key == "LAST_NAME":
            return last
        if key in ("FULL_NAME", "NAME"):
            return full
        if key == "CITY":
            return pick(rng, data.get("CITIES", ["Austin"]))
        if key == "STATE":
            return pick(rng, data.get("STATES", ["TX"]))
        if key == "STREET":
            number = rng.randint(100, 9999)
            street = pick(rng, data.get("STREETS", ["Maple Ave"]))
            return f"{number} {street}"
        if key == "ZIP":
            return random_zip(rng)
        if key in ("COMPANY", "VENDOR"):
            return pick(rng, data.get("COMPANIES", ["Acme Systems"]))
        if key == "DEPARTMENT":
            return pick(rng, data.get("DEPARTMENTS", ["Ops"]))
        if key == "PRODUCT":
            return pick(rng, data.get("PRODUCTS", ["Gear Set"]))
        if key == "DATE":
            return random_date(rng)
        if key == "TIME":
            return random_time(rng)
        if key == "AMOUNT":
            return random_amount(rng)
        if key == "PERCENT":
            return random_percent(rng)
        if key == "QTY":
            return random_qty(rng)
        if key == "PHONE":
            return random_phone(rng)
        if key == "EMAIL":
            domain = pick(rng, data.get("DOMAINS", ["example.com"]))
            return f"{first.lower()}.{last.lower()}@{domain}"
        if key == "SKU":
            return random_sku(rng)
        if key == "MODEL":
            return random_model(rng)
        if key == "SERIAL":
            return random_serial(rng)
        if key == "ID":
            return random_id(rng, "ID")
        if key == "INVOICE":
            return random_id(rng, "INV")
        if key == "ORDER":
            return random_id(rng, "ORD")
        if key == "TICKET":
            return random_id(rng, "TCK")
        if key == "EMPLOYEE_ID":
            return str(rng.randint(10000, 99999))
        if key == "SHIFT":
            return pick(rng, ["A", "B", "C"])
        if key == "HOURS":
            return random_hours(rng)
        if key == "WEIGHT":
            return random_weight(rng)
        if key == "TEMPERATURE":
            return random_temperature(rng)
        if key == "SPEED":
            return random_speed(rng)
        if key == "UNIT":
            return pick(rng, data.get("UNITS", ["kg"]))
        if key == "GATE":
            return f"{rng.choice(list('ABCDEFGH'))}{rng.randint(1, 9)}"
        if key == "ROOM":
            return str(rng.randint(100, 899))
        if key == "CODE":
            return random_code(rng)
        if key == "NOTE":
            return build_note(rng, data)
        if key == "OBJECT":
            return pick(rng, data.get("OBJECTS", ["panel"]))
        if key == "ACTION":
            return pick(rng, data.get("ACTIONS", ["checked"]))
        if key == "ADJECTIVE":
            return pick(rng, data.get("ADJECTIVES", ["steady"]))
        raise ValueError(f"Unsupported template token: {key}")

    return TOKEN_RE.sub(replace, template)


def build_text_from_words(words: list[str], target_length: int, rng: random.Random) -> str:
    if not words:
        return ""
    selected = []
    current = 0
    while current < target_length:
        word = pick(rng, words)
        added = len(word) + (1 if selected else 0)
        if selected and current + added > target_length:
            break
        selected.append(word)
        current += added
        if not selected:
            current = len(word)
    if not selected:
        selected = [words[0]]
    return " ".join(selected)


def clamp_difficulty(value: int) -> int:
    return max(1, min(5, value))


def variant_name(base: str, index: int, total: int) -> str:
    if total <= 1:
        return base
    return f"{base} {index + 1:02d}"


def build_drills(spec: dict, rng: random.Random) -> list[dict]:
    levels = []
    for drill in spec.get("drills", []):
        lengths = drill["lengths"]
        ranges = drill["wordLengthRanges"]
        variants = drill.get("variants", 1)
        for i in range(variants):
            length = lengths[i % len(lengths)]
            word_range = ranges[i % len(ranges)]
            difficulty = clamp_difficulty(drill.get("difficulty", 1) + i // max(1, variants // 2))
            level = {
                "id": f"{drill['id_prefix']}-{i + 1:03d}",
                "name": variant_name(drill["name"], i, variants),
                "description": drill["description"],
                "category": drill["category"],
                "difficulty": difficulty,
                "tags": drill.get("tags", []),
                "sortOrder": drill.get("sortOrderStart", 0) + i,
                "source": f"drill:{drill['id_prefix']}",
                "pool": drill["pool"],
                "length": length,
                "wordLengthRange": word_range,
                "includeSpaces": drill.get("includeSpaces", True),
            }
            levels.append(level)
    return levels


def build_wordlists(spec: dict, rng: random.Random) -> list[dict]:
    levels = []
    for entry in spec.get("wordlists", []):
        wordlist_path = WORDLISTS_DIR / entry["wordlist_file"]
        words = load_text_list(wordlist_path)
        variants = entry.get("variants", 1)
        targets = entry["target_lengths"]
        for i in range(variants):
            target = targets[i % len(targets)]
            fixed_text = build_text_from_words(words, target, rng).strip()
            if not fixed_text:
                continue
            level = {
                "id": f"{entry['id_prefix']}-{i + 1:03d}",
                "name": variant_name(entry["name"], i, variants),
                "description": entry["description"],
                "category": entry["category"],
                "difficulty": clamp_difficulty(entry.get("difficulty", 1)),
                "tags": entry.get("tags", []),
                "sortOrder": entry.get("sortOrderStart", 0) + i,
                "source": f"wordlist:{entry['wordlist_file']}",
                "pool": "abcdefghijklmnopqrstuvwxyz",
                "length": len(fixed_text),
                "wordLengthRange": [1, 1],
                "includeSpaces": True,
                "fixedText": fixed_text,
            }
            levels.append(level)
    return levels


def build_templates(spec: dict, rng: random.Random, data: dict[str, list[str]]) -> list[dict]:
    levels = []
    for entry in spec.get("templates", []):
        template_path = TEMPLATES_DIR / entry["template_file"]
        template_text = template_path.read_text()
        variants = entry.get("variants", 1)
        for i in range(variants):
            rendered = render_template(template_text, rng, data).strip()
            if not rendered:
                continue
            level = {
                "id": f"{entry['id_prefix']}-{i + 1:03d}",
                "name": variant_name(entry["name"], i, variants),
                "description": entry["description"],
                "category": entry["category"],
                "difficulty": clamp_difficulty(entry.get("difficulty", 1)),
                "tags": entry.get("tags", []),
                "sortOrder": entry.get("sortOrderStart", 0) + i,
                "source": f"template:{entry['template_file']}",
                "pool": "abcdefghijklmnopqrstuvwxyz",
                "length": len(rendered),
                "wordLengthRange": [1, 1],
                "includeSpaces": True,
                "fixedText": rendered,
            }
            levels.append(level)
    return levels


def validate_levels(levels: list[dict]) -> list[str]:
    errors = []
    seen_ids = set()
    for level in levels:
        level_id = level.get("id", "")
        if not level_id:
            errors.append("Missing id")
        elif level_id in seen_ids:
            errors.append(f"Duplicate id: {level_id}")
        else:
            seen_ids.add(level_id)

        name = level.get("name", "")
        if not name:
            errors.append(f"Level {level_id} missing name")
        description = level.get("description", "")
        if not description:
            errors.append(f"Level {level_id} missing description")

        length = level.get("length", 0)
        if not isinstance(length, int) or length <= 0:
            errors.append(f"Level {level_id} invalid length {length}")

        fixed_text = level.get("fixedText")
        pool = level.get("pool", "")
        if not fixed_text:
            if not pool:
                errors.append(f"Level {level_id} missing pool")
        else:
            if fixed_text.strip() != fixed_text:
                errors.append(f"Level {level_id} fixedText not trimmed")
            for ch in fixed_text:
                code = ord(ch)
                if ch == "\n":
                    continue
                if code < 32 or code > 126:
                    errors.append(f"Level {level_id} has non-ASCII character")
                    break

        word_range = level.get("wordLengthRange", [])
        if not isinstance(word_range, list) or len(word_range) != 2:
            errors.append(f"Level {level_id} invalid wordLengthRange")
        else:
            lower, upper = word_range
            if lower < 1 or upper < 1 or lower > upper:
                errors.append(f"Level {level_id} invalid wordLengthRange {word_range}")
            if isinstance(length, int) and upper > length:
                errors.append(f"Level {level_id} wordLengthRange exceeds length")

    return errors


def generate_levels(spec: dict, seed_override: Optional[int]) -> list[dict]:
    seed = seed_override if seed_override is not None else spec.get("seed", 0)
    rng = random.Random(seed)
    data = load_data_lists(DATA_DIR)

    levels = []
    for level in spec.get("static_levels", []):
        normalized = dict(level)
        fixed_text = normalized.get("fixedText")
        if fixed_text is not None:
            trimmed = fixed_text.strip()
            normalized["fixedText"] = trimmed
            normalized["length"] = len(trimmed)
        levels.append(normalized)
    levels.extend(build_drills(spec, rng))
    levels.extend(build_wordlists(spec, rng))
    levels.extend(build_templates(spec, rng, data))
    return levels


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate levels.json")
    parser.add_argument("--seed", type=int, help="Override RNG seed")
    parser.add_argument("--count", type=int, help="Limit output to first N levels")
    parser.add_argument("--validate", action="store_true", help="Validate generated levels")
    parser.add_argument("--output", type=Path, help="Override output path")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    spec = json.loads(SPEC_PATH.read_text())
    levels = generate_levels(spec, args.seed)

    if args.count is not None:
        if args.count > len(levels):
            print(f"Requested count {args.count} exceeds generated total {len(levels)}", file=sys.stderr)
            return 1
        levels = levels[: args.count]

    target_count = spec.get("target_count")
    if target_count is not None and len(levels) != target_count:
        print(f"Warning: generated {len(levels)} levels, target_count is {target_count}", file=sys.stderr)

    if args.validate:
        errors = validate_levels(levels)
        if errors:
            for error in errors:
                print(error, file=sys.stderr)
            return 1

    output_path = args.output if args.output else OUTPUT_PATH
    output_path.write_text(json.dumps(levels, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
