# for manipulating  rodent movement data in MARK
## analyze survival and dispseral probabilities for species and guilds
# Use multistrata models that give S(survival), p(capture probability) and Psi(transition probability)
# Will compare data among species and guilds. 
# Major covariates include sex, guild, and average body mass

library(RMark) 

#set working directory and import source code
wd = "C://Users//sarah//Documents//GitHub//portal-rodent-dispersal"
setwd(wd)

source("movement_fxns.r") #functions for stake_movement.r
source("stake_movement.r") #makes a mark data structure using species-level data from Portal Project


# bring in the inp file and convert it to RMark format 
ms_data <- convert.inp("mark_datafiles//do_mark.inp", group.df=data.frame(sex=c("male","female","unidsex")),  #FIXME
                      covariates = data.frame(mass = "sd_mass", guild = c("hgran", "cgran", "foli")))

# Build up the model. Looking at sex effects on dispersal/survival
ms_process <- process.data(ms_data,model="Multistrata",begin.time=2000,
                           group=c("sex"), covariates = c("mass", "guild"))

ms_ddl <- make.design.data(ms_process)

# Add dynamic dummy variable age class fields to the design data for Psi and p
ms_ddl$Psi$hy=0
ms_ddl$Psi$hy[ms_ddl$Psi$sex==0&ms_ddl$Psi$stratum=="A"]=1
ms_ddl$Psi$ahy=0
ms_ddl$Psi$ahy[ms_ddl$Psi$sex>=1&ms_ddl$Psi$stratum=="A"]=1

ms_ddl$p$hy=0
ms_ddl$p$hy[ms_ddl$p$sex==1&ms_ddl$p$stratum=="A"]=1
ms_ddl$p$hy[ms_ddl$p$sex==1&ms_ddl$p$stratum=="B"]=1
ms_ddl$p$sy=0
ms_ddl$p$sy[ms_ddl$p$sex==2&ms_ddl$p$stratum=="A"]=1
ms_ddl$p$asy=0
ms_ddl$p$asy[ms_ddl$p$sex>=3&ms_ddl$p$stratum=="A"]=1
ms_ddl$p$ahy=0
ms_ddl$p$ahy[ms_ddl$p$sex>=2&ms_ddl$p$stratum=="B"]=1

##### Add dummy variables for operating on specific states or transitions
  # A = 1 (home), B = 2 (away)
  # moving to B from anywhere, is risky
  # moving to A from anywhere, is less risky (within home, "normal" movements)
ms_ddl$Psi$toB=0
ms_ddl$Psi$toB[ms_ddl$Psi$stratum=="1" & ms_ddl$Psi$tostratum=="2"]=1

ms_ddl$Psi$toA=0
ms_ddl$Psi$toA[ms_ddl$Psi$stratum=="2"]=1

ms_ddl$p$strA=0
ms_ddl$p$strA[ms_ddl$p$stratum=="A"]=1
ms_ddl$p$strB=0
ms_ddl$p$strB[ms_ddl$p$stratum=="B"]=1

## TODO: fix recapture probabilities for unsampled or omitted months!
    # periods = c(267, 277, 278, 283, 284, 300, 311, 313, 314, 318, 321, 323, 
              #   337, 339, 344, 351)

# Add a field for monthly reporting probabilities 
ms_ddl$p$rpt=0
ms_ddl$p$rpt[ms_ddl$p$prd] == 267 = 0
ms_ddl$p$rpt[ms_ddl$p$prd] == 277 = 0

# TODO: Lots of work on building up the models!
                          