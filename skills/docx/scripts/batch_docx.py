#!/usr/bin/env python3
"""
Batch DOCX Processing Utility

Provides batch operations for multiple DOCX files:
- Convert to text/markdown
- Apply find/replace
- Merge documents
- Extract metadata

Usage:
    python batch_docx.py <command> [options]

Commands:
    text        - Extract text from all documents
    replace     - Find and replace text across documents
    merge       - Merge multiple documents into one
    info        - Extract metadata from documents

Examples:
    python batch_docx.py text ./documents/
    python batch_docx.py replace ./documents/ --old "ACME" --new "NewCorp"
    python batch_docx.py merge ./documents/ --output merged.docx
"""

import os
import sys
import argparse
import zipfile
from pathlib import Path
from docx import Document

def extract_text_from_docx(doc_path):
    """Extract all text from a DOCX file."""
    doc = Document(doc_path)
    text_parts = []

    for para in doc.paragraphs:
        if para.text.strip():
            text_parts.append(para.text)

    return '\n'.join(text_parts)

def batch_text(input_dir, output_dir):
    """Extract text from all DOCX files in directory."""
    input_path = Path(input_dir)
    output_path = Path(output_dir) if output_dir else input_path.parent / f"{input_path.name}_text"

    output_path.mkdir(parents=True, exist_ok=True)

    docx_files = list(input_path.glob("*.docx")) + list(input_path.glob("*.docm"))

    if not docx_files:
        print(f"[WARN] No DOCX files found in {input_dir}")
        return 0

    for docx_file in docx_files:
        try:
            text = extract_text_from_docx(docx_file)
            output_file = output_path / f"{docx_file.stem}.txt"

            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(text)

            print(f"[OK] {docx_file.name} -> {output_file.name}")

        except Exception as e:
            print(f"[FAIL] {docx_file.name}: {e}")

    return len(docx_files)

def batch_replace(input_dir, output_dir, old_text, new_text):
    """Find and replace text in all DOCX files."""
    input_path = Path(input_dir)
    output_path = Path(output_dir) if output_dir else input_path.parent / f"{input_path.name}_replaced"
    output_path.mkdir(parents=True, exist_ok=True)

    docx_files = list(input_path.glob("*.docx"))

    if not docx_files:
        print(f"[WARN] No DOCX files found in {input_dir}")
        return 0

    count = 0
    for docx_file in docx_files:
        try:
            doc = Document(docx_file)
            replaced = 0

            for para in doc.paragraphs:
                if old_text in para.text:
                    para.text = para.text.replace(old_text, new_text)
                    replaced += 1

            for table in doc.tables:
                for row in table.rows:
                    for cell in row.cells:
                        if old_text in cell.text:
                            cell.text = cell.text.replace(old_text, new_text)
                            replaced += 1

            if replaced > 0:
                output_file = output_path / docx_file.name
                doc.save(output_file)
                print(f"[OK] {docx_file.name}: {replaced} replacements")
                count += 1
            else:
                print(f"[SKIP] {docx_file.name}: no matches")

        except Exception as e:
            print(f"[FAIL] {docx_file.name}: {e}")

    return count

def batch_merge(input_files, output_file):
    """Merge multiple DOCX files into one."""
    from docxcompose.composer import Composer
    from docx import Document

    if len(input_files) < 2:
        print("[FAIL] Need at least 2 files to merge")
        return False

    try:
        base_doc = Document(input_files[0])
        composer = Composer(base_doc)

        for file in input_files[1:]:
            doc = Document(file)
            composer.append(doc)

        composer.save(output_file)
        print(f"[OK] Merged {len(input_files)} files -> {output_file}")
        return True

    except ImportError:
        # Fallback without docxcompose
        print("[WARN] docxcompose not installed, using basic merge")

        base_doc = Document(input_files[0])

        for file in input_files[1:]:
            doc = Document(file)
            for element in doc.element.body:
                base_doc.element.body.append(element)

        base_doc.save(output_file)
        print(f"[OK] Merged {len(input_files)} files -> {output_file}")
        return True

    except Exception as e:
        print(f"[FAIL] Merge error: {e}")
        return False

def batch_info(input_dir):
    """Extract metadata from all DOCX files."""
    input_path = Path(input_dir)
    docx_files = list(input_path.glob("*.docx"))

    if not docx_files:
        print(f"[WARN] No DOCX files found in {input_dir}")
        return 0

    for docx_file in docx_files:
        try:
            doc = Document(docx_file)
            print(f"\n{docx_file.name}:")
            print(f"  Paragraphs: {len(doc.paragraphs)}")
            print(f"  Tables: {len(doc.tables)}")
            print(f"  Sections: {len(doc.sections)}")

            if hasattr(doc, 'core_properties'):
                props = doc.core_properties
                if props.title:
                    print(f"  Title: {props.title}")
                if props.author:
                    print(f"  Author: {props.author}")

        except Exception as e:
            print(f"[FAIL] {docx_file.name}: {e}")

    return len(docx_files)

def main():
    parser = argparse.ArgumentParser(
        description="Batch DOCX Processing Utility",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )

    subparsers = parser.add_subparsers(dest='command', help='Available commands')

    # Text extraction
    text_parser = subparsers.add_parser('text', help='Extract text from DOCX files')
    text_parser.add_argument('input_dir', help='Input directory containing DOCX files')
    text_parser.add_argument('-o', '--output', help='Output directory (default: <input>_text)')

    # Replace
    replace_parser = subparsers.add_parser('replace', help='Find and replace text')
    replace_parser.add_argument('input_dir', help='Input directory containing DOCX files')
    replace_parser.add_argument('-o', '--output', help='Output directory')
    replace_parser.add_argument('--old', required=True, help='Text to find')
    replace_parser.add_argument('--new', required=True, help='Replacement text')

    # Merge
    merge_parser = subparsers.add_parser('merge', help='Merge multiple DOCX files')
    merge_parser.add_argument('files', nargs='+', help='Files to merge')
    merge_parser.add_argument('-o', '--output', default='merged.docx', help='Output file')

    # Info
    info_parser = subparsers.add_parser('info', help='Extract document metadata')
    info_parser.add_argument('input_dir', help='Input directory containing DOCX files')

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        return 1

    if args.command == 'text':
        batch_text(args.input_dir, args.output)

    elif args.command == 'replace':
        batch_replace(args.input_dir, args.output, args.old, args.new)

    elif args.command == 'merge':
        batch_merge(args.files, args.output)

    elif args.command == 'info':
        batch_info(args.input_dir)

    return 0

if __name__ == "__main__":
    sys.exit(main())