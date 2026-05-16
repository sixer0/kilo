# PPTX Examples

This directory contains working examples for PowerPoint presentation processing.

## Examples Overview

| Example | Description | Complexity |
|---------|-------------|------------|
| `01_basic_presentation.js` | Create a simple presentation with slides and text | Beginner |
| `02_presentation_with_shapes.js` | Add shapes, colors, and visual elements | Beginner |
| `03_presentation_with_tables.js` | Create slides with data tables | Intermediate |
| `04_presentation_with_charts.js` | Add charts and data visualization | Intermediate |
| `05_template_based_presentation.js` | Use templates for consistent design | Intermediate |

## Quick Start

```bash
# Install dependencies
npm install pptxgenjs

# Run an example
node 01_basic_presentation.js

# Check output
ls -la *.pptx
```

## Requirements

- Node.js 14+
- pptxgenjs (`npm install -g pptxgenjs`)

## Examples

### Example 01: Basic Presentation

**File:** `01_basic_presentation.js`

```javascript
/**
 * PPTX Example 01: Basic Presentation
 *
 * Creates a simple presentation with title and content slides.
 */

const pptxgen = require("pptxgenjs");

async function createBasicPresentation() {
  const pres = new pptxgen();
  pres.layout = "LAYOUT_16x9";

  // Title slide
  const slide1 = pres.addSlide();
  slide1.addText("Welcome to the Report", {
    x: 0.5, y: 2, w: 9, h: 1,
    fontSize: 44, bold: true, color: "2C3E50",
    align: "center"
  });
  slide1.addText("Q4 2024 Performance Review", {
    x: 0.5, y: 3.2, w: 9, h: 0.6,
    fontSize: 24, color: "7F8C8D",
    align: "center"
  });

  // Content slide
  const slide2 = pres.addSlide();
  slide2.addText("Key Highlights", {
    x: 0.5, y: 0.5, w: 9, h: 0.8,
    fontSize: 32, bold: true, color: "2C3E50"
  });

  // Bullet points
  slide2.addText([
    { text: "Revenue increased by 24% year-over-year", options: { bullet: true, breakLine: true } },
    { text: "Customer satisfaction scores at all-time high", options: { bullet: true, breakLine: true } },
    { text: "New product launch successful", options: { bullet: true, breakLine: true } },
    { text: "International expansion on track", options: { bullet: true } }
  ], {
    x: 0.7, y: 1.5, w: 8.5, h: 3,
    fontSize: 20, color: "34495E"
  });

  // Save
  await pres.writeFile({ fileName: "example_01_basic.pptx" });
  console.log("[OK] Created: example_01_basic.pptx");
}

createBasicPresentation().catch(console.error);
```

### Example 02: Presentation with Shapes

**File:** `02_presentation_with_shapes.js`

```javascript
/**
 * PPTX Example 02: Presentation with Shapes
 *
 * Creates a presentation with colored shapes and visual elements.
 */

const pptxgen = require("pptxgenjs");

async function createPresentationWithShapes() {
  const pres = new pptxgen();
  pres.layout = "LAYOUT_16x9";

  const slide = pres.addSlide();
  slide.background = { color: "F5F5F5" };

  // Header bar
  slide.addShape("rect", {
    x: 0, y: 0, w: 10, h: 0.8,
    fill: { color: "2C3E50" }
  });
  slide.addText("Dashboard Overview", {
    x: 0.5, y: 0.15, w: 9, h: 0.5,
    fontSize: 24, bold: true, color: "FFFFFF"
  });

  // KPI boxes
  const kpis = [
    { label: "Revenue", value: "$1.2M", color: "27AE60" },
    { label: "Users", value: "15,000", color: "3498DB" },
    { label: "Growth", value: "+24%", color: "9B59B6" }
  ];

  kpis.forEach((kpi, i) => {
    const x = 0.5 + i * 3.1;
    // Box
    slide.addShape("roundRect", {
      x: x, y: 1.2, w: 2.8, h: 1.6,
      fill: { color: kpi.color },
      shadow: { type: "outer", blur: 3, offset: 2, angle: 45, opacity: 0.2 }
    });
    // Value
    slide.addText(kpi.value, {
      x: x, y: 1.4, w: 2.8, h: 0.8,
      fontSize: 32, bold: true, color: "FFFFFF", align: "center"
    });
    // Label
    slide.addText(kpi.label, {
      x: x, y: 2.2, w: 2.8, h: 0.5,
      fontSize: 14, color: "FFFFFF", align: "center"
    });
  });

  // Progress bar
  slide.addText("Project Progress", {
    x: 0.5, y: 3.2, w: 9, h: 0.4,
    fontSize: 18, bold: true, color: "2C3E50"
  });

  // Bar background
  slide.addShape("rect", {
    x: 0.5, y: 3.7, w: 9, h: 0.4,
    fill: { color: "E0E0E0" }
  });
  // Bar fill (75%)
  slide.addShape("rect", {
    x: 0.5, y: 3.7, w: 6.75, h: 0.4,
    fill: { color: "3498DB" }
  });
  slide.addText("75%", {
    x: 7.5, y: 3.65, w: 1, h: 0.5,
    fontSize: 14, bold: true, color: "2C3E50"
  });

  await pres.writeFile({ fileName: "example_02_shapes.pptx" });
  console.log("[OK] Created: example_02_shapes.pptx");
}

createPresentationWithShapes().catch(console.error);
```

