/**
 * Phase 1 Verification Script for Kilo Document Skills
 * 
 * Validates that all skill documentation meets quality standards
 */

const fs = require('fs');
const path = require('path');

const SKILLS_DIR = path.join(__dirname, '..', 'skills');

// Skills to verify
const SKILLS = ['docx', 'pdf', 'pptx', 'xlsx'];

// Required files per skill
const REQUIRED_FILES = {
  docx: ['SKILL.md', 'docx-js.md', 'ooxml.md'],
  pdf: ['SKILL.md', 'forms.md'],
  pptx: ['SKILL.md', 'html2pptx.md', 'ooxml.md'],
  xlsx: ['SKILL.md']
};

// Quality thresholds
const MIN_LINES = 300;
const MIN_CODE_EXAMPLES = 5;

let totalTests = 0;
let passedTests = 0;
let failedTests = [];

function test(name, fn) {
  totalTests++;
  try {
    fn();
    passedTests++;
    console.log(`  ✅ ${name}`);
  } catch (e) {
    passedTests--;
    failedTests.push({ name, error: e.message });
    console.log(`  ❌ ${name}: ${e.message}`);
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

console.log('\n📋 Phase 1 Verification - Kilo Document Skills\n');
console.log('='.repeat(60));

// Test each skill
for (const skill of SKILLS) {
  console.log(`\n📁 Skill: ${skill.toUpperCase()}\n`);

  const skillDir = path.join(SKILLS_DIR, skill);
  const files = REQUIRED_FILES[skill];

  // Test 1: Required files exist
  test(`${skill}: Required files exist`, () => {
    for (const file of files) {
      const filePath = path.join(skillDir, file);
      assert(fs.existsSync(filePath), `Missing: ${file}`);
    }
  });

  // Test 2: SKILL.md has minimum length
  test(`${skill}: SKILL.md meets minimum length`, () => {
    const skillMd = path.join(skillDir, 'SKILL.md');
    const content = fs.readFileSync(skillMd, 'utf8');
    const lines = content.split('\n').length;
    assert(lines >= MIN_LINES, `SKILL.md has ${lines} lines, need ${MIN_LINES}+`);
  });

  // Test 3: Has code examples
  test(`${skill}: Has code examples`, () => {
    const skillMd = path.join(skillDir, 'SKILL.md');
    const content = fs.readFileSync(skillMd, 'utf8');
    const codeBlocks = countPattern(content, '```');
    assert(codeBlocks >= MIN_CODE_EXAMPLES * 2, `Need ${MIN_CODE_EXAMPLES * 2} code block markers (found ${codeBlocks})`);
  });

  // Test 4: Has dependencies section
  test(`${skill}: Has dependencies documented`, () => {
    const skillMd = path.join(skillDir, 'SKILL.md');
    const content = fs.readFileSync(skillMd, 'utf8').toLowerCase();
    assert(content.includes('dependencies') || content.includes('install'), 'Missing dependencies section');
  });

  // Test 5: Has subagent patterns
  test(`${skill}: Has subagent workflow patterns`, () => {
    const skillMd = path.join(skillDir, 'SKILL.md');
    const content = fs.readFileSync(skillMd, 'utf8');
    const hasPatterns = content.includes('Pattern 1') || content.includes('subagent');
    assert(hasPatterns, 'Missing subagent patterns');
  });

  // Test 6: Has quick reference or table
  test(`${skill}: Has quick reference or table`, () => {
    const skillMd = path.join(skillDir, 'SKILL.md');
    const content = fs.readFileSync(skillMd, 'utf8');
    const hasTable = content.includes('| Task') || content.includes('| Tool');
    assert(hasTable, 'Missing quick reference table');
  });

  // Test 7: Cross-references to related files
  test(`${skill}: Has cross-references to related files`, () => {
    const skillMd = path.join(skillDir, 'SKILL.md');
    const content = fs.readFileSync(skillMd, 'utf8');
    const hasRefs = content.includes('.md') || content.includes('Related Files');
    assert(hasRefs, 'Missing cross-references');
  });

  // Additional tests for specific skills
  if (skill === 'docx') {
    test(`${skill}: Has redlining workflow`, () => {
      const skillMd = path.join(skillDir, 'SKILL.md');
      const content = fs.readFileSync(skillMd, 'utf8').toLowerCase();
      assert(content.includes('redlin'), 'Missing redlining workflow documentation');
    });
  }

  if (skill === 'pdf') {
    test(`${skill}: Has OCR documentation`, () => {
      const skillMd = path.join(skillDir, 'SKILL.md');
      const content = fs.readFileSync(skillMd, 'utf8').toLowerCase();
      assert(content.includes('ocr') || content.includes('pytesseract'), 'Missing OCR documentation');
    });
  }

  if (skill === 'pptx') {
    test(`${skill}: Has PptxGenJS examples`, () => {
      const skillMd = path.join(skillDir, 'SKILL.md');
      const content = fs.readFileSync(skillMd, 'utf8');
      assert(content.includes('pptxgen') || content.includes('addSlide'), 'Missing PptxGenJS examples');
    });
  }

  if (skill === 'xlsx') {
    test(`${skill}: Has formula documentation`, () => {
      const skillMd = path.join(skillDir, 'SKILL.md');
      const content = fs.readFileSync(skillMd, 'utf8').toLowerCase();
      assert(content.includes('formula') && content.includes('='), 'Missing formula documentation');
    });
  }
}

// Summary
console.log('\n' + '='.repeat(60));
console.log(`\n📊 Results: ${passedTests}/${totalTests} tests passed`);

if (failedTests.length > 0) {
  console.log('\n❌ Failed Tests:');
  for (const f of failedTests) {
    console.log(`   - ${f.name}`);
    console.log(`     ${f.error}`);
  }
  process.exit(1);
} else {
  console.log('\n✅ All Phase 1 verification tests passed!');
  process.exit(0);
}