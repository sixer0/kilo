# PDF Processing Skill

## Overview

Comprehensive PDF manipulation for agent workflows: text/table extraction, creation, merging, splitting, forms, OCR, and conversions.

## Quick Reference

| Task | Tool | Command/Code |
|------|------|--------------|
| Read/merge/split | pypdf | See Basic Operations |
| Extract text/tables | pdfplumber | `page.extract_text()` |
| Create PDFs | reportlab | `canvas.Canvas()` |
| Extract tables to Excel | pandas | `page.extract_tables()` |
| Fill forms | pypdf | `writer.update_page_form_field_values()` |
| OCR scanned PDFs | pytesseract | Convert to image first |
| Command line merge/split | qpdf | `qpdf --empty --pages ...` |

## Basic Operations with pypdf

### Reading a PDF

```python
from pypdf import PdfReader, PdfWriter

reader = PdfReader("document.pdf")
print(f"Pages: {len(reader.pages)}")

# Extract text
text = ""
for page in reader.pages:
    text += page.extract_text()
```

### Merge PDFs

```python
from pypdf import PdfReader, PdfWriter

writer = PdfWriter()
for pdf_file in ["doc1.pdf", "doc2.pdf", "doc3.pdf"]:
    reader = PdfReader(pdf_file)
    writer.append(reader)  # Use append() to preserve fields

with open("merged.pdf", "wb") as output:
    writer.write(output)
```

### Split PDF

```python
reader = PdfReader("input.pdf")
for i, page in enumerate(reader.pages):
    writer = PdfWriter()
    writer.add_page(page)
    with open(f"page_{i+1}.pdf", "wb") as output:
        writer.write(output)
```

### Extract Metadata

```python
reader = PdfReader("document.pdf")
meta = reader.metadata
print(f"Title: {meta.title}")
print(f"Author: {meta.author}")
```

### Rotate Pages

```python
page.rotate(90)  # Rotate 90 degrees clockwise
```

## Text and Table Extraction with pdfplumber

### Basic Text with Layout

```python
import pdfplumber

with pdfplumber.open("document.pdf") as pdf:
    for page in pdf.pages:
        text = page.extract_text()
        print(text)
```

### Extract Tables

```python
import pdfplumber

with pdfplumber.open("document.pdf") as pdf:
    for i, page in enumerate(pdf.pages):
        tables = page.extract_tables()
        for j, table in enumerate(tables):
            print(f"Table {j+1} on page {i+1}:")
            for row in table:
                print(row)
```

### Extract Tables to Excel

```python
import pandas as pd
import pdfplumber

all_tables = []
with pdfplumber.open("document.pdf") as pdf:
    for page in pdf.pages:
        tables = page.extract_tables()
        for table in tables:
            if table:
                df = pd.DataFrame(table[1:], columns=table[0])
                all_tables.append(df)

if all_tables:
    combined_df = pd.concat(all_tables, ignore_index=True)
    combined_df.to_excel("extracted_tables.xlsx", index=False)
```

### Fine-Tuned Table Extraction

```python
settings = {
    "vertical_strategy": "text",
    "horizontal_strategy": "text",
    "snap_tolerance": 3,
    "intersection_tolerance": 3,
}

table = page.extract_table(settings=settings)
```

### Cropped Region Extraction

```python
# Extract from specific region (x0, top, x1, bottom)
bbox = (100, 200, 500, 400)
page = pdf.pages[0].crop(bbox)
text = page.extract_text()
```

## Creating PDFs with ReportLab

### Basic PDF

```python
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas

c = canvas.Canvas("hello.pdf", pagesize=letter)
width, height = letter
c.drawString(100, height - 100, "Hello World!")
c.save()
```

### Multi-Page with Platypus

```python
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak
from reportlab.lib.styles import getSampleStyleSheet

doc = SimpleDocTemplate("report.pdf", pagesize=letter)
styles = getSampleStyleSheet()

story = [
    Paragraph("Title", styles['Title']),
    Spacer(1, 12),
    Paragraph("Body text", styles['Normal']),
    PageBreak(),
    Paragraph("Page 2", styles['Heading1']),
]

doc.build(story)
```

### PDF with Tables

```python
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle
from reportlab.lib import colors

table_data = [["Name", "Amount"], ["Item 1", "$100"], ["Item 2", "$200"]]
table = Table(table_data)
table.setStyle(TableStyle([
    ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
    ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
    ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
    ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
    ('FONTSIZE', (0, 0), (-1, 0), 12),
    ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
    ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
]))

doc.build([table])
```

