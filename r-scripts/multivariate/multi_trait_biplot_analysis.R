# Multi-trait Biplot Analysis
# Methods: GT, GYT, MGIDI, GGE
# Package: metan

library(metan)

gt_model <- gtb(data, Genotypes, resp = Gy:A)
plot(gt_model)

gyt_model <- gytb(
  data,
  gen = Genotypes,
  yield = Gy,
  traits = c(NSP, PP, Tw, Ph, PB, NDVI, SPAD, RWC, MSI, Proline, E, GH2O, A)
)
plot(gyt_model)

mgidi_data <- data[, c(
  "Genotypes","Gy","NSP","PP","Tw","Ph","PB",
  "NDVI","SPAD","RWC","MSI","Proline","E","GH2O","A"
)]

mgidi_model <- mgidi(
  mgidi_data,
  SI = 15,
  ideotype = rep("h", 14),
  verbose = TRUE
)

plot(mgidi_model)
plot(mgidi_model, type = "contribution")

gge_model <- gge(
  Revised_01Feb2026,
  env = Env,
  gen = Genotypes,
  resp = Gy
)

plot(gge_model, label = "both", repel = TRUE)
