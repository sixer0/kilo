# PDF Forms Guide

## Overview

This guide covers filling, creating, and manipulating PDF forms using pypdf and related libraries.

## Understanding PDF Form Types

| Form Type | Description | Best Tool |
|-----------|-------------|-----------|
| **AcroForms** | Classic PDF forms with field widgets | pypdf |
| **XFA Forms** | XML-based dynamic forms | Not supported by pypdf |
| **Hybrid Forms** | Both AcroForms and XFA | Partial support |

## Reading Form Fields

### Get All Fields

```python
from pypdf import PdfReader

def get_form_fields(pdf_path):
    """Get all form fields from a PDF."""
    reader = PdfReader(pdf_path)

    if not reader.get_form_text_fields():
        print("No form fields found")
        return {}

    fields = reader.get_form_text_fields()
    return fields

def get_all_fields_with_metadata(pdf_path):
    """Get fields with full metadata."""
    reader = PdfReader(pdf_path)
    fields = {}

    for page in reader.pages:
        for annot in page.get('/Annots', []):
            annot = annot.get_object()
            if annot.get('/Subtype') == '/Widget':
                field_name = annot.get('/T')
                field_type = annot.get('/FT')
                field_value = annot.get('/V')
                fields[field_name] = {
                    'type': field_type,
                    'value': field_value,
                    'page': page.indirect_ref
                }

    return fields
```

### Field Types

| Field Type | Description | Values |
|------------|-------------|--------|
| `/Tx` | Text field | Any string |
| `/Btn` | Button (checkbox/radio) | `/Yes` or `/Off` |
| `/Ch` | Choice (dropdown/list) | One of options |
| `/Sig` | Signature field | Signature data |

## Filling Forms

### Basic Text Field Filling

```python
from pypdf import PdfReader, PdfWriter

def fill_text_field(pdf_path, output_path, field_data):
    """
    Fill text fields in a PDF form.

    Args:
        pdf_path: Path to input PDF
        output_path: Path to output PDF
        field_data: Dict of {field_name: value}
    """
    reader = PdfReader(pdf_path)
    writer = PdfWriter()

    # Copy all pages
    writer.clone_reader_document_from(reader)

    # Update form fields
    writer.update_page_form_field_values(
        writer.pages[0],
        field_data,
        auto_regenerate=False
    )

    with open(output_path, 'wb') as f:
        writer.write(f)

# Usage
fill_text_field(
    "form.pdf",
    "filled_form.pdf",
    {
        "name": "John Doe",
        "email": "john@example.com",
        "address": "123 Main St"
    }
)
```

### Critical: auto_regenerate=False

**IMPORTANT**: Always use `auto_regenerate=False` when filling forms. This prevents the "Do you want to save changes?" dialog in Adobe Reader.

```python
# CORRECT
writer.update_page_form_field_values(
    writer.pages[0],
    field_data,
    auto_regenerate=False  # Critical for proper rendering
)

# WRONG - causes save dialog issues
writer.update_page_form_field_values(
    writer.pages[0],
    field_data
    # auto_regenerate defaults to True
)
```

## Checkbox and Radio Buttons

### Filling Checkboxes

```python
from pypdf import PdfReader, PdfWriter

def fill_checkbox(pdf_path, output_path, checkbox_data):
    """Fill checkbox fields."""
    reader = PdfReader(pdf_path)
    writer = PdfWriter()
    writer.clone_reader_document_from(reader)

    # Checkbox values: '/Yes' = checked, '/Off' = unchecked
    writer.update_page_form_field_values(
        writer.pages[0],
        checkbox_data,
        auto_regenerate=False
    )

    with open(output_path, 'wb') as f:
        writer.write(f)

# Usage
fill_checkbox(
    "checkbox_form.pdf",
    "filled.pdf",
    {
        "agree_terms": "/Yes",
        "subscribe": "/Off"
    }
)
```

### Filling Radio Buttons

```python
def fill_radio_button(pdf_path, output_path, field_name, selected_value):
    """Fill a radio button group."""
    reader = PdfReader(pdf_path)
    writer = PdfWriter()
    writer.clone_reader_document_from(reader)

    # For radio buttons, set the selected one to '/Yes', others to '/Off'
    field_data = {}
    for option in ["Option1", "Option2", "Option3"]:
        key = f"{field_name}.{option}"
        field_data[key] = "/Yes" if option == selected_value else "/Off"

    writer.update_page_form_field_values(
        writer.pages[0],
        field_data,
        auto_regenerate=False
    )

    with open(output_path, 'wb') as f:
        writer.write(f)
```

## Dropdown and List Fields

```python
def fill_dropdown(pdf_path, output_path, dropdown_data):
    """Fill dropdown/choice fields."""
    reader = PdfReader(pdf_path)
    writer = PdfWriter()
    writer.clone_reader_document_from(reader)

    # For choice fields, use the export value (not display text)
    writer.update_page_form_field_values(
        writer.pages[0],
        dropdown_data,
        auto_regenerate=False
    )

    with open(output_path, 'wb') as f:
        writer.write(f)

# Usage
fill_dropdown(
    "survey.pdf",
    "completed.pdf",
    {
        "country": "USA",  # Use export value
        "department": "Engineering"
    }
)
```

## Complex Forms with Appearance Streams

### Enable Appearance Generation

```python
def fill_form_robust(pdf_path, output_path, field_data):
    """
    Robust form filling with proper appearance generation.
    Use this when fields don't render correctly with basic approach.
    """
    reader = PdfReader(pdf_path)
    writer = PdfWriter()

    # Enable appearance generation
    writer.set_need_appearances_writer()

    writer.clone_reader_document_from(reader)

    # Update fields
    writer.update_page_form_field_values(
        writer.pages[0],
        field_data,
        auto_regenerate=False
    )

    with open(output_path, 'wb') as f:
        writer.write(f)
```

