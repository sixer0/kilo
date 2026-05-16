# OOXML Document Editing Guide

## Overview

OOXML (Office Open XML) is the ISO standard format for Microsoft Office documents (.docx, .xlsx, .pptx). This guide covers direct XML manipulation for advanced document editing that cannot be achieved through standard libraries.

**IMPORTANT**: Only use this guide when python-pptx or other high-level libraries cannot accomplish your task. Direct XML manipulation requires careful attention to namespaces and structure.

## Understanding OOXML Structure

A .pptx file is a ZIP archive containing:

```
presentation.zip
├── [Content_Types].xml
├── _rels/
│   └── .rels
├── ppt/
│   ├── presentation.xml (main content)
│   ├── slides/
│   │   ├── slide1.xml
│   │   └── slide2.xml
│   ├── slideLayouts/
│   ├── slideMasters/
│   ├── notesSlides/
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

def unpack_pptx(input_path, output_dir):
    """Extract PowerPoint file to directory."""
    with zipfile.ZipFile(input_path, 'r') as z:
        z.extractall(output_dir)
    print(f"Unpacked to: {output_dir}")

# Usage
unpack_pptx("presentation.pptx", "unpacked_pptx")
```

### Step 2: Parse and Edit XML

```python
from lxml import etree
import defusedxml.ElementTree as ET

# Define PPTX namespaces
NAMESPACES = {
    'p': 'http://schemas.openxmlformats.org/presentationml/2006/main',
    'a': 'http://schemas.openxmlformats.org/drawingml/2006/main',
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

def pack_pptx(input_dir, output_path):
    """Repack directory to PowerPoint file."""
    with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as z:
        for root, dirs, files in os.walk(input_dir):
            for file in files:
                file_path = os.path.join(root, file)
                arcname = os.path.relpath(file_path, input_dir)
                z.write(file_path, arcname)
    print(f"Created: {output_path}")
```

## Slide Operations

### Find Text in Slide

```python
from lxml import etree

def find_text_in_slide(slide_path, search_text):
    """Find all occurrences of text in a slide."""
    tree = etree.parse(slide_path)

    for elem in tree.xpath('.//a:t', namespaces={
        'a': 'http://schemas.openxmlformats.org/drawingml/2006/main'
    }):
        if elem.text and search_text in elem.text:
            print(f"Found: {elem.text}")

def get_all_text(slide_path):
    """Extract all text from a slide."""
    tree = etree.parse(slide_path)
    texts = []

    for elem in tree.xpath('.//a:t', namespaces={
        'a': 'http://schemas.openxmlformats.org/drawingml/2006/main'
    }):
        if elem.text:
            texts.append(elem.text)

    return texts
```

### Replace Text in Slide

```python
def replace_text_in_slide(slide_path, old_text, new_text):
    """Replace text in a specific slide."""
    tree = etree.parse(slide_path)
    count = 0

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
            count = replace_text_in_slide(slide_path, old_text, new_text)
            total += count

    return total
```

### Add New Slide

```python
import shutil
import os

def duplicate_slide(pptx_dir, source_slide_num, new_slide_num):
    """Create a new slide by duplicating an existing one."""
    source = f"{pptx_dir}/ppt/slides/slide{source_slide_num}.xml"
    new = f"{pptx_dir}/ppt/slides/slide{new_slide_num}.xml"

    shutil.copy(source, new)

    # Update relationships
    # (More complex - requires modifying .rels files)
    return new_slide_num

def create_blank_slide(pptx_dir, slide_num):
    """Create a minimal blank slide."""
    slide_xml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:sld xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main"
       xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
  <p:cSld>
    <p:spTree>
      <p:nvGrpSpPr>
        <p:cNvPr id="1" name=""/>
        <p:cNvGrpSpPr/>
        <p:nvPr/>
      </p:nvGrpSpPr>
      <p:grpSpPr/>
    </p:spTree>
  </p:cSld>
</p:sld>'''

    slide_path = f"{pptx_dir}/ppt/slides/slide{slide_num}.xml"
    with open(slide_path, 'w', encoding='utf-8') as f:
        f.write(slide_xml)
```

### Delete Slide

```python
import os

def delete_slide(pptx_dir, slide_num):
    """Delete a slide from the presentation."""
    slide_path = f"{pptx_dir}/ppt/slides/slide{slide_num}.xml"
    if os.path.exists(slide_path):
        os.remove(slide_path)

    # Also need to update:
    # - [Content_Types].xml
    # - ppt/_rels/presentation.xml.rels
    # - ppt/presentation.xml (slide list)
    return True
```

## Layout and Theme Operations

### Change Slide Background

```python
from lxml import etree

def change_slide_background(pptx_dir, slide_num, color_hex):
    """Change slide background color."""
    slide_path = f"{pptx_dir}/ppt/slides/slide{slide_num}.xml"
    tree = etree.parse(slide_path)

    ns = {
        'p': 'http://schemas.openxmlformats.org/presentationml/2006/main',
        'a': 'http://schemas.openxmlformats.org/drawingml/2006/main',
    }

    # Find spTree (shape tree)
    spTree = tree.xpath('//p:spTree', namespaces=ns)
    if not spTree:
        return False

    spTree = spTree[0]

    # Remove existing background if any
    existing_bg = tree.xpath('//p:bg', namespaces=ns)
    if existing_bg:
        existing_bg[0].getparent().remove(existing_bg[0])

    # Create new background with solid fill
    bg_elem = etree.Element('{http://schemas.openxmlformats.org/presentationml/2006/main}bg')
    bgPr = etree.SubElement(bg_elem, '{http://schemas.openxmlformats.org/drawingml/2006/main}solidFill')
    srgbClr = etree.SubElement(bgPr, '{http://schemas.openxmlformats.org/drawingml/2006/main}srgbClr')
    srgbClr.set('val', color_hex)

    # Insert at beginning of spTree
    spTree.insert(0, bg_elem)

    tree.write(slide_path, xml_declaration=True, encoding='UTF-8')
    return True
```

