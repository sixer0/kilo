#!/usr/bin/env python3
"""
Batch PPTX Processing Utility

Provides batch operations for multiple PPTX files:
- Extract text from all slides
- Apply template to multiple files
- Extract metadata
- Export slides to images (requires LibreOffice)

Usage:
    python batch_pptx.py <command> [options]

Commands:
    text        - Extract text from all presentations
    info        - Extract metadata from presentations
    export      - Export slides to images (requires soffice)

Examples:
    python batch_pptx.py text ./presentations/
    python batch_pptx.py info ./presentations/
    python batch_pptx.py export ./presentations/ --format png
"""

import os
import sys
import argparse
from pathlib import Path

def extract_text_from_pptx(pptx_path):
    """Extract text from a PPTX file."""
    from pptx import Presentation

    prs = Presentation(pptx_path)
    text_parts = []

    for slide_num, slide in enumerate(prs.slides, 1):
        slide_text = [f"--- Slide {slide_num} ---"]

        for shape in slide.shapes:
            if hasattr(shape, "text_frame"):
                for para in shape.text_frame.paragraphs:
                    text = para.text.strip()
                    if text:
                        slide_text.append(text)

        if slide_text:
            text_parts.append('\n'.join(slide_text))

    return '\n\n'.join(text_parts)

def batch_text(input_dir, output_dir):
    """Extract text from all PPTX files in directory."""
    input_path = Path(input_dir)
    output_path = Path(output_dir) if output_dir else input_path.parent / f"{input_path.name}_text"
    output_path.mkdir(parents=True, exist_ok=True)

    pptx_files = list(input_path.glob("*.pptx")) + list(input_path.glob("*.pptm"))

    if not pptx_files:
        print(f"[WARN] No PPTX files found in {input_dir}")
        return 0

    for pptx_file in pptx_files:
        try:
            text = extract_text_from_pptx(pptx_file)
            output_file = output_path / f"{pptx_file.stem}.txt"

            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(text)

            print(f"[OK] {pptx_file.name} -> {output_file.name}")

        except Exception as e:
            print(f"[FAIL] {pptx_file.name}: {e}")

    return len(pptx_files)

def batch_info(input_dir):
    """Extract metadata from all PPTX files."""
    from pptx import Presentation

    input_path = Path(input_dir)
    pptx_files = list(input_path.glob("*.pptx"))

    if not pptx_files:
        print(f"[WARN] No PPTX files found in {input_dir}")
        return 0

    for pptx_file in pptx_files:
        try:
            prs = Presentation(pptx_file)
            print(f"\n{pptx_file.name}:")
            print(f"  Slides: {len(prs.slides)}")
            print(f"  Layouts: {len(prs.slide_layouts)}")
            print(f"  Width: {prs.slide_width}")
            print(f"  Height: {prs.slide_height}")

        except Exception as e:
            print(f"[FAIL] {pptx_file.name}: {e}")

    return len(pptx_files)

def batch_export(input_dir, output_dir, format='png', dpi='150'):
    """Export slides to images using LibreOffice."""
    input_path = Path(input_dir)
    output_path = Path(output_dir) if output_dir else input_path.parent / f"{input_path.name}_images"
    output_path.mkdir(parents=True, exist_ok=True)

    pptx_files = list(input_path.glob("*.pptx"))

    if not pptx_files:
        print(f"[WARN] No PPTX files found in {input_dir}")
        return 0

    import subprocess

    for pptx_file in pptx_files:
        try:
            # Convert to PDF first
            pdf_name = pptx_file.stem + '.pdf'
            pdf_path = output_path / pdf_name

            # Use LibreOffice to convert
            result = subprocess.run([
                'soffice',
                '--headless',
                '--convert-to', 'pdf',
                '--outdir', str(output_path),
                str(pptx_file)
            ], capture_output=True, text=True)

            if result.returncode != 0:
                print(f"[FAIL] {pptx_file.name}: conversion failed")
                continue

            # Convert PDF to images
            if format != 'pdf':
                # Use pdftoppm if available
                pdf_file = output_path / pdf_name
                if pdf_file.exists():
                    subprocess.run([
                        'pdftoppm',
                        '-jpeg' if format == 'jpg' else '-png',
                        '-r', dpi,
                        str(pdf_file),
                        str(output_path / pptx_file.stem)
                    ])

            print(f"[OK] {pptx_file.name} exported")

        except FileNotFoundError as e:
            print(f"[FAIL] {pptx_file.name}: {e}")
            print("  Make sure LibreOffice is installed and in PATH")
        except Exception as e:
            print(f"[FAIL] {pptx_file.name}: {e}")

    return len(pptx_files)

def main():
    parser = argparse.ArgumentParser(
        description="Batch PPTX Processing Utility",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )

    subparsers = parser.add_subparsers(dest='command', help='Available commands')

    # Text extraction
    text_parser = subparsers.add_parser('text', help='Extract text from PPTX files')
    text_parser.add_argument('input_dir', help='Input directory containing PPTX files')
    text_parser.add_argument('-o', '--output', help='Output directory')

    # Info
    info_parser = subparsers.add_parser('info', help='Extract presentation metadata')
    info_parser.add_argument('input_dir', help='Input directory containing PPTX files')

    # Export
    export_parser = subparsers.add_parser('export', help='Export slides to images')
    export_parser.add_argument('input_dir', help='Input directory containing PPTX files')
    export_parser.add_argument('-o', '--output', help='Output directory')
    export_parser.add_argument('-f', '--format', default='png', choices=['png', 'jpg', 'pdf'],
                              help='Output format')
    export_parser.add_argument('-r', '--dpi', default='150', help='Image resolution (dpi)')

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        return 1

    if args.command == 'text':
        batch_text(args.input_dir, args.output)

    elif args.command == 'info':
        batch_info(args.input_dir)

    elif args.command == 'export':
        batch_export(args.input_dir, args.output, args.format, args.dpi)

    return 0

if __name__ == "__main__":
    sys.exit(main())