## Flattening Forms

### Flatten Form Fields (Make Non-Editable)

```python
from pypdf import PdfReader, PdfWriter

def flatten_form(pdf_path, output_path):
    """Flatten form fields - values become part of the PDF."""
    reader = PdfReader(pdf_path)
    writer = PdfWriter()

    # Clone without fields
    writer.clone_reader_document_from(reader)

    # Get field names
    fields = reader.get_fields()

    # Update with current values
    field_data = {}
    if fields:
        for name, field in fields.items():
            if field.get('/V'):
                field_data[name] = field.get('/V')

    writer.update_page_form_field_values(
        writer.pages[0],
        field_data,
        auto_regenerate=False
    )

    # Remove form fields
    writer.remove_form_fields()

    with open(output_path, 'wb') as f:
        writer.write(f)
```

### Partial Flatten (Keep Some Fields Editable)

```python
def flatten_specific_fields(pdf_path, output_path, fields_to_flatten):
    """Flatten specific fields while keeping others editable."""
    reader = PdfReader(pdf_path)
    writer = PdfWriter()
    writer.clone_reader_document_from(reader)

    # Get current field values
    all_fields = reader.get_fields()
    field_data = {}

    for name in fields_to_flatten:
        if name in all_fields and all_fields[name].get('/V'):
            field_data[name] = all_fields[name].get('/V')

    writer.update_page_form_field_values(
        writer.pages[0],
        field_data,
        auto_regenerate=False
    )

    # Remove only specified fields
    for name in fields_to_flatten:
        writer.remove_form_fields(names=[name])

    with open(output_path, 'wb') as f:
        writer.write(f)
```

## Creating Forms from Scratch

### Using ReportLab for New Forms

```python
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
from reportlab.lib import colors

def create_form_with_fields(output_path):
    """Create a PDF with form fields using ReportLab."""
    c = canvas.Canvas(output_path, pagesize=letter)

    # Add static text
    c.setFont("Helvetica", 12)
    c.drawString(50, 750, "Name:")
    c.drawString(50, 720, "Email:")

    # Draw input boxes (visual only - not actual fields)
    c.rect(150, 740, 300, 20)
    c.rect(150, 710, 300, 20)

    # Add submit button (visual only)
    c.setFillColor(colors.blue)
    c.rect(150, 670, 100, 30, fill=True)
    c.setFillColor(colors.white)
    c.drawString(170, 680, "Submit")

    c.save()
    print(f"Created: {output_path}")
```

## Form Field Coordinates

### Get Field Positions

```python
from pypdf import PdfReader

def get_field_positions(pdf_path):
    """Get coordinates of all form fields."""
    reader = PdfReader(pdf_path)

    positions = []
    for page_num, page in enumerate(reader.pages):
        if '/Annots' in page:
            for annot in page['/Annots']:
                annot = annot.get_object()
                if annot.get('/Subtype') == '/Widget':
                    rect = annot.get('/Rect')
                    positions.append({
                        'page': page_num + 1,
                        'name': annot.get('/T'),
                        'type': annot.get('/FT'),
                        'rect': rect
                    })

    return positions

# Print positions for debugging
for pos in get_field_positions("form.pdf"):
    print(f"Page {pos['page']}: {pos['name']} at {pos['rect']}")
```

## Batch Form Processing

### Fill Multiple Forms from Data Source

```python
import pandas as pd
from pypdf import PdfReader, PdfWriter

def batch_fill_forms(template_path, data_path, output_dir):
    """
    Fill multiple forms from a data source.

    Args:
        template_path: Path to PDF form template
        data_path: Path to CSV/Excel with fill data
        output_dir: Directory for output files
    """
    # Read data
    if data_path.endswith('.csv'):
        df = pd.read_csv(data_path)
    else:
        df = pd.read_excel(data_path)

    for idx, row in df.iterrows():
        reader = PdfReader(template_path)
        writer = PdfWriter()
        writer.clone_reader_document_from(reader)

        # Convert row to field data
        field_data = row.to_dict()

        writer.update_page_form_field_values(
            writer.pages[0],
            field_data,
            auto_regenerate=False
        )

        output_path = f"{output_dir}/filled_form_{idx + 1}.pdf"
        with open(output_path, 'wb') as f:
            writer.write(f)

        print(f"Created: {output_path}")
```

## Common Issues and Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| Fields not visible after fill | Missing appearance stream | Use `set_need_appearances_writer()` |
| Save dialog appears | Wrong auto_regenerate setting | Use `auto_regenerate=False` |
| Wrong font in filled fields | Font not embedded | Use `auto_regenerate=True` with caution |
| Dropdown shows wrong value | Export vs display value | Use export value from field options |

## Validation

### Verify Filled Form

```python
def verify_filled_form(pdf_path, expected_values):
    """Verify form was filled correctly."""
    reader = PdfReader(pdf_path)
    fields = reader.get_form_text_fields()

    mismatches = []
    for field_name, expected in expected_values.items():
        actual = fields.get(field_name)
        if actual != expected:
            mismatches.append({
                'field': field_name,
                'expected': expected,
                'actual': actual
            })

    if mismatches:
        print("Mismatches found:")
        for m in mismatches:
            print(f"  {m['field']}: expected '{m['expected']}', got '{m['actual']}'")
        return False

    return True

# Usage
verify_filled_form("filled.pdf", {
    "name": "John Doe",
    "email": "john@example.com"
})
```

## Related Documentation

- `SKILL.md` - Main PDF skill documentation
- [pypdf Form Fields](https://pypdf.io/latest/api.html#form-fields) - Official documentation