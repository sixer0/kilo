# docx-js Document Creation Guide

## Overview

docx-js (or simply `docx`) is a JavaScript/TypeScript library for creating Microsoft Word documents (.docx) without requiring Microsoft Word. This guide covers the API and patterns for agent-based document generation.

## Installation

```bash
npm install docx
```

## Basic Document Creation

### Hello World

```javascript
const { Document, Packer, Paragraph, TextRun } = require("docx");
const fs = require("fs");

async function createDocument() {
  const doc = new Document({
    sections: [{
      properties: {},
      children: [
        new Paragraph({
          children: [
            new TextRun("Hello World!")
          ]
        })
      ]
    }]
  });

  const buffer = await Packer.toBuffer(doc);
  fs.writeFileSync("output.docx", buffer);
  console.log("Document created!");
}

createDocument().catch(console.error);
```

### Document Structure

```javascript
const { Document, Packer, Paragraph, TextRun, HeadingLevel } = require("docx");

async function createFormattedDoc() {
  const doc = new Document({
    creator: "Kilo Agent",
    title: "Report",
    description: "Generated report document",
    sections: [{
      properties: {
        page: {
          margin: {
            top: 1440,    // 1 inch in twips (1 inch = 1440 twips)
            right: 1440,
            bottom: 1440,
            left: 1440
          }
        }
      },
      children: [
        // Heading
        new Paragraph({
          text: "Document Title",
          heading: HeadingLevel.HEADING_1,
          spacing: { after: 200 }
        }),

        // Paragraph with mixed formatting
        new Paragraph({
          children: [
            new TextRun({
              text: "Bold text",
              bold: true
            }),
            new TextRun({
              text: " and normal text"
            }),
            new TextRun({
              text: " and italic text",
              italics: true
            })
          ]
        })
      ]
    }]
  });

  await Packer.toBuffer(doc).then(buffer => {
    fs.writeFileSync("report.docx", buffer);
  });
}
```

## Text and Paragraphs

### Paragraph Options

```javascript
const { Paragraph, TextRun, AlignmentType, BorderStyle } = require("docx");

// Simple paragraph
new Paragraph({
  text: "Simple text"
});

// Paragraph with alignment
new Paragraph({
  text: "Centered text",
  alignment: AlignmentType.CENTER
});

// Paragraph with spacing
new Paragraph({
  text: "Spaced paragraph",
  spacing: {
    before: 400,   // Before in twips (20pt)
    after: 400,    // After in twips
    line: 276      // Line spacing (1.15x)
  }
});

// Paragraph with border
new Paragraph({
  text: "Bordered paragraph",
  border: {
    bottom: {
      color: "auto",
      space: 1,
      style: BorderStyle.SINGLE,
      size: 6
    }
  }
});

// Paragraph with indent
new Paragraph({
  text: "Indented paragraph",
  indent: {
    left: 720,     // 0.5 inch
    hanging: 360   // Hanging indent
  }
});
```

### Text Runs (Inline Formatting)

```javascript
const { TextRun } = require("docx");

// Basic text run
new TextRun("Plain text")

// Bold
new TextRun({ text: "Bold text", bold: true })

// Italic
new TextRun({ text: "Italic text", italics: true })

// Underline
new TextRun({ text: "Underlined text", underline: {} })

// Strikethrough
new TextRun({ text: "Strikethrough", strike: true })

// Color
new TextRun({ text: "Colored text", color: "FF0000" })

// Size (in half-points, so 24 = 12pt)
new TextRun({ text: "Large text", size: 48 })

// Font
new TextRun({ text: "Custom font", font: "Arial" })

// Multiple formats
new TextRun({
  text: "Complex formatting",
  bold: true,
  italics: true,
  underline: {},
  color: "0000FF",
  size: 24,
  font: "Times New Roman"
})
```

### Mixed Formatting

```javascript
new Paragraph({
  children: [
    new TextRun({ text: "Name: ", bold: true }),
    new TextRun("John Doe"),
    new TextRun({ text: "  |  Email: ", bold: true }),
    new TextRun("john@example.com")
  ]
})
```

## Headings