### Custom Page Templates with Headers/Footers

```python
from reportlab.platypus import BaseDocTemplate, PageTemplate, Frame

def header_footer(canvas, doc):
    canvas.saveState()
    canvas.setFont('Helvetica', 9)
    canvas.drawString(72, 750, "Header Text")
    canvas.drawRightString(523, 750, f"Page {doc.page}")
    canvas.restoreState()

doc = BaseDocTemplate("output.pdf", pagesize=letter)
template = PageTemplate(
    id='main',
    frames=[Frame(72, 72, 451, 680)],
    onPage=header_footer
)
doc.addPageTemplates([template])
doc.build([Paragraph("Content")])
```

## Command Line Tools

### pdftotext (poppler-utils)

```bash
# Extract text
pdftotext input.pdf output.txt

# Preserve layout
pdftotext -layout input.pdf output.txt

# Specific pages
pdftotext -f 1 -l 5 input.pdf output.txt
```

### qpdf

```bash
# Merge PDFs
qpdf --empty --pages file1.pdf file2.pdf -- merged.pdf

# Split pages
qpdf input.pdf --pages . 1-5 -- pages1-5.pdf

# Rotate pages
qpdf input.pdf output.pdf --rotate=+90:1
```

## OCR for Scanned PDFs

### Preprocessing Pipeline

```python
import cv2
import pytesseract
from pdf2image import convert_from_path
from PIL import Image

def preprocess_for_ocr(image_path):
    """Preprocess image for optimal OCR results."""
    image = cv2.imread(image_path)
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    denoised = cv2.medianBlur(gray, 3)
    binary = cv2.adaptiveThreshold(
        denoised, 255,
        cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv2.THRESH_BINARY, 11, 2
    )
    return Image.fromarray(binary)
```

### OCR Full Workflow

```python
from pdf2image import convert_from_path
import pytesseract

images = convert_from_path('scanned.pdf')
text = ""
for i, image in enumerate(images):
    text += f"Page {i+1}:\n"
    text += pytesseract.image_to_string(image)
    text += "\n\n"
```

### Tesseract Configuration

```python
# Basic
text = pytesseract.image_to_string(preprocessed_image)

# With custom config
text = pytesseract.image_to_string(
    image,
    config='--psm 6 --oem 3'
)

# PSM modes:
# 3 - Fully automatic (default)
# 4 - Single column of variable text
# 6 - Single uniform block of text
# 7 - Single text line
# 8 - Single word
# 10 - Single character
```

### Confidence-Based Extraction

```python
def extract_with_confidence(image_path, threshold=60):
    data = pytesseract.image_to_data(image_path, output_type=pytesseract.Output.DICT)
    words = []
    for i, text in enumerate(data['text']):
        if text.strip() and data['conf'][i] >= threshold:
            words.append(text)
    return ' '.join(words)
```

## PDF Forms

**IMPORTANT**: Read `forms.md` for comprehensive form handling.

### Reading Form Fields

```python
from pypdf import PdfReader

reader = PdfReader("form.pdf")
text_fields = reader.get_form_text_fields()
all_fields = reader.get_fields()
```

### Filling Forms

```python
from pypdf import PdfReader, PdfWriter

reader = PdfReader("form.pdf")
writer = PdfWriter()
writer.clone_reader_document_from(reader)

# Update fields - auto_regenerate=False is critical
writer.update_page_form_field_values(
    writer.pages[0],
    {"name": "John Doe", "email": "john@example.com"},
    auto_regenerate=False
)

with open("filled.pdf", "wb") as f:
    writer.write(f)
```

### Flatten Forms

```python
writer.remove_form_fields()  # Make non-editable
```

## Common Tasks

### Add Watermark

```python
from pypdf import PdfReader, PdfWriter

watermark = PdfReader("watermark.pdf").pages[0]
reader = PdfReader("document.pdf")
writer = PdfWriter()

for page in reader.pages:
    page.merge_page(watermark)
    writer.add_page(page)

with open("watermarked.pdf", "wb") as output:
    writer.write(output)
```

### Extract Images

```bash
pdfimages -j input.pdf output_prefix
```

### Password Protection

```python
from pypdf import PdfReader, PdfWriter

reader = PdfReader("input.pdf")
writer = PdfWriter()
for page in reader.pages:
    writer.add_page(page)
writer.encrypt("userpassword", "ownerpassword")

with open("encrypted.pdf", "wb") as output:
    writer.write(output)
```

