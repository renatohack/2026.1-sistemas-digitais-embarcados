import re
from pathlib import Path
from html import escape

md_path = Path('RELATORIO_TP1.md')
html_path = Path('RELATORIO_TP1.html')
text = md_path.read_text(encoding='utf-8')
lines = text.splitlines()


def inline_fmt(s: str) -> str:
    s = escape(s)
    s = re.sub(r'`([^`]+)`', r'<code>\1</code>', s)
    s = re.sub(r'\*\*([^*]+)\*\*', r'<strong>\1</strong>', s)
    return s

html = []
html.append('<!doctype html>')
html.append('<html lang="pt-BR"><head><meta charset="utf-8">')
html.append('<title>Relatório Técnico - TP1</title>')
html.append('''<style>
body { font-family: "Segoe UI", Arial, sans-serif; line-height: 1.35; margin: 24mm 18mm; color: #111; }
h1 { font-size: 22px; margin: 0.5em 0 0.35em; }
h2 { font-size: 18px; margin: 0.9em 0 0.35em; }
h3 { font-size: 15px; margin: 0.8em 0 0.3em; }
p { margin: 0.3em 0 0.6em; }
ul { margin: 0.2em 0 0.8em 1.2em; }
hr { border: none; border-top: 1px solid #888; margin: 12px 0; }
code { font-family: Consolas, "Courier New", monospace; background: #f2f2f2; padding: 0 4px; border-radius: 3px; }
table { width: 100%; border-collapse: collapse; margin: 0.5em 0 0.9em; font-size: 13px; }
th, td { border: 1px solid #444; padding: 6px 8px; vertical-align: top; }
th { background: #f3f3f3; text-align: left; }
@page { size: A4; margin: 16mm; }
</style></head><body>''')

in_ul = False
i = 0
n = len(lines)

while i < n:
    line = lines[i].rstrip('\n')
    stripped = line.strip()

    if stripped == '':
        if in_ul:
            html.append('</ul>')
            in_ul = False
        i += 1
        continue

    if stripped == '---':
        if in_ul:
            html.append('</ul>')
            in_ul = False
        html.append('<hr>')
        i += 1
        continue

    if stripped.startswith('|') and stripped.endswith('|') and i + 1 < n:
        sep = lines[i + 1].strip()
        if sep.startswith('|') and sep.endswith('|') and set(sep.replace('|', '').replace('-', '').replace(':', '').replace(' ', '')) == set():
            if in_ul:
                html.append('</ul>')
                in_ul = False
            head_cells = [c.strip() for c in stripped.strip('|').split('|')]
            html.append('<table>')
            html.append('<thead><tr>' + ''.join(f'<th>{inline_fmt(c)}</th>' for c in head_cells) + '</tr></thead>')
            html.append('<tbody>')
            i += 2
            while i < n:
                row = lines[i].strip()
                if not (row.startswith('|') and row.endswith('|')):
                    break
                cells = [c.strip() for c in row.strip('|').split('|')]
                html.append('<tr>' + ''.join(f'<td>{inline_fmt(c)}</td>' for c in cells) + '</tr>')
                i += 1
            html.append('</tbody></table>')
            continue

    if stripped.startswith('#'):
        if in_ul:
            html.append('</ul>')
            in_ul = False
        level = len(stripped) - len(stripped.lstrip('#'))
        level = 1 if level < 1 else 6 if level > 6 else level
        content = stripped[level:].strip()
        html.append(f'<h{level}>{inline_fmt(content)}</h{level}>')
        i += 1
        continue

    if stripped.startswith('- '):
        if not in_ul:
            html.append('<ul>')
            in_ul = True
        html.append(f'<li>{inline_fmt(stripped[2:].strip())}</li>')
        i += 1
        continue

    if in_ul:
        html.append('</ul>')
        in_ul = False
    html.append(f'<p>{inline_fmt(stripped)}</p>')
    i += 1

if in_ul:
    html.append('</ul>')

html.append('</body></html>')
html_path.write_text('\n'.join(html), encoding='utf-8')
print(str(html_path.resolve()))
