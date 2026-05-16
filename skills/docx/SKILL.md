# DOCX Document Processing Skill

## Overview

This skill enables comprehensive Word document (.docx) creation, editing, and analysis for agent workflows. It supports document generation, tracked changes, comments, formatting, and text extraction.

## Quick Reference

| Task | Tool | Command/Code |
|------|------|--------------|
| Extract text | pandoc | `pandoc --track-changes=all file.docx -o output.md` |
| Create new | docx-js | `new Document({...})` |
| Edit existing | python-docx | `Document('file.docx')` |
| Raw XML edit | lxml + zipfile | See OOXML section |
| Track changes | docx-revisions | `RevisionDocument` |
| Convert to PDF | LibreOffice | `soffice --headless --convert-to pdf` |

## Document Types and Tools

### Decision Tree

```
Need to READ document?
│
├─ YES: Extract text/content
│   └─ Use pandoc for text extraction
│
├─ NO: CREATE new document?
│   └─ YES: Use docx-js (JavaScript/TypeScript)
│
└─ NO: EDIT existing document?
    │
    ├─ Simple changes (your own document)
    │   └─ Use python-docx or basic OOXML
    │
    ├─ Complex changes (someone else's document)
    │   └─ Use Redlining workflow (recommended)
    │
    └─ Legal, academic, business docs
        └─ Use Redlining workflow (required)
```

## Reading and Analyzing Content

### Text Extraction with pandoc

```bash
# Extract to markdown
pandoc document.docx -o output.md

# Include tracked changes in output
pandoc --track-changes=all document.docx -o output.md

# Extract specific sections
pandoc document.docx --section-divs -o output.html
```

### Python Text Extraction

```python
from docx import Document

doc = Document('document.docx')

# All paragraphs
for para in doc.paragraphs:
    print(para.text)

# All tables
for table in doc.tables:
    for row in table.rows:
        print([cell.text for cell in row.cells])

# Document structure
print(f"Paragraphs: {len(doc.paragraphs)}")
print(f"Tables: {len(doc.tables)}")
print(f"Sections: {len(doc.sections)}")
```

### Raw XML Access (Advanced)

```bash
# Unpack document to directory
python ooxml/scripts/unpack.py document.docx unpacked/

# Key files:
# - word/document.xml      - Main document content
# - word/comments.xml      - Comments
# - word/settings.xml      - Document settings
# - word/styles.xml        - Style definitions
# - word/media/            - Embedded images
```

## Creating New Documents

### Using docx-js (JavaScript/TypeScript)

**IMPORTANT**: Read `docx-js.md` completely before creating documents.

```javascript
const { Document, Packer, Paragraph, TextRun } = require("docx");

const doc = new Document({
  sections: [{
    children: [
      new Paragraph({
        text: "Hello World!",
        heading: "Heading1"
      })
    ]
  }]
});

Packer.toBuffer(doc).then(buffer => {
  fs.writeFileSync("output.docx", buffer);
});
```

### Document Creation Patterns

**Simple document:**
```python
from docx import Document

doc = Document()
doc.add_heading('Title', 0)
doc.add_paragraph('Body text')
doc.save('output.docx')
```

**With formatting:**
```python
from docx import Document
from docx.shared import Pt, Inches
from docx.enum.text import WD_ALIGN_PARAGRAPH

doc = Document()
title = doc.add_heading('Report Title', 0)
title.alignment = WD_ALIGN_PARAGRAPH.CENTER

para = doc.add_paragraph()
run = para.add_run('Bold text')
run.bold = True
run.font.size = Pt(14)

doc.add_picture('logo.png', width=Inches(1.5))
doc.save('output.docx')
```

## Editing Existing Documents

**IMPORTANT**: Read `ooxml.md` completely before editing documents.

### Using python-docx

```python
from docx import Document

doc = Document('existing.docx')

# Modify first paragraph
first_para = doc.paragraphs[0]
first_para.text = 'Updated text'

# Add new content
doc.add_heading('New Section', 1)
doc.add_paragraph('New content')

# Modify table
if doc.tables:
    table = doc.tables[0]
    table.cell(0, 0).text = 'New value'

# Access headers/footers
section = doc.sections[0]
header = section.header
header.paragraphs[0].text = "Document Header"

doc.save('modified.docx')
```

