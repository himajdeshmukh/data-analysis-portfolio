# ============================================================
# Title: Automated ANOVA and Excel Export for Experimental Designs
#
# Description:
#   This script performs Analysis of Variance (ANOVA) for multiple
#   response variables across different experimental designs such as
#   RCBD, CRD, factorial RBD/CRD, split-plot, and strip-plot designs.
#   Results for each trait are automatically exported to an Excel
#   workbook with one worksheet per trait.
#
# Author: Dr. Himaj Deshmukh
#
# Required Packages:
#   doebioresearch
#   openxlsx
#
# ============================================================

library(doebioresearch)
library(openxlsx)

# ------------------------------------------------------------
# Function: run_anova_export
# ------------------------------------------------------------
# data       : data frame containing experimental data
# resp_cols  : column indices of response variables
# design     : experimental design type
# factors    : list of design-specific factors
# file_name  : output Excel file name
# test       : significance test option
# ------------------------------------------------------------

run_anova_export <- function(
  data,
  resp_cols,
  design = "frbd3fact",
  factors = list(),
  file_name = "anova_results.xlsx",
  test = 1
) {

  wb <- createWorkbook()

  for (j in resp_cols) {

    trait_name <- names(data)[j]
    cat("Processing:", trait_name, "\n")

    fit <- switch(
      tolower(design),

      "rcbd" =
        rcbd(data[j], factors$Trt, factors$Rep, test),

      "frbd2fact" =
        frbd2fact(
          data[j],
          factors$replication,
          factors$FactorA,
          factors$FactorB,
          test
        ),

      "frbd3fact" =
        frbd3fact(
          data[j],
          factors$replication,
          factors$FactorA,
          factors$FactorB,
          factors$FactorC,
          test
        ),

      "crd" =
        crd(data[j], factors$Treatments, test),

      "fcrd2fact" =
        fcrd2fact(
          data[j],
          factors$FactorA,
          factors$FactorB,
          test
        ),

      "fcrd3fact" =
        fcrd3fact(
          data[j],
          factors$FactorA,
          factors$FactorB,
          factors$FactorC,
          test
        ),

      "splitplot" =
        splitplot(
          data[j],
          factors$replication,
          factors$MainPlot,
          factors$SubPlot,
          test
        ),

      "stripplot" =
        stripplot(
          data[j],
          factors$replication,
          factors$ColumnFactor,
          factors$RowFactor,
          test
        ),

      "lsd" =
        lsd(
          data[j],
          factors$Treatment,
          factors$Row,
          factors$Column,
          test
        ),

      stop("Unknown experimental design specified.")
    )

    output_lines <- capture.output(print(fit))

    sheet_name <- gsub("[\\[\\]:/\\\\?*]", "_", trait_name)
    sheet_name <- substr(sheet_name, 1, 31)

    addWorksheet(wb, sheet_name)
    writeData(wb, sheet_name, data.frame(Output = output_lines))
  }

  saveWorkbook(wb, file_name, overwrite = TRUE)
  cat("ANOVA results saved to:", file_name, "\n")
}

run_anova_export(
  data = frbd3fact_cv_LONG,
  resp_cols = 5:8,
  design = "frbd3fact", #change design
  factors = list(
    replication = frbd3fact_cv_LONG$Replication,
    FactorA = frbd3fact_cv_LONG$Variety, #change according to design
    FactorB = frbd3fact_cv_LONG$Intensity,
    FactorC = frbd3fact_cv_LONG$Duration#change according to design
  ),
  test = 1
)
