"""Converts the wine-style study (Excel workbook) into tool/data/study/study_db.json.

Intent 261108-wine-style-profiles, code-generation plan Step 1 (D1, D9).

    python3 -I tool/convert_study.py <study.xlsx> [tool/data/study/study_db.json]

The workbook is read once, with the standard library only (an .xlsx file is a
zip of XML parts), and written as a structured JSON database that the
generator `tool/build_profile_map.dart` reads. The study stays the source of
truth: when it is updated, run this script again, then the generator.

The study content is data only: cells are copied as text or integers, never
interpreted here. A numeric cell holding the study's "not estimated" mark
("—") becomes null; every other cell keeps its text.
"""
import datetime
import hashlib
import json
import os
import re
import sys
import xml.etree.ElementTree as ET
import zipfile

MAIN = 'http://schemas.openxmlformats.org/spreadsheetml/2006/main'
REL = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships'
PKG_REL = 'http://schemas.openxmlformats.org/package/2006/relationships'
NS = {'m': MAIN}

# Sheet name in the workbook -> key in the JSON database.
SHEETS = {
    'Profili candidati': 'profiles',
    'Mappa completa': 'combinations',
    'Revisione 60': 'review60',
    'Vitigni e tipi': 'grapesAndTypes',
    'Fonti': 'sources',
}

# Columns whose values are integers (or "—" for "not estimated").
INTEGER_COLUMNS = {
    'Start', 'Peak', 'End', 'Start v2', 'Peak v2', 'End v2',
    'Start v2 (anni)', 'Peak v2 (anni)', 'End v2 (anni)', 'Riesame (mesi)',
}
NOT_ESTIMATED = {'—', '-', ''}

# Rows above the header: title, subtitle, study line, blank line.
HEADER_ROW = 4

EXPECTED_ROWS = {'profiles': 24, 'combinations': 5946, 'review60': 60}


def column_index(ref):
    letters = re.match(r'[A-Z]+', ref).group()
    index = 0
    for letter in letters:
        index = index * 26 + ord(letter) - 64
    return index - 1


def shared_strings(archive):
    if 'xl/sharedStrings.xml' not in archive.namelist():
        return []
    root = ET.fromstring(archive.read('xl/sharedStrings.xml'))
    return [''.join(t.text or '' for t in si.iter('{%s}t' % MAIN))
            for si in root.findall('m:si', NS)]


def sheet_paths(archive):
    """Sheet name -> worksheet part, through the workbook relationships."""
    workbook = ET.fromstring(archive.read('xl/workbook.xml'))
    rels = ET.fromstring(archive.read('xl/_rels/workbook.xml.rels'))
    targets = {rel.get('Id'): rel.get('Target')
               for rel in rels.findall('{%s}Relationship' % PKG_REL)}
    paths = {}
    for sheet in workbook.find('m:sheets', NS):
        target = targets[sheet.get('{%s}id' % REL)]
        target = target.lstrip('/')
        paths[sheet.get('name')] = target if target.startswith('xl/') else 'xl/' + target
    return paths


def read_rows(archive, path, strings):
    root = ET.fromstring(archive.read(path))
    rows = []
    for row in root.iter('{%s}row' % MAIN):
        values = {}
        for cell in row.findall('m:c', NS):
            kind = cell.get('t')
            value = cell.find('m:v', NS)
            inline = cell.find('m:is', NS)
            if kind == 's' and value is not None:
                text = strings[int(value.text)]
            elif kind == 'inlineStr' and inline is not None:
                text = ''.join(t.text or '' for t in inline.iter('{%s}t' % MAIN))
            else:
                text = value.text if value is not None else ''
            values[column_index(cell.get('r'))] = (text or '').strip()
        if values:
            rows.append([values.get(i, '') for i in range(max(values) + 1)])
        else:
            rows.append([])
    return rows


