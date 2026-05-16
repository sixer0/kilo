#!/usr/bin/env python3
"""
PDF Example 04: Fill PDF Forms
Shows how to fill form fields in a PDF.
"""

def fill_form():
    import os

    if not os.path.exists("form.pdf"):
        print("[WARN] form.pdf not found")
        print("  Place a PDF form in this directory and run:")
        print("  python 04_fill_form.py")
        return

    try:
        from pypdf import PdfReader, PdfWriter

        reader = PdfReader("form.pdf")
        writer = PdfWriter()
        writer.clone_reader_document_from(reader)

        # Update form fields
        writer.update_page_form_field_values(
            writer.pages[0],
            {"name": "John Doe", "date": "2024-01-15"},
            auto_regenerate=False
        )

        writer.write("form_filled.pdf")
        print("[OK] Created: form_filled.pdf")
    except ImportError:
        print("[WARN] pypdf not installed")
        print("  Install with: pip install pypdf")

if __name__ == "__main__":
    fill_form()