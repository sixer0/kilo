# XLSX Examples

This directory contains working examples for Excel spreadsheet processing.

## Examples

| Example | Description |
|---------|-------------|
| `01_basic_spreadsheet.py` | Create spreadsheet with formulas |
| `02_spreadsheet_with_charts.py` | Add charts to spreadsheet |
| `03_read_modify_excel.py` | Load and modify existing files |
| `04_data_validation.py` | Data validation and conditional formatting |

## Requirements

```bash
pip install openpyxl pandas
```

## Usage

```bash
cd skills/xlsx/examples

# Run examples
python 01_basic_spreadsheet.py
python 02_spreadsheet_with_charts.py

# For read/modify example, place input.xlsx in this directory
python 03_read_modify_excel.py
```

## Notes

- Charts may render differently in Excel vs openpyxl
- Use LibreOffice to verify complex spreadsheets