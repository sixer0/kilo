# PPTX Presentation Processing Skill

## Overview

Presentation creation, editing, and analysis for agent workflows using PptxGenJS (JavaScript) and python-pptx (Python). Supports template-based generation, slide manipulation, speaker notes, and format conversion.

## Quick Reference

| Task | Tool | Command/Code |
|------|------|--------------|
| Extract text | markitdown | `python -m markitdown file.pptx` |
| Create new | PptxGenJS | See Creating Presentations section |
| Edit existing | python-pptx | See Editing Presentations section |
| Use template | python-pptx | `Presentation('template.pptx')` |
| Speaker notes | PptxGenJS | `slide.addNotes('text')` |
| Create charts | PptxGenJS | `slide.addChart()` |
| Convert to images | LibreOffice + poppler | See Converting Slides |

## Understanding PPTX Structure

A .pptx file is a ZIP archive containing:

```
presentation.zip
├── [Content_Types].xml
├── _rels/
├── ppt/
│   ├── presentation.xml      # Main metadata
│   ├── slides/
│   │   ├── slide1.xml
│   │   └── slide2.xml
│   ├── slideLayouts/
│   ├── slideMasters/
│   ├── notesSlides/
│   └── media/                  # Images
└── docProps/
```

## Reading and Analyzing Content

### Text Extraction with markitdown

```bash
python -m markitdown path-to-file.pptx
```

### Raw XML Access (Advanced)

```bash
python ooxml/scripts/unpack.py <office_file> <output_dir>
```

Key files:
- `ppt/presentation.xml` - Main metadata
- `ppt/slides/slide{N}.xml` - Slide contents
- `ppt/notesSlides/notesSlide{N}.xml` - Speaker notes
- `ppt/slideLayouts/` - Layout templates

## Creating New Presentations

### PptxGenJS (JavaScript/TypeScript)

**IMPORTANT**: Read `html2pptx.md` completely before creating presentations.

#### Basic Example

```javascript
const pptxgen = require("pptxgenjs");

async function createPresentation() {
  const pres = new pptxgen();
  const slide = pres.addSlide();

  // Add text
  slide.addText("Hello World!", {
    x: 1,
    y: 1,
    w: 8,
    h: 1,
    color: "363636",
    fontSize: 36,
    bold: true
  });

  await pres.writeFile({ fileName: "output.pptx" });
}

createPresentation().catch(console.error);
```

#### Slide Dimensions

| Layout | Width | Height | Aspect Ratio |
|--------|-------|--------|--------------|
| LAYOUT_16x9 (default) | 10 in | 5.625 in | 16:9 |
| LAYOUT_16x10 | 10 in | 6.25 in | 16:10 |
| LAYOUT_4x3 | 10 in | 7.5 in | 4:3 |

#### Adding Text with Formatting

```javascript
// Simple text
slide.addText("Simple text", { x: 1, y: 1, w: 8, h: 0.5 });

// Mixed formatting (array of text objects)
slide.addText([
  { text: "Bold text", options: { bold: true } },
  { text: " and normal text", options: { bold: false } },
  { text: " and italic", options: { italic: true, color: "FF0000" } }
], { x: 1, y: 1, w: 8, h: 1 });

// Line breaks
slide.addText("Line 1\nLine 2\nLine 3", {
  x: 1, y: 1, w: 8, h: 1.5
});
```

#### Adding Tables

```javascript
const rows = [
  ["Header 1", "Header 2", "Header 3"],
  ["Cell 1", "Cell 2", "Cell 3"],
  ["Cell 4", "Cell 5", "Cell 6"]
];

slide.addTable(rows, {
  x: 0.5,
  y: 2,
  w: 9,
  colW: [3, 3, 3],
  border: { pt: 0.5, color: "CCCCCC" },
  fill: { color: "F9F9F9" },
  fontFace: "Arial",
  fontSize: 12
});
```

#### Adding Shapes

