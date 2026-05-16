#!/usr/bin/env python3
"""
PDF Example 02: Create PDF with ReportLab
Creates a PDF with text, tables, and basic formatting.
"""

from reportlab.lib.pagesizes import letter
from reportlab.platyp import SimpleDocTemplate, Paragraph, Table, TableStyle
from reportlab.lib import colors

def create_pdf():
    doc = SimpleDocTemplate("example_02_created.pdf", pagesize=letter)

    story = []
    story.append(Paragraph("Report Title", styles['Title']))
    story.append(Paragraph("This PDF was created with ReportLab."))

    table_data = [["Name", "Value"], ["Item 1", "$100"], ["Item 2", "$200"]]
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

    story.append(table)
    doc.build(story)
    print("[OK] Created: example_02_created.pdf")

if __name__ == "__main__":
    try:
        from reportlab.platypus import SimpleDocTemplate, Paragraph, Table, TableStyle
        from reportlab.lib import colors
        from reportlab.lib.pagesizes import letter
        from reportlab.lib.styles import getSampleStyleSheet
        styles = getSampleStyleSheet()
        create_pdf()
    except ImportError:
        print("[WARN] ReportLab not installed")
        print("  Install with: pip install reportlab")