def typed(column, text):
    if column in INTEGER_COLUMNS:
        if text in NOT_ESTIMATED:
            return None
        if not re.fullmatch(r'-?\d+', text):
            raise SystemExit(f'convert_study: column "{column}" holds "{text}", not an integer')
        return int(text)
    return text


def table(rows, key):
    header = rows[HEADER_ROW]
    columns = [c for c in header if c]
    body = []
    for row in rows[HEADER_ROW + 1:]:
        if not row or not any(row):
            continue
        cells = (row + [''] * len(columns))[:len(columns)]
        body.append([typed(c, v) for c, v in zip(columns, cells)])
    expected = EXPECTED_ROWS.get(key)
    if expected is not None and len(body) != expected:
        raise SystemExit(f'convert_study: sheet {key} has {len(body)} rows, expected {expected}')
    return {
        'title': rows[0][0] if rows and rows[0] else '',
        'notes': [r[0] for r in rows[1:HEADER_ROW] if r and r[0]],
        'columns': columns,
        'rows': body,
    }


def study_date(notes):
    for note in notes:
        match = re.search(r'(\d{2})/(\d{2})/(\d{4})', note)
        if match:
            day, month, year = match.groups()
            return f'{year}-{month}-{day}'
    raise SystemExit('convert_study: no study date in the header rows')


def main(argv):
    if len(argv) < 2:
        print(__doc__, file=sys.stderr)
        return 2
    source = argv[1]
    output = argv[2] if len(argv) > 2 else 'tool/data/study/study_db.json'
    with open(source, 'rb') as handle:
        digest = hashlib.sha256(handle.read()).hexdigest()
    with zipfile.ZipFile(source) as archive:
        strings = shared_strings(archive)
        paths = sheet_paths(archive)
        missing = [name for name in SHEETS if name not in paths]
        if missing:
            raise SystemExit(f'convert_study: missing sheets {missing}')
        sheets = {key: table(read_rows(archive, paths[name], strings), key)
                  for name, key in SHEETS.items()}
    date = study_date(sheets['profiles']['notes'])
    status = next((n.split('•', 1)[1].strip() for n in sheets['profiles']['notes']
                   if 'Studio del' in n and '•' in n), '')
    database = {
        'formatVersion': 1,
        'study': {
            'title': 'Vinoozy - valutazione dei vini (profili di stile)',
            'date': date,
            'version': f'{date}-draft',
            'status': status,
            'sourceFile': os.path.basename(source),
            'sourceSha256': digest,
            'convertedOn': datetime.date.today().isoformat(),
            'sheets': {key: name for name, key in SHEETS.items()},
        },
    }
    database.update(sheets)
    os.makedirs(os.path.dirname(output) or '.', exist_ok=True)
    with open(output, 'w', encoding='utf-8') as handle:
        handle.write('{\n')
        keys = list(database)
        for index, key in enumerate(keys):
            value = database[key]
            handle.write(f'  {json.dumps(key)}: ')
            if isinstance(value, dict) and 'rows' in value:
                head = {k: v for k, v in value.items() if k != 'rows'}
                handle.write('{\n')
                for k, v in head.items():
                    handle.write(f'    {json.dumps(k)}: {json.dumps(v, ensure_ascii=False)},\n')
                handle.write('    "rows": [\n')
                for i, row in enumerate(value['rows']):
                    end = ',\n' if i < len(value['rows']) - 1 else '\n'
                    handle.write('      ' + json.dumps(row, ensure_ascii=False) + end)
                handle.write('    ]\n  }')
            else:
                handle.write(json.dumps(value, ensure_ascii=False, indent=2).replace('\n', '\n  '))
            handle.write(',\n' if index < len(keys) - 1 else '\n')
        handle.write('}\n')
    counts = {key: len(sheets[key]['rows']) for key in sheets}
    print(json.dumps({'output': output, 'study': database['study'], 'rows': counts}, ensure_ascii=False))
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