```javascript
// Rectangle
slide.addShape("rect", {
  x: 0.5,
  y: 0.5,
  w: 9,
  h: 0.1,
  fill: { color: "4A90D9" }
});

// Rounded rectangle with text
slide.addText("Click me", {
  shape: "roundRect",
  x: 3,
  y: 4,
  w: 4,
  h: 0.8,
  fill: { color: "4A90D9" },
  color: "FFFFFF",
  align: "center",
  valign: "middle"
});

// Circle
slide.addShape("ellipse", {
  x: 8,
  y: 0.5,
  w: 1,
  h: 1,
  fill: { color: "E74C3C" }
});
```

#### Adding Images

```javascript
// From file path
slide.addImage({
  path: "images/logo.png",
  x: 8.5,
  y: 0.3,
  w: 1,
  h: 0.5
});

// From base64
slide.addImage({
  data: "image/png;base64,iVBORw0KGgoAAAANSUhEUg...",
  x: 8.5,
  y: 0.3,
  w: 1,
  h: 0.5
});
```

#### Adding Charts

```javascript
const chartData = [
  {
    name: "Sales",
    labels: ["Jan", "Feb", "Mar", "Apr"],
    values: [1500, 4600, 5156, 3167]
  },
  {
    name: "Expenses",
    labels: ["Jan", "Feb", "Mar", "Apr"],
    values: [1000, 2600, 3456, 4567]
  }
];

slide.addChart(pres.ChartType.bar, chartData, {
  x: 0.5,
  y: 2,
  w: 9,
  h: 4,
  showTitle: true,
  title: "Sales vs Expenses",
  barDir: "col",
  chartColors: ["4A90D9", "E74C3C"]
});
```

Chart types: `area`, `bar`, `bar3d`, `bubble`, `doughnut`, `line`, `pie`, `radar`, `scatter`

#### Speaker Notes

```javascript
slide.addNotes("Speaker notes for this slide.\n\nAdd multiple paragraphs.");

// Or with formatting
slide.addNotes(`
  Key points to cover:
  1. First point
  2. Second point
  Time: ~5 minutes
`);
```

## Master Slides and Templates

### Creating Master Slides

```javascript
pres.defineSlideMaster({
  title: "CORPORATE_TEMPLATE",
  background: { color: "FFFFFF" },
  margin: [0.5, 0.75, 0.5, 0.75],
  objects: [
    {
      rect: {
        x: 0, y: 0, w: "100%", h: 0.75,
        fill: { color: "2C3E50" }
      }
    },
    {
      image: {
        x: 9, y: 0.15, w: 0.6, h: 0.45,
        path: "images/logo.png"
      }
    }
  ],
  slideNumber: { x: 0.3, y: "95%" }
});
```

### Using Master Slides

```javascript
const slide = pres.addSlide({ masterName: "CORPORATE_TEMPLATE" });

slide.addText("Report Title", {
  x: 0.5, y: 1.2, w: 9, h: 0.8,
  fontSize: 32, bold: true, color: "2C3E50"
});
```

## Creating from Template (python-pptx)

### Basic Template Usage

```python
from pptx import Presentation

prs = Presentation('template.pptx')

# Get slide layout
title_layout = prs.slide_layouts[0]
slide = prs.slides.add_slide(title_layout)

# Fill placeholders
title = slide.shapes.title
title.text = "Updated Title"

subtitle = slide.placeholders[1]
subtitle.text = "New subtitle"

prs.save('output.pptx')
```

### Extract Template Content

```bash
# Extract to markdown
python -m markitdown template.pptx > template-content.md

# Generate thumbnails
python scripts/thumbnail.py template.pptx
```

### Template-Based Workflow

1. **Extract content**: `python -m markitdown template.pptx > content.md`
2. **Generate thumbnails**: `python scripts/thumbnail.py template.pptx`
3. **Analyze and inventory**: Review structure, save to `template-inventory.md`
4. **Create outline**: Map slides to content
5. **Rearrange slides**: `python scripts/rearrange.py template.pptx working.pptx 0,34,50,52`
6. **Apply replacements**: `python scripts/replace.py working.pptx replacements.json output.pptx`

## Editing Existing Presentations

**IMPORTANT**: Read `ooxml.md` completely for advanced editing.

### python-pptx Editing

```python
from pptx import Presentation

prs = Presentation('existing.pptx')

for slide in prs.slides:
    for shape in slide.shapes:
        if shape.has_text_frame:
            for para in shape.text_frame.paragraphs:
                for run in para.runs:
                    if 'placeholder' in run.text:
                        run.text = run.text.replace('placeholder', 'new value')

prs.save('modified.pptx')
```

