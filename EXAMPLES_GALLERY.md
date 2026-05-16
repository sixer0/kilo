# Kilo Document Skills - Examples Gallery

This gallery provides comprehensive working examples for all document processing skills in Kilo.

## Overview

| Skill | Description | Examples | Batch Utility |
|-------|-------------|----------|--------------|
| **DOCX** | Word document creation and editing | 5 examples | `batch_docx.py` |
| **PDF** | PDF manipulation and extraction | 4 examples | - |
| **PPTX** | PowerPoint presentation creation | 5 examples | `batch_pptx.py` |
| **XLSX** | Excel spreadsheet processing | 4 examples | - |

---

## DOCX Examples

**Location:** `skills/docx/examples/`

| # | Example | Description |
|---|---------|-------------|
| 01 | `01_basic_document.py` | Create simple document with headings and paragraphs |
| 02 | `02_document_with_tables.py` | Create document with formatted tables |
| 03 | `03_document_with_styles.py` | Apply styles, colors, and formatting |
| 04 | `04_read_existing_document.py` | Load and modify existing documents |
| 05 | `05_extract_text.py` | Extract text from documents |

### Run DOCX Examples

```bash
cd skills/docx/examples

# Run individual example
python 01_basic_document.py

# Run all examples
for f in 0*.py; do python "$f"; done
```

### Batch Processing with DOCX

```bash
cd skills/docx/scripts

# Extract text from all documents
python batch_docx.py text /path/to/documents/

# Find and replace across documents
python batch_docx.py replace /path/to/documents/ --old "ACME" --new "NewCorp"

# Get document info
python batch_docx.py info /path/to/documents/
```

---

## PDF Examples

**Location:** `skills/pdf/examples/`

| # | Example | Description |
|---|---------|-------------|
| 01 | `01_merge_pdfs.py` | Merge multiple PDF files |
| 02 | `02_split_pdf.py` | Split PDF into individual pages |
| 03 | `03_extract_text_tables.py` | Extract text and tables from PDF |
| 04 | `04_create_pdf.py` | Create new PDF with ReportLab |

### Run PDF Examples

```bash
cd skills/pdf/examples

# Run individual example
python 01_merge_pdfs.py

# Extract text from all PDFs
python 03_extract_text_tables.py
```

---

## PPTX Examples

**Location:** `skills/pptx/examples/`

| # | Example | Description |
|---|---------|-------------|
| 01 | `01_basic_presentation.js` | Create presentation with slides and text |
| 02 | `02_presentation_with_shapes.js` | Add shapes, colors, KPI boxes |
| 03 | `03_presentation_with_tables.js` | Create slides with data tables |
| 04 | `04_presentation_with_charts.js` | Add bar, line, and pie charts |
| 05 | `05_template_based_presentation.js` | Use master slides for consistency |

### Run PPTX Examples

```bash
cd skills/pptx/examples

# Install dependencies
npm install pptxgenjs

# Run individual example
node 01_basic_presentation.js

# Run all examples
for f in 0*.js; do node "$f"; done
```

### Batch Processing with PPTX

```bash
cd skills/pptx/scripts

# Extract text from all presentations
python batch_pptx.py text /path/to/presentations/

# Get presentation info
python batch_pptx.py info /path/to/presentations/

# Export slides to images
python batch_pptx.py export /path/to/presentations/ --format png
```

---

## XLSX Examples

**Location:** `skills/xlsx/examples/`

| # | Example | Description |
|---|---------|-------------|
| 01 | `01_basic_spreadsheet.py` | Create spreadsheet with formulas |
| 02 | `02_spreadsheet_with_charts.py` | Add charts to spreadsheet |
| 03 | `03_read_modify_excel.py` | Load and modify existing files |
| 04 | `04_data_validation.py` | Apply data validation and formatting |

### Run XLSX Examples

```bash
cd skills/xlsx/examples

# Run individual example
python 01_basic_spreadsheet.py
```

---

## Quick Reference

### Common Commands

```bash
# DOCX text extraction
pandoc document.docx -o output.md

# PDF text extraction
pdftotext document.pdf output.txt

# PPTX text extraction
python -m markitdown presentation.pptx

# XLSX to CSV
python -c "import pandas as pd; pd.read_excel('file.xlsx').to_csv('file.csv')"
```

### Library Installation

```bash
# Python packages
pip install python-docx pypdf pdfplumber reportlab openpyxl pandas

# JavaScript packages
npm install pptxgenjs docx
```

---

## File Structure

```
skills/
├── docx/
│   ├── SKILL.md
│   ├── docx-js.md
│   ├── ooxml.md
│   ├── examples/
│   │   ├── README.md
│   │   ├── 01_basic_document.py
│   │   ├── 02_document_with_tables.py
│   │   ├── 03_document_with_styles.py
│   │   ├── 04_read_existing_document.py
│   │   └── 05_extract_text.py
│   └── scripts/
│       ├── batch_docx.py
│       └── validate_docx.py
├── pdf/
│   ├── SKILL.md
│   ├── forms.md
│   └── examples/
│       └── README.md
├── pptx/
│   ├── SKILL.md
│   ├── html2pptx.md
│   ├── ooxml.md
│   ├── examples/
│   │   ├── README.md
│   │   ├── 01_basic_presentation.js
│   │   ├── 02_presentation_with_shapes.js
│   │   ├── 03_presentation_with_tables.js
│   │   ├── 04_presentation_with_charts.js
│   │   └── 05_template_based_presentation.js
│   └── scripts/
│       ├── batch_pptx.py
│       └── validate_pptx.py
└── xlsx/
    ├── SKILL.md
    ├── examples/
    │   └── README.md
    └── scripts/
        └── recalc.py
```

---

## Learning Path

1. **Beginner**: Start with basic examples (01_* files)
   - DOCX: `01_basic_document.py`
   - PPTX: `01_basic_presentation.js`
   - PDF: `01_merge_pdfs.py`
   - XLSX: `01_basic_spreadsheet.py`

2. **Intermediate**: Move to feature-specific examples
   - Tables, charts, formatting
   - Template-based creation

3. **Advanced**: Batch processing and automation
   - Use batch utilities for bulk operations
   - Combine multiple skills in workflows

---

## Contributing New Examples

When adding examples:
1. Follow the numbering convention (01_, 02_, etc.)
2. Include clear comments and docstrings
3. Add usage instructions at the top
4. Update this gallery README

---

*Last updated: April 2026*