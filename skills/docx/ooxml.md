# OOXML Document Editing Guide

## Overview

OOXML (Office Open XML) is the ISO standard format for Microsoft Office documents (.docx, .xlsx, .pptx). This guide covers direct XML manipulation for advanced document editing that cannot be achieved through standard libraries.

**IMPORTANT**: Only use this guide when python-docx or other high-level libraries cannot accomplish your task. Direct XML manipulation requires careful attention to namespaces and structure.

## Understanding OOXML Structure

A .docx/.pptx file is a ZIP archive containing:

```
document.zip
├── [Content_Types].xml
├── _rels/
│   └── .rels
├── word/ (for docx) or ppt/ (for pptx)
│   ├── document.xml (main content)
│   ├── styles.xml
│   ├── settings.xml
│   ├── headers/ or footer*.xml
│   └── media/ (images)
└── docProps/
    └── core.xml
```

## Common Tools for OOXML Manipulation

### Python Libraries

| Library | Purpose |
|---------|---------|
| `zipfile` | Read/write ZIP archives |
| `lxml` | XML parsing and manipulation |
| `defusedxml` | Secure XML parsing (recommended) |

### Installation

```bash
pip install lxml defusedxml
```

## Basic Workflow

### Step 1: Unpack Document

```python
import zipfile
import os
from pathlib import Path

def unpack_office_file(input_path, output_dir):
    """Extract office file to directory."""
    with zipfile.ZipFile(input_path, 'r') as z:
        z.extractall(output_dir)
    print(f"Unpacked to: {output_dir}")

# Usage
unpack_office_file("document.docx", "unpacked_doc")
```

### Step 2: Parse and Edit XML

```python
from lxml import etree
import defusedxml.ElementTree as ET

# Define namespaces
NAMESPACES = {
    'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main',  # docx
    'a': 'http://schemas.openxmlformats.org/drawingml/2006/main',
    'wp': 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing',
    'r': 'http://schemas.openxmlformats.org/officeDocument/2006/relationships'
}

def parse_xml(file_path):
    """Parse XML with namespace handling."""
    tree = ET.parse(file_path)
    return tree

def find_elements(tree, xpath, namespaces=None):
    """Find elements using XPath."""
    return tree.xpath(xpath, namespaces=namespaces or NAMESPACES)
```

### Step 3: Repack Document

```python
import zipfile
import os

def pack_office_file(input_dir, output_path):
    """Repack directory to office file."""
    with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as z:
        for root, dirs, files in os.walk(input_dir):
            for file in files:
                file_path = os.path.join(root, file)
                arcname = os.path.relpath(file_path, input_dir)
                z.write(file_path, arcname)
    print(f"Created: {output_path}")
```

## DOCX Specific Operations

### Finding Text (docx)

```python
from lxml import etree

def find_text_in_document(xml_path, search_text):
    """Find all occurrences of text in document.xml."""
    tree = etree.parse(xml_path)
    ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}

    # Find all text elements containing search text
    for elem in tree.xpath('//w:t', namespaces=ns):
        if elem.text and search_text in elem.text:
            print(f"Found: {elem.text}")

def replace_text_in_document(xml_path, old_text, new_text):
    """Replace text in document.xml."""
    tree = etree.parse(xml_path)
    ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}

    count = 0
    for elem in tree.xpath('//w:t', namespaces=ns):
        if elem.text and old_text in elem.text:
            elem.text = elem.text.replace(old_text, new_text)
            count += 1

    tree.write(xml_path, xml_declaration=True, encoding='UTF-8')
    return count
```

### Adding a Paragraph (docx)

```python
from lxml import etree

def add_paragraph(xml_path, text, style=None):
    """Add a new paragraph to document.xml."""
    tree = etree.parse(xml_path)
    ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}

    # Find the body element
    body = tree.xpath('//w:body', namespaces=ns)[0]

    # Create new paragraph
    para = etree.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}p')

    # Create run
    run = etree.SubElement(para, '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}r')

    # Create text element
    text_elem = etree.SubElement(run, '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}t')
    text_elem.text = text

    # Add style if specified
    if style:
        pPr = etree.SubElement(para, '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}pPr')
        pStyle = etree.SubElement(pPr, '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}pStyle')
        pStyle.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val', style)

    # Append to body
    body.append(para)

    tree.write(xml_path, xml_declaration=True, encoding='UTF-8')
```

### Working with Tables (docx)

```python
def add_table_row(table_elem):
    """Add a row to an existing table."""
    ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}

    # Create row
    row = etree.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}tr')

    # Create cells (example: 3 cells)
    for _ in range(3):
        cell = etree.SubElement(row, '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}tc')
        para = etree.SubElement(cell, '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}p')
        run = etree.SubElement(para, '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}r')
        text = etree.SubElement(run, '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}t')
        text.text = ""

    table_elem.append(row)
```

## PPTX Specific Operations

### Finding and Replacing Slide Text (pptx)

