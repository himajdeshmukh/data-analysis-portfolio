# ============================================================
# Title: Location-wise Partitioned ANOVA for Half-Diallel Analysis
#
# Description:
#   Performs location-wise, thesis-style ANOVA for half-diallel
#   experiments with orthogonal partitioning of treatments into
#   Parents, Crosses, and Parents vs Crosses.
#
#   Generates Excel output with one worksheet per
#   trait × location combination.
#
# ============================================================

library(dplyr)
library(tidyr)
library(emmeans)
library(openxlsx)
library(DiallelAnalysisR)

# ------------------------------------------------------------
# Input data (generic name)
# ------------------------------------------------------------
diallel_data <- diallel_dataset

diallel_data <- diallel_data %>%
  mutate(
    Replication = factor(Replication),
    Location = factor(Location),
    Parent1 = factor(Parent1),
    Parent2 = factor(Parent2),
    Genotype = factor(paste(Parent1, Parent2, sep = "x")),
    EntryType = factor(ifelse(Parent1 == Parent2, "Parent", "Cross"))
  )

# Response variables (traits)
response_traits <- c(
  "Trait_1","Trait_2","Trait_3","Trait_4","Trait_5",
  "Trait_6","Trait_7","Trait_8","Trait_9","Trait_10",
  "Trait_11","Trait_12","Trait_13","Trait_14",
  "Trait_15","Trait_16","Trait_17","Trait_18","Trait_19"
)

# ------------------------------------------------------------
# Significance symbols
# ------------------------------------------------------------
significance_code <- function(p){
  ifelse(p < 0.01, "**",
         ifelse(p < 0.05, "*", ""))
}

# ------------------------------------------------------------
# Workbook setup
# ------------------------------------------------------------
workbook <- createWorkbook()

# ============================================================
# ANALYSIS LOOP
# ============================================================
for(trait in response_traits){
  for(loc in levels(diallel_data$Location)){

    df_loc <- diallel_data %>% filter(Location == loc)

    # Orthogonal ANOVA model
    model <- aov(
      as.formula(paste(trait, "~ Replication + EntryType + EntryType:Genotype")),
      data = df_loc
    )

    aov_tab <- anova(model)

    # Extract sources
    df_rep <- aov_tab["Replication","Df"]
    ss_rep <- aov_tab["Replication","Sum Sq"]
    ms_rep <- aov_tab["Replication","Mean Sq"]

    df_pvc <- aov_tab["EntryType","Df"]
    ss_pvc <- aov_tab["EntryType","Sum Sq"]
    ms_pvc <- aov_tab["EntryType","Mean Sq"]

    df_pc  <- aov_tab["EntryType:Genotype","Df"]
    ss_pc  <- aov_tab["EntryType:Genotype","Sum Sq"]
    ms_pc  <- aov_tab["EntryType:Genotype","Mean Sq"]

    df_err <- aov_tab["Residuals","Df"]
    ss_err <- aov_tab["Residuals","Sum Sq"]
    ms_err <- aov_tab["Residuals","Mean Sq"]

    # Supplementary ANOVA: Parents
    model_parent <- aov(
      as.formula(paste(trait, "~ Replication + Genotype")),
      data = df_loc %>% filter(EntryType == "Parent")
    )
    aov_parent <- anova(model_parent)

    # Supplementary ANOVA: Crosses
    model_cross <- aov(
      as.formula(paste(trait, "~ Replication + Genotype")),
      data = df_loc %>% filter(EntryType == "Cross")
    )
    aov_cross <- anova(model_cross)

    # Treatments
    df_trt <- df_pvc + df_pc
    ss_trt <- ss_pvc + ss_pc
    ms_trt <- ss_trt / df_trt

    # F and P values
    f_rep <- ms_rep / ms_err
    f_trt <- ms_trt / ms_err
    f_pvc <- ms_pvc / ms_err

    p_rep <- pf(f_rep, df_rep, df_err, lower.tail = FALSE)
    p_trt <- pf(f_trt, df_trt, df_err, lower.tail = FALSE)
    p_pvc <- pf(f_pvc, df_pvc, df_err, lower.tail = FALSE)

    # Parents and Crosses
    df_par <- aov_parent["Genotype","Df"]
    ss_par <- aov_parent["Genotype","Sum Sq"]
    ms_par <- aov_parent["Genotype","Mean Sq"]
    f_par  <- aov_parent["Genotype","F value"]
    p_par  <- aov_parent["Genotype","Pr(>F)"]

    df_crs <- aov_cross["Genotype","Df"]
    ss_crs <- aov_cross["Genotype","Sum Sq"]
    ms_crs <- aov_cross["Genotype","Mean Sq"]
    f_crs  <- aov_cross["Genotype","F value"]
    p_crs  <- aov_cross["Genotype","Pr(>F)"]

    # Summary statistics
    r <- length(unique(df_loc$Replication))
    grand_mean <- mean(df_loc[[trait]], na.rm = TRUE)

    SEm <- sqrt(ms_err / r)
    CD  <- qt(0.975, df_err) * SEm * sqrt(2)
    CV  <- sqrt(ms_err) / grand_mean * 100

    # Final ANOVA table
    result_table <- data.frame(
      Source = c("Replications","Treatments","Parents",
                 "Crosses","Parents vs Crosses","Error"),
      Df = c(df_rep, df_trt, df_par, df_crs, df_pvc, df_err),
      Sum_Sq = c(ss_rep, ss_trt, ss_par, ss_crs, ss_pvc, ss_err),
      Mean_Sq = c(ms_rep, ms_trt, ms_par, ms_crs, ms_pvc, ms_err),
      F_value = c(f_rep, f_trt, f_par, f_crs, f_pvc, NA),
      Pr_F = c(p_rep, p_trt, p_par, p_crs, p_pvc, NA),
      Signif = c(
        significance_code(p_rep),
        significance_code(p_trt),
        significance_code(p_par),
        significance_code(p_crs),
        significance_code(p_pvc),
        ""
      )
    )

    sheet_name <- paste(trait, "Location", loc, sep = "_")
    addWorksheet(workbook, sheet_name)
    writeData(workbook, sheet_name, result_table)

    writeData(
      workbook,
      sheet_name,
      data.frame(
        Mean = grand_mean,
        SEm = SEm,
        CD_5percent = CD,
        CV_percent = CV
      ),
      startRow = nrow(result_table) + 4
    )
  }
}

# ------------------------------------------------------------
# Save Excel output
# ------------------------------------------------------------
saveWorkbook(
  workbook,
  file = "Diallel_Locationwise_ANOVA.xlsx",
  overwrite = TRUE
)
