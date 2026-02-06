# ============================================================
# Title: Path Coefficient Analysis Using Structural Equation Modeling
#
# Description:
#   Performs path coefficient analysis to quantify direct effects
#   of yield-related traits on final yield using structural equation
#   modeling (SEM).
#
#   The analysis uses standardized path coefficients and provides
#   both numerical summaries and graphical visualization.
#
# Required Packages:
#   lavaan, semPlot
# ============================================================

library(lavaan)
library(semPlot)

# ------------------------------------------------------------
# Input data (generic name)
# ------------------------------------------------------------
analysis_data <- path_analysis_data

# ------------------------------------------------------------
# Retain only numeric variables
# ------------------------------------------------------------
analysis_data <- analysis_data[, sapply(analysis_data, is.numeric)]

# ------------------------------------------------------------
# Define path model
# ------------------------------------------------------------
# Yield is modeled as a function of component traits
path_model <- '
  Yield ~ SC + CC + LS + NS + TY
'

# ------------------------------------------------------------
# Fit SEM model
# ------------------------------------------------------------
fit <- sem(
  model = path_model,
  data = analysis_data,
  meanstructure = TRUE
)

# ------------------------------------------------------------
# Model summary
# ------------------------------------------------------------
summary(
  fit,
  standardized = TRUE,
  rsquare = TRUE
)

# ------------------------------------------------------------
# Path diagram (standardized coefficients)
# ------------------------------------------------------------
semPaths(
  fit,
  whatLabels   = "std",     # standardized coefficients
  layout       = "tree",
  edge.label.cex = 0.8,
  sizeMan      = 6,
  residuals    = FALSE,
  nCharNodes   = 0,
  label.cex    = 0.9,
  mar          = c(5, 5, 5, 5)
)