```python
from lxml import etree

def replace_slide_text(pptx_dir, slide_num, old_text, new_text):
    """Replace text in a specific slide."""
    slide_path = f"{pptx_dir}/ppt/slides/slide{slide_num}.xml"
    tree = etree.parse(slide_path)

    count = 0
    # Find all text elements
    for elem in tree.xpath('.//a:t', namespaces={
        'a': 'http://schemas.openxmlformats.org/drawingml/2006/main'
    }):
        if elem.text and old_text in elem.text:
            elem.text = elem.text.replace(old_text, new_text)
            count += 1

    tree.write(slide_path, xml_declaration=True, encoding='UTF-8')
    return count

def replace_all_slides_text(pptx_dir, old_text, new_text):
    """Replace text across all slides."""
    import os
    total = 0
    slides_dir = f"{pptx_dir}/ppt/slides"

    for filename in os.listdir(slides_dir):
        if filename.startswith('slide') and filename.endswith('.xml'):
            slide_path = os.path.join(slides_dir, filename)
            tree = etree.parse(slide_path)

            for elem in tree.xpath('.//a:t', namespaces={
                'a': 'http://schemas.openxmlformats.org/drawingml/2006/main'
            }):
                if elem.text and old_text in elem.text:
                    elem.text = elem.text.replace(old_text, new_text)
                    total += 1

            tree.write(slide_path, xml_declaration=True, encoding='UTF-8')

    return total
```

### Modifying Slide Layout (pptx)

```python
def change_slide_background(pptx_dir, slide_num, color_hex):
    """Change slide background color."""
    slide_path = f"{pptx_dir}/ppt/slides/slide{slide_num}.xml"
    tree = etree.parse(slide_path)

    ns = {
        'p': 'http://schemas.openxmlformats.org/presentationml/2006/main',
        'a': 'http://schemas.openxmlformats.org/drawingml/2006/main',
        'r': 'http://schemas.openxmlformats.org/officeDocument/2006/relationships'
    }

    # Find or create cSld element
    cSld = tree.xpath('//p:cSld', namespaces=ns)
    if not cSld:
        return False

    # Create or modify bg element
    bg = tree.xpath('//p:bg', namespaces=ns)
    if bg:
        bg[0].getparent().remove(bg[0])

    # Add new background with solid fill
    spTree = tree.xpath('//p:spTree', namespaces=ns)[0]
    bg_elem = etree.Element('{http://schemas.openxmlformats.org/presentationml/2006/main}bg')
    bgPr = etree.SubElement(bg_elem, '{http://schemas.openxmlformats.org/drawingml/2006/main}solidFill')
    srgbClr = etree.SubElement(bgPr, '{http://schemas.openxmlformats.org/drawingml/2006/main}srgbClr')
    srgbClr.set('val', color_hex)

    spTree.insert(0, bg_elem)

    tree.write(slide_path, xml_declaration=True, encoding='UTF-8')
    return True
```

## Advanced: Adding Track Changes (docx)

```python
def add_tracked_insertion(xml_path, text, author, insert_date):
    """Add a tracked insertion to document.xml."""
    tree = etree.parse(xml_path)
    ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}

    # Find insertion point - for example, end of a specific paragraph
    target = tree.xpath('//w:p[last()]', namespaces=ns)[0]

    # Create run with track change markup
    run = etree.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}r')

    # Add revision info
    rPr = etree.SubElement(run, '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}rPr')

    # Add author
    author_elem = etree.SubElement(rPr, '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}author')
    author_elem.text = author

    # Add date
    date_elem = etree.SubElement(rPr, '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}dtm')
    date_elem.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val', insert_date)

    # Add text with ins element wrapping
    ins = etree.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}ins')
    ins.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}author', author)
    ins.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}date', insert_date)

    text_elem = etree.SubElement(run, '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}t')
    text_elem.text = text

    ins.append(run)
    target.append(ins)

    tree.write(xml_path, xml_declaration=True, encoding='UTF-8')
```

## Validation

### Validate OOXML Structure

```python
from lxml import etree

def validate_document_xml(xml_path):
    """Check if document.xml is well-formed."""
    try:
        etree.parse(xml_path)
        return True, None
    except etree.XMLSyntaxError as e:
        return False, str(e)

def validate_document_structure(unpacked_dir):
    """Validate entire document structure."""
    required_files = {
        'docx': ['[Content_Types].xml', '_rels/.rels', 'word/document.xml'],
        'pptx': ['[Content_Types].xml', '_rels/.rels', 'ppt/presentation.xml'],
    }

    # Detect type
    if os.path.exists(os.path.join(unpacked_dir, 'word')):
        doc_type = 'docx'
    elif os.path.exists(os.path.join(unpacked_dir, 'ppt')):
        doc_type = 'pptx'
    else:
        return False, "Unknown document type"

    missing = []
    for f in required_files[doc_type]:
        if not os.path.exists(os.path.join(unpacked_dir, f)):
            missing.append(f)

    if missing:
        return False, f"Missing files: {missing}"

    return True, None
```

## Common Pitfalls

| Pitfall | Prevention |
|---------|-------------|
| Namespace corruption | Always use proper namespace prefixes |
| Encoding issues | Always write with UTF-8 encoding |
| File corruption | Always validate XML before saving |
| Missing relationships | Ensure _rels/.rels is updated |
| Invalid XML structure | Use lxml validation before repacking |

## Security Note

**WARNING**: Never process untrusted Office files without:
1. Using `defusedxml` instead of standard xml libraries
2. Limiting file size
3. Running in sandboxed environment

```python
# Safe XML parsing
import defusedxml.ElementTree as ET

# Memory limit for parsing
MAX_FILE_SIZE = 50 * 1024 * 1024  # 50MB

def safe_parse(xml_path):
    file_size = os.path.getsize(xml_path)
    if file_size > MAX_FILE_SIZE:
        raise ValueError("File too large")
    return ET.parse(xml_path)
```

## Related Files

- `SKILL.md` - Main skill documentation
- `html2pptx.md` - HTML to PowerPoint conversion (pptx)
- `docx-js.md` - JavaScript document creation (docx)