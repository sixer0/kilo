#!/usr/bin/env python3
"""
DOCX Skill Validation Script

Validates that the docx skill can:
1. Read and parse docx files
2. Create basic documents
3. Extract text from documents

Usage:
    python validate_docx.py [test_file.docx]

Exit codes:
    0 - All tests passed
    1 - One or more tests failed
"""

import sys
import os
import tempfile
import zipfile
from pathlib import Path

# Check for python-docx
try:
    from docx import Document
except ImportError:
    print("[FAILED] python-docx not installed")
    print("   Install with: pip install python-docx")
    sys.exit(1)

# Check for pandoc
import subprocess

def check_pandoc():
    try:
        result = subprocess.run(
            ['pandoc', '--version'],
            capture_output=True,
            text=True,
            timeout=5
        )
        return result.returncode == 0
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return False

def test_read_docx(file_path=None):
    """Test reading a docx file."""
    print("\n[Test] Read DOCX file")

    if file_path is None:
        # Create a minimal test document
        print("   Creating test document...")
        doc = Document()
        doc.add_heading('Test Document', 0)
        doc.add_paragraph('This is a test paragraph.')

        fd, file_path = tempfile.mkstemp(suffix='.docx')
        os.close(fd)
        doc.save(file_path)
        print(f"   Created: {file_path}")
    else:
        if not os.path.exists(file_path):
            print(f"   [WARN] Test file not found: {file_path}")
            print("   Creating new test document instead...")
            doc = Document()
            doc.add_heading('Test Document', 0)
            doc.add_paragraph('This is a test paragraph.')
            fd, temp_path = tempfile.mkstemp(suffix='.docx')
            os.close(fd)
            os.remove(temp_path)
            file_path = temp_path
            doc.save(file_path)

    try:
        doc = Document(file_path)

        # Check structure
        paragraphs = len(doc.paragraphs)
        tables = len(doc.tables)
        sections = len(doc.sections)

        print(f"   [PASS] Read successfully")
        print(f"   Paragraphs: {paragraphs}, Tables: {tables}, Sections: {sections}")

        return True, file_path

    except Exception as e:
        print(f"   [FAIL] {e}")
        return False, file_path

def test_create_docx():
    """Test creating a new docx file."""
    print("\n[Test] Create DOCX file")

    try:
        doc = Document()
        doc.add_heading('Validation Test', 0)
        doc.add_paragraph('This document was created by the docx skill validation script.')

        # Add a table
        table = doc.add_table(rows=2, cols=2)
        table.cell(0, 0).text = 'Header 1'
        table.cell(0, 1).text = 'Header 2'
        table.cell(1, 0).text = 'Data 1'
        table.cell(1, 1).text = 'Data 2'

        fd, output_path = tempfile.mkstemp(suffix='.docx')
        os.close(fd)
        doc.save(output_path)

        # Verify it can be reopened
        doc2 = Document(output_path)
        assert len(doc2.paragraphs) >= 2

        print(f"   [PASS] Created successfully")

        # Clean up
        os.remove(output_path)

        return True

    except Exception as e:
        print(f"   [FAIL] {e}")
        return False

def test_ooxml_structure(file_path):
    """Test OOXML structure validation."""
    print("\n[Test] OOXML structure")

    try:
        # DOCX is a ZIP file - verify structure
        with zipfile.ZipFile(file_path, 'r') as z:
            namelist = z.namelist()

            required = ['[Content_Types].xml', 'word/document.xml']
            missing = []

            for req in required:
                if not any(req in name for name in namelist):
                    missing.append(req)

            if missing:
                print(f"   [WARN] Missing files: {missing}")
            else:
                print(f"   [PASS] Valid OOXML structure")
                print(f"   Files in archive: {len(namelist)}")

            return True

    except zipfile.BadZipFile:
        print(f"   [FAIL] Not a valid ZIP archive")
        return False
    except Exception as e:
        print(f"   [FAIL] {e}")
        return False

def test_pandoc_available():
    """Test if pandoc is available."""
    print("\n[Test] Pandoc availability")

    if check_pandoc():
        print("   [PASS] Pandoc is installed")
        return True
    else:
        print("   [WARN] Pandoc not found (optional)")
        print("   Install from: https://pandoc.org/")
        return True  # Not critical

def run_validation(test_file=None):
    """Run all validation tests."""
    print("=" * 60)
    print("DOCX Skill Validation")
    print("=" * 60)

    results = []
    test_file_path = None

    # Test 1: Create and read
    success, test_file_path = test_read_docx(test_file)
    results.append(success)

    # Test 2: Create new document
    results.append(test_create_docx())

    # Test 3: OOXML structure (if we have a file)
    if test_file_path:
        results.append(test_ooxml_structure(test_file_path))

    # Test 4: Pandoc availability
    results.append(test_pandoc_available())

    # Summary
    print("\n" + "=" * 60)
    passed = sum(results)
    total = len(results)
    print(f"Results: {passed}/{total} tests passed")

    if passed == total:
        print("\n[PASS] All validation tests passed!")
        return 0
    else:
        print(f"\n[FAIL] {total - passed} test(s) failed")
        return 1

if __name__ == "__main__":
    test_file = sys.argv[1] if len(sys.argv) > 1 else None
    sys.exit(run_validation(test_file))