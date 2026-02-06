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