### Example 03: Presentation with Tables

**File:** `03_presentation_with_tables.js`

```javascript
/**
 * PPTX Example 03: Presentation with Tables
 *
 * Creates a presentation with data tables.
 */

const pptxgen = require("pptxgenjs");

async function createPresentationWithTables() {
  const pres = new pptxgen();
  pres.layout = "LAYOUT_16x9";

  const slide = pres.addSlide();
  slide.addText("Quarterly Sales Report", {
    x: 0.5, y: 0.3, w: 9, h: 0.6,
    fontSize: 28, bold: true, color: "2C3E50"
  });

  // Sales data table
  const tableData = [
    [
      { text: "Region", options: { bold: true, fill: "2C3E50", color: "FFFFFF" } },
      { text: "Q1", options: { bold: true, fill: "2C3E50", color: "FFFFFF" } },
      { text: "Q2", options: { bold: true, fill: "2C3E50", color: "FFFFFF" } },
      { text: "Q3", options: { bold: true, fill: "2C3E50", color: "FFFFFF" } },
      { text: "Q4", options: { bold: true, fill: "2C3E50", color: "FFFFFF" } }
    ],
    ["North America", "$320K", "$380K", "$420K", "$480K"],
    ["Europe", "$280K", "$310K", "$350K", "$390K"],
    ["Asia Pacific", "$220K", "$260K", "$300K", "$360K"],
    [
      { text: "Total", options: { bold: true } },
      { text: "$820K", options: { bold: true } },
      { text: "$950K", options: { bold: true } },
      { text: "$1.07M", options: { bold: true } },
      { text: "$1.23M", options: { bold: true } }
    ]
  ];

  slide.addTable(tableData, {
    x: 0.5, y: 1.2, w: 9, h: 2.5,
    colW: [2, 1.5, 1.5, 1.5, 1.5],
    border: { pt: 0.5, color: "CCCCCC" },
    fontFace: "Arial",
    fontSize: 14,
    color: "2C3E50",
    align: "center",
    valign: "middle"
  });

  // Growth metrics table
  slide.addText("Year-over-Year Growth", {
    x: 0.5, y: 4, w: 9, h: 0.5,
    fontSize: 18, bold: true, color: "2C3E50"
  });

  const growthData = [
    [
      { text: "Metric", options: { bold: true, fill: "3498DB", color: "FFFFFF" } },
      { text: "2023", options: { bold: true, fill: "3498DB", color: "FFFFFF" } },
      { text: "2024", options: { bold: true, fill: "3498DB", color: "FFFFFF" } },
      { text: "Growth", options: { bold: true, fill: "3498DB", color: "FFFFFF" } }
    ],
    ["Revenue", "$3.2M", "$4.0M", "+25%"],
    ["Customers", "45K", "58K", "+29%"],
    ["ARPU", "$71", "$69", "-3%"]
  ];

  slide.addTable(growthData, {
    x: 0.5, y: 4.5, w: 9, h: 1.2,
    colW: [3, 2, 2, 2],
    border: { pt: 0.5, color: "CCCCCC" },
    fontFace: "Arial",
    fontSize: 12,
    align: "center"
  });

  await pres.writeFile({ fileName: "example_03_tables.pptx" });
  console.log("[OK] Created: example_03_tables.pptx");
}

createPresentationWithTables().catch(console.error);
```

### Example 04: Presentation with Charts

**File:** `04_presentation_with_charts.js`