### Speaker Notes (python-pptx)

```python
# Add notes
notes_slide = slide.notes_slide
notes_text_frame = notes_slide.notes_text_frame
notes_text_frame.text = 'Speaker notes here'

# Extract notes
for slide in prs.slides:
    text_note = slide.notes_slide.notes_text_frame.text
    print(f"Slide notes: {text_note}")
```

### Raw XML Editing

```bash
# Unpack
python ooxml/scripts/unpack.py file.pptx unpacked/

# Edit XML files

# Validate
python ooxml/scripts/validate.py unpacked/ --original file.pptx

# Repack
python ooxml/scripts/pack.py unpacked/ output.pptx
```

## Creating Thumbnail Grids

```bash
python scripts/thumbnail.py template.pptx [output_prefix]
```

Options:
- `--cols 4`: Custom column count (3-6)
- Output: `thumbnails.jpg`

## Converting Slides to Images

```bash
# PPTX to PDF
soffice --headless --convert-to pdf template.pptx

# PDF to JPEG
pdftoppm -jpeg -r 150 template.pdf slide
```

## Common Patterns for Subagents

### Pattern 1: Batch Slide Generation

```javascript
async function generateSlidesFromData(data, template) {
  const pres = new pptxgen();

  for (const item of data) {
    const slide = pres.addSlide({ masterName: template });

    slide.addText(item.title, {
      x: 0.7, y: 0.5, w: 8.6, h: 0.8,
      fontSize: 28, bold: true
    });

    slide.addText(item.content, {
      x: 0.7, y: 1.8, w: 8.6, h: 3.5,
      fontSize: 16, color: "34495E"
    });

    slide.addText(`${data.indexOf(item) + 1} / ${data.length}`, {
      x: 9, y: 5.2, w: 0.8, h: 0.3,
      fontSize: 10, color: "95A5A6", align: "right"
    });
  }

  return pres;
}
```

### Pattern 2: Report Generation

```javascript
async function generateReport(reportData) {
  const pres = new pptxgen();

  // Title slide
  const titleSlide = pres.addSlide();
  titleSlide.addText(reportData.title, {
    x: 0.5, y: 2.5, w: 9, h: 1,
    fontSize: 40, bold: true, align: "center", color: "2C3E50"
  });
  titleSlide.addText(reportData.subtitle || "", {
    x: 0.5, y: 3.5, w: 9, h: 0.5,
    fontSize: 20, align: "center", color: "7F8C8D"
  });

  // Content slides
  for (const section of reportData.sections) {
    const slide = pres.addSlide();
    slide.addText(section.title, {
      x: 0.5, y: 0.5, w: 9, h: 0.7,
      fontSize: 28, bold: true, color: "2C3E50"
    });

    slide.addText(
      section.bullets.map((b, i) => ({
        text: b,
        options: {
          bullet: { type: "number", startAt: i + 1 },
          breakLine: i < section.bullets.length - 1
        }
      })),
      { x: 0.7, y: 1.5, w: 8.6, h: 3.5, fontSize: 16, color: "34495E" }
    );
  }

  await pres.writeFile({ fileName: reportData.outputPath });
  return reportData.outputPath;
}
```

### Pattern 3: Data Presentation with KPIs

```javascript
async function createDataPresentation(data) {
  const pres = new pptxgen();
  pres.layout = pres.LayoutType.wide;

  // KPI boxes
  const kpiData = [
    { label: "Revenue", value: "$1.2M", color: "27AE60" },
    { label: "Users", value: "15,000", color: "3498DB" },
    { label: "Growth", value: "+24%", color: "9B59B6" }
  ];

  const summarySlide = pres.addSlide();
  summarySlide.addText("Executive Summary", {
    x: 0.5, y: 0.5, w: 9, h: 0.8,
    fontSize: 32, bold: true
  });

  kpiData.forEach((kpi, i) => {
    const x = 0.5 + i * 3;
    summarySlide.addShape(pres.ShapeType.rect, {
      x: x, y: 1.5, w: 2.8, h: 1.5,
      fill: { color: kpi.color },
      shadow: { type: "outer", blur: 3, offset: 2, angle: 45, opacity: 0.2 }
    });
    summarySlide.addText(kpi.value, {
      x: x, y: 1.7, w: 2.8, h: 0.8,
      fontSize: 28, bold: true, color: "FFFFFF", align: "center"
    });
    summarySlide.addText(kpi.label, {
      x: x, y: 2.5, w: 2.8, h: 0.4,
      fontSize: 14, color: "FFFFFF", align: "center"
    });
  });

  // Chart slide
  const chartSlide = pres.addSlide();
  chartSlide.addChart(pres.ChartType.line, data.chartData, {
    x: 0.5, y: 0.5, w: 9, h: 4.5,
    showTitle: true, title: data.chartTitle || "Performance Trend"
  });

  return pres;
}
```

