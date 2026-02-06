# Diallel Analysis (Griffing Method II)

Implements Griffing's Method II for half-diallel crosses to estimate:
- General combining ability (GCA)
- Specific combining ability (SCA)

## Scope of Analysis

This script performs **single-location diallel analysis** using
**Griffing’s Method II (Model I)**.

Although the input dataset may contain a location identifier,
the Griffing model implemented here does **not include location
effects or genotype × location interaction**.

Therefore:

- The analysis assumes data from **one environment/location at a time**, or
- Griffing analysis should be conducted **separately for each location**

Pooled diallel analysis across locations is **not implemented** in this script
and should be preceded by appropriate pooled ANOVA to confirm
homogeneity of error variances.

This approach follows standard practice in plant breeding research,
where combining ability parameters are estimated separately for
each environment.

#**Pooled_diallel_gca_sca_analysis**
# Pooled Diallel Analysis (GCA and SCA)

The file pooled_diallel_gca_sca_analysis contains R scripts for **pooled (multi-environment) diallel analysis**
based on Griffing’s fixed-effects framework. The analyses are designed for
half-diallel mating designs commonly used in plant breeding and quantitative
genetics.

---

## Script Included

### `pooled_diallel_gca_sca_analysis.R`

**Purpose**  
Performs pooled diallel analysis across multiple locations/environments to
estimate:

- General combining ability (GCA)
- Specific combining ability (SCA)
- Environment, GCA, and SCA interactions
- Standard errors and critical differences

Results are exported to Excel with **one worksheet per trait**, suitable for
thesis writing and publication.

---

## Statistical Model

For each trait, the following linear model is fitted:

Y = μ + Environment + Rep(Environment)
+ GCA + SCA
+ GCA × Environment
+ SCA × Environment
+ Error


Where:
- **GCA** is estimated from parental effects
- **SCA** is estimated from cross effects
- Environments are treated as fixed
- Replications are nested within environments

---

## Scope of Analysis

- ✔ **Multi-location (pooled) diallel analysis**
- ✔ Half-diallel mating design
- ✔ Fixed-effects (Griffing-type) interpretation
- ✔ Suitable when homogeneity of error variances across environments
  has been established through pooled ANOVA

This script is **not** intended for single-location analysis.  
For single-environment diallel analysis, use the corresponding
single-location Griffing script.

---

## Input Data Requirements

The input dataset must contain:

- Parent identifiers (`Parent1`, `Parent2`)
- Location or environment identifier (`Location`)
- Replication identifier (`Replication`)
- Numeric trait columns

Each row should represent one experimental unit.

---

## Output

An Excel workbook is generated containing, for each trait:

1. Pooled ANOVA table
2. Pooled GCA effects
3. Pooled SCA effects
4. Standard errors and critical differences (5% and 1%)

---

## Packages Used

- `dplyr`
- `tidyr`
- `openxlsx`

---

## Notes

This implementation follows standard diallel analysis methodology
used in plant breeding research and is intended for transparent,
reproducible reporting of combining ability studies.