```javascript
const { Paragraph, TextRun, HeadingLevel } = require("docx");

// Using heading level
new Paragraph({
  text: "Chapter 1",
  heading: HeadingLevel.HEADING_1
})

new Paragraph({
  text: "Section 1.1",
  heading: HeadingLevel.HEADING_2
})

// Manual heading style
new Paragraph({
  children: [
    new TextRun({
      text: "Manual Heading",
      bold: true,
      size: 32,
      font: "Arial"
    })
  ],
  spacing: { before: 480, after: 240 }
})
```

## Lists

### Bulleted List

```javascript
const { Paragraph, TextRun, IndentType } = require("docx");

const bulletItems = [
  "First item",
  "Second item",
  "Third item"
];

bulletItems.map(item => (
  new Paragraph({
    text: item,
    bullet: {
      level: 0
    },
    indent: {
      left: 720,
      hanging: 360
    }
  })
))

// Nested bullet list
new Paragraph({
  text: "Sub-item",
  bullet: {
    level: 1  // Second level indent
  }
})
```

### Numbered List

```javascript
new Paragraph({
  text: "First numbered item",
  numbering: {
    reference: "my-numbering",
    level: 0
  }
})

new Paragraph({
  text: "Second numbered item",
  numbering: {
    reference: "my-numbering",
    level: 0
  }
})

// In Document definition:
const doc = new Document({
  numbering: {
    config: [{
      reference: "my-numbering",
      levels: [{
        level: 0,
        format: "decimal",
        text: "%1.",
        alignment: AlignmentType.START,
        style: {
          paragraph: {
            indent: {
              left: 720,
              hanging: 360
            }
          }
        }
      }]
    }]
  },
  sections: [{ children: [...] }]
})
```

## Tables

### Basic Table

```javascript
const { Table, Row, Cell, WidthType, BorderStyle } = require("docx");

const table = new Table({
  width: { size: 100, type: WidthType.PERCENTAGE },
  rows: [
    // Header row
    new Row({
      children: [
        new Cell({
          children: [new Paragraph({ text: "Header 1" })],
          shading: { fill: "4A90D9" }
        }),
        new Cell({
          children: [new Paragraph({ text: "Header 2" })],
          shading: { fill: "4A90D9" }
        })
      ]
    }),
    // Data row
    new Row({
      children: [
        new Cell({
          children: [new Paragraph({ text: "Cell 1" })]
        }),
        new Cell({
          children: [new Paragraph({ text: "Cell 2" })]
        })
      ]
    })
  ]
})
```

### Table with Formatting

```javascript
const { Table, Row, Cell, WidthType, AlignmentType, BorderStyle } = require("docx");

const formattedTable = new Table({
  width: { size: 100, type: WidthType.PERCENTAGE },
  borders: {
    top: { style: BorderStyle.SINGLE, size: 1, color: "CCCCCC" },
    bottom: { style: BorderStyle.SINGLE, size: 1, color: "CCCCCC" },
    left: { style: BorderStyle.SINGLE, size: 1, color: "CCCCCC" },
    right: { style: BorderStyle.SINGLE, size: 1, color: "CCCCCC" }
  },
  rows: [
    new Row({
      children: [
        new Cell({
          children: [new Paragraph({ text: "Name", alignment: AlignmentType.CENTER })],
          width: { size: 25, type: WidthType.PERCENTAGE },
          shading: { fill: "F0F0F0" }
        }),
        new Cell({
          children: [new Paragraph({ text: "Value", alignment: AlignmentType.CENTER })],
          width: { size: 75, type: WidthType.PERCENTAGE },
          shading: { fill: "F0F0F0" }
        })
      ]
    })
  ]
})
```

### Dynamic Table from Data

```javascript
function createTableFromData(data, headers) {
  const { Table, Row, Cell, WidthType } = require("docx");

  // Header row
  const headerRow = new Row({
    children: headers.map(h => new Cell({
      children: [new Paragraph({ text: h })],
      shading: { fill: "2C3E50" }
    }))
  });

  // Data rows
  const dataRows = data.map(rowData =>
    new Row({
      children: headers.map(h => new Cell({
        children: [new Paragraph({ text: String(rowData[h] || "") })]
      }))
    })
  );

  return new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    rows: [headerRow, ...dataRows]
  });
}
```

