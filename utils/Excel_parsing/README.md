# Printed ANOVA Output Parser (Python)

## Background and Problem Statement

In many agricultural, biological, and experimental research workflows,
statistical analyses are performed in software such as **R**.  
The resulting outputs—especially **ANOVA tables, pooled analyses, and
mean comparison results**—are often generated in **print-oriented formats**.

Common characteristics of such outputs include:
- Tables exported as **plain text or printed summaries**
- Multiple tables embedded in a single column of an Excel sheet
- Irregular spacing and alignment
- Mixed content (headers, footnotes, symbols, significance codes)
- Inconsistent delimiters (spaces, commas, line breaks)
- Repeated annotations such as `[1]`, `$`, or significance symbols (`***`)

While these outputs are human-readable, they are **not machine-readable**
and cannot be directly used for:
- Downstream statistical analysis
- Visualization
- Reporting automation
- Reproducible data pipelines

Manually cleaning these files is:
- Time-consuming
- Error-prone
- Difficult to reproduce
- Unsuitable for large or repeated analyses

---

## Objective of This Script

This Python script is designed to **systematically convert printed or
semi-structured ANOVA outputs** stored in Excel files into
**clean, analysis-ready tabular data**.

The goal is not cosmetic formatting, but **structural recovery** of
statistical tables so they can be reused programmatically.

---

## Input Characteristics

The script expects:
- An Excel file with **one or more sheets**
- Each sheet containing **printed statistical output** in a single column
- Content may include:
  - ANOVA tables
  - Headings and descriptive text
  - Footnotes and annotations
  - Significance indicators
  - Blank lines separating tables

The script does **not** assume:
- Fixed column positions
- Consistent delimiters
- Uniform table structure across sheets

---

## Core Challenges Addressed

This script explicitly handles the following real-world issues:

### 1. Mixed Text and Table Content
Printed outputs often mix narrative text and numeric tables.
The script detects and separates:
- Table rows
- Non-tabular descriptive lines

### 2. Irregular Table Boundaries
Tables may be separated by blank lines or interrupted by text.
The script tracks when it is *inside* a table and when a table ends.

### 3. Inconsistent Delimiters
Different rows may use:
- Spaces
- Commas
- Aligned text
Custom parsing rules are applied based on detected patterns.

### 4. Statistical Annotations
The script removes or safely handles:
- Square-bracket annotations (e.g. `[1]`, `[2]`)
- Lines starting with `$`
- Significance symbols and formatted markers

### 5. Multi-Sheet Excel Inputs
Each sheet is processed independently, preserving:
- Sheet names
- Table structure per sheet

### 6. Safe Numeric Conversion
Only values that are **strictly numeric** (including scientific notation)
are converted to numbers.
All other text is preserved exactly as-is to avoid data corruption.

---

## How the Script Works (High-Level Logic)

1. **Load Excel file**
   - Reads all sheets in the input workbook

2. **Line-by-line parsing**
   - Treats each cell as a potential row of printed output
   - Strips unwanted annotations and symbols

3. **Table detection**
   - Uses regular expressions to identify table-like rows
   - Maintains state to determine when a table starts and ends

4. **Custom splitting rules**
   - Applies specific parsing logic for known patterns
     (e.g. MSerror, SEm, headers, significance lines)

5. **Table reconstruction**
   - Reassembles rows into consistent rectangular tables
   - Normalizes column lengths across rows

6. **Type handling**
   - Converts numeric values safely
   - Leaves text untouched where ambiguity exists

7. **Output generation**
   - Writes cleaned tables back to Excel
   - Preserves original sheet structure
   - Produces analysis-ready files

---

## Output

The script generates:
- A new Excel file
- One cleaned sheet per input sheet
- Tables that can be directly used for:
  - Statistical analysis
  - Visualization
  - Reporting
  - Further automation

The output file is suitable for use in:
- Python
- R
- Excel
- Other data analysis tools

---

## Intended Use Cases

This script is particularly useful for:
- Agricultural and plant breeding experiments
- Multi-location or pooled ANOVA analyses
- Legacy statistical workflows
- Converting printed outputs into reproducible pipelines
- Large projects where manual cleaning is infeasible

---

## Design Philosophy

- **Robust over rigid**: Handles variability in real outputs
- **Safe over aggressive**: Avoids forced conversions
- **Reproducible**: Same input always produces the same output
- **Minimal assumptions**: Does not depend on fixed formats

---

## Notes

- The script focuses on structural recovery, not statistical interpretation
- It is intentionally conservative in numeric conversion
- Designed to be extended for additional output formats if needed

---

## Summary

This utility bridges the gap between
**human-readable statistical output** and
**machine-readable analytical data**.

It enables printed ANOVA results to become a reusable,
reproducible part of modern data analysis workflows.
