# ============================================================
# Title: Pooled Diallel Analysis for GCA and SCA Across Locations
#
# Description:
#   Performs pooled (multi-environment) diallel analysis following
#   Griffing’s fixed-effects framework using linear models.
#
#   The script computes:
#   - Pooled ANOVA with Environment, GCA, SCA, and interactions
#   - Pooled GCA and SCA effects
#   - Standard errors and critical differences
#
#   Results are exported to Excel with one worksheet per trait.
#
# Scope:
#   This is a MULTI-LOCATION (pooled) diallel analysis.
#
# Required Packages:
#   dplyr, tidyr, openxlsx
# ============================================================

options(contrasts = c("contr.sum", "contr.poly"))

library(dplyr)
library(tidyr)
library(openxlsx)

# ------------------------------------------------------------
# Input data (generic name)
# ------------------------------------------------------------
diallel_data <- pooled_diallel_data

diallel_data <- diallel_data %>%
  mutate(
    Parent1 = factor(Parent1),
    Parent2 = factor(Parent2),
    Location = factor(Location),
    Replication = factor(Replication),
    Cross = interaction(Parent1, Parent2, drop = TRUE)
  )

parents <- sort(unique(diallel_data$Parent1))
p <- length(parents)
e <- length(unique(diallel_data$Location))

# ------------------------------------------------------------
# Identify response traits
# ------------------------------------------------------------
response_traits <- setdiff(
  names(diallel_data),
  c("Parent1", "Parent2", "Cross", "Replication", "Location")
)

# ------------------------------------------------------------
# Output workbook
# ------------------------------------------------------------
wb <- createWorkbook()