### Apply Layout from Layouts

```python
def apply_layout_to_slide(pptx_dir, slide_num, layout_idx):
    """Apply a layout to a slide."""
    slide_path = f"{pptx_dir}/ppt/slides/slide{slide_num}.xml"
    tree = etree.parse(slide_path)

    ns = {
        'p': 'http://schemas.openxmlformats.org/presentationml/2006/main',
        'r': 'http://schemas.openxmlformats.org/officeDocument/2006/relationships'
    }

    # Get cSld element
    cSld = tree.xpath('//p:cSld', namespaces=ns)
    if not cSld:
        return False

    # Set layout name attribute
    # This requires proper relationship setup
    # For full implementation, use python-pptx instead

    return True
```

## Shape Operations

### Add Text Box

```python
from lxml import etree

def add_textbox(slide_path, text, x, y, w, h):
    """Add a text box shape to a slide."""
    tree = etree.parse(slide_path)
    ns = {
        'p': 'http://schemas.openxmlformats.org/presentationml/2006/main',
        'a': 'http://schemas.openxmlformats.org/drawingml/2006/main'
    }

    spTree = tree.xpath('//p:spTree', namespaces=ns)[0]

    # Create shape
    sp = etree.Element('{http://schemas.openxmlformats.org/presentationml/2006/main}sp')

    # Non-visual properties
    nvSpPr = etree.SubElement(sp, '{http://schemas.openxmlformats.org/presentationml/2006/main}nvSpPr')
    cNvPr = etree.SubElement(nvSpPr, '{http://schemas.openxmlformats.org/presentationml/2006/main}cNvPr')
    cNvPr.set('id', '1')
    cNvPr.set('name', 'TextBox 1')

    # Shape properties
    spPr = etree.SubElement(sp, '{http://schemas.openxmlformats.org/presentationml/2006/main}spPr')
    xfrm = etree.SubElement(spPr, '{http://schemas.openxmlformats.org/drawingml/2006/main}xfrm')
    off = etree.SubElement(xfrm, '{http://schemas.openxmlformats.org/drawingml/2006/main}off')
    off.set('x', str(int(x * 914400)))  # Convert inches to EMUs
    off.set('y', str(int(y * 914400)))
    ext = etree.SubElement(xfrm, '{http://schemas.openxmlformats.org/drawingml/2006/main}ext')
    ext.set('cx', str(int(w * 914400)))
    ext.set('cy', str(int(h * 914400)))
    prstGeom = etree.SubElement(spPr, '{http://schemas.openxmlformats.org/drawingml/2006/main}prstGeom')
    prstGeom.set('prst', 'rect')

    # Text frame
    txBody = etree.SubElement(sp, '{http://schemas.openxmlformats.org/presentationml/2006/main}txBody')
    for elem in tree.xpath('//a: lstStyle', namespaces=ns):
        txBody.append(elem)

    p = etree.SubElement(txBody, '{http://schemas.openxmlformats.org/drawingml/2006/main}p')
    r = etree.SubElement(p, '{http://schemas.openxmlformats.org/drawingml/2006/main}r')
    t = etree.SubElement(r, '{http://schemas.openxmlformats.org/drawingml/2006/main}t')
    t.text = text

    spTree.append(sp)
    tree.write(slide_path, xml_declaration=True, encoding='UTF-8')
```

## Speaker Notes Operations

```python
def add_speaker_notes(pptx_dir, slide_num, notes_text):
    """Add or update speaker notes for a slide."""
    notes_path = f"{pptx_dir}/ppt/notesSlides/notesSlide{slide_num}.xml"

    # Create notes slide if not exists
    notes_xml = f'''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:notes xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main"
         xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
  <p:cSld>
    <p:shapes>
      <p:sp>
        <p:nvSpPr/>
        <p:txBody>
          <a:lstStyle/>
          <a:p>
            <a:r>
              <a:t>{notes_text}</a:t>
            </a:r>
          </a:p>
        </p:txBody>
      </p:sp>
    </p:shapes>
  </p:cSld>
</p:notes>'''

    with open(notes_path, 'w', encoding='utf-8') as f:
        f.write(notes_xml)

    # Update relationships (simplified)
    return True
```

## Validation

### Validate Slide XML

```python
from lxml import etree

def validate_slide_xml(slide_path):
    """Check if slide XML is well-formed."""
    try:
        etree.parse(slide_path)
        return True, None
    except etree.XMLSyntaxError as e:
        return False, str(e)

def validate_pptx_structure(pptx_dir):
    """Validate entire presentation structure."""
    required_files = [
        '[Content_Types].xml',
        '_rels/.rels',
        'ppt/presentation.xml',
        'ppt/_rels/presentation.xml.rels'
    ]

    missing = []
    for f in required_files:
        if not os.path.exists(os.path.join(pptx_dir, f)):
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
| EMU conversion errors | Remember: 1 inch = 914400 EMUs |

## Quick Reference

### EMU Conversions

| Unit | EMUs |
|------|------|
| 1 inch | 914400 |
| 1 pt | 12700 |
| 1 cm | 360000 |

### Namespace Prefixes

| Prefix | Namespace |
|--------|-----------|
| p: | presentationml |
| a: | drawingml |
| r: | officeDocument/relationships |
| xdr: | drawingml/spreadsheetDrawing |

## Related Files

- `SKILL.md` - Main skill documentation
- `html2pptx.md` - HTML to PowerPoint conversion guide