## Error Handling and Pitfalls

| Issue | Cause | Solution |
|-------|-------|----------|
| File corruption | Hex colors with `#` prefix | Use `0088CC` not `#0088CC` |
| Opacity ignored | Encoding in hex string | Use `opacity: 50` property |
| Shadow fails | Reusing shadow object | Create fresh shadow each time |
| Text not wrapping | Missing width parameter | Set explicit `w` width |
| FileNotFoundError | File path issues | Verify path with `os.path.exists()` |
| PermissionError | File in use | Close file in other programs, use temp copy |
| Invalid layout index | Layout doesn't exist | Check `len(prs.slide_layouts)` first |

### Error Handling Patterns

```javascript
// Safe file writing with error handling
async function safeCreatePresentation(data, outputPath) {
  try {
    const pres = new pptxgen();

    // Add slides
    for (const item of data) {
      const slide = pres.addSlide();
      // ... add content ...
    }

    // Write file
    await pres.writeFile({ fileName: outputPath });
    return { success: true, path: outputPath };

  } catch (error) {
    if (error.code === 'ENOENT') {
      return { success: false, error: 'Directory not found' };
    }
    return { success: false, error: error.message };
  }
}
```

```python
# Python error handling pattern
from pptx import Presentation
import os

def safe_load_pptx(file_path):
    """Load presentation with error handling."""
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"File not found: {file_path}")

    try:
        prs = Presentation(file_path)
        return prs
    except Exception as e:
        raise ValueError(f"Cannot open presentation: {e}")
```

### Shadow Helper

```javascript
function makeShadow() {
  return JSON.parse(JSON.stringify({
    type: "outer", angle: 90, blur: 3,
    color: "000000", offset: 1.8, opacity: 0.35
  }));
}

// Create fresh shadow for each shape
slide.addShape(pres.ShapeType.rect, { x: 1, y: 1, w: 2, h: 1, shadow: makeShadow() });
slide.addShape(pres.ShapeType.rect, { x: 4, y: 1, w: 2, h: 1, shadow: makeShadow() });
```

## Position and Size Reference

All dimensions in **inches**:

| Position | Value |
|----------|-------|
| Slide width | 10 in |
| Slide height (16:9) | 5.625 in |
| Safe margin | 0.5 in |
| Content width | 9 in |

## Quick Reference

| Task | Tool | Command/Code |
|------|------|--------------|
| Extract text | markitdown | `python -m markitdown file.pptx` |
| Create new (JS) | PptxGenJS | `new pptxgen()` then `addSlide()` |
| Create new (Python) | python-pptx | `Presentation()` then `slides.add_slide()` |
| Edit existing | python-pptx | Load template, modify shapes |
| Add speaker notes | PptxGenJS | `slide.addNotes('text')` |
| Add charts | PptxGenJS | `slide.addChart(pres.ChartType.bar, data)` |
| Add tables | PptxGenJS | `slide.addTable(rows, options)` |
| Template workflow | python-pptx | Use slide layouts and placeholders |
| Unpack for XML edit | ooxml scripts | See ooxml.md |
| Convert to images | LibreOffice + poppler | `soffice --headless --convert-to pdf` |

## Dependencies

