# for manipulating  rodent movement data in MARK
## analyze survival and dispseral probabilities for species and guilds
# Use multistrata models that give S(survival), p(capture probability) and Psi(transition probability)
# Will compare data among species and guilds. 
# Major covariates include sex, guild, and average body mass

# Do psi and S significantly differ among species/guilds?

# Within a species/guild, do covariates (sex, body mass) influence psi and S?

rm(list=ls(all=TRUE))   # clears the computer's memory
library(RMark) 

#---------------------------------------------------------------------------------
#          bring in the data and source files
#---------------------------------------------------------------------------------
#set working directory and import source code
setwd("~/")

# Run the line below to generate new .inp files 
#source("stake_movement.r") #makes a mark data structure using species-level data from Portal Project


# bring in the inp file and convert it to RMark format - This file includes all the data from all the species 
ms_data <- convert.inp("mark_datafiles//all_mark.inp", group.df=data.frame(sex = c("male","female","unidsex")),  
                      covariates = c("sd_mass", "guild", "species", "status"))
#convert to factor
ms_data$guild = as.factor(ms_data$guild)
ms_data$species = as.factor(ms_data$species)
ms_data$status = as.factor(ms_data$status)

#---------------------------------------------------------------------------------
#          process multistrata data, includes capture at home, and dipsersal transitions 
#---------------------------------------------------------------------------------
# Build up the model. Looking at sex effects on dispersal/survival
ms_process <- process.data(ms_data, model = "Multistrata", begin.time = 261, groups = c("sex", "guild", "species", "status"))

ms_ddl <- make.design.data(ms_process) #ddl = design data list

#---------------------------------------------------------------------------------
#          make dummy variables and covariates
#---------------------------------------------------------------------------------
# Add dummy variables for operating on specific states(strata) or transitions
# A = 1 (home), B = 2 (away)
# A to B and B to B, is risky
# A to A and B to A, is less risky (within home, "normal" movements)

# Surival probability given that the individual is in A
ms_ddl$S$inA = 0
ms_ddl$S$inA[ms_ddl$S$stratum == "1"] = 1

# Surival probability given that the individual is in B
ms_ddl$S$inB = 0
ms_ddl$S$inB[ms_ddl$S$stratum == "2"] = 1

# Transition probability given that the individual  A ---> B
ms_ddl$Psi$toA = 0
ms_ddl$Psi$toA[ms_ddl$Psi$stratum == "2" & ms_ddl$Psi$tostratum == "1"] = 1

# Transition probability given that the individual  B ---> A
ms_ddl$Psi$toB = 0
ms_ddl$Psi$toB[ms_ddl$Psi$stratum == "1" & ms_ddl$Psi$tostratum == "2"] = 1 

# recapture probability given that the individual is in A
ms_ddl$p$strataA = 0
ms_ddl$p$strataA[ms_ddl$p$stratum == "1"] = 1

# recapture probability given that the individual is in B
ms_ddl$p$strataB = 0
ms_ddl$p$strataB[ms_ddl$p$stratum == "2"] = 1


#--------------------------------------------------------------------------------
#           Build up the models
#---------------------------------------------------------------------------------
#          Define model structures for S (survival probability)
#---------------------------------------------------------------------------------
Snull <- list(formula = ~1)          

Sstrata <- list(formula = ~stratum)   

Sguild <- list(formula = ~guild)  

Sspecies <- list(formula = ~species) 

Sstatus <- list(formula = ~status) 

Sspeciesstrata <- list(formula = ~species * strata) 

#---------------------------------------------------------------------------------
#          Define model structures for p (capture probability)
#---------------------------------------------------------------------------------
# fix recapture probabilities for unsampled or omitted months
#    skipped_periods = c(267, 277, 278, 283, 284, 300, 311, 313, 314, 318, 321, 323, 337, 339, 344, 351): p = 0

# select periods that were omitted from the study - untrapped
p267 = as.numeric(row.names(ms_ddl$p[ms_ddl$p$time == 267,])) 
p277 = as.numeric(row.names(ms_ddl$p[ms_ddl$p$time == 277,]))
p278 = as.numeric(row.names(ms_ddl$p[ms_ddl$p$time == 278,]))
p283 = as.numeric(row.names(ms_ddl$p[ms_ddl$p$time == 283,]))
p284 = as.numeric(row.names(ms_ddl$p[ms_ddl$p$time == 284,]))
p300 = as.numeric(row.names(ms_ddl$p[ms_ddl$p$time == 300,]))
p311 = as.numeric(row.names(ms_ddl$p[ms_ddl$p$time == 311,]))
p313 = as.numeric(row.names(ms_ddl$p[ms_ddl$p$time == 313,]))
p314 = as.numeric(row.names(ms_ddl$p[ms_ddl$p$time == 314,]))
p318 = as.numeric(row.names(ms_ddl$p[ms_ddl$p$time == 318,]))
p321 = as.numeric(row.names(ms_ddl$p[ms_ddl$p$time == 321,]))
p323 = as.numeric(row.names(ms_ddl$p[ms_ddl$p$time == 323,]))
p337 = as.numeric(row.names(ms_ddl$p[ms_ddl$p$time == 337,]))
p339 = as.numeric(row.names(ms_ddl$p[ms_ddl$p$time == 339,]))
p344 = as.numeric(row.names(ms_ddl$p[ms_ddl$p$time == 344,]))
p351 = as.numeric(row.names(ms_ddl$p[ms_ddl$p$time == 351,]))

