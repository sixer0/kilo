# HTML to PowerPoint Conversion Guide

## Overview

This guide covers the **html2pptx** workflow for converting HTML content into PowerPoint presentations using PptxGenJS. This is the recommended approach for creating presentations from scratch.

## Quick Start

### Installation

```bash
npm install -g pptxgenjs
```

### Basic Example

```javascript
const pptxgen = require("pptxgenjs");

async function createPresentation() {
  const pres = new pptxgen();
  const slide = pres.addSlide();

  // Add text with formatting
  slide.addText("Hello World!", {
    x: 1,
    y: 1,
    w: 8,
    h: 1,
    color: "363636",
    fontSize: 36,
    bold: true
  });

  // Save presentation
  await pres.writeFile({ fileName: "output.pptx" });
  console.log("Presentation created!");
}

createPresentation().catch(console.error);
```

## Slide Dimensions

| Layout | Width | Height | Aspect Ratio |
|--------|-------|--------|--------------|
| **LAYOUT_16x9 (default)** | 10 in | 5.625 in | 16:9 |
| LAYOUT_16x10 | 10 in | 6.25 in | 16:10 |
| LAYOUT_4x3 | 10 in | 7.5 in | 4:3 |

## Creating Slides from HTML

### HTML Slide Template

Create one HTML file per slide (720pt × 405pt for 16:9):

```html
<!DOCTYPE html>
<html>
<head>
  <style>
    body {
      margin: 0;
      padding: 0;
      width: 720pt;
      height: 405pt;
      font-family: Arial, sans-serif;
      background: #ffffff;
    }
    .title {
      font-size: 28pt;
      font-weight: bold;
      color: #2c3e50;
      position: absolute;
      top: 50pt;
      left: 50pt;
      width: 620pt;
    }
    .content {
      font-size: 18pt;
      color: #34495e;
      position: absolute;
      top: 150pt;
      left: 50pt;
      width: 620pt;
    }
  </style>
</head>
<body>
  <div class="title">Slide Title</div>
  <div class="content">Slide content goes here</div>
</body>
</html>
```

### Conversion Script

```javascript
const pptxgen = require("pptxgenjs");
const fs = require("fs");
const path = require("path");

async function htmlToPptx(htmlFiles, outputFile) {
  const pres = new pptxgen();

  for (const htmlFile of htmlFiles) {
    const slide = pres.addSlide();

    // Parse HTML and add content
    const htmlContent = fs.readFileSync(htmlFile, "utf-8");

    // Extract title (simplified - in production use a proper HTML parser)
    const titleMatch = htmlContent.match(/class="title"[^>]*>([^<]+)/);
    const contentMatch = htmlContent.match(/class="content"[^>]*>([^<]+)/);

    if (titleMatch) {
      slide.addText(titleMatch[1], {
        x: 0.7,
        y: 0.7,
        w: 8.6,
        h: 0.8,
        fontSize: 28,
        bold: true,
        color: "2C3E50"
      });
    }

    if (contentMatch) {
      slide.addText(contentMatch[1], {
        x: 0.7,
        y: 2.1,
        w: 8.6,
        h: 3,
        fontSize: 18,
        color: "34495E"
      });
    }
  }

  await pres.writeFile({ fileName: outputFile });
  console.log(`Created: ${outputFile}`);
}

// Usage
htmlToPptx(["slide1.html", "slide2.html"], "presentation.pptx");
```

## Working with PptxGenJS API

### Text API

#### Simple text
```javascript
slide.addText("Simple text", {
  x: 1,
  y: 1,
  w: 8,
  h: 0.5
});
```

#### Mixed formatting (array of text objects)
```javascript
slide.addText([
  { text: "Bold text", options: { bold: true } },
  { text: " and normal text", options: { bold: false } },
  { text: " and italic text", options: { italic: true, color: "FF0000" } }
], {
  x: 1,
  y: 1,
  w: 8,
  h: 1
});
```

#### Line breaks
```javascript
slide.addText("Line 1\nLine 2\nLine 3", {
  x: 1,
  y: 1,
  w: 8,
  h: 1.5
});
```

### Table API

#### Simple table
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

#### Table with cell-level formatting
```javascript
const rows = [
  [
    { text: "Name", options: { bold: true, fill: "4A90D9", color: "FFFFFF" } },
    { text: "Value", options: { bold: true, fill: "4A90D9", color: "FFFFFF" } }
  ],
  [
    { text: "Item 1", options: { align: "left" } },
    { text: "$100", options: { align: "right" } }
  ]
];

slide.addTable(rows, {
  x: 0.5,
  y: 2,
  w: 9
});
```

