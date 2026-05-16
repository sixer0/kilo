#!/usr/bin/env python3
"""
PDF Example 01: Basic PDF Operations
Demonstrates merge, split, and text extraction.
"""

import os
import sys

def merge_pdfs():
    """Merge multiple PDFs."""
    try:
        from pypdf import PdfReader, PdfWriter

        input_files = ["file1.pdf", "file2.pdf"]
        writer = PdfWriter()

        for f in input_files:
            if os.path.exists(f):
                reader = PdfReader(f)
                writer.append(reader)

        writer.write("merged.pdf")
        print("[OK] Merged PDFs -> merged.pdf")
        return True
    except Exception as e:
        print(f"[FAIL] {e}")
        return False

def split_pdf():
    """Split PDF into individual pages."""
    try:
        from pypdf import PdfReader, PdfWriter

        if not os.path.exists("input.pdf"):
            print("[WARN] input.pdf not found - skipping split")
            return True

        reader = PdfReader("input.pdf")
        for i, page in enumerate(reader.pages):
            writer = PdfWriter()
            writer.add_page(page)
            writer.write(f"page_{i+1}.pdf")
        print(f"[OK] Split into {len(reader.pages)} pages")
        return True
    except Exception as e:
        print(f"[FAIL] {e}")
        return False

def extract_text():
    """Extract text from PDF."""
    try:
        from pypdf import PdfReader

        if not os.path.exists("input.pdf"):
            print("[WARN] input.pdf not found - skipping extract")
            return True

        reader = PdfReader("input.pdf")
        for i, page in enumerate(reader.pages):
            text = page.extract_text()
            print(f"Page {i+1}: {len(text)} chars")
        return True
    except Exception as e:
        print(f"[FAIL] {e}")
        return False

if __name__ == "__main__":
    print("[OK] PDF Example 01 - Basic Operations")
    print("  To test: place file1.pdf and file2.pdf in this directory")
    print("  Then run: python 01_basic_operations.py")