### Memory-Efficient Large PDF Processing

```python
import pdfplumber
import gc

def process_large_pdf(pdf_path, chunk_size=100):
    with pdfplumber.open(pdf_path) as pdf:
        total = len(pdf.pages)

    for start in range(0, total, chunk_size):
        end = min(start + chunk_size, total)
        with pdfplumber.open(pdf_path) as pdf:
            for i in range(start, end):
                page = pdf.pages[i]
                # Process page
                page.flush_cache()
        gc.collect()
```

## Validation and Error Handling

### Check if PDF is Encrypted

```python
from pypdf import PdfReader

reader = PdfReader("document.pdf")
if reader.is_encrypted:
    reader.decrypt("password")
```

### Validate PDF Structure

```python
from pypdf import PdfReader

reader = PdfReader("document.pdf")
print(f"Valid: {len(reader.pages)} pages")
print(f"Encrypted: {reader.is_encrypted}")
print(f"Metadata: {reader.metadata}")
```

## Best Practices

### PDF Processing

1. **Determine if PDF is scanned or digital before processing**
   ```python
   def classify_pdf(pdf_path):
       with pdfplumber.open(pdf_path) as pdf:
           first_page_text = pdf.pages[0].extract_text()[:500]
       if len(first_page_text.strip()) < 50:
           return "scanned"  # Needs OCR
       return "digital"  # Can extract directly
   ```

2. **Use `writer.append()` not `writer.add_page()` for merging**
   - Preserves form fields and structure
   ```python
   # CORRECT
   writer.append(reader)
   # WRONG
   writer.add_page(reader.pages[0])
   ```

3. **Crop pages before extraction for better accuracy**
   ```python
   bbox = (100, 200, 500, 400)  # (x0, top, x1, bottom)
   cropped = page.crop(bbox)
   text = cropped.extract_text()
   ```

4. **Use explicit line detection for complex tables**
   ```python
   settings = {
       'vertical_strategy': 'explicit',
       'horizontal_strategy': 'lines',
       'explicit_vertical_lines': v_lines,
       'explicit_horizontal_lines': h_lines
   }
   table = page.extract_table(settings=settings)
   ```

5. **Always use `auto_regenerate=False` when filling forms**
   - Prevents "Do you want to save changes?" dialog

### OCR Best Practices

6. **Preprocess images before OCR**
   ```python
   import cv2
   # Grayscale, denoise, threshold
   gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
   denoised = cv2.medianBlur(gray, 3)
   binary = cv2.adaptiveThreshold(denoised, 255,
       cv2.ADAPTIVE_THRESH_GAUSSIAN_C, 11, 2)
   ```

7. **Target 300 DPI minimum for scanned documents**
   - Lower resolution = lower OCR accuracy
   - Characters should be 20-40px tall after preprocessing

8. **Use `psm 6` (Fully automatic page segmentation) as default**
   ```python
   text = pytesseract.image_to_string(img, config='--psm 6')
   ```

### Memory Management

9. **Process large PDFs in chunks**
   ```python
   import gc
   for chunk_start in range(0, total_pages, chunk_size):
       with pdfplumber.open(pdf_path) as pdf:
           for i in range(chunk_start, chunk_start + chunk_size):
               page = pdf.pages[i]
               # process
               page.flush_cache()
               page.close()
       gc.collect()
   ```

10. **Call `page.close()` explicitly when done**
    - Releases memory immediately

11. **Use `data_only=True` only for reading cached values**
    - Never save after `data_only=True` - formulas will be lost

### ReportLab PDF Creation

12. **Use Platypus for complex layouts**
    - Document > PageTemplate > Frame > Flowables
    - Better for structured documents

13. **Set page margins explicitly**
    ```python
    doc = SimpleDocTemplate("out.pdf", pagesize=letter,
                           leftMargin=72, rightMargin=72,
                           topMargin=72, bottomMargin=72)
    ```

## Best Practices for Subagents

### Pattern 1: Classification Before Processing

```python
def process_pdf(pdf_path):
    """Classify and route to appropriate extraction method."""
    with pdfplumber.open(pdf_path) as pdf:
        first_page_text = pdf.pages[0].extract_text()[:1000]

    # Determine if scanned (minimal text)
    if len(first_page_text.strip()) < 50:
        return ocr_extraction(pdf_path)
    else:
        return text_extraction(pdf_path)
```