## Images

```javascript
const { Paragraph, ImageRun, Table, Row, Cell } = require("docx");
const fs = require("fs");

// Inline image
new Paragraph({
  children: [
    new ImageRun({
      data: fs.readFileSync("image.png"),
      transformation: {
        width: 300,
        height: 200
      }
    })
  ]
})

// Image from URL (fetch first)
async function addImageFromUrl(url) {
  const response = await fetch(url);
  const buffer = await response.arrayBuffer();

  return new ImageRun({
    data: Buffer.from(buffer),
    transformation: {
      width: 300,
      height: 200
    }
  });
}
```

## Headers and Footers

```javascript
const { Document, Header, Footer, Paragraph, TextRun } = require("docx");

const doc = new Document({
  sections: [{
    headers: {
      default: new Header({
        children: [
          new Paragraph({
            children: [
              new TextRun({ text: "Document Title", italics: true })
            ],
            alignment: AlignmentType.RIGHT
          })
        ]
      })
    },
    footers: {
      default: new Footer({
        children: [
          new Paragraph({
            children: [
              new TextRun({ text: "Page ", size: 20 }),
              // Page number requires special handling
            ],
            alignment: AlignmentType.CENTER
          })
        ]
      })
    },
    children: [
      // Document content
    ]
  }]
})
```

## Page Breaks

```javascript
const { Paragraph, PageBreak } = require("docx");

// Manual page break
new Paragraph({
  children: [new PageBreak()]
})

// Using spacing (soft break approach)
new Paragraph({
  text: "",
  spacing: { after: 400 }
})
```

## Document Properties

```javascript
const doc = new Document({
  creator: "Kilo Agent",
  title: "Generated Report",
  subject: "Q4 Sales Report",
  keywords: "sales, report, quarterly",
  description: "Auto-generated quarterly sales report",
  styles: {
    default: {
      document: {
        run: {
          font: "Arial",
          size: 24  // 12pt
        }
      }
    }
  },
  sections: [{ children: [] }]
})
```

## Complex Example: Report Generation

```javascript
const {
  Document, Packer, Paragraph, TextRun, Table, Row, Cell,
  HeadingLevel, AlignmentType, WidthType, BorderStyle, Header, Footer
} = require("docx");
const fs = require("fs");

async function generateReport(reportData) {
  const doc = new Document({
    creator: "Kilo Agent",
    title: reportData.title,

    // Numbering for lists
    numbering: {
      config: [{
        reference: "bullet-list",
        levels: [{
          level: 0,
          format: "bullet",
          text: "•",
          alignment: AlignmentType.START,
          style: {
            paragraph: { indent: { left: 720, hanging: 360 } }
          }
        }]
      }]
    },

    // Default styles
    styles: {
      default: {
        document: {
          run: { font: "Arial", size: 24 }
        }
      }
    },

    sections: [{
      // Header for each section
      headers: {
        default: new Header({
          children: [new Paragraph({
            children: [new TextRun({ text: reportData.title, italics: true })],
            alignment: AlignmentType.RIGHT
          })]
        })
      },

      // Footer for each section
      footers: {
        default: new Footer({
          children: [new Paragraph({
            children: [new TextRun({ text: "Generated by Kilo Agent", size: 18 })],
            alignment: AlignmentType.CENTER
          })]
        })
      },

      properties: {
        page: {
          margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 }
        }
      },

      children: [
        // Title
        new Paragraph({
          text: reportData.title,
          heading: HeadingLevel.HEADING_1,
          alignment: AlignmentType.CENTER,
          spacing: { after: 400 }
        }),

        // Subtitle
        new Paragraph({
          children: [new TextRun({ text: reportData.subtitle, italics: true })],
          alignment: AlignmentType.CENTER,
          spacing: { after: 600 }
        }),

        // Summary section
        new Paragraph({
          text: "Executive Summary",
          heading: HeadingLevel.HEADING_2,
          spacing: { before: 400, after: 200 }
        }),

        new Paragraph({
          children: [new TextRun({ text: reportData.summary })]
        }),

        // Data table
        new Paragraph({
          text: "Data",
          heading: HeadingLevel.HEADING_2,
          spacing: { before: 600, after: 200 }
        }),

        // Table from data
        new Table({
          width: { size: 100, type: WidthType.PERCENTAGE },
          rows: [
            new Row({
              children: [
                new Cell({ children: [new Paragraph({ text: "Item" })], shading: { fill: "4A90D9" } }),
                new Cell({ children: [new Paragraph({ text: "Value" })], shading: { fill: "4A90D9" } })
              ]
            }),
            ...reportData.items.map(item => new Row({
              children: [
                new Cell({ children: [new Paragraph({ text: item.name })] }),
                new Cell({ children: [new Paragraph({ text: String(item.value) })] })
              ]
            }))
          ]
        }),

        // Bullet points
        new Paragraph({
          text: "Key Points",
          heading: HeadingLevel.HEADING_2,
          spacing: { before: 600, after: 200 }
        }),

        ...reportData.keyPoints.map(point => new Paragraph({
          text: point,
          numbering: { reference: "bullet-list", level: 0 }
        }))
      ]
    }]
  });

  const buffer = await Packer.toBuffer(doc);
  fs.writeFileSync(reportData.outputPath, buffer);
  return reportData.outputPath;
}

// Usage
generateReport({
  title: "Q4 Sales Report",
  subtitle: "October - December 2024",
  summary: "This report summarizes sales performance for Q4 2024...",
  items: [
    { name: "Revenue", value: "$1.2M" },
    { name: "Growth", value: "+24%" }
  ],
  keyPoints: [
    "Strong growth in enterprise segment",
    "New product launch successful",
    "International expansion on track"
  ],
  outputPath: "Q4_Report.docx"
}).then(() => console.log("Report generated!"));
```

