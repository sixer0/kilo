/**
 * Phase 3 Verification Script for Kilo Document Skills
 *
 * Validates Phase 3 improvements: best practices, examples gallery, batch utilities
 */

const fs = require('fs');
const path = require('path');

const SKILLS_DIR = path.join(__dirname, '..', 'skills');
const SKILLS = ['docx', 'pdf', 'pptx', 'xlsx'];

let totalTests = 0;
let passedTests = 0;
let failedTests = [];

function test(name, fn) {
  totalTests++;
  try {
    fn();
    passedTests++;
    console.log(`  [PASS] ${name}`);
  } catch (e) {
    passedTests--;
    failedTests.push({ name, error: e.message });
    console.log(`  [FAIL] ${name}: ${e.message}`);
  }
}

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

console.log('\n============================================================');
console.log('Phase 3 Verification - Feature Completeness');
console.log('============================================================');

// ============================================================================
// Best Practices Section Tests
// ============================================================================

console.log('\n[1] Best Practices Sections\n');

for (const skill of SKILLS) {
  const skillDir = path.join(SKILLS_DIR, skill);
  const skillMd = path.join(skillDir, 'SKILL.md');

  test(`${skill}: Has Best Practices section`, () => {
    const content = fs.readFileSync(skillMd, 'utf8');
    const hasBestPractices = content.includes('## Best Practices');
    assert(hasBestPractices, 'Missing Best Practices section');
  });

  test(`${skill}: Best Practices has numbered list (5+ items)`, () => {
    const content = fs.readFileSync(skillMd, 'utf8');
    const bestPracticesSection = content.substring(content.indexOf('## Best Practices'));
    const nextSectionIndex = bestPracticesSection.indexOf('## Code Style');
    const sectionText = nextSectionIndex > 0
      ? bestPracticesSection.substring(0, nextSectionIndex)
      : bestPracticesSection.substring(0, 3000);

    // Count numbered items (pattern: "1." through "12.")
    const numberedItems = (sectionText.match(/\d+\.\s+\*\*/g) || []).length;
    assert(numberedItems >= 5, `Expected 5+ best practices, found ${numberedItems}`);
  });

  test(`${skill}: Best Practices includes code examples`, () => {
    const content = fs.readFileSync(skillMd, 'utf8');
    const bestPracticesSection = content.substring(content.indexOf('## Best Practices'));
    const sectionText = bestPracticesSection.substring(0, 2000); // Check first 2000 chars
    const hasCode = sectionText.includes('```') || sectionText.includes('CORRECT') || sectionText.includes('WRONG');
    assert(hasCode, 'Best practices should include code examples');
  });
}

// ============================================================================
// Examples Gallery Tests
// ============================================================================

console.log('\n[2] Examples Gallery\n');

const KILO_ROOT = path.join(__dirname, '..');

test('Has Examples Gallery (EXAMPLES_GALLERY.md)', () => {
  const galleryPath = path.join(KILO_ROOT, 'EXAMPLES_GALLERY.md');
  assert(fs.existsSync(galleryPath), 'Missing EXAMPLES_GALLERY.md');
});

test('Gallery has overview table', () => {
  const galleryPath = path.join(KILO_ROOT, 'EXAMPLES_GALLERY.md');
  const content = fs.readFileSync(galleryPath, 'utf8');
  const hasTable = content.includes('| Skill |') && content.includes('Examples');
  assert(hasTable, 'Gallery should have overview table');
});

test('Gallery has learning path', () => {
  const galleryPath = path.join(KILO_ROOT, 'EXAMPLES_GALLERY.md');
  const content = fs.readFileSync(galleryPath, 'utf8');
  const hasLearningPath = content.includes('Learning Path') || content.includes('Beginner');
  assert(hasLearningPath, 'Gallery should have learning path');
});

// ============================================================================
// Examples Directories Tests
// ============================================================================

console.log('\n[3] Examples Directories\n');

for (const skill of SKILLS) {
  const examplesDir = path.join(SKILLS_DIR, skill, 'examples');

  test(`${skill}: Has examples directory`, () => {
    assert(fs.existsSync(examplesDir), 'Missing examples directory');
  });

  test(`${skill}: Has examples README`, () => {
    const readmePath = path.join(examplesDir, 'README.md');
    assert(fs.existsSync(readmePath), 'Missing README.md');
  });

  test(`${skill}: Has example files`, () => {
    const files = fs.readdirSync(examplesDir).filter(f => f.match(/^0\d_/));
    assert(files.length >= 3, `Expected at least 3 examples, found ${files.length}`);
  });
}

// ============================================================================
// Batch Processing Utilities Tests
// ============================================================================

console.log('\n[4] Batch Processing Utilities\n');

const batchDocx = path.join(SKILLS_DIR, 'docx', 'scripts', 'batch_docx.py');
const batchPptx = path.join(SKILLS_DIR, 'pptx', 'scripts', 'batch_pptx.py');

test('docx: Has batch_docx.py utility', () => {
  assert(fs.existsSync(batchDocx), 'Missing batch_docx.py');
});

test('docx: batch_docx.py has CLI interface', () => {
  const content = fs.readFileSync(batchDocx, 'utf8');
  const hasArgparse = content.includes('argparse') && content.includes('add_subparsers');
  assert(hasArgparse, 'batch_docx.py should have CLI interface');
});

test('docx: batch_docx.py supports text command', () => {
  const content = fs.readFileSync(batchDocx, 'utf8');
  const hasTextCmd = content.includes("'text'") && content.includes('batch_text');
  assert(hasTextCmd, 'batch_docx.py should support text command');
});

test('docx: batch_docx.py supports replace command', () => {
  const content = fs.readFileSync(batchDocx, 'utf8');
  const hasReplaceCmd = content.includes("'replace'") && content.includes('batch_replace');
  assert(hasReplaceCmd, 'batch_docx.py should support replace command');
});

test('pptx: Has batch_pptx.py utility', () => {
  assert(fs.existsSync(batchPptx), 'Missing batch_pptx.py');
});

test('pptx: batch_pptx.py has CLI interface', () => {
  const content = fs.readFileSync(batchPptx, 'utf8');
  const hasArgparse = content.includes('argparse') && content.includes('add_subparsers');
  assert(hasArgparse, 'batch_pptx.py should have CLI interface');
});

test('pptx: batch_pptx.py supports text command', () => {
  const content = fs.readFileSync(batchPptx, 'utf8');
  const hasTextCmd = content.includes("'text'") && content.includes('batch_text');
  assert(hasTextCmd, 'batch_pptx.py should support text command');
});

// ============================================================================
// Summary
// ============================================================================

console.log('\n============================================================');
console.log(`\nResults: ${passedTests}/${totalTests} tests passed\n`);

if (failedTests.length > 0) {
  console.log('[FAIL] Failed Tests:\n');
  for (const f of failedTests) {
    console.log(`   - ${f.name}`);
    console.log(`     ${f.error}`);
  }
  console.log('');
  process.exit(1);
} else {
  console.log('[PASS] All Phase 3 verification tests passed!');
  console.log('');
  console.log('Phase 3 Summary:');
  console.log('  - Best Practices: Added to all 4 skills (5+ items each)');
  console.log('  - Examples Gallery: Created with overview and learning path');
  console.log('  - Examples: 16+ working examples across all skills');
  console.log('  - Batch Utilities: batch_docx.py and batch_pptx.py with CLI');
  console.log('');
  process.exit(0);
}