### Using Document Library (for OOXML editing)

```python
from scripts.document import Document, DocxXMLEditor

doc = Document('unpacked/')

# Find element containing text
node = doc["word/document.xml"].get_node(tag="w:r", contains="text to change")

# Make modifications
# ... edit node ...

doc.save()
```

## Redlining Workflow (Document Review)

For reviewing and editing documents with track changes:

### Step 1: Get Markdown with Changes

```bash
pandoc --track-changes=all document.docx -o current.md
```

### Step 2: Identify Changes

Group changes into batches of 3-10 related edits for efficient processing.

### Step 3: Unpack Document

```bash
python ooxml/scripts/unpack.py document.docx unpacked/
```

### Step 4: Implement Changes (Batched)

```python
from docx_revisions import RevisionDocument

rdoc = RevisionDocument("contract.docx")

# Replace with tracking
count = rdoc.find_and_replace_tracked(
    "Old Company Name",
    "New Company Name",
    author="Legal Bot",
    comment="Name change per merger agreement"
)
print(f"Replaced {count} occurrences")

rdoc.save("contract_revised.docx")
```

### Step 5: Accept/Reject Changes

```python
# Accept all changes
rdoc = RevisionDocument("tracked.docx")
rdoc.accept_all()
rdoc.save("clean.docx")

# Or reject all
rdoc = RevisionDocument("tracked.docx")
rdoc.reject_all()
rdoc.save("original.docx")
```

### Step 6: Verify Changes

```bash
# Convert back to markdown and verify
pandoc --track-changes=all reviewed-document.docx -o verified.md
```

## Tables

### Creating Tables

```python
from docx import Document

doc = Document()

# Add table with data
table = doc.add_table(rows=3, cols=3)
table.style = 'Table Grid'

# Header row
hdr_cells = table.rows[0].cells
hdr_cells[0].text = 'Name'
hdr_cells[1].text = 'Qty'
hdr_cells[2].text = 'Amount'

# Data rows
data = [('Item 1', 10, 100), ('Item 2', 5, 50)]
for i, (name, qty, amount) in enumerate(data, start=1):
    row = table.rows[i].cells
    row[0].text = name
    row[1].text = str(qty)
    row[2].text = str(amount)
```

### Table from Data (Dynamic)

```python
def create_table_from_data(doc, data, headers):
    """Create table with headers from list of dicts."""
    table = doc.add_table(rows=1, cols=len(headers))
    table.style = 'Medium Grid 1 Accent 1'

    # Header row
    hdr_cells = table.rows[0].cells
    for i, h in enumerate(headers):
        hdr_cells[i].text = h

    # Data rows
    for row_data in data:
        row = table.add_row()
        for i, key in enumerate(headers):
            row.cells[i].text = str(row_data.get(key, ''))

    return table
```

### Merging Cells

```python
# Horizontal merge
cell = table.cell(0, 0)
cell.merge(table.cell(0, 1))

# Vertical merge
cell = table.cell(0, 0)
cell.merge(table.cell(1, 0))
```

## Headers and Footers

### Modify Header/Footer

```python
section = doc.sections[0]

# Header
header = section.header
header.paragraphs[0].text = "Report Title"
header.paragraphs[0].style = doc.styles['Header']

# Footer with page numbers
footer = section.footer
p = footer.paragraphs[0]
p.add_run("Page ")
p.add_page_number()
p.add_run(" of ")
p.add_num_pages()

# Different first page
section.different_first_page_header_footer = True
first_header = section.first_page_header
first_header.paragraphs[0].text = "Cover Page Header"
```

### Tab-Based Alignment

Headers use tabs for left/center/right zones:
```python
header.paragraphs[0].text = "Left Text\tCenter Text\tRight Text"
```

## Document Conversion

### DOCX to PDF

```python
from docx2pdf import convert

# Single file
convert("input.docx", "output.pdf")

# Batch
convert("my_docs/")
```

### Using LibreOffice

```bash
soffice --headless --convert-to pdf document.docx
```

### Image Conversion

```bash
# DOCX to PDF
soffice --headless --convert-to pdf document.docx

# PDF to images
pdftoppm -jpeg -r 150 document.pdf page
```

