# XLSX Spreadsheet Processing Guide

## Overview

This guide covers creating, editing, and analyzing Excel spreadsheets (.xlsx, .xlsm, .csv, .tsv) using Python. Designed for agent workflows with focus on formulas, formatting, data analysis, and visualization.

## Quick Reference

| Task | Tool | Code |
|------|------|------|
| Read data | pandas | `pd.read_excel('file.xlsx')` |
| Create workbook | openpyxl | `Workbook()` |
| Write formulas | openpyxl | `ws['A1'] = '=SUM(B1:B10)'` |
| Create charts | openpyxl | See Charts section |
| Recalculate | LibreOffice | `python scripts/recalc.py file.xlsx` |

## Installation

```bash
pip install openpyxl pandas
```

## Requirements for Outputs

### All Excel Files

- **Zero Formula Errors**: Every file MUST have zero errors (#REF!, #DIV/0!, #VALUE!, #N/A, #NAME?)
- **Preserve Templates**: Match existing format, style, and conventions when modifying files

### Financial Models Color Coding

| Color | RGB | Meaning |
|-------|-----|---------|
| Blue text | 0,0,255 | Hardcoded inputs |
| Black text | 0,0,0 | All formulas and calculations |
| Green text | 0,128,0 | Links from other worksheets |
| Red text | 255,0,0 | External links to other files |
| Yellow background | 255,255,0 | Key assumptions needing attention |

### Number Formatting

| Type | Format | Example |
|------|--------|---------|
| Years | Text | `"2024"` not `2,024` |
| Currency | `$#,##0` | With units in headers |
| Zeros | `$#,##0;($#,##0);-` | Display as `-` |
| Percentages | `0.0%` | Default format |
| Multiples | `0.0x` | Growth metrics |
| Negative | Parentheses | `(123)` not `-123` |

## Reading and Analyzing Data

### Basic Read with pandas

```python
import pandas as pd

# Read all sheets
xl = pd.ExcelFile('file.xlsx')
print(f"Sheets: {xl.sheet_names}")

# Read specific sheet
df = pd.read_excel('file.xlsx', sheet_name='Data')
print(df.head())

# Read with headers
df = pd.read_excel('file.xlsx', header=1)  # Row 2 as header

# Read multiple sheets
dfs = pd.read_excel('file.xlsx', sheet_name=None)
for name, data in dfs.items():
    print(f"Sheet: {name}, Rows: {len(data)}")
```

### Reading Formulas (Not Values)

```python
from openpyxl import load_workbook

# Load WITHOUT data_only to see formulas
wb = load_workbook('file.xlsx', data_only=False)
ws = wb.active

# Read formula
formula = ws['A1'].value  # Returns '=SUM(B1:B10)' or None

# Read calculated value (may be stale)
wb_data = load_workbook('file.xlsx', data_only=True)
value = wb_data.active['A1'].value  # Returns cached value or None
```

### Data Exploration

```python
import pandas as pd

df = pd.read_excel('sales.xlsx')

# Basic info
df.info()
df.describe()

# Find patterns
df[df['Revenue'] > 10000]
df.groupby('Region')['Sales'].sum()

# Export
df.to_excel('output.xlsx', index=False)
```

## Creating New Excel Files

### Basic Workbook

```python
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment

wb = Workbook()
ws = wb.active
ws.title = "Data"

# Add headers
ws['A1'] = 'Name'
ws['B1'] = 'Amount'
ws['C1'] = 'Date'

# Style header row
for cell in ws[1]:
    cell.font = Font(bold=True)
    cell.fill = PatternFill('solid', fgColor='4A90D9')
    cell.alignment = Alignment(horizontal='center')

# Add data
ws['A2'] = 'Item 1'
ws['B2'] = 1000
ws['C2'] = '2024-01-15'

# Add formula
ws['D1'] = 'Total'
ws['D2'] = '=SUM(B2:B100)'

wb.save('output.xlsx')
```

### With Column Widths and Row Heights

```python
from openpyxl import Workbook

wb = Workbook()
ws = wb.active

# Set column widths
ws.column_dimensions['A'].width = 20
ws.column_dimensions['B'].width = 15
ws.column_dimensions['C'].width = 12

# Set row height
ws.row_dimensions[1].height = 30

wb.save('formatted.xlsx')
```

### Merged Cells

```python
from openpyxl import Workbook

wb = Workbook()
ws = wb.active

# Merge cells
ws.merge_cells('A1:D1')
ws['A1'] = 'Merged Title'
ws['A1'].alignment = Alignment(horizontal='center', vertical='center')

# Unmerge
ws.unmerge_cells('A1:D1')
```

## Editing Existing Excel Files

### Load and Modify

```python
from openpyxl import load_workbook

wb = load_workbook('existing.xlsx')
ws = wb.active

# Update cell
ws['A1'] = 'New Value'

# Insert rows
ws.insert_rows(2)  # Insert at row 2

# Delete rows
ws.delete_rows(5)  # Delete row 5

# Preserve formulas (NEVER use data_only=True when saving)
wb.save('modified.xlsx')
```

### **CRITICAL: Formula Preservation**

```python
# WRONG - formulas will be replaced with values
wb = load_workbook('file.xlsx', data_only=True)
wb.save('output.xlsx')  # ALL FORMULAS LOST!

# CORRECT - formulas preserved
wb = load_workbook('file.xlsx', data_only=False)
# ... make changes ...
wb.save('output.xlsx')
```

### **CRITICAL: Use Formulas, Not Hardcoded Values**

```python
# WRONG
total = df['Sales'].sum()
sheet['B10'] = total  # Hardcodes calculated value

# CORRECT
sheet['B10'] = '=SUM(B2:B9)'  # Let Excel calculate
```

## Formula Handling

### Formula Reference

```python
# Basic arithmetic
ws['A1'] = '=B1+C1'
ws['A2'] = '=B2-C2'
ws['A3'] = '=B3*C3'
ws['A4'] = '=B4/C4'

# Common functions
ws['A1'] = '=SUM(A1:A10)'
ws['A2'] = '=AVERAGE(B1:B10)'
ws['A3'] = '=MAX(C1:C20)'
ws['A4'] = '=MIN(D1:D20)'
ws['A5'] = '=COUNT(E1:E100)'

# Conditional
ws['A1'] = '=IF(B1>100,"High","Low")'
ws['A2'] = '=IFERROR(A1/B1,0)'  # Handle division errors
ws['A3'] = '=IFS(C1>=90,"A",C1>=80,"B",TRUE,"C")'  # Multiple conditions

# Date functions
ws['A1'] = '=TODAY()'
ws['A2'] = '=NOW()'
ws['A3'] = '=YEAR(B1)'
ws['A4'] = '=MONTH(B1)'
ws['A5'] = '=DAY(B1)'

# Text functions
ws['A1'] = '=CONCAT(A1," ",B1)'
ws['A2'] = '=UPPER(C1)'
ws['A3'] = '=LOWER(D1)'
ws['A4'] = '=TRIM(E1)'
ws['A5'] = '=LEN(F1)'

# Lookup functions
ws['A1'] = '=VLOOKUP(E1,Sheet2!A:B,2,FALSE)'
ws['A2'] = '=INDEX(A1:C10,2,3)'
ws['A3'] = '=MATCH(B1,D1:D100,0)'
```

### Cross-Sheet References

```python
ws['A1'] = '=Sheet2!A1'
ws['A2'] = '=Sheet2!B2:C10'
ws['A3'] = '=SUM(Sheet2!A1:A100)'

# Sheet with spaces in name
ws['A1'] = "='Q4 Data'!A1"
ws['A2'] = "='Q4 Data'!B2"
```

### Formula Translation (Moving Formulas)

```python
from openpyxl.formulas.translate import Translator

# Move formula one column right
ws['G2'] = Translator("=SUM(B2:E2)", origin="F2").translate_formula("G2")
# Result: '=SUM(C2:F2)' - relative refs adjusted, absolute unchanged
```

### Unknown Excel Functions

For newer Excel functions not in openpyxl's vocabulary:

```python
# Prefix with _xlfn.
ws['A1'] = '=_xlfn.IFERROR(A1/B1,0)'
ws['A2'] = '=_xlfn.CONCAT(A1," ",B1)'
```

### Array Formulas

```python
from openpyxl.worksheet.formula import ArrayFormula

ws["E2"] = ArrayFormula("E2:E11", "=SUM(C2:C11*D2:D11)")
# Only visible at top-left cell (E2)
```

## Chart Creation

### Basic Bar/Column Chart

```python
from openpyxl import Workbook
from openpyxl.chart import BarChart, Reference

wb = Workbook()
ws = wb.active

# Sample data
data = [["Month", "Sales"], ["Jan", 100], ["Feb", 150], ["Mar", 200]]
for row in data:
    ws.append(row)

# Create chart
chart = BarChart()
chart.type = "col"
chart.title = "Monthly Sales"
chart.y_axis.title = "Revenue"
chart.x_axis.title = "Month"

# Define data ranges
data_ref = Reference(ws, min_col=2, min_row=2, max_row=4)
categories_ref = Reference(ws, min_col=1, min_row=2, max_row=4)

chart.add_data(data_ref, titles_from_data=False)
chart.set_categories(categories_ref)

# Position chart
ws.add_chart(chart, "D2")

wb.save("chart.xlsx")
```

### Line Chart with Multiple Series

```python
from openpyxl.chart import LineChart, Reference

# Data in rows 1-7, columns A-D
chart = LineChart()
chart.title = "Quarterly Performance"
chart.y_axis.title = "Units"
chart.x_axis.title = "Quarter"

data_ref = Reference(ws, min_col=2, min_row=1, max_col=4, max_row=7)
cats_ref = Reference(ws, min_col=1, min_row=2, max_row=7)

chart.add_data(data_ref, titles_from_data=True)
chart.set_categories(cats_ref)
ws.add_chart(chart, "F1")
```

### Chart Properties Reference

| Property | Description |
|----------|-------------|
| `chart.title` | Chart title |
| `chart.style` | Style number (1-48) |
| `chart.width` | Width in cm |
| `chart.height` | Height in cm |
| `chart.x_axis.title` | X-axis label |
| `chart.y_axis.title` | Y-axis label |
| `chart.legend` | `None` to disable |

## Data Validation

### Dropdown List

```python
from openpyxl.worksheet.datavalidation import DataValidation

dv = DataValidation(type="list", formula1='"Apple,Orange,Banana"', allow_blank=True)
dv.error = "Please select from the list"
dv.errorTitle = "Invalid Entry"
ws.add_data_validation(dv)
dv.add("A1:A10")
```

### Number Range

```python
dv = DataValidation(type="whole", operator="between", formula1="0", formula2="100")
dv.error = "Enter a number between 0 and 100"
ws.add_data_validation(dv)
dv.add("B1:B10")
```

### Custom Formula

```python
dv = DataValidation(type="custom", formula1="=ISNUMBER(A1)", allow_blank=True)
ws.add_data_validation(dv)
dv.add("C1:C10")
```

## Conditional Formatting

### Color Scale (3-Color)

```python
from openpyxl.formatting.rule import ColorScaleRule

rule = ColorScaleRule(
    start_type="percentile", start_value=10, start_color="F8696B",
    mid_type="percentile", mid_value=50, mid_color="FFEB84",
    end_type="percentile", end_value=90, end_color="63BE7B"
)
ws.conditional_formatting.add("A1:F100", rule)
```

### Cell Value Rules

```python
from openpyxl.styles import PatternFill
from openpyxl.formatting.rule import CellIsRule

rule = CellIsRule(operator="greaterThan", formula=["500"],
                  fill=PatternFill(start_color="C6EFCE"))
ws.conditional_formatting.add("B1:B100", rule)
```

### Formula-Based Rule

```python
from openpyxl.formatting.rule import FormulaRule

rule = FormulaRule(formula=["$A1>$B1"],
                  fill=PatternFill(start_color="FFEB9C"))
ws.conditional_formatting.add("C1:C100", rule)
```

## Tables

```python
from openpyxl.worksheet.table import Table, TableStyleInfo

# Create table from data range
table = Table(displayName="SalesTable", ref="A1:C4")
table.tableStyleInfo = TableStyleInfo(
    name="TableStyleMedium2",
    showFirstColumn=False,
    showLastColumn=False,
    showRowStripes=True,
    showColumnStripes=False
)
ws.add_table(table)

# Structured references in formulas
ws['D1'] = '=SUM(SalesTable[Sales])'
```

## Named Ranges

### Create Named Range

```python
from openpyxl.workbook.defined_name import DefinedName

# Create named range
dn = DefinedName("SalesData", attr_text="Sheet!$A$2:$A$100")
wb.defined_names.append(dn)

# Use in formula
ws['B1'] = '=SUM(SalesData)'
```

### Sheet-Scoped Named Range

```python
dn = DefinedName("Rate", attr_text="Sheet2!$B$1")
dn.local_sheet_id = ws.sheet_id
wb.defined_names.append(dn)
```

## Recalculating Formulas

### Using recalc.py Script

```bash
python scripts/recalc.py output.xlsx
python scripts/recalc.py output.xlsx 30  # With timeout
```

The script:
- Forces LibreOffice to recalculate all formulas
- Scans for Excel errors (#REF!, #DIV/0!, etc.)
- Returns JSON with error details

### Manual Recalculation in Excel

When opening a file in Excel, press `Ctrl+Alt+F9` to force recalculation of all formulas.

## Formula Verification Checklist

- [ ] Test 2-3 sample references
- [ ] Column mapping: Excel columns (column 64 = BL)
- [ ] Row offset: DataFrame row 5 = Excel row 6
- [ ] NaN handling: Check for null values
- [ ] Division by zero: Verify denominators aren't zero
- [ ] Cross-sheet references: Use `SheetName!A1` format
- [ ] New functions: Prefix with `_xlfn.` if unknown

## Multi-Sheet Operations

```python
# All sheets
for sheet in wb.worksheets:
    print(f"Processing: {sheet.title}")

# Skip utility sheets
for sheet in wb.worksheets:
    if sheet.title.startswith("_") or sheet.title.endswith("_template"):
        continue
    process_sheet(sheet)

# Copy worksheet within same workbook
ws_copy = wb.copy_worksheet(wb["Data"])
ws_copy.title = "Data Copy"
```

## Performance Tips

| Scenario | Approach |
|----------|----------|
| Large files | Use `read_only=True` for reading |
| Streaming writes | Use `write_only=True` mode |
| Many writes | Batch operations, minimize style changes |
| Memory issues | Process sheet by sheet, call `gc.collect()` |

## Error Handling

```python
try:
    wb = load_workbook(file_path)
    # ... operations ...
    wb.save(file_path)
    wb.close()
except FileNotFoundError:
    print("File not found")
except PermissionError:
    print("File is open in Excel. Close it and retry.")
except Exception as e:
    print(f"Error: {e}")
```

## Common Patterns for Subagents

### Pattern 1: Workbook from Template

```python
from openpyxl import load_workbook

def generate_from_template(template_path, data, output_path):
    """Generate workbook from template with data."""
    wb = load_workbook(template_path)
    ws = wb.active

    # Replace placeholders in headers
    for row in ws.iter_rows():
        for cell in row:
            if cell.value and isinstance(cell.value, str):
                for key, value in data.items():
                    if f'{{{{{key}}}}}' in str(cell.value):
                        cell.value = cell.value.replace(f'{{{{{key}}}}}', str(value))

    wb.save(output_path)
    wb.close()
```

### Pattern 2: Batch Processing Multiple Workbooks

```python
import os
from openpyxl import load_workbook

def process_workbooks(input_dir, output_dir, operation):
    """Batch process multiple Excel files."""
    for filename in os.listdir(input_dir):
        if filename.endswith(('.xlsx', '.xlsm')):
            input_path = os.path.join(input_dir, filename)
            output_path = os.path.join(output_dir, filename)

            wb = load_workbook(input_path)

            # Apply operation to each sheet
            for sheet in wb.worksheets:
                if not sheet.title.startswith('_'):
                    operation(sheet)

            wb.save(output_path)
            wb.close()
            print(f"Processed: {filename}")
```

### Pattern 3: Formula Verification Pipeline

```python
from openpyxl import load_workbook

def verify_and_fix_formulas(file_path):
    """Verify all formulas and fix common errors."""
    wb = load_workbook(file_path, data_only=False)
    errors = []

    for sheet in wb.worksheets:
        for row in sheet.iter_rows():
            for cell in row:
                if cell.value and isinstance(cell.value, str):
                    if cell.value.startswith('='):
                        # Check for common errors
                        if '#REF!' in cell.value:
                            errors.append(f"{sheet.title}!{cell.coordinate}: #REF! error")
                        elif '#DIV/0!' in cell.value:
                            errors.append(f"{sheet.title}!{cell.coordinate}: #DIV/0! error")

    wb.close()

    if errors:
        print("Formula errors found:")
        for e in errors:
            print(f"  - {e}")
        return False

    return True
```

### Pattern 4: Multi-Sheet Consolidation

```python
import pandas as pd
from openpyxl import Workbook

def consolidate_sheets(file_path, output_path):
    """Consolidate data from multiple sheets into one."""
    xl = pd.ExcelFile(file_path)
    all_data = []

    for sheet_name in xl.sheet_names:
        if not sheet_name.startswith('_'):
            df = pd.read_excel(file_path, sheet_name=sheet_name)
            df['_source'] = sheet_name
            all_data.append(df)

    consolidated = pd.concat(all_data, ignore_index=True)

    # Write to new workbook
    wb = Workbook()
    ws = wb.active
    ws.title = "Consolidated"

    # Write headers
    for col, header in enumerate(consolidated.columns, start=1):
        ws.cell(row=1, column=col, value=header)

    # Write data
    for row_idx, row_data in enumerate(consolidated.values, start=2):
        for col_idx, value in enumerate(row_data, start=1):
            ws.cell(row=row_idx, column=col_idx, value=value)

    wb.save(output_path)
```

## Best Practices

### Excel File Creation

1. **Use `data_only=False` when loading for editing**
   ```python
   # CORRECT - See formulas, can edit
   wb = load_workbook('file.xlsx', data_only=False)
   wb['A1'] = '=SUM(B1:B10)'
   wb.save('output.xlsx')

   # WRONG - Formulas become values, lost on save
   wb = load_workbook('file.xlsx', data_only=True)
   wb.save('output.xlsx')  # ALL FORMULAS LOST!
   ```

2. **Use `write_only=True` for large file creation**
   ```python
   from openpyxl import Workbook
   wb = Workbook(write_only=True)
   # Cannot read back without reopening
   ```

3. **Always close workbooks properly**
   ```python
   wb = load_workbook('file.xlsx')
   try:
       # ... operations ...
   finally:
       wb.close()  # Always close
   ```

4. **Use streaming for very large files**
   - Process in chunks with pandas
   - Use `read_only=True` mode for reading

### Formula Best Practices

5. **Use formulas, not hardcoded values**
   ```python
   # CORRECT
   ws['B10'] = '=SUM(B2:B9)'  # Excel calculates

   # WRONG
   total = df['Sales'].sum()
   ws['B10'] = total  # Hardcodes calculated value
   ```

6. **Prefix new Excel functions with `_xlfn.`**
   ```python
   ws['A1'] = '=_xlfn.IFERROR(A1/B1,0)'
   ws['A2'] = '=_xlfn.CONCAT(A1," ",B1)'
   ```

7. **Use IFERROR to handle potential errors**
   ```python
   ws['A1'] = '=IFERROR(A1/B1,0)'  # Returns 0 instead of #DIV/0!
   ```

### Chart Best Practices

8. **Test charts in Excel after creation**
   - openpyxl chart rendering may differ from Excel
   - For complex charts, consider using xlsxwriter

9. **Set `titles_from_data=True` when first row has headers**
   ```python
   data_ref = Reference(ws, min_col=2, min_row=1, max_col=4, max_row=7)
   chart.add_data(data_ref, titles_from_data=True)
   ```

### Performance Tips

10. **Use chunked processing for large files**
    ```python
    import gc
    for chunk in pd.read_excel('large.xlsx', chunksize=1000):
        process(chunk)
        gc.collect()
    ```

11. **Minimize style operations in loops**
    - Apply styles once, not per cell

12. **Use appropriate column widths up front**
    ```python
    ws.column_dimensions['A'].width = 20
    ```

## Error Handling

### Common Issues and Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| `None` values reading with `data_only=True` | File never opened in Excel to recalculate | Use `data_only=False` or open/save in Excel first |
| Formulas not working after copy | References drifted | Use `Translator` class or re-enter formulas |
| Performance slow with large files | Default mode is memory-intensive | Use `read_only=True` or `write_only=True` modes |
| Cannot create pivot tables | Feature not implemented | Use template approach or pandas aggregation |
| Charts render incorrectly | openpyxl chart engine limitations | Test in Excel, use xlsxwriter for complex charts |
| File corrupted on save | Interrupted write or Excel still open | Always close workbook properly, use temp file pattern |
| Named range conflicts | Duplicate names across scopes | Explicitly scope: `Workbook.defined_names[name].local_sheet_id` |
| Conditional formatting not applying | Range not properly added | Call `ws.conditional_formatting.add(range, rule)` after creating rule |
| #REF! errors in formulas | Sheet deleted or column removed | Verify all sheet references exist, use IFERROR to handle gracefully |
| Permission denied | File is open in Excel | Close Excel and retry, use try/except to handle |

### Error Handling Patterns

```python
from openpyxl import load_workbook
import logging

def safe_excel_operation(file_path, operation_func):
    """Wrapper for Excel operations with proper error handling."""
    try:
        wb = load_workbook(file_path)
        result = operation_func(wb)
        wb.save(file_path)
        wb.close()
        return {"success": True, "result": result}
    except FileNotFoundError:
        return {"success": False, "error": "File not found"}
    except PermissionError:
        return {"success": False, "error": "File is open in Excel. Close it and retry."}
    except Exception as e:
        logging.error(f"Excel operation failed: {e}")
        return {"success": False, "error": str(e)}
```

### Formula Verification Pattern

```python
def verify_formulas_after_write(file_path, expected_formula_cells):
    """Post-write verification that formulas are present."""
    wb = load_workbook(file_path, data_only=False)
    issues = []

    for sheet_name, cell_addr, expected_prefix in expected_formula_cells:
        ws = wb[sheet_name]
        cell_value = ws[cell_addr].value

        if cell_value is None:
            issues.append(f"{sheet_name}!{cell_addr}: Cell is empty")
        elif not str(cell_value).startswith(expected_prefix):
            issues.append(f"{sheet_name}!{cell_addr}: Expected '{expected_prefix}', got '{cell_value}'")

    wb.close()

    if issues:
        return {"verified": False, "issues": issues}
    return {"verified": True}
```

## Quick Reference

| Task | Tool | Code/Command |
|------|------|--------------|
| Read data | pandas | `pd.read_excel('file.xlsx')` |
| Create workbook | openpyxl | `Workbook()` |
| Load existing | openpyxl | `load_workbook('file.xlsx')` |
| Write formulas | openpyxl | `ws['A1'] = '=SUM(B1:B10)'` |
| Create charts | openpyxl | See Charts section |
| Data validation | openpyxl | `DataValidation(type="list", formula1='"A,B,C"')` |
| Conditional formatting | openpyxl | `ws.conditional_formatting.add(range, rule)` |
| Recalculate formulas | LibreOffice | `python scripts/recalc.py file.xlsx` |
| Batch process | pandas + openpyxl | Process sheet by sheet, use read_only mode |
| Error handling wrapper | try/except | See Error Handling patterns above |

## Dependencies

| Tool | Purpose | Install Command |
|------|---------|-----------------|
| openpyxl | Spreadsheet manipulation | `pip install openpyxl` |
| pandas | Data analysis | `pip install pandas` |
| LibreOffice | Formula recalculation | Install from libreoffice.org |
| xlsxwriter | High-performance writes (alternative) | `pip install xlsxwriter` |

## Related Files

- `SKILL.md` - Main skill documentation
- `scripts/recalc.py` - Formula recalculation utility