### Shape API

#### Rectangles and shapes
```javascript
// Solid rectangle
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

// Circle/ellipse
slide.addShape("ellipse", {
  x: 8,
  y: 0.5,
  w: 1,
  h: 1,
  fill: { color: "E74C3C" }
});
```

### Image API

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
  data: "image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAAB...",
  x: 8.5,
  y: 0.3,
  w: 1,
  h: 0.5
});

// From URL
slide.addImage({
  url: "https://example.com/image.png",
  x: 8.5,
  y: 0.3,
  w: 1,
  h: 0.5
});
```

### Chart API

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

**Available chart types:**
- `area`, `bar`, `bar3d`, `bubble`, `doughnut`
- `line`, `pie`, `radar`, `scatter`

### Speaker Notes

```javascript
slide.addNotes("Speaker notes for this slide go here.\n\nAdd multiple paragraphs.");

slide.addNotes(`
  Key points to cover:
  1. First point
  2. Second point
  3. Third point

  Time: ~5 minutes
`);
```

## Master Slides and Layouts

### Creating Master Slides

```javascript
// Define a master slide layout
pres.defineSlideMaster({
  title: "CORPORATE_TEMPLATE",
  background: { color: "FFFFFF" },
  margin: [0.5, 0.75, 0.5, 0.75],
  objects: [
    // Header bar
    {
      rect: {
        x: 0,
        y: 0,
        w: "100%",
        h: 0.75,
        fill: { color: "2C3E50" }
      }
    },
    // Logo placeholder
    {
      image: {
        x: 9,
        y: 0.15,
        w: 0.6,
        h: 0.45,
        path: "images/logo.png"
      }
    },
    // Footer text
    {
      text: "Confidential",
      options: {
        x: 0.5,
        y: 5.3,
        w: 9,
        fontSize: 10,
        color: "95A5A6"
      }
    }
  ],
  slideNumber: {
    x: 0.3,
    y: "95%"
  }
});
```

### Using Master Slides

```javascript
// Create slide from master
const slide = pres.addSlide({ masterName: "CORPORATE_TEMPLATE" });

// Add content on top of master
slide.addText("Report Title", {
  x: 0.5,
  y: 1.2,
  w: 9,
  h: 0.8,
  fontSize: 32,
  bold: true,
  color: "2C3E50"
});