## Track Changes and Comments

### Using docx-revisions

```python
from docx_revisions import RevisionDocument

# Read tracked changes
rdoc = RevisionDocument("tracked.docx")

# Find with tracking
rdoc.find_and_replace_tracked("old", "new", author="Agent")

# Accept/reject
rdoc.accept_all()
rdoc.reject_all()
```

### Comments with Spire.Doc

```python
from spire.doc import Document, Comment

doc = Document()
doc.LoadFromFile("template.docx")

# Add comment
comment = Comment(doc)
comment.Body.AddParagraph("Review comment")
comment.Format.Author = "Reviewer"
doc.Comments.Add(comment)

doc.SaveToFile("commented.docx")
```

### Extracting Comments

```python
doc = Document()
doc.LoadFromFile("reviewed.docx")

for comment in doc.Comments:
    print(f"Author: {comment.Format.Author}")
    for para in comment.Body.Paragraphs:
        print(f"Text: {para.Text}")
```

## Advanced OOXML Manipulation

Read `ooxml.md` for detailed XML editing procedures:

- Finding and replacing text
- Adding/modifying paragraphs
- Working with tables
- Track changes XML structure
- Validation

## Common Patterns for Subagents

### Pattern 1: Document from Template

```python
from docx import Document

def generate_from_template(template_path, data, output_path):
    doc = Document(template_path)

    # Replace placeholders
    for para in doc.paragraphs:
        for key, value in data.items():
            if f'{{{{{key}}}}}' in para.text:
                para.text = para.text.replace(f'{{{{{key}}}}}', str(value))

    doc.save(output_path)
```

### Pattern 2: Batch Processing

```python
import os
from docx import Document

def process_documents(input_dir, output_dir):
    for filename in os.listdir(input_dir):
        if filename.endswith('.docx'):
            doc = Document(os.path.join(input_dir, filename))
            # ... process ...
            doc.save(os.path.join(output_dir, filename))
```

### Pattern 3: Redlining Workflow

```python
from docx_revisions import RevisionDocument

def review_and_update(document_path, changes):
    rdoc = RevisionDocument(document_path)

    for old_text, new_text, author in changes:
        rdoc.find_and_replace_tracked(
            old_text,
            new_text,
            author=author,
            comment="Auto-review"
        )

    rdoc.save(document_path.replace('.docx', '_reviewed.docx'))
```

## Best Practices

### Document Creation

1. **Use templates with pre-defined styles**
   - Create one paragraph with each style you need, then delete it (registers style in template)
   - Never assume styles exist - always use styled templates
   ```python
   # CORRECT
   doc = Document('template.docx')  # Has all styles pre-defined
   # WRONG
   doc = Document()  # No styling infrastructure
   ```

2. **Pre-allocate tables with correct dimensions**
   ```python
   # CORRECT - Pre-allocate
   table = doc.add_table(rows=len(data), cols=len(data[0]))
   for i, row in enumerate(data):
       for j, cell_text in enumerate(row):
           table.cell(i, j).text = str(cell_text)

   # WRONG - Row by row (slower)
   table = doc.add_table(rows=1, cols=3)
   for item in data:
       row = table.add_row()  # Each call has overhead
   ```

3. **Use formulas not hardcoded values where applicable**
   - Let Word calculate, don't hardcode results
   - Use `docxtpl` for template-based generation with Jinja2 syntax

4. **Handle errors with try/except blocks**
   - Always close documents properly
   - Use context managers when possible

5. **Validate XML before saving (for OOXML edits)**
   ```python
   from lxml import etree
   def validate_xml(path):
       try:
           etree.parse(path)
           return True
       except etree.XMLSyntaxError:
           return False
   ```

6. **Test output in Microsoft Word**
   - Open generated documents in Word to verify formatting
   - Check for compatibility issues with different Word versions

### Memory Management

7. **Call gc.collect() after processing large documents**
   ```python
   import gc
   from docx import Document

   def process_large_doc(path):
       doc = Document(path)
       # ... process ...
       del doc
       gc.collect()
   ```

8. **Use streaming for large file I/O**
   ```python
   from io import BytesIO
   # Save to stream
   target_stream = BytesIO()
   doc.save(target_stream)
   ```

