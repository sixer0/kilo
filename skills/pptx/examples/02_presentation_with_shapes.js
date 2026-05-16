/**
 * PPTX Example 02: Presentation with Shapes
 */

const pptxgen = require("pptxgenjs");

async function createPresentationWithShapes() {
  const pres = new pptxgen();
  pres.layout = "LAYOUT_16x9";

  const slide = pres.addSlide();
  slide.background = { color: "F5F5F5" };

  slide.addShape("rect", {
    x: 0, y: 0, w: 10, h: 0.8,
    fill: { color: "2C3E50" }
  });
  slide.addText("Dashboard Overview", {
    x: 0.5, y: 0.15, w: 9, h: 0.5,
    fontSize: 24, bold: true, color: "FFFFFF"
  });

  const kpis = [
    { label: "Revenue", value: "$1.2M", color: "27AE60" },
    { label: "Users", value: "15,000", color: "3498DB" },
    { label: "Growth", value: "+24%", color: "9B59B6" }
  ];

  kpis.forEach((kpi, i) => {
    const x = 0.5 + i * 3.1;
    slide.addShape("roundRect", {
      x: x, y: 1.2, w: 2.8, h: 1.6,
      fill: { color: kpi.color },
      shadow: { type: "outer", blur: 3, offset: 2, angle: 45, opacity: 0.2 }
    });
    slide.addText(kpi.value, {
      x: x, y: 1.4, w: 2.8, h: 0.8,
      fontSize: 32, bold: true, color: "FFFFFF", align: "center"
    });
    slide.addText(kpi.label, {
      x: x, y: 2.2, w: 2.8, h: 0.5,
      fontSize: 14, color: "FFFFFF", align: "center"
    });
  });

  await pres.writeFile({ fileName: "example_02_shapes.pptx" });
  console.log("[OK] Created: example_02_shapes.pptx");
}

createPresentationWithShapes().catch(console.error);