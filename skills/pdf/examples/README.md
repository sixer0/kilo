# PDF Examples

This directory contains working examples for PDF processing.

## Examples

| Example | Description |
|---------|-------------|
| `01_basic_operations.py` | Merge, split, and extract text |
| `02_create_pdf.py` | Create PDF with ReportLab |
| `03_extract_tables.py` | Extract tables using pdfplumber |
| `04_fill_form.py` | Fill PDF forms with pypdf |

## Requirements

```bash
pip install pypdf pdfplumber reportlab
```

## Usage

```bash
cd skills/pdf/examples

# Place your PDF files (e.g., input.pdf, form.pdf) in this directory

# Run examples
python 01_basic_operations.py
python 02_create_pdf.py
```

## Notes

- Some examples require existing PDF files to process
- Follow the on-screen instructions for each example