## Common Patterns for Subagents

### Pattern 1: Template-Based Generation

```javascript
async function generateFromTemplate(data, outputPath) {
  const { Document, Packer, Paragraph, TextRun } = require("docx");

  const doc = new Document({
    sections: [{
      children: data.map(item => new Paragraph({
        children: [
          new TextRun({ text: item.label + ": ", bold: true }),
          new TextRun(String(item.value))
        ]
      }))
    }]
  });

  const buffer = await Packer.toBuffer(doc);
  fs.writeFileSync(outputPath, buffer);
}
```

### Pattern 2: Batch Document Generation

```javascript
async function generateBatch(items, template, outputDir) {
  const fs = require("fs");
  const results = [];

  for (const item of items) {
    const doc = new Document({
      sections: [{
        children: [
          new Paragraph({ text: item.title }),
          new Paragraph({ text: item.content })
        ]
      }]
    });

    const buffer = await Packer.toBuffer(doc);
    const outputPath = `${outputDir}/${item.id}.docx`;
    fs.writeFileSync(outputPath, buffer);
    results.push(outputPath);
  }

  return results;
}
```

### Pattern 3: Document with Table of Contents

```javascript
async function generateWithTOC(sections, outputPath) {
  const { Document, Packer, Paragraph, TextRun, HeadingLevel } = require("docx");

  const children = [];

  // Add TOC header
  children.push(new Paragraph({
    text: "Table of Contents",
    heading: HeadingLevel.HEADING_1
  }));

  // Add sections with page breaks
  sections.forEach((section, idx) => {
    children.push(new Paragraph({
      text: `${idx + 1}. ${section.title}`,
      heading: HeadingLevel.HEADING_2
    }));

    children.push(new Paragraph({
      children: section.content.map(c => new TextRun(c))
    }));

    if (idx < sections.length - 1) {
      children.push(new Paragraph({ children: [new PageBreak()] }));
    }
  });

  const doc = new Document({
    sections: [{ children }]
  });

  const buffer = await Packer.toBuffer(doc);
  fs.writeFileSync(outputPath, buffer);
}
```

## Dependencies

| Tool | Purpose | Install Command |
|------|---------|-----------------|
| docx | Document generation | `npm install docx` |
| Node.js | Runtime | Install from nodejs.org |

## Related Files

- `SKILL.md` - Main docx skill documentation
- `ooxml.md` - OOXML editing guide (for advanced manipulation)