| Tool | Purpose | Install Command |
|------|---------|-----------------|
| pptxgenjs | JS presentation creation | `npm install -g pptxgenjs` |
| python-pptx | Python presentation manipulation | `pip install python-pptx` |
| markitdown | Text extraction | `pip install "markitdown[pptx]"` |
| playwright | HTML to image | `npm install -g playwright` |
| sharp | Image processing | `npm install -g sharp` |
| LibreOffice | PDF conversion | Install from libreoffice.org |
| poppler-utils | PDF to image | Install via package manager |

## Best Practices

### Presentation Creation

1. **Pre-define master templates for corporate branding**
   - Define once, reuse many times
   - Avoid generating styles at runtime
   ```javascript
   pres.defineSlideMaster({
     title: "CORPORATE_TEMPLATE",
     background: { color: "FFFFFF" },
     margin: [0.5, 0.75, 0.5, 0.75],
     objects: [...]
   });
   ```

2. **Use placeholder names for content injection**
   - More reliable than position-based access
   - Consistent across slide layouts

3. **Use percent positioning for responsive layouts**
   ```javascript
   slide.addText("Text", { x: '50%', y: '20%', w: '80%' })
   ```

4. **Create fresh PptxGenJS instances per presentation**
   ```javascript
   // WRONG - Object reuse causes issues
   const pres = new PptxGenJS();
   // ... create slide1 ...
   // ... reuse pres for slide2 ...

   // CORRECT - Fresh instance per presentation
   async function generateReport(data) {
     const pres = new pptxgen();  // New instance
     // ... build presentation
     return pres;
   }
   ```

### Color and Formatting

5. **Never use `#` prefix in hex colors for PptxGenJS**
   ```javascript
   // WRONG
   slide.addShape({ fill: { color: "#0088CC" } })

   // CORRECT
   slide.addShape({ fill: { color: "0088CC" } })
   ```

6. **Use `opacity` property, not alpha in hex**
   ```javascript
   // WRONG
   { color: "FF0000AA" }  // Alpha ignored

   // CORRECT
   { color: "FF0000", opacity: 50 }
   ```

7. **Clone shadow objects for each shape**
   ```javascript
   function makeShadow() {
     return JSON.parse(JSON.stringify({ type: 'outer', blur: 3, offset: 2, angle: 45, color: '000000', opacity: 0.3 }));
   }
   slide.addShape({ shadow: makeShadow() });  // Fresh each time
   slide.addShape({ shadow: makeShadow() });  // Fresh each time
   ```

### Async/Await Patterns

8. **Always await writeFile()**
   ```javascript
   // WRONG - File may not be written
   pres.writeFile({ fileName: "out.pptx" });
   console.log("Done");  // May print before file written

   // CORRECT
   await pres.writeFile({ fileName: "out.pptx" });
   console.log("Done");  // File definitely written
   ```

9. **Use Promise.all for batch generation**
   ```javascript
   async function generateBatch(presentations) {
     const promises = presentations.map(data =>
       createPresentation(data).then(pres =>
         pres.writeFile({ fileName: `${data.id}.pptx` })
       )
     );
     await Promise.all(promises);
   }
   ```

### Slide Layout and Design

10. **Use consistent margins (0.5 in safe zone)**
    - Content inside 0.5 in from each edge
    - Gives 9 in x 5.625 in content area (16:9)

11. **Set explicit width for text wrapping**
    ```javascript
    // WRONG - Text won't wrap
    slide.addText("Long text that needs to wrap", { x: 1, y: 1 })

    // CORRECT - Width set
    slide.addText("Long text that needs to wrap", { x: 1, y: 1, w: 8 })
    ```

12. **Test slides at actual presentation size**
    - 10 in x 5.625 in at 96 DPI = 960 x 540 pixels

### Charts Best Practices

13. **Use appropriate chart types for data**
    - Bar/column for comparisons
    - Line for trends over time
    - Pie for proportion breakdown

14. **Set explicit chart dimensions and position**
    ```javascript
    slide.addChart(pres.ChartType.bar, data, {
      x: 0.5, y: 2, w: 9, h: 3.5,
      showTitle: true,
      showLegend: true
    });
    ```

## Related Files

- `html2pptx.md` - HTML to PowerPoint conversion guide
- `ooxml.md` - OOXML editing guide (advanced)
- `scripts/thumbnail.py` - Thumbnail generation
- `scripts/rearrange.py` - Slide rearrangement
- `scripts/replace.py` - Text replacement