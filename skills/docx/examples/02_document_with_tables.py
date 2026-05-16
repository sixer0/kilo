#!/usr/bin/env python3
"""
DOCX Example 02: Document with Tables
Creates a document containing formatted tables.
"""

from docx import Document

def create_document_with_tables():
    doc = Document()
    doc.add_heading('Sales Report with Tables', 0)

    table = doc.add_table(rows=3, cols=3)
    table.style = 'Table Grid'

    headers = ['Quarter', 'Revenue', 'Growth']
    for i, h in enumerate(headers):
        table.rows[0].cells[i].text = h
        table.rows[0].cells[i].paragraphs[0].runs[0].bold = True

    data = [('Q1 2024', '$1.2M', '+15%'), ('Q2 2024', '$1.5M', '+25%')]
    for row_idx, row_data in enumerate(data, 1):
        for col_idx, val in enumerate(row_data):
            table.rows[row_idx].cells[col_idx].text = val

    return doc

if __name__ == "__main__":
    doc = create_document_with_tables()
    doc.save("example_02_tables.docx")
    print("[OK] Created: example_02_tables.docx")