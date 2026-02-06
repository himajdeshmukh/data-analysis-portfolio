# ============================================================
# Title: Pooled Split-Plot ANOVA Across Seasons
#
# Description:
#   Performs pooled split-plot ANOVA across seasons/environments
#   using the CANE package.
#
#   The analysis includes:
#   - Split-plot ANOVA with main and subplot factors
#   - Season-wise treatment means
#   - Pooled means across seasons
#   - Alternative model for estimating main-factor means
#
# Required Package:
#   CANE
# ============================================================

library(CANE)

# ------------------------------------------------------------
# Input data (generic name)
# ------------------------------------------------------------
analysis_data <- splitplot_dataset

analysis_data <- analysis_data |>
  transform(
    Season      = as.factor(Season),
    Replication = as.factor(Replication),
    MainFactor  = as.factor(as.character(MainFactor)),
    SubFactor   = as.factor(SubFactor)
  )

# ------------------------------------------------------------
# Response variable
# ------------------------------------------------------------
response_var <- "Response"

# ============================================================
# MAIN SPLIT-PLOT ANOVA
# ============================================================
splitplot_result <- PooledSPD(
  data = analysis_data,
  Response = response_var,
  Location = "Season",
  Replication = "Replication",
  MainPlot = "MainFactor",
  SubPlot = "SubFactor",
  alpha = 0.05,
  Mult_Comp_Test = 1
)

print(splitplot_result)

# ============================================================
# NON-TRANSFORMED MEANS
# ============================================================

# Season-wise means
seasonwise_means <- aggregate(
  analysis_data[[response_var]],
  by = list(
    Season  = analysis_data$Season,
    SubFactor = analysis_data$SubFactor
  ),
  FUN = mean
)
colnames(seasonwise_means)[3] <- "Season_Mean"

# Pooled means across seasons
pooled_means <- aggregate(
  analysis_data[[response_var]],
  by = list(SubFactor = analysis_data$SubFactor),
  FUN = mean
)
colnames(pooled_means)[2] <- "Pooled_Mean"

# Combined table
combined_means <- merge(
  seasonwise_means,
  pooled_means,
  by = "SubFactor"
)

combined_means

# ============================================================
# ALTERNATIVE MODEL: MAIN-FACTOR MEANS
# ============================================================
# (Used to obtain pooled means of the main factor)
main_factor_model <- PooledSPD(
  data = analysis_data,
  Response = response_var,
  Location = "Season",
  Replication = "Replication",
  MainPlot = "SubFactor",
  SubPlot = "MainFactor",
  alpha = 0.05,
  Mult_Comp_Test = 1
)

main_factor_means <- main_factor_model$Treatments_Comparison$means
main_factor_means
