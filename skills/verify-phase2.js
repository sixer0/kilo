/**
 * Phase 2 Verification Script for Kilo Document Skills
 *
 * Validates Phase 2 improvements: error handling, dependencies, quick references
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

function countPattern(content, pattern) {
  const regex = new RegExp(pattern, 'gi');
  const matches = content.match(regex);
  return matches ? matches.length : 0;
}

console.log('\nPhase 2 Verification - Standardize & Harden\n');
console.log('='.repeat(60));

for (const skill of SKILLS) {
  console.log(`\nSkill: ${skill.toUpperCase()}\n`);

  const skillDir = path.join(SKILLS_DIR, skill);
  const skillMd = path.join(skillDir, 'SKILL.md');
  const content = fs.readFileSync(skillMd, 'utf8');

  // Test 1: Has error handling section
  test(`${skill}: Has error handling section`, () => {
    const hasErrorSection = content.includes('## Error Handling') ||
                           content.includes('Common Issues') ||
                           content.includes('| Issue |');
    assert(hasErrorSection, 'Missing error handling section');
  });

  // Test 2: Error handling has table format
  test(`${skill}: Error handling has table format`, () => {
    const hasTable = content.includes('| Issue |') ||
                    content.includes('| Problem |') ||
                    content.includes('| Error |');
    assert(hasTable, 'Error handling should have table format');
  });

  // Test 3: Has quick reference table
  test(`${skill}: Has quick reference table`, () => {
    const hasQuickRef = content.includes('## Quick Reference') ||
                       content.includes('| Task |');
    assert(hasQuickRef, 'Missing quick reference table');
  });

  // Test 4: Dependencies format standardized
  test(`${skill}: Has standardized dependencies section`, () => {
    const hasDeps = content.includes('| Tool |') &&
                   content.includes('| Purpose |') &&
                   content.includes('| Install Command |');
    assert(hasDeps, 'Dependencies not standardized');
  });

  // Test 5: Has common failure scenarios
  test(`${skill}: Documents common failure scenarios`, () => {
    const hasFailureScenarios = content.includes('FileNotFoundError') ||
                               content.includes('PermissionError') ||
                               content.includes('#REF!');
    assert(hasFailureScenarios, 'Missing common failure scenarios');
  });

  // Test 6: Has error handling patterns/code
  test(`${skill}: Has error handling code patterns`, () => {
    const hasPattern = content.includes('try:') ||
                      content.includes('except') ||
                      content.includes('Error Handling Patterns');
    assert(hasPattern, 'Missing error handling code patterns');
  });
}

// Validation scripts tests
console.log('\nValidation Scripts:\n');

const docxScript = path.join(SKILLS_DIR, 'docx', 'scripts', 'validate_docx.py');
const pptxScript = path.join(SKILLS_DIR, 'pptx', 'scripts', 'validate_pptx.py');

test('docx: Has validation script', () => {
  assert(fs.existsSync(docxScript), 'Missing validate_docx.py');
});

test('pptx: Has validation script', () => {
  assert(fs.existsSync(pptxScript), 'Missing validate_pptx.py');
});

test('docx: Validation script is executable', () => {
  const content = fs.readFileSync(docxScript, 'utf8');
  assert(content.includes('def test_'), 'Missing test functions');
  assert(content.includes('if __name__'), 'Missing main block');
});

test('pptx: Validation script is executable', () => {
  const content = fs.readFileSync(pptxScript, 'utf8');
  assert(content.includes('def test_'), 'Missing test functions');
  assert(content.includes('if __name__'), 'Missing main block');
});

// Summary
console.log('\n' + '='.repeat(60));
console.log(`\nResults: ${passedTests}/${totalTests} tests passed`);

if (failedTests.length > 0) {
  console.log('\nFailed Tests:');
  for (const f of failedTests) {
    console.log(`   - ${f.name}`);
  }
  process.exit(1);
} else {
  console.log('\n[PASS] All Phase 2 verification tests passed!');
  process.exit(0);
}