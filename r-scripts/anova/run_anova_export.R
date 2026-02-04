# ============================================================
# Title: Automated ANOVA and Excel Export for Multiple Designs
# Description:
#   Performs ANOVA for multiple traits across several experimental
#   designs (RCBD, CRD, factorial, split-plot, strip-plot) and
#   exports results to an Excel workbook (one sheet per trait).
#
# Packages:
#   doebioresearch, openxlsx
#
# ============================================================

library(doebioresearch)
library(openxlsx)

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

    output_text <- capture.output(print(fit))

    sheet_name <- gsub("[\\[\\]:/\\\\?*]", "_", trait_name)
    sheet_name <- substr(sheet_name, 1, 31)

    addWorksheet(wb, sheet_name)
    writeData(wb, sheet_name, data.frame(Output = output_text))
  }

  saveWorkbook(wb, file_name, overwrite = TRUE)
  cat("ANOVA results saved to:", file_name, "\n")
}
