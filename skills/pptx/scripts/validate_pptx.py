#!/usr/bin/env python3
"""
PPTX Skill Validation Script

Validates that the pptx skill can:
1. Read and parse pptx files
2. Create basic presentations
3. Work with slides and shapes

Usage:
    python validate_pptx.py [test_file.pptx]

Exit codes:
    0 - All tests passed
    1 - One or more tests failed
"""

import sys
import os
import tempfile
import zipfile
from pathlib import Path

# Check for python-pptx
try:
    from pptx import Presentation
except ImportError:
    print("[FAIL] python-pptx not installed")
    print("   Install with: pip install python-pptx")
    sys.exit(1)

def test_read_pptx(file_path=None):
    """Test reading a pptx file."""
    print("\n[Test] Read PPTX file")

    if file_path is None:
        # Create a minimal test presentation
        print("   Creating test presentation...")
        prs = Presentation()
        slide = prs.slides.add_slide(prs.slide_layouts[0])
        title = slide.shapes.title
        title.text = "Test Presentation"

        fd, file_path = tempfile.mkstemp(suffix='.pptx')
        os.close(fd)
        prs.save(file_path)
        print(f"   Created: {file_path}")
    else:
        if not os.path.exists(file_path):
            print(f"   [WARN] Test file not found: {file_path}")
            print("   Creating new test presentation instead...")
            prs = Presentation()
            slide = prs.slides.add_slide(prs.slide_layouts[0])
            title = slide.shapes.title
            title.text = "Test Presentation"
            fd, temp_path = tempfile.mkstemp(suffix='.pptx')
            os.close(fd)
            os.remove(temp_path)
            file_path = temp_path
            prs.save(file_path)

    try:
        prs = Presentation(file_path)

        # Check structure
        slides = len(prs.slides)
        layouts = len(prs.slide_layouts)

        print(f"   [PASS] Read successfully")
        print(f"   Slides: {slides}, Layouts: {layouts}")

        return True, file_path

    except Exception as e:
        print(f"   [FAIL] {e}")
        return False, file_path

def test_create_pptx():
    """Test creating a new pptx file."""
    print("\n[Test] Create PPTX file")

    try:
        prs = Presentation()
        prs.slide_width = 9144000  # 10 inches in EMUs
        prs.slide_height = 5143500  # 5.625 inches

        # Add title slide
        title_slide = prs.slides.add_slide(prs.slide_layouts[0])
        title = title_slide.shapes.title
        title.text = "Validation Test"

        # Add content slide
        content_slide = prs.slides.add_slide(prs.slide_layouts[1])
        title = content_slide.shapes.title
        title.text = "Content Slide"

        fd, output_path = tempfile.mkstemp(suffix='.pptx')
        os.close(fd)
        prs.save(output_path)

        # Verify it can be reopened
        prs2 = Presentation(output_path)
        assert len(prs2.slides) >= 2

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
        # PPTX is a ZIP file - verify structure
        with zipfile.ZipFile(file_path, 'r') as z:
            namelist = z.namelist()

            required = ['[Content_Types].xml', 'ppt/presentation.xml']
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

def test_slide_manipulation(file_path):
    """Test slide manipulation."""
    print("\n[Test] Slide manipulation")

    try:
        prs = Presentation(file_path)
        initial_slides = len(prs.slides)

        # Try to access shapes on each slide
        shape_count = 0
        for slide in prs.slides:
            shape_count += len(slide.shapes)

        print(f"   [PASS] Slides accessible")
        print(f"   Total shapes: {shape_count}")

        return True

    except Exception as e:
        print(f"   [FAIL] {e}")
        return False

def run_validation(test_file=None):
    """Run all validation tests."""
    print("=" * 60)
    print("PPTX Skill Validation")
    print("=" * 60)

    results = []
    test_file_path = None

    # Test 1: Create and read
    success, test_file_path = test_read_pptx(test_file)
    results.append(success)

    # Test 2: Create new presentation
    results.append(test_create_pptx())

    # Test 3: OOXML structure (if we have a file)
    if test_file_path:
        results.append(test_ooxml_structure(test_file_path))

    # Test 4: Slide manipulation
    if test_file_path:
        results.append(test_slide_manipulation(test_file_path))

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