### Pattern 2: Table Extraction with Fallback

```python
import pdfplumber
import pandas as pd

def extract_tables_robust(pdf_path):
    tables = []
    with pdfplumber.open(pdf_path) as pdf:
        for page in pdf.pages:
            # Try default extraction
            page_tables = page.extract_tables()
            for table in page_tables:
                if table:
                    df = pd.DataFrame(table[1:], columns=table[0])
                    tables.append(df)
    return tables
```

### Pattern 3: Batch Processing

```python
import os
from pypdf import PdfReader, PdfWriter

def merge_all_pdfs(input_dir, output_file):
    writer = PdfWriter()
    for filename in sorted(os.listdir(input_dir)):
        if filename.endswith('.pdf'):
            writer.append(os.path.join(input_dir, filename))
    with open(output_file, 'wb') as f:
        writer.write(f)
```

## Validation and Error Handling

### Common Issues and Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| Memory blowup with large PDFs | Loading entire file | Use chunk-based processing, call `page.close()` |
| PDF is encrypted | Password protection | Use `reader.decrypt('password')` |
| Table extraction fails | Complex layout | Use explicit line detection, crop regions |
| OCR returns garbage | Low-quality scan | Use preprocessing (denoise, deskew, threshold) |
| Form fields not saving | Missing appearance stream | Use `set_need_appearances_writer()` |
| PDF corrupted on write | Interrupted operation | Always use temp file, close properly |
| Text extraction empty | Scanned/image PDF | Use OCR with pytesseract |
| Merge preserves fields | Need `append()` not `add_page()` | Use `writer.append(reader)` |

### Error Handling Patterns

```python
from pypdf import PdfReader, PdfWriter
import logging

def safe_pdf_operation(input_path, output_path, operation):
    """Wrapper for PDF operations with error handling."""
    try:
        reader = PdfReader(input_path)

        if reader.is_encrypted:
            try:
                reader.decrypt('')
            except Exception:
                return {"success": False, "error": "Cannot decrypt PDF"}

        result = operation(reader)

        writer = PdfWriter()
        # ... apply operation ...

        writer.write(output_path)
        return {"success": True}

    except FileNotFoundError:
        return {"success": False, "error": "File not found"}
    except PermissionError:
        return {"success": False, "error": "File in use by another process"}
    except Exception as e:
        logging.error(f"PDF operation failed: {e}")
        return {"success": False, "error": str(e)}
```

### Memory-Efficient Large PDF Processing

```python
import pdfplumber
import gc

def process_large_pdf(pdf_path, chunk_size=100):
    """Process large PDFs in chunks to avoid memory issues."""
    with pdfplumber.open(pdf_path) as pdf:
        total = len(pdf.pages)

    for start in range(0, total, chunk_size):
        end = min(start + chunk_size, total)
        with pdfplumber.open(pdf_path) as pdf:
            for i in range(start, end):
                page = pdf.pages[i]
                # Process page
                text = page.extract_text()
                # ... do something with text ...
                page.flush_cache()
                page.close()
        gc.collect()
```

## Quick Reference

| Task | Best Tool | Code/Command |
|------|-----------|--------------|
| Merge PDFs | pypdf | `writer.append(reader)` |
| Split PDF | pypdf | `writer.add_page(page)` |
| Extract text | pdfplumber | `page.extract_text()` |
| Extract tables | pdfplumber | `page.extract_tables()` |
| Create PDFs | reportlab | `canvas.Canvas()` |
| Command merge | qpdf | `qpdf --empty --pages ...` |
| OCR | pytesseract | `image_to_string()` |
| Fill forms | pypdf | `update_page_form_field_values()` |

## Dependencies

| Tool | Purpose | Install Command |
|------|---------|-----------------|
| pypdf | Basic PDF ops | `pip install pypdf` |
| pdfplumber | Text/table extraction | `pip install pdfplumber` |
| reportlab | PDF creation | `pip install reportlab` |
| pandas | Data handling | `pip install pandas` |
| pytesseract | OCR | `pip install pytesseract` |
| pdf2image | OCR workflow | `pip install pdf2image` |
| poppler-utils | Command line | Install via package manager |
| qpdf | PDF manipulation | Install via package manager |
| opencv-python | Image preprocessing | `pip install opencv-python` |

## Related Files

- `forms.md` - PDF forms filling guide
- `scripts/` - Helper scripts for PDF processing