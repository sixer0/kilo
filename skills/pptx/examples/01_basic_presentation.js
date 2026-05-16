/**
 * PPTX Example 01: Basic Presentation
 */

const pptxgen = require("pptxgenjs");

async function createBasicPresentation() {
  const pres = new pptxgen();
  pres.layout = "LAYOUT_16x9";

  const slide1 = pres.addSlide();
  slide1.addText("Welcome to the Report", {
    x: 0.5, y: 2, w: 9, h: 1,
    fontSize: 44, bold: true, color: "2C3E50", align: "center"
  });
  slide1.addText("Q4 2024 Performance Review", {
    x: 0.5, y: 3.2, w: 9, h: 0.6,
    fontSize: 24, color: "7F8C8D", align: "center"
  });

  const slide2 = pres.addSlide();
  slide2.addText("Key Highlights", {
    x: 0.5, y: 0.5, w: 9, h: 0.8,
    fontSize: 32, bold: true, color: "2C3E50"
  });
  slide2.addText([
    { text: "Revenue increased by 24%", options: { bullet: true, breakLine: true } },
    { text: "Customer satisfaction high", options: { bullet: true, breakLine: true } },
    { text: "New product launch successful", options: { bullet: true } }
  ], { x: 0.7, y: 1.5, w: 8.5, h: 3, fontSize: 20, color: "34495E" });

  await pres.writeFile({ fileName: "example_01_basic.pptx" });
  console.log("[OK] Created: example_01_basic.pptx");
}

createBasicPresentation().catch(console.error);