# ============================================================
# MAIN ANALYSIS LOOP
# ============================================================
for (trait in response_traits) {

  if (!is.numeric(diallel_data[[trait]])) next

  df <- diallel_data %>%
    select(
      Parent1, Parent2, Cross,
      Replication, Location,
      Trait = all_of(trait)
    )

  # ----------------------------------------------------------
  # Linear model for pooled diallel analysis
  # ----------------------------------------------------------
  model <- aov(
    Trait ~
      Location +
      Replication %in% Location +
      Parent1 + Parent2 +
      Cross +
      Location:Parent1 +
      Location:Parent2 +
      Location:Cross,
    data = df
  )

  # ----------------------------------------------------------
  # Raw ANOVA table
  # ----------------------------------------------------------
  aov_raw <- summary(model)[[1]]

  aov_df <- data.frame(
    Source = trimws(rownames(aov_raw)),
    df_mod = aov_raw[, "Df"],
    SS_mod = aov_raw[, "Sum Sq"],
    MS_mod = aov_raw[, "Mean Sq"],
    row.names = NULL
  )

  # ----------------------------------------------------------
  # Collapse sums of squares for reporting
  # ----------------------------------------------------------
  collapse_ss <- function(src)
    sum(aov_df$SS_mod[aov_df$Source %in% src])

  SS_env  <- collapse_ss("Location")
  SS_gca  <- collapse_ss(c("Parent1", "Parent2"))
  SS_sca  <- collapse_ss("Cross")
  SS_gcaE <- collapse_ss(c("Location:Parent1", "Location:Parent2"))
  SS_scaE <- collapse_ss("Location:Cross")
  SS_err  <- collapse_ss("Residuals")

  # ----------------------------------------------------------
  # Theoretical degrees of freedom (Griffing)
  # ----------------------------------------------------------
  df_env  <- e - 1
  df_gca  <- p - 1
  df_sca  <- p * (p - 1) / 2
  df_gcaE <- (p - 1) * (e - 1)
  df_scaE <- (p * (p - 1) / 2) * (e - 1)
  df_err  <- aov_df$df_mod[aov_df$Source == "Residuals"]

  # ----------------------------------------------------------
  # Mean squares for F tests
  # ----------------------------------------------------------
  MS_env   <- aov_df$MS_mod[aov_df$Source == "Location"]
  MS_repE <- aov_df$MS_mod[grep("Replication", aov_df$Source)]

  MS_gca  <- mean(aov_df$MS_mod[aov_df$Source %in% c("Parent1","Parent2")])
  MS_sca  <- aov_df$MS_mod[aov_df$Source == "Cross"]
  MS_gcaE <- mean(aov_df$MS_mod[aov_df$Source %in%
                                 c("Location:Parent1","Location:Parent2")])
  MS_scaE <- aov_df$MS_mod[aov_df$Source == "Location:Cross"]
  MS_err  <- aov_df$MS_mod[aov_df$Source == "Residuals"]

  # ----------------------------------------------------------
  # F tests
  # ----------------------------------------------------------
  F_env  <- MS_env  / MS_repE
  F_gca  <- MS_gca  / MS_gcaE
  F_sca  <- MS_sca  / MS_scaE
  F_gcaE <- MS_gcaE / MS_err
  F_scaE <- MS_scaE / MS_err

  Pr_env  <- pf(F_env,  df_env,  length(MS_repE), lower.tail = FALSE)
  Pr_gca  <- pf(F_gca,  df_gca,  df_gcaE, lower.tail = FALSE)
  Pr_sca  <- pf(F_sca,  df_sca,  df_scaE, lower.tail = FALSE)
  Pr_gcaE <- pf(F_gcaE, df_gcaE, df_err,  lower.tail = FALSE)
  Pr_scaE <- pf(F_scaE, df_scaE, df_err,  lower.tail = FALSE)

  signif_code <- function(p)
    ifelse(p < 0.001,"***",
           ifelse(p < 0.01,"**",
                  ifelse(p < 0.05,"*","ns")))

  pooled_anova <- data.frame(
    Source = c("Environment","GCA","SCA",
               "GCA × Environment","SCA × Environment","Error"),
    df = c(df_env, df_gca, df_sca, df_gcaE, df_scaE, df_err),
    SS = c(SS_env, SS_gca, SS_sca, SS_gcaE, SS_scaE, SS_err),
    MS = c(SS_env/df_env, SS_gca/df_gca, SS_sca/df_sca,
           SS_gcaE/df_gcaE, SS_scaE/df_scaE, SS_err/df_err),
    F  = c(F_env, F_gca, F_sca, F_gcaE, F_scaE, NA),
    Pr = c(Pr_env, Pr_gca, Pr_sca, Pr_gcaE, Pr_scaE, NA),
    Sig = c(
      signif_code(Pr_env),
      signif_code(Pr_gca),
      signif_code(Pr_sca),
      signif_code(Pr_gcaE),
      signif_code(Pr_scaE),
      ""
    )
  )

  # ----------------------------------------------------------
  # Fitted means
  # ----------------------------------------------------------
  df$Fitted <- fitted(model)

  cross_means <- df %>%
    group_by(Parent1, Parent2) %>%
    summarise(Yhat = mean(Fitted), .groups = "drop")

  grand_mean <- mean(cross_means$Yhat)

  # ----------------------------------------------------------
  # Pooled GCA
  # ----------------------------------------------------------
  gca_tbl <- cross_means %>%
    pivot_longer(c(Parent1, Parent2), values_to = "Parent") %>%
    group_by(Parent) %>%
    summarise(mean_ij = mean(Yhat), .groups = "drop") %>%
    mutate(Pooled_GCA = mean_ij - grand_mean)

  # ----------------------------------------------------------
  # Pooled SCA
  # ----------------------------------------------------------
  sca_tbl <- cross_means %>%
    left_join(gca_tbl, by = c("Parent1" = "Parent")) %>%
    rename(g_i = Pooled_GCA) %>%
    left_join(gca_tbl, by = c("Parent2" = "Parent")) %>%
    rename(g_j = Pooled_GCA) %>%
    mutate(SCA = Yhat - grand_mean - g_i - g_j)

  # ----------------------------------------------------------
  # Standard errors and CD
  # ----------------------------------------------------------
  r <- length(unique(df$Replication))

  SE_gca <- sqrt(((p - 1) / p) * (MS_err / (e * r)))
  SE_sca <- sqrt(MS_err / (e * r))

  t5 <- qt(0.975, df_err)
  t1 <- qt(0.995, df_err)

  CD_gca_5 <- t5 * sqrt(2) * SE_gca
  CD_gca_1 <- t1 * sqrt(2) * SE_gca
  CD_sca_5 <- t5 * sqrt(2) * SE_sca
  CD_sca_1 <- t1 * sqrt(2) * SE_sca

  gca_tbl <- gca_tbl %>%
    mutate(
      Sig_5 = ifelse(abs(Pooled_GCA) > CD_gca_5, "*", ""),
      Sig_1 = ifelse(abs(Pooled_GCA) > CD_gca_1, "**", "")
    )

  sca_tbl <- sca_tbl %>%
    mutate(
      Sig_5 = ifelse(abs(SCA) > CD_sca_5, "*", ""),
      Sig_1 = ifelse(abs(SCA) > CD_sca_1, "**", "")
    )

  # ----------------------------------------------------------
  # Write Excel output
  # ----------------------------------------------------------
  addWorksheet(wb, trait)

  writeData(wb, trait, "Pooled ANOVA", startRow = 1)
  writeData(wb, trait, pooled_anova, startRow = 2)

  r0 <- nrow(pooled_anova) + 4
  writeData(wb, trait, "Pooled GCA Effects", startRow = r0)
  writeData(wb, trait, gca_tbl, startRow = r0 + 1)

  r1 <- r0 + nrow(gca_tbl) + 4
  writeData(wb, trait, "Pooled SCA Effects", startRow = r1)
  writeData(wb, trait, sca_tbl, startRow = r1 + 1)

  r2 <- r1 + nrow(sca_tbl) + 4
  writeData(wb, trait, "Standard Errors and CD", startRow = r2)
  writeData(
    wb, trait,
    data.frame(
      Effect = c("GCA","SCA"),
      SE = c(SE_gca, SE_sca),
      CD_5 = c(CD_gca_5, CD_sca_5),
      CD_1 = c(CD_gca_1, CD_sca_1)
    ),
    startRow = r2 + 1
  )
}

# ------------------------------------------------------------
# Save Excel file
# ------------------------------------------------------------
saveWorkbook(
  wb,
  "Pooled_Diallel_GCA_SCA_Analysis.xlsx",
  overwrite = TRUE
)