slide.addText("Q4 2024 Sales Performance", {
  x: 0.5,
  y: 2.2,
  w: 9,
  h: 0.5,
  fontSize: 18,
  color: "7F8C8D"
});
```

## Common Patterns for Subagents

### Pattern 1: Batch Slide Generation

```javascript
async function generateSlidesFromData(data, template) {
  const pres = new pptxgen();

  for (const item of data) {
    const slide = pres.addSlide({ masterName: template });

    // Add title
    slide.addText(item.title, {
      x: 0.7,
      y: 0.5,
      w: 8.6,
      h: 0.8,
      fontSize: 28,
      bold: true
    });

    // Add content
    slide.addText(item.content, {
      x: 0.7,
      y: 1.8,
      w: 8.6,
      h: 3.5,
      fontSize: 16,
      color: "34495E"
    });

    // Add page number
    slide.addText(`${data.indexOf(item) + 1} / ${data.length}`, {
      x: 9,
      y: 5.2,
      w: 0.8,
      h: 0.3,
      fontSize: 10,
      color: "95A5A6",
      align: "right"
    });
  }

  return pres;
}
```

### Pattern 2: Template-Based Report Generation

```javascript
async function generateReport(reportData) {
  const pres = new pptxgen();

  // Title slide
  const titleSlide = pres.addSlide();
  titleSlide.addText(reportData.title, {
    x: 0.5,
    y: 2.5,
    w: 9,
    h: 1,
    fontSize: 40,
    bold: true,
    align: "center",
    color: "2C3E50"
  });
  titleSlide.addText(reportData.subtitle || "", {
    x: 0.5,
    y: 3.5,
    w: 9,
    h: 0.5,
    fontSize: 20,
    align: "center",
    color: "7F8C8D"
  });

  // Content slides
  for (const section of reportData.sections) {
    const slide = pres.addSlide();
    slide.addText(section.title, {
      x: 0.5,
      y: 0.5,
      w: 9,
      h: 0.7,
      fontSize: 28,
      bold: true,
      color: "2C3E50"
    });

    // Add bullet points
    slide.addText(
      section.bullets.map((b, i) => ({
        text: b,
        options: {
          bullet: { type: "number", startAt: i + 1 },
          breakLine: i < section.bullets.length - 1
        }
      })),
      {
        x: 0.7,
        y: 1.5,
        w: 8.6,
        h: 3.5,
        fontSize: 16,
        color: "34495E"
      }
    );
  }

  await pres.writeFile({ fileName: reportData.outputPath });
  return reportData.outputPath;
}
```

### Pattern 3: Interactive Presentation with Data

```javascript
async function createDataPresentation(data) {
  const pres = new pptxgen();

  // Set layout
  pres.layout = pres.LayoutType.wide;

  // Executive summary slide
  const summarySlide = pres.addSlide();
  summarySlide.addText("Executive Summary", {
    x: 0.5,
    y: 0.5,
    w: 9,
    h: 0.8,
    fontSize: 32,
    bold: true
  });

  // KPI boxes
  const kpiData = [
    { label: "Revenue", value: "$1.2M", color: "27AE60" },
    { label: "Users", value: "15,000", color: "3498DB" },
    { label: "Growth", value: "+24%", color: "9B59B6" }
  ];

  kpiData.forEach((kpi, i) => {
    const x = 0.5 + i * 3;
    summarySlide.addShape(pres.ShapeType.rect, {
      x: x,
      y: 1.5,
      w: 2.8,
      h: 1.5,
      fill: { color: kpi.color },
      shadow: { type: "outer", blur: 3, offset: 2, angle: 45, opacity: 0.2 }
    });
    summarySlide.addText(kpi.value, {
      x: x,
      y: 1.7,
      w: 2.8,
      h: 0.8,
      fontSize: 28,
      bold: true,
      color: "FFFFFF",
      align: "center"
    });
    summarySlide.addText(kpi.label, {
      x: x,
      y: 2.5,
      w: 2.8,
      h: 0.4,
      fontSize: 14,
      color: "FFFFFF",
      align: "center"
    });
  });

  // Chart slide
  const chartSlide = pres.addSlide();
  chartSlide.addChart(pres.ChartType.line, data.chartData, {
    x: 0.5,
    y: 0.5,
    w: 9,
    h: 4.5,
    showTitle: true,
    title: data.chartTitle || "Performance Trend",
    showLegend: true,
    lineSize: 2
  });

  return pres;
}
```

## Error Handling

### Common Issues and Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| File corruption | Hex colors with `#` prefix | Use `0088CC` not `#0088CC` |
| Opacity ignored | Using hex in alpha channel | Use `opacity: 50` property |
| Shadow fails on shapes | Reusing shadow object | Create fresh shadow each time |
| Text not wrapping | Missing width parameter | Set explicit `w` width |

### Shadow Helper Function

```javascript
function makeShadow() {
  return JSON.parse(JSON.stringify({
    type: "outer",
    angle: 90,
    blur: 3,
    color: "000000",
    offset: 1.8,
    opacity: 0.35
  }));
}

// Use fresh shadow for each shape
slide.addShape(pres.ShapeType.rect, {
  x: 1,
  y: 1,
  w: 2,
  h: 1,
  shadow: makeShadow()
});
slide.addShape(pres.ShapeType.rect, {
  x: 4,
  y: 1,
  w: 2,
  h: 1,
  shadow: makeShadow()  // Fresh instance
});
```

## Position and Size Reference

All dimensions are in **inches**:

| Position | Value |
|----------|-------|
| Slide width | 10 in |
| Slide height (16:9) | 5.625 in |
| Safe margin | 0.5 in |
| Content width | 9 in |

### Grid System

```
x: 0    1    2    3    4    5    6    7    8    9   10
y:0 +----+----+----+----+----+----+----+----+----+----+
   |
y:1 |    <-- content starts at x=0.5, y=0.5 -->    |
   |
y:2 |                                                  |
   |
y:3 |                                                  |
   |
y:4 |                                                  |
   |
y:5 +------------------------------------------------+
y:6 |
```

## Dependencies

| Tool | Purpose | Install Command |
|------|---------|-----------------|
| pptxgenjs | Presentation generation | `npm install -g pptxgenjs` |
| Node.js | Runtime | Install from nodejs.org |

## Related Files

- `SKILL.md` - Main skill documentation
- `ooxml.md` - For raw XML editing (advanced)