### XML Manipulation

9. **Never manipulate XML as strings**
   ```python
   # WRONG - Can corrupt XML
   with open('document.xml', 'r') as f:
       content = f.read()
   content = content.replace('old', 'new')

   # CORRECT - Use DOM API
   tree = etree.parse('document.xml')
   # ... modify via DOM API ...
   ```

10. **Clone option objects when creating multiple similar shapes**
    - PptxGenJS mutates option objects in place

## Code Style Guidelines

- Write concise code
- Avoid verbose variable names
- Avoid unnecessary print statements
- Use meaningful but short variable names

## Error Handling

### Common Issues and Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| "Style not found" | Style not in template | Use template with styles pre-applied, or add style via Word |
| Corrupt file on open | Invalid XML structure | Validate with lxml before saving, use xmllint |
| Memory leak with large docs | lxml holds references | Call `gc.collect()`, use xml.etree.ElementTree alternative |
| Blank document result | Initial empty paragraph not consumed | Use `document._body.clear_content()` before adding |
| Header modification affects wrong section | Inheritance behavior | Set `header.is_linked_to_previous = False` first |
| Table cell access error | Index out of range | Always check `len(table.rows)` before access |
| Image not appearing | Missing namespace in template | Ensure template has required DrawingML namespaces |
| Placeholder not replaced | Unicode/hidden character differences | Use `para.text.strip()` comparison, debug with XML view |
| pandoc conversion fails | Document protection or corruption | Try `pandoc --strict` or open/save in Word first |

### Error Handling Patterns

```python
from docx import Document
import gc

def safe_document_processing(file_path):
    """Document processing with proper error handling."""
    try:
        doc = Document(file_path)

        # Process document
        for para in doc.paragraphs:
            # ... process ...

        doc.save(file_path.replace('.docx', '_processed.docx'))
        return {"success": True, "output": file_path}

    except FileNotFoundError:
        return {"success": False, "error": "File not found"}
    except PermissionError:
        return {"success": False, "error": "File is open in another program"}
    except Exception as e:
        return {"success": False, "error": str(e)}
    finally:
        del doc
        gc.collect()
```

### Validation Before Save (OOXML)

```python
from lxml import etree

def validate_document_xml(xml_path):
    """Validate document.xml is well-formed."""
    try:
        with open(xml_path, 'rb') as f:
            etree.parse(f)
        return True, None
    except etree.XMLSyntaxError as e:
        return False, str(e)

def safe_save_document(unpacked_dir, output_path):
    """Save document with validation."""
    doc_xml = os.path.join(unpacked_dir, 'word', 'document.xml')
    is_valid, error = validate_document_xml(doc_xml)

    if not is_valid:
        raise ValueError(f"Invalid XML: {error}")

    pack_office_file(unpacked_dir, output_path)
```

## Quick Reference

| Task | Tool | Command/Code |
|------|------|--------------|
| Extract text | pandoc | `pandoc document.docx -o output.md` |
| Create new document | docx-js | `new Document({...})` |
| Edit existing | python-docx | `Document('file.docx')` |
| Track changes | docx-revisions | `RevisionDocument()` |
| Raw XML edit | lxml + zipfile | See ooxml.md |
| Convert to PDF | LibreOffice | `soffice --headless --convert-to pdf` |
| Validate XML | lxml | `etree.parse(xml_path)` |
| Memory cleanup | gc | `gc.collect()` after large docs |

## Dependencies

| Tool | Purpose | Install Command |
|------|---------|-----------------|
| pandoc | Text extraction | Install from pandoc.org |
| docx | JavaScript document creation | `npm install -g docx` |
| python-docx | Python document manipulation | `pip install python-docx` |
| docx-revisions | Track changes | `pip install docx-revisions` |
| docx2pdf | PDF conversion | `pip install docx2pdf` |
| defusedxml | Secure XML parsing | `pip install defusedxml` |
| lxml | XML manipulation | `pip install lxml` |
| LibreOffice | PDF conversion | Install from libreoffice.org |
| poppler-utils | PDF-to-image | Install via package manager |

## Related Files

- `docx-js.md` - JavaScript document creation
- `ooxml.md` - OOXML editing guide
- `scripts/` - Helper scripts for document processing