# set those periods to p = 0, because they *can't* be anything else
p267val = rep(0, length(p267))
p277val = rep(0, length(p277))
p278val = rep(0, length(p278))
p283val = rep(0, length(p283))
p284val = rep(0, length(p284))
p300val = rep(0, length(p300))
p311val = rep(0, length(p311))
p313val = rep(0, length(p313))
p314val = rep(0, length(p314))
p318val = rep(0, length(p318))
p321val = rep(0, length(p321))
p323val = rep(0, length(p323))
p337val = rep(0, length(p337))
p339val = rep(0, length(p339))
p344val = rep(0, length(p344))
p351val = rep(0, length(p351))


# look for effects on recapture probability, given that some p are fixed to 0 (listed below)
# link = "logit" is the default. "cloglog" may be esp. useful when there are fewer recaptures

#Null Model
pnull <- list(formula = ~1, fixed = list(index = c(p267, p277, p278, p283, p284, p300, p311, p313, p314,
                                                   p318, p321, p323, p337, p339, p344, p351), 
                                         value = c(p267val, p277val, p278val, p283val, p284val, p300val, p311val,
                                                   p313val, p314val, p318val, p321val, p323val, p337val, p339val,
                                                   p344val, p351val), link = "cloglog"))
# Strata effect (in A or in B)
pstrata <- list(formula = ~stratum, fixed = list(index = c(p267, p277, p278, p283, p284, p300, p311, p313, p314,
                                                     p318, p321, p323, p337, p339, p344, p351), 
                                             value = c(p267val, p277val, p278val, p283val, p284val, p300val, p311val,
                                                       p313val, p314val, p318val, p321val, p323val, p337val, p339val,
                                                       p344val, p351val), link = "cloglog"))
# Guild effect 
pguild <- list(formula = ~guild, fixed = list(index = c(p267, p277, p278, p283, p284, p300, p311, p313, p314,
                                                                   p318, p321, p323, p337, p339, p344, p351), 
                                                         value = c(p267val, p277val, p278val, p283val, p284val, p300val, p311val,
                                                                   p313val, p314val, p318val, p321val, p323val, p337val, p339val,
                                                                   p344val, p351val), link = "cloglog"))
# Species effect
pspecies <- list(formula = ~species, fixed = list(index = c(p267, p277, p278, p283, p284, p300, p311, p313, p314,
                                                                       p318, p321, p323, p337, p339, p344, p351), 
                                                             value = c(p267val, p277val, p278val, p283val, p284val, p300val, p311val,
                                                                       p313val, p314val, p318val, p321val, p323val, p337val, p339val,
                                                                       p344val, p351val), link = "cloglog"))
# status effect
pstatus <- list(formula = ~status, fixed = list(index = c(p267, p277, p278, p283, p284, p300, p311, p313, p314,
                                                                       p318, p321, p323, p337, p339, p344, p351), 
                                                             value = c(p267val, p277val, p278val, p283val, p284val, p300val, p311val,
                                                                       p313val, p314val, p318val, p321val, p323val, p337val, p339val,
                                                                       p344val, p351val), link = "cloglog"))



#---------------------------------------------------------------------------------
#          Define model structures for Psi (transition probability)
#---------------------------------------------------------------------------------
Psinull <- list(formula = ~1, link = "logit")

Psistrata <- list(formula = ~stratum, link = "logit")

Psiguild <- list(formula = ~guild, link = "logit")

Psispecies <- list(formula = ~species, link = "logit")

Psistatus <- list(formula = ~status, link = "logit")

Psispeciesstrata <- list(formulat = ~species * strata, link = "logit")

#---------------------------------------------------------------------------------
#          Run Models and collect results
#---------------------------------------------------------------------------------
#send results to new folder - change working directory
wd = "mark_output"
setwd(wd)

# #SIMANNEAL should be best for multistrata models, but may take longer to run
Snull_pnull_Psinull <- mark(ms_process, ms_ddl, model.parameters = list(S = Snull,  p = pnull, Psi = Psinull),
                            options = "SIMANNEAL")

