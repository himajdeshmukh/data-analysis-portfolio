# Exploratory Visualization of Agronomic and Environmental Data

This folder contains R scripts for **exploratory and inferential visualization**
of agronomic experiments across environments, seasons, varieties, and sowing dates.

The visualizations are designed to complement statistical analyses by providing
clear, interpretable graphical summaries of trait behavior and relationships.

---

## Script Included

### `exploratory_plots.R`

**Purpose**

Generates a collection of publication-quality plots to explore:

- Trait–environment relationships
- Variety-wise performance across seasons
- Seasonal and sowing-date effects on agronomic traits
- Associations between yield and environmental variables

This script is **plot-only** and does **not** perform data cleaning,
model fitting, or table generation.

---

## Types of Visualizations

### 1. Trait × Environment Correlation
- Correlation heatmap with hierarchical clustering
- Bubble plot showing strength and direction of correlations

These plots help identify traits that respond similarly across environments.

---

### 2. Variety Comparisons
- Variety-wise comparisons of traits using violin plots
- Mean estimates with confidence intervals
- Pairwise statistical comparisons with multiple-testing correction

Both single-season and multi-season (grouped) comparisons are included.

---

### 3. Season and Environment Effects
- Boxplots comparing trait distributions across seasons
- Statistical significance of seasonal differences

These plots illustrate environmental variability and stability of traits.

---

### 4. Association and Correlation Plots
- Scatter plots with correlation statistics
- Confidence intervals and effect sizes

Used to assess relationships between yield and environmental or physiological variables.

---

### 5. Sowing Date Effects
- Comparison of sowing dates for traits such as field emergence and seed weight
- Pairwise comparisons highlighting optimal sowing windows

---

## Input Data Assumptions

The script assumes that the following datasets are already prepared:

- A main agronomic dataset containing:
  - Environment/season identifiers
  - Variety identifiers
  - Sowing dates
  - Numeric trait columns
- A long-format dataset containing trait–environment correlation values

No data preprocessing is performed in this script.

---

## Output

The script generates multiple graphical outputs (≈10–12 plots), which can be:

- Displayed interactively in R
- Saved as image files (PNG/PDF) for reports or presentations
- Embedded directly in GitHub README files for portfolio display

---

## Packages Used

- `tidyverse`
- `ggstatsplot`
- `ggcorrplot`
- `ggtext`
- `patchwork`

---

## Notes

These visualizations are intended for:
- Exploratory data analysis
- Result interpretation
- Communication of findings in theses, reports, and presentations

They are designed to be reusable across different agronomic and
environmental datasets with similar structure.
