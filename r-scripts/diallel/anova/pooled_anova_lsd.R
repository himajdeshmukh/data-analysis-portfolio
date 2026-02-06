# ============================================================
# Title: Pooled ANOVA and LSD Mean Separation Across Locations
#
# Description:
#   Performs pooled ANOVA across multiple environments/locations
#   using a fixed-effects model with nested replications.
#   Genotype-wise mean separation is conducted using LSD, and
#   all results are exported to Excel with one worksheet per trait.
#
# ============================================================

library(dplyr)
library(lme4)
library(lmerTest)
library(openxlsx)
library(agricolae)

# ------------------------------------------------------------
# Input data (generic name)
# ------------------------------------------------------------
analysis_data <- experiment_data %>%
  select(-Parent1, -Parent2, -GenotypeCode)

analysis_data$Genotype    <- as.factor(analysis_data$Genotype)
analysis_data$Replication <- as.factor(analysis_data$Replication)
analysis_data$Location    <- as.factor(analysis_data$Location)

data <- analysis_data

# ------------------------------------------------------------
# Significance stars
# ------------------------------------------------------------
add_significance <- function(p) {
  if (is.na(p)) return("")
  if (p < 0.001) "***"
  else if (p < 0.01) "**"
  else if (p < 0.05) "*"
  else ""
}

# ------------------------------------------------------------
# Identify numeric traits
# ------------------------------------------------------------
response_traits <- names(data)[sapply(data, is.numeric)]

# ------------------------------------------------------------
# Workbook setup
# ------------------------------------------------------------
wb <- createWorkbook()

# ============================================================
# ANALYSIS LOOP
# ============================================================
for (trait in response_traits) {

  # Pooled ANOVA model
  model <- aov(
    as.formula(
      paste(
        trait,
        "~ Location + Replication %in% Location + Genotype + Genotype:Location"
      )
    ),
    data = data
  )

  aov_table <- as.data.frame(anova(model))
  aov_table$Significance <- sapply(aov_table$`Pr(>F)`, add_significance)

  # ----------------------------------------------------------
  # LSD test (Genotype-wise)
  # ----------------------------------------------------------
  lsd_result <- agricolae::LSD.test(
    model,
    trt = "Genotype",
    console = FALSE
  )

  means <- lsd_result$groups
  means$Genotype <- rownames(means)
  rownames(means) <- NULL

  mean_column <- setdiff(names(means), c("groups", "Genotype"))[1]
  means <- means[, c("Genotype", mean_column, "groups")]
  colnames(means) <- c("Genotype", "Mean", "Group")

  # ----------------------------------------------------------
  # Experimental statistics
  # ----------------------------------------------------------
  stats <- as.data.frame(lsd_result$statistics)
  stats$Parameter <- rownames(stats)
  rownames(stats) <- NULL
  stats <- stats[, c("Parameter", names(stats)[1:(ncol(stats) - 1)])]

  # ----------------------------------------------------------
  # Write to Excel
  # ----------------------------------------------------------
  addWorksheet(wb, trait)
  row_pos <- 1

  writeData(
    wb,
    trait,
    paste("Pooled ANOVA for", trait),
    startRow = row_pos
  )
  row_pos <- row_pos + 2

  writeData(
    wb,
    trait,
    cbind(Source = rownames(aov_table), aov_table),
    startRow = row_pos
  )
  row_pos <- row_pos + nrow(aov_table) + 3

  writeData(
    wb,
    trait,
    "LSD Mean Separation (Genotype-wise)",
    startRow = row_pos
  )
  row_pos <- row_pos + 2

  writeData(wb, trait, means, startRow = row_pos)
  row_pos <- row_pos + nrow(means) + 3

  writeData(
    wb,
    trait,
    "Experimental Statistics",
    startRow = row_pos
  )
  row_pos <- row_pos + 2

  writeData(wb, trait, stats, startRow = row_pos)
}

# ------------------------------------------------------------
# Save Excel output
# ------------------------------------------------------------
saveWorkbook(
  wb,
  file = "Diallel_Pooled_ANOVA_LSD.xlsx",
  overwrite = TRUE
)
