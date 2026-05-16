/**
 * PPTX Example 03: Presentation with Tables
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

  const tableData = [
    [
      { text: "Region", options: { bold: true, fill: "2C3E50", color: "FFFFFF" } },
      { text: "Q1", options: { bold: true, fill: "2C3E50", color: "FFFFFF" } },
      { text: "Q2", options: { bold: true, fill: "2C3E50", color: "FFFFFF" } },
      { text: "Q3", options: { bold: true, fill: "2C3E50", color: "FFFFFF" } }
    ],
    ["North America", "$320K", "$380K", "$420K"],
    ["Europe", "$280K", "$310K", "$350K"],
    ["Asia Pacific", "$220K", "$260K", "$300K"]
  ];

  slide.addTable(tableData, {
    x: 0.5, y: 1.2, w: 9, h: 2,
    colW: [2.5, 2, 2, 2.5],
    border: { pt: 0.5, color: "CCCCCC" },
    fontFace: "Arial", fontSize: 14, align: "center"
  });

  await pres.writeFile({ fileName: "example_03_tables.pptx" });
  console.log("[OK] Created: example_03_tables.pptx");
}

createPresentationWithTables().catch(console.error);