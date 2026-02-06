# ============================================================
# Title: Genotypic and Phenotypic Correlation Analysis
#
# Description:
#   Computes genotypic and phenotypic correlation coefficients
#   among traits in diallel populations.
#
#   Analyses are performed:
#   - Location-wise
#   - Across locations (pooled, adjusted for environment effects)
#
#   Results are returned as R objects for downstream analysis
#   or reporting. No file export is performed.
#
# Required Packages:
#   dplyr, variability
# ============================================================

library(dplyr)
library(variability)

# ------------------------------------------------------------
# Input data (generic name)
# ------------------------------------------------------------
correlation_data <- diallel_correlation_data %>%
  select(-Parent1, -Parent2, -GenotypeCode)

# ------------------------------------------------------------
# Split data by location
# ------------------------------------------------------------
location_levels <- unique(correlation_data$Location)

data_by_location <- lapply(
  location_levels,
  function(loc) correlation_data %>% filter(Location == loc)
)
names(data_by_location) <- as.character(location_levels)

# ------------------------------------------------------------
# Identify trait columns
# ------------------------------------------------------------
trait_data <- correlation_data %>%
  select(where(is.numeric)) %>%
  select(-Location)

# ============================================================
# LOCATION-WISE CORRELATIONS
# ============================================================
genotypic_corr_locationwise  <- list()
phenotypic_corr_locationwise <- list()

for (loc in names(data_by_location)) {

  df_loc <- data_by_location[[loc]]

  traits_loc <- df_loc %>%
    select(where(is.numeric)) %>%
    select(-Location)

  genotypic_corr_locationwise[[loc]] <- geno.corr(
    traits_loc,
    df_loc$Genotype,
    df_loc$Replication
  )

  phenotypic_corr_locationwise[[loc]] <- pheno.corr(
    traits_loc,
    df_loc$Genotype,
    df_loc$Replication
  )
}

# ============================================================
# POOLED CORRELATIONS (ENVIRONMENT-ADJUSTED)
# ============================================================

# Adjust traits for location effects
traits_adjusted <- as.data.frame(
  residuals(
    lm(
      as.matrix(
        correlation_data %>%
          select(where(is.numeric)) %>%
          select(-Location)
      ) ~ correlation_data$Location
    )
  )
)

genotypic_corr_pooled <- geno.corr(
  traits_adjusted,
  correlation_data$Genotype,
  correlation_data$Replication
)

phenotypic_corr_pooled <- pheno.corr(
  traits_adjusted,
  correlation_data$Genotype,
  correlation_data$Replication
)

# ============================================================
# OUTPUT OBJECTS
# ============================================================
# genotypic_corr_locationwise  : list of genotypic correlations by location
# phenotypic_corr_locationwise : list of phenotypic correlations by location
# genotypic_corr_pooled        : pooled genotypic correlation
# phenotypic_corr_pooled       : pooled phenotypic correlation