Sstrata_pstrata_Psistrata <- mark(ms_process, ms_ddl, model.parameters = list(S = Sstrata,  p = pstrata, Psi = Psistrata),
                                  options = "SIMANNEAL")

Sguild_pguild_Psiguild <- mark(ms_process, ms_ddl, model.parameters = list(S = Sguild,  p = pguild, Psi = Psiguild),
                               options = "SIMANNEAL")

Sspecies_pspecies_Psispecies <- mark(ms_process, ms_ddl, model.parameters = list(S = Sspecies,  p = pspecies, Psi = Psispecies),
                                     options = "SIMANNEAL")

Sstatus_pstatus_Psistatus <- mark(ms_process, ms_ddl, model.parameters = list(S = Sstatus, p = pstatus, Psi = Psistatus), 
                                  options = "SIMANNEAL")


Sspeciesstrata_pguild_Psispeciesstrata <- mark(ms_process, ms_ddl, model.parameters = list (s = Sspeciesstrata, p = pguild, Psi = Psispeciesstrata),
                                               options = "SIMANNEAL")

#summarize results
ms_results <- collect.models(type = "Multistrata")


#---------------------------------------------------------------------------------
#          Write result data to csv files
#---------------------------------------------------------------------------------
write.csv(Snull_pnull_Psinull$results$beta, "ms_null_beta.csv")
write.csv(Snull_pnull_Psinull$results$real, "ms_null_real.csv")
write.csv(Sstrata_pstrata_Psistrata$results$beta, "ms_strata_beta.csv")
write.csv(Sstrata_pstrata_Psistrata$results$real, "ms_strata_real.csv")
write.csv(Sguild_pguild_Psiguild$results$beta, "ms_guild_beta.csv")
write.csv(Sguild_pguild_Psiguild$results$real, "ms_guild_real.csv")
write.csv(Sspecies_pspecies_Psispecies$results$beta, "ms_species_beta.csv")
write.csv(Sspecies_pspecies_Psispecies$results$real, "ms_species_real.csv")
write.csv(Sstatus_pstatus_Psistatus$results$beta, "ms_status_beta.csv")
write.csv(Sstatus_pstatus_Psistatus$results$real, "ms_status_real.csv")




# #Null model
# Snull_pnull_Psinull <- mark(ms_process,ms_ddl, model.parameters = list(S = Snull,  p = pnull, Psi = Psinull)),
#                             options = "SIMANNEAL")
# #S on guild
# Sguild_pnull_Psinull <- mark(ms_process,ms_ddl, model.parameters = list(S = Sguild,  p = pnull, Psi = Psinull),
#                              options = "SIMANNEAL")
# #S and Psi on guild
# Sguild_pnull_Psiguild <- mark(ms_process,ms_ddl, model.parameters = list(S = Sguild,  p = pnull, Psi = Psiguild),
#                               options = "SIMANNEAL")
# #S, p and Psi on guild
# Sguild_pguild_Psiguild <- mark(ms_process,ms_ddl, model.parameters = list(S = Sguild,  p = pguild, Psi = Psiguild),
#                                options = "SIMANNEAL")
# #Psi on guild
# Snull_pnull_Psiguild <- mark(ms_process,ms_ddl, model.parameters = list(S = Snull,  p = pnull, Psi = Psiguild),
#                                  options = "SIMANNEAL")
# 
# #S, p and Psi on strata
# Sstrata_pstrata_Psistrata <- mark(ms_process,ms_ddl, model.parameters = list(S = Sstrata,  p = pstrata, Psi = Psistrata),
#                                   options = "SIMANNEAL")
# #s on guild, p and Psi on strata
# Sguild_pstrata_Psistrata <- mark(ms_process,ms_ddl, model.parameters = list(S = Sguild,  p = pstrata, Psi = Psiguild),
#                                  options = "SIMANNEAL")
# #Psi on guild, S and p on strata
# Sstrata_pstrata_Psiguild <- mark(ms_process,ms_ddl, model.parameters = list(S = Sstrata,  p = pstrata, Psi = Psiguild),
#                                  options = "SIMANNEAL")
# #S and Psi on guld, p on strata
# Sguild_pstrata_Psiguild <- mark(ms_process,ms_ddl, model.parameters = list(S = Sguild,  p = pstrata, Psi = Psiguild),
#                                  options = "SIMANNEAL")
# 
# #S, p and Psi on species
# Sspecies_pspecies_Pspecies <- mark(ms_process,ms_ddl, model.parameters = list(S = Sspecies,  p = pspecies, Psi = Pspecies),
#                                    options = "SIMANNEAL")
# #S and Psi on species
# Sspecies_pnull_Pspecies <- mark(ms_process,ms_ddl, model.parameters = list(S = Sspecies,  p = pnull, Psi = Pspecies),
#                                    options = "SIMANNEAL")