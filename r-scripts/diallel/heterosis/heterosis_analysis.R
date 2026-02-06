# ============================================================
# Title: Heterosis and Heterobeltiosis Analysis in Diallel Crosses
#
# Description:
#   Computes mid-parent heterosis, better-parent heterosis
#   (heterobeltiosis), and related parameters for diallel
#   hybrid populations.
#
#   Analyses are performed:
#   - Location-wise
#   - Across locations (pooled)
#
#   The script returns R objects for downstream reporting
#   or visualization. No file export is performed.
#
# Required Packages:
#   dplyr, EstimateBreed
# ============================================================

library(dplyr)
library(EstimateBreed)

# ------------------------------------------------------------
# Input data (generic name)
# ------------------------------------------------------------
heterosis_data <- diallel_heterosis_data

# ------------------------------------------------------------
# Trait list
# ------------------------------------------------------------
response_traits <- c(
  "Trait1","Trait2","Trait3","Trait4","Trait5",
  "Trait6","Trait7","Trait8","Trait9","Trait10",
  "Trait11","Trait12","Trait13","Trait14","Trait15",
  "Trait16","Trait17","Trait18","Trait19"
)

# ------------------------------------------------------------
# Containers for results
# ------------------------------------------------------------
heterosis_locationwise <- list()
heterosis_pooled <- list()

locations <- unique(heterosis_data$Location)

# ============================================================
# MAIN LOOP
# ============================================================
for (trait in response_traits) {

  # -------------------------------------------
  # LOCATION-WISE HETEROSIS
  # -------------------------------------------
  loc_results <- list()

  for (loc in locations) {

    df_loc <- heterosis_data %>% filter(Location == loc)

    # Trait means
    means <- df_loc %>%
      group_by(Genotype) %>%
      summarise(
        Mean = mean(.data[[trait]], na.rm = TRUE),
        REP  = n_distinct(Replication),
        .groups = "drop"
      )

    # Identify parents
    parent_ids <- unique(df_loc$Parent1[df_loc$Parent1 == df_loc$Parent2])

    parents <- means %>%
      filter(Genotype %in% parent_ids) %>%
      rename(
        Parent = Genotype,
        ParentMean = Mean
      )

    # Hybrids
    hybrids <- df_loc %>%
      filter(Parent1 != Parent2) %>%
      distinct(Parent1, Parent2, Genotype) %>%
      left_join(means, by = "Genotype") %>%
      rename(
        GEN = Genotype,
        PR  = Mean
      )

    # Input for EstimateBreed
    het_input <- hybrids %>%
      left_join(parents, by = c("Parent1" = "Parent")) %>%
      rename(GM = ParentMean) %>%
      left_join(parents, by = c("Parent2" = "Parent")) %>%
      rename(GP = ParentMean) %>%
      select(GEN, GM, GP, PR, REP)

    # Heterosis estimation
    het_out <- with(
      het_input,
      het(GEN, GM, GP, PR, REP, param = "all")
    )

    loc_results[[as.character(loc)]] <- het_out
  }

  heterosis_locationwise[[trait]] <- loc_results

  # -------------------------------------------
  # POOLED HETEROSIS
  # -------------------------------------------
  means_pool <- heterosis_data %>%
    group_by(Genotype) %>%
    summarise(
      Mean = mean(.data[[trait]], na.rm = TRUE),
      REP  = n_distinct(Replication),
      .groups = "drop"
    )

  parent_ids_pool <- unique(
    heterosis_data$Parent1[
      heterosis_data$Parent1 == heterosis_data$Parent2
    ]
  )

  parents_pool <- means_pool %>%
    filter(Genotype %in% parent_ids_pool) %>%
    rename(
      Parent = Genotype,
      ParentMean = Mean
    )

  hybrids_pool <- heterosis_data %>%
    filter(Parent1 != Parent2) %>%
    distinct(Parent1, Parent2, Genotype) %>%
    left_join(means_pool, by = "Genotype") %>%
    rename(
      GEN = Genotype,
      PR  = Mean
    )

  het_input_pool <- hybrids_pool %>%
    left_join(parents_pool, by = c("Parent1" = "Parent")) %>%
    rename(GM = ParentMean) %>%
    left_join(parents_pool, by = c("Parent2" = "Parent")) %>%
    rename(GP = ParentMean) %>%
    select(GEN, GM, GP, PR, REP)

  het_out_pool <- with(
    het_input_pool,
    het(GEN, GM, GP, PR, REP, param = "all")
  )

  heterosis_pooled[[trait]] <- het_out_pool
}

# ============================================================
# OUTPUT OBJECTS
# ============================================================
# heterosis_locationwise : list of heterosis results by trait × location
# heterosis_pooled       : list of pooled heterosis results by trait
