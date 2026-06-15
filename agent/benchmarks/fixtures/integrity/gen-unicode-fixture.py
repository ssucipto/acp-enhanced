from pathlib import Path

path = Path(__file__).resolve().parent / "unicode-hidden.ts"
path.write_text('const hidden = "hello\u200dworld";\n', encoding="utf-8")
# Verify
text = path.read_text(encoding="utf-8")
assert "\u200d" in text
print("OK:", path)
