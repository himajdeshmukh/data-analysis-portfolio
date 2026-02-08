import pandas as pd
import re

# Input & output (relative paths for repo use)
input_file = "data/pooled_rbd_all_traits_printed_output.xlsx"
output_file = "output/long_anova_pooled_ready.xlsx"

# Regex patterns
table_line_pattern = re.compile(r"^[\s]*[A-Za-z0-9\.:]+(\s+[<>=0-9\.\*\-e]+)+")
square_brackets_pattern = re.compile(r"\[\d+\]")  # matches [1], [2], etc.

# Load Excel with multiple sheets
xls = pd.ExcelFile(input_file)

with pd.ExcelWriter(output_file, engine="openpyxl") as writer:

    for sheet_name in xls.sheet_names:
        df = pd.read_excel(
            xls,
            sheet_name=sheet_name,
            header=None,
            usecols=[0],
            names=["text"]
        )

        df = df[df["text"].notna()]

        all_rows = []
        current_table = []
        in_table = False

        for line in df["text"]:
            line = str(line).strip()

            # Remove [number] patterns
            line = square_brackets_pattern.sub("", line).strip()

            # Skip lines starting with $
            if line.startswith("$"):
                continue

            # Blank line handling
            if line == "":
                if in_table and current_table:
                    all_rows.extend(current_table)
                    all_rows.append([])
                    current_table = []
                in_table = False
                continue

            # Custom splitting rules
            if line.lstrip().startswith("MSerror"):
                split_line = line.split()

            elif line.lstrip().startswith('"SEm') or line.lstrip().startswith("SEm"):
                line = line.strip('"').strip()
                split_line = [p.strip() for p in line.split(",") if p.strip()]

            elif "Df" in line and "Sum Sq" in line and "Mean Sq" in line:
                line = line.replace("Sum Sq", "Sum_Sq").replace("Mean Sq", "Mean_Sq")
                split_line = [x.replace("_", " ") for x in line.split()]

            elif re.search(r"0\s*‘\*\*\*’", line):
                parts = re.findall(r"\d+\.?\d*\s*‘.*?’|\d+", line)
                split_line = [p.strip() for p in parts if p.strip()]

            elif line.lstrip().startswith("W"):
                split_line = [p.strip() for p in line.split(",") if p.strip()]

            elif table_line_pattern.match(line):
                in_table = True
                split_line = line.split()

            else:
                if in_table and current_table:
                    all_rows.extend(current_table)
                    all_rows.append([])
                    current_table = []
                in_table = False
                split_line = [line]

            if in_table and table_line_pattern.match(line):
                current_table.append(split_line)
            else:
                all_rows.append(split_line)

        if current_table:
            all_rows.extend(current_table)
            all_rows.append([])

        if all_rows:
            max_cols = max(len(r) for r in all_rows)
            all_rows = [
                row + [""] * (max_cols - len(row)) if len(row) < max_cols else row
                for row in all_rows
            ]

            def to_numeric_if_possible(cell):
                if isinstance(cell, str):
                    s = cell.strip()
                    if re.fullmatch(r"[+-]?\d+(\.\d+)?([eE][+-]?\d+)?", s):
                        try:
                            num = float(s)
                            return int(num) if num.is_integer() else num
                        except:
                            return cell
                return cell

            all_rows = [[to_numeric_if_possible(c) for c in row] for row in all_rows]

            pd.DataFrame(all_rows).to_excel(
                writer,
                sheet_name=sheet_name,
                index=False,
                header=False
            )

print(f"✅ Parsed tables saved to: {output_file}")
