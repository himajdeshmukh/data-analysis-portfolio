# ============================================================
# Title: Diallel Analysis Using Griffing Method II (Model I)
#
# Description:
#   Performs single-location half-diallel analysis using
#   Griffing’s Method II (fixed effects model).
#
#   For each trait, the script computes:
#   - Genotypic means
#   - ANOVA with significance levels
#   - Genetic components
#   - GCA and SCA effects
#   - Standard errors
#
#   Results are exported to an Excel workbook with
#   one worksheet per trait.
#
# Important:
#   This script is intended for SINGLE-LOCATION analysis.
#   If data include multiple locations, Griffing analysis
#   must be performed separately for each location.
#
# Required Packages:
#   DiallelAnalysisR, openxlsx
# ============================================================

library(DiallelAnalysisR)
library(openxlsx)

# ------------------------------------------------------------
# Input data (generic name)
# ------------------------------------------------------------
diallel_data <- as.data.frame(diallel_dataset)

diallel_data$Parent1     <- as.numeric(as.character(diallel_data$Parent1))
diallel_data$Parent2     <- as.numeric(as.character(diallel_data$Parent2))
diallel_data$Replication <- as.factor(diallel_data$Replication)

# ------------------------------------------------------------
# Trait list (exclude design columns)
# ------------------------------------------------------------
response_traits <- setdiff(
  colnames(diallel_data),
  c("Parent1", "Parent2", "Replication", "Location")
)

# ------------------------------------------------------------
# Significance symbols
# ------------------------------------------------------------
significance_symbol <- function(p) {
  if (is.na(p)) ""
  else if (p < 0.001) "***"
  else if (p < 0.01) "**"
  else if (p < 0.05) "*"
  else if (p < 0.1) "."
  else ""
}

# ------------------------------------------------------------
# Workbook setup
# ------------------------------------------------------------
wb <- createWorkbook()

# ============================================================
# ANALYSIS LOOP
# ============================================================
for (trait in response_traits) {

  cat("Running Griffing analysis for trait:", trait, "\n")

  # Griffing Method II, Model I
  model_call <- paste0(
    "Griffing(",
    "y = ", trait, ", ",
    "Rep = Replication, ",
    "Cross1 = Parent1, ",
    "Cross2 = Parent2, ",
    "data = diallel_data, ",
    "Method = 2, ",
    "Model = 1",
    ")"
  )

  g <- eval(parse(text = model_call))

  # ----------------------------------------------------------
  # Create worksheet
  # ----------------------------------------------------------
  addWorksheet(wb, trait)
  row_pos <- 1

  # ===============================
  # Means
  # ===============================
  writeData(wb, trait, "MEANS", startRow = row_pos)
  row_pos <- row_pos + 1

  writeData(
    wb, trait,
    as.data.frame(g$Means),
    startRow = row_pos,
    rowNames = TRUE
  )
  row_pos <- row_pos + nrow(g$Means) + 3

  # ===============================
  # ANOVA (with significance)
  # ===============================
  anova_df <- as.data.frame(g$ANOVA)
  anova_df <- cbind(Source = rownames(anova_df), anova_df)

  if ("Pr(>F)" %in% colnames(anova_df)) {
    anova_df$Significance <- sapply(
      anova_df$`Pr(>F)`,
      significance_symbol
    )
  }

  writeData(wb, trait, "ANOVA", startRow = row_pos)
  row_pos <- row_pos + 1

  writeData(
    wb, trait,
    anova_df,
    startRow = row_pos
  )
  row_pos <- row_pos + nrow(anova_df) + 3

  # ===============================
  # Genetic components
  # ===============================
  writeData(wb, trait, "GENETIC COMPONENTS", startRow = row_pos)
  row_pos <- row_pos + 1

  writeData(
    wb, trait,
    as.data.frame(g$Genetic.Components),
    startRow = row_pos,
    rowNames = TRUE
  )
  row_pos <- row_pos + nrow(g$Genetic.Components) + 3

  # ===============================
  # Effects (GCA and SCA)
  # ===============================
  writeData(wb, trait, "EFFECTS (GCA and SCA)", startRow = row_pos)
  row_pos <- row_pos + 1

  writeData(
    wb, trait,
    as.data.frame(g$Effects),
    startRow = row_pos,
    rowNames = TRUE
  )
  row_pos <- row_pos + nrow(g$Effects) + 3

  # ===============================
  # Standard errors
  # ===============================
  writeData(wb, trait, "STANDARD ERRORS", startRow = row_pos)
  row_pos <- row_pos + 1

  writeData(
    wb, trait,
    data.frame(Standard_Error = g$StdErr),
    startRow = row_pos
  )
}

# ------------------------------------------------------------
# Save Excel output
# ------------------------------------------------------------
saveWorkbook(
  wb,
  file = "Diallel_Griffing_Method2_SingleLocation.xlsx",
  overwrite = TRUE
)