```javascript
/**
 * PPTX Example 04: Presentation with Charts
 *
 * Creates a presentation with data visualization charts.
 */

const pptxgen = require("pptxgenjs");

async function createPresentationWithCharts() {
  const pres = new pptxgen();
  pres.layout = "LAYOUT_16x9";

  // Revenue chart slide
  const slide1 = pres.addSlide();
  slide1.addText("Revenue Performance", {
    x: 0.5, y: 0.3, w: 9, h: 0.6,
    fontSize: 28, bold: true, color: "2C3E50"
  });

  const revenueData = [
    {
      name: "Actual",
      labels: ["Jan", "Feb", "Mar", "Apr", "May", "Jun"],
      values: [1500, 4600, 5156, 3167, 5890, 7200]
    },
    {
      name: "Projected",
      labels: ["Jan", "Feb", "Mar", "Apr", "May", "Jun"],
      values: [1200, 3800, 4500, 2800, 5200, 6500]
    }
  ];

  slide1.addChart(pres.ChartType.bar, revenueData, {
    x: 0.5, y: 1, w: 5.5, h: 4,
    barDir: "col",
    showTitle: true,
    title: "Monthly Revenue (USD)",
    chartColors: ["27AE60", "3498DB"],
    catAxisLabelRotate: 45,
    valAxisLabelFormatCode: "$#,##0",
    showLegend: true,
    legendPos: "b"
  });

  // Pie chart
  slide1.addChart(pres.ChartType.doughnut, [{
    name: "Revenue",
    labels: ["Product A", "Product B", "Product C", "Services"],
    values: [35, 25, 20, 20]
  }], {
    x: 6.2, y: 1, w: 3.5, h: 4,
    showTitle: true,
    title: "Revenue by Product",
    chartColors: ["2C3E50", "3498DB", "27AE60", "9B59B6"],
    showLegend: true,
    legendPos: "b"
  });

  // Trend line chart slide
  const slide2 = pres.addSlide();
  slide2.addText("Growth Trends", {
    x: 0.5, y: 0.3, w: 9, h: 0.6,
    fontSize: 28, bold: true, color: "2C3E50"
  });

  const trendData = [
    {
      name: "Customers",
      labels: ["Q1", "Q2", "Q3", "Q4"],
      values: [45000, 52000, 55000, 58000]
    },
    {
      name: "Revenue (K)",
      labels: ["Q1", "Q2", "Q3", "Q4"],
      values: [3200, 3800, 4200, 4000]
    }
  ];

  slide2.addChart(pres.ChartType.line, trendData, {
    x: 0.5, y: 1, w: 9, h: 4,
    showTitle: true,
    title: "Quarterly Performance Trend",
    chartColors: ["3498DB", "27AE60"],
    lineSize: 2,
    lineSmooth: true,
    showLegend: true,
    catAxisLabelRotate: 0
  });

  await pres.writeFile({ fileName: "example_04_charts.pptx" });
  console.log("[OK] Created: example_04_charts.pptx");
}

createPresentationWithCharts().catch(console.error);
```

### Example 05: Template-Based Presentation

**File:** `05_template_based_presentation.js`

```javascript
/**
 * PPTX Example 05: Template-Based Presentation
 *
 * Creates presentations using predefined master slides.
 */

const pptxgen = require("pptxgenjs");

async function createTemplatePresentation() {
  const pres = new pptxgen();

  // Define master template
  pres.defineSlideMaster({
    title: "CORPORATE",
    background: { color: "FFFFFF" },
    margin: 0.5
  });

  // Add header bar to master
  const headerSlide = pres.addSlide({ masterName: "CORPORATE" });
  headerSlide.addShape("rect", {
    x: 0, y: 0, w: 10, h: 0.6,
    fill: { color: "2C3E50" }
  });
  headerSlide.addText("Corporate Report", {
    x: 0.5, y: 0.1, w: 9, h: 0.4,
    fontSize: 16, bold: true, color: "FFFFFF"
  });

  // Generate slides from data
  const sections = [
    { title: "Executive Summary", bullets: ["Key metric 1", "Key metric 2", "Key metric 3"] },
    { title: "Financial Overview", bullets: ["Revenue growth", "Cost reduction", "Profit margin"] },
    { title: "Market Analysis", bullets: ["Market size", "Competitor analysis", "Opportunities"] },
    { title: "Next Steps", bullets: ["Action item 1", "Action item 2", "Action item 3"] }
  ];

  for (let i = 0; i < sections.length; i++) {
    const slide = pres.addSlide({ masterName: "CORPORATE" });

    // Section number
    slide.addText(`0${i + 1}`, {
      x: 0.5, y: 1, w: 1, h: 0.8,
      fontSize: 48, bold: true, color: "3498DB"
    });

    // Section title
    slide.addText(sections[i].title, {
      x: 1.5, y: 1, w: 8, h: 0.8,
      fontSize: 32, bold: true, color: "2C3E50"
    });

    // Bullets
    slide.addText(
      sections[i].bullets.map((b, idx) => ({
        text: b,
        options: { bullet: true, breakLine: idx < sections[i].bullets.length - 1 }
      })),
      {
        x: 1.5, y: 2, w: 8, h: 3,
        fontSize: 20, color: "34495E"
      }
    );

    // Footer
    slide.addText(`${i + 1} / ${sections.length}`, {
      x: 9, y: 5.2, w: 0.5, h: 0.3,
      fontSize: 10, color: "95A5A6", align: "right"
    });
  }

  await pres.writeFile({ fileName: "example_05_template.pptx" });
  console.log("[OK] Created: example_05_template.pptx");
}

createTemplatePresentation().catch(console.error);
```

## Batch Processing

For batch processing, use the batch utility scripts in the parent `scripts/` directory.

## Note

All examples use `await pres.writeFile()` to ensure files are completely written before the script exits.