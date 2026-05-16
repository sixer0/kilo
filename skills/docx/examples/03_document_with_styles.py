#!/usr/bin/env python3
"""
DOCX Example 03: Document with Styles
Demonstrates applying styles and formatting.
"""

from docx import Document
from docx.shared import Pt, RGBColor

def create_styled_document():
    doc = Document()
    title = doc.add_heading('', 0)
    run = title.add_run('Styled Document Report')
    run.font.size = Pt(28)
    run.font.bold = True
    run.font.color.rgb = RGBColor(0, 51, 102)

    p = doc.add_paragraph()
    run = p.add_run('Important: ')
    run.bold = True
    run.font.color.rgb = RGBColor(200, 0, 0)
    run = p.add_run('Critical information here.')

    return doc

if __name__ == "__main__":
    doc = create_styled_document()
    doc.save("example_03_styled.docx")
    print("[OK] Created: example_03_styled.docx")