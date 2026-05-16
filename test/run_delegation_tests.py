#!/usr/bin/env python3
"""
Kilo Skills Delegation Test Suite
Tests that subagents can correctly use the documented skills.
"""

import os
import sys
import subprocess

def run_test(name, script_path):
    """Run a single test script."""
    print(f"\n{'='*60}")
    print(f"Running: {name}")
    print(f"{'='*60}")

    try:
        result = subprocess.run(
            [sys.executable, script_path],
            capture_output=True,
            text=True,
            timeout=60
        )

        print(result.stdout)
        if result.stderr:
            print(result.stderr)

        return result.returncode == 0
    except subprocess.TimeoutExpired:
        print(f"  [FAIL] Test timed out")
        return False
    except Exception as e:
        print(f"  [FAIL] {e}")
        return False

def main():
    print("\n" + "="*60)
    print("KILO SKILLS DELEGATION TEST SUITE")
    print("="*60)

    test_dir = os.path.dirname(__file__)

    tests = [
        ("DOCX Skill Delegation", os.path.join(test_dir, "test_docx_delegation.py")),
        ("PDF Skill Delegation", os.path.join(test_dir, "test_pdf_delegation.py")),
        ("PPTX Skill Delegation", os.path.join(test_dir, "test_pptx_delegation.py")),
        ("XLSX Skill Delegation", os.path.join(test_dir, "test_xlsx_delegation.py")),
    ]

    results = []
    for name, script in tests:
        if os.path.exists(script):
            result = run_test(name, script)
            results.append((name, result))
        else:
            print(f"\n[WARN] Test not found: {script}")
            results.append((name, False))

    # Summary
    print("\n" + "="*60)
    print("DELEGATION TEST SUMMARY")
    print("="*60)

    passed = 0
    failed = 0

    for name, result in results:
        status = "[PASS]" if result else "[FAIL]"
        print(f"  {status} {name}")
        if result:
            passed += 1
        else:
            failed += 1

    print(f"\nTotal: {passed}/{passed+failed} passed")

    if failed == 0:
        print("\n[SUCCESS] All delegation tests passed!")
        return 0
    else:
        print(f"\n[FAILURE] {failed} test(s) failed")
        return 1

if __name__ == "__main__":
    sys.exit(main())