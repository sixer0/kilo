#!/usr/bin/env python3
"""
PDF Example 03: Extract Tables from PDF
Shows how to extract tables using pdfplumber.
"""

def extract_tables():
    import os

    if not os.path.exists("input.pdf"):
        print("[WARN] input.pdf not found")
        print("  Place a PDF with tables in this directory and run:")
        print("  python 03_extract_tables.py")
        return

    try:
        import pdfplumber

        with pdfplumber.open("input.pdf") as pdf:
            for i, page in enumerate(pdf.pages):
                tables = page.extract_tables()
                print(f"Page {i+1}: {len(tables)} tables")
                for j, table in enumerate(tables):
                    if table:
                        print(f"  Table {j+1}: {len(table)} rows")
        print("[OK] Table extraction complete")
    except ImportError:
        print("[WARN] pdfplumber not installed")
        print("  Install with: pip install pdfplumber")

if __name__ == "__main__":
    extract_tables()