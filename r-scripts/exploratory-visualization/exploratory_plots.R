# ============================================================
# Title: Exploratory Visualization of Agronomic and Environmental Data
#
# Description:
#   Generates a collection of exploratory and inferential
#   visualizations for agronomic experiments, including:
#   - Trait × environment correlations
#   - Variety-wise comparisons across seasons
#   - Sowing-date effects on key traits
#   - Correlation and association plots
#
#   This script ONLY generates plots.
#   It assumes that the input datasets are already prepared.
#
# Required Packages:
#   tidyverse, ggstatsplot, ggcorrplot, ggtext, patchwork
# ============================================================

library(tidyverse)
library(ggstatsplot)
library(ggcorrplot)
library(ggtext)
library(patchwork)

# ------------------------------------------------------------
# INPUT DATA (assumed pre-processed)
# ------------------------------------------------------------
# Env_Agro_Analysis        : main agronomic dataset
# Env_Agro_Correlation    : long-format trait–environment correlations
# ------------------------------------------------------------

# ============================================================
# 1. Trait × Environment Correlation Heatmap
# ============================================================
corr_matrix <- Env_Agro_Correlation %>%
  pivot_wider(names_from = Environment, values_from = Correlation) %>%
  column_to_rownames("Trait") %>%
  as.matrix()

ggcorrplot(
  corr_matrix,
  hc.order = TRUE,
  type = "lower",
  lab = TRUE,
  lab_size = 3,
  colors = c("#6D9EC1", "white", "#E46726"),
  title = "Trait–Environment Correlation Heatmap",
  ggtheme = theme_minimal()
)

# ============================================================
# 2. Trait × Environment Bubble Correlation Plot
# ============================================================
ggplot(
  Env_Agro_Correlation,
  aes(
    x = Environment,
    y = Trait,
    fill = Correlation,
    size = abs(Correlation)
  )
) +
  geom_point(shape = 21, color = "black", alpha = 0.8) +
  scale_fill_gradient2(
    low = "blue", mid = "white", high = "red", midpoint = 0
  ) +
  scale_size_continuous(range = c(2, 8), guide = "none") +
  theme_minimal() +
  labs(
    title = "Trait–Environment Correlation Bubble Plot",
    x = "Environment",
    y = "Trait"
  )

# ============================================================
# 3. Variety Comparison (Single Season)
# ============================================================
ggbetweenstats(
  data = Env_Agro_Analysis %>% filter(Season == "S1"),
  x = Variety,
  y = PlantHeight,
  type = "parametric",
  title = "Plant Height Comparison Across Varieties (Season S1)",
  messages = FALSE,
  pairwise.comparisons = TRUE,
  pairwise.display = "significant"
)

# ============================================================
# 4. Variety Comparison Across Seasons (Grouped)
# ============================================================
grouped_ggbetweenstats(
  data = Env_Agro_Analysis,
  x = Variety,
  y = PlantHeight,
  grouping.var = Season,
  type = "parametric",
  title.prefix = "Season",
  results.subtitle = FALSE,
  messages = FALSE
)

# ============================================================
# 5. Yield vs Thermal Time Correlation
# ============================================================
ggscatterstats(
  data = Env_Agro_Analysis,
  x = Yield,
  y = ThermalTime,
  type = "pearson",
  title = "Yield vs Thermal Time",
  label.expression = TRUE
)

# ============================================================
# 6. Season-wise Boxplot with Significance
# ============================================================
ggplot(
  Env_Agro_Analysis,
  aes(x = Season, y = PlantHeight, fill = Season)
) +
  geom_boxplot(alpha = 0.7) +
  theme_minimal() +
  labs(
    title = "Plant Height Across Seasons",
    x = "Season",
    y = "Plant Height"
  ) +
  theme(legend.position = "none")

# ============================================================
# 7. Variety-wise Trait Comparisons (Multiple Traits)
# ============================================================
p1 <- ggbetweenstats(
  data = Env_Agro_Analysis,
  x = Variety,
  y = PlantHeight,
  title = "Plant Height",
  messages = FALSE,
  results.subtitle = FALSE
)

p2 <- ggbetweenstats(
  data = Env_Agro_Analysis,
  x = Variety,
  y = Yield,
  title = "Yield",
  messages = FALSE,
  results.subtitle = FALSE
)

p1 + p2 + plot_annotation(
  title = "Variety-wise Comparison of Agronomic Traits"
)

# ============================================================
# 8. Sowing Date Effects on Field Emergence
# ============================================================
ggbetweenstats(
  data = Env_Agro_Analysis,
  x = SowingDate,
  y = FieldEmergence,
  type = "parametric",
  title = "Effect of Sowing Date on Field Emergence",
  pairwise.comparisons = TRUE,
  messages = FALSE
)

# ============================================================
# 9. Sowing Date Effects on Hundred Seed Weight
# ============================================================
ggbetweenstats(
  data = Env_Agro_Analysis,
  x = SowingDate,
  y = HundredSeedWeight,
  type = "parametric",
  title = "Effect of Sowing Date on Hundred Seed Weight",
  pairwise.comparisons = TRUE,
  messages = FALSE
)
