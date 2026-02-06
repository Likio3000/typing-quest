# LevelsSource

Source materials for generating `TypingGame/levels.json`.

## Structure

- `spec.json`: Generation recipe (seed, static levels, drills, wordlists, templates).
- `wordlists/`: One word per line lists used for word-based levels.
- `templates/`: Text templates with `{{PLACEHOLDER}}` tokens for data-entry and story levels.
- `data/`: Text lists used by templates (names, cities, products, etc.).

## Generate Levels

```sh
python3 scripts/generate_levels.py --validate
```

This regenerates `TypingGame/levels.json` and validates the output.

## Template Placeholders

Supported placeholders include:

- `{{FIRST_NAME}}`, `{{LAST_NAME}}`, `{{NAME}}`
- `{{CITY}}`, `{{STATE}}`, `{{STREET}}`, `{{ZIP}}`
- `{{COMPANY}}`, `{{DEPARTMENT}}`, `{{PRODUCT}}`
- `{{DATE}}`, `{{TIME}}`
- `{{AMOUNT}}`, `{{PERCENT}}`, `{{QTY}}`
- `{{INVOICE}}`, `{{ORDER}}`, `{{TICKET}}`, `{{ID}}`
- `{{SKU}}`, `{{MODEL}}`, `{{SERIAL}}`
- `{{PHONE}}`, `{{EMAIL}}`
- `{{CODE}}`, `{{GATE}}`
- `{{NOTE}}`, `{{OBJECT}}`, `{{ACTION}}`, `{{ADJECTIVE}}`

If you add a new placeholder, update `scripts/generate_levels.py`.
