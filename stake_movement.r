# Code for working with individual-level rodent data
# movement with stakes

library(calibrate)
library(fields)

#---------------------------------------------------------------------------------
#          setup - select wd, import data, source code,  file to collect results
#---------------------------------------------------------------------------------
#set working directory
wd = "C://Users//sarah//Documents//GitHub//portal-rodent-dispersal"
setwd(wd)
source("movement_fxns.R")

#import the data by guild
het = read.csv("rawdata//heteromyids_2000-2009.csv")   # DO, DM, PB, PP, PF
cricet = read.csv("rawdata//cricetids_2000-2009.csv")  # PE, PM, RM
foliv = read.csv("rawdata//folivores_2000-2009.csv")   # SH, SF, NA (as NAO)
insec = read.csv("rawdata//onychomys_2000-2009.csv")   # OT, OL

# output directed to rodent_results.txt in wd. output is appended
# to existing file. output also sent to terminal. 
sink("rodent_results.txt", append=TRUE, split=TRUE)

#---------------------------------------------------------------------------------
#          clean up the data
#---------------------------------------------------------------------------------

# change some cols from factor to character class
het$tag = as.character(het$tag); cricet$tag = as.character(cricet$tag); foliv$tag = as.character(foliv$tag); insec$tag = as.character(insec$tag)
het$species = as.character(het$species); cricet$species = as.character(cricet$species); foliv$species = as.character(foliv$species); insec$species = as.character(insec$species)
het$sex = as.character(het$sex); cricet$sex = as.character(cricet$sex); foliv$sex = as.character(foliv$sex); insec$sex = as.character(insec$sex)

# give untagged individuals a unique 7-number code
het = id_unknowns(het, 16); cricet = id_unknowns(cricet, 16); foliv = id_unknowns(foliv, 16); insec = id_unknowns(insec, 16)

# get rid of 'bad data'; deletes data that is not a pit tag, where sex is inconsistent or where species is inconsistent. 
het = subsetDat(het); cricet = subsetDat(cricet); foliv = subsetDat(foliv); insec = subsetDat(insec)

#---------------------------------------------------------------------------------
#          calculate life-history details - reproduction, temporal persistence
#---------------------------------------------------------------------------------

#average proportion of reproductive females by month across all years
doreprd = mean_mo_repro(subset(het, species == "DO" & sex == "F")); dmreprd = mean_mo_repro(subset(het, species == "DM" & sex == "F")); pfreprd = mean_mo_repro(subset(het, species == "PF" & sex == "F")); ppreprd = mean_mo_repro(subset(het, species == "PP" & sex == "F")); pbreprd = mean_mo_repro(subset(het, species == "PB" & sex == "F"));
pereprd = mean_mo_repro(subset(cricet, species == "PE" & sex == "F")); pmreprd = mean_mo_repro(subset(cricet, species == "PM" & sex == "F")); rmreprd = mean_mo_repro(subset(cricet, species == "RM" & sex == "F"))
shreprd = mean_mo_repro(subset(foliv, species == "SH" & sex == "F")); sfreprd = mean_mo_repro(subset(foliv, species == "SF" & sex == "F")); naoreprd = mean_mo_repro(subset(foliv, species == "NAO" & sex == "F"))
otreprd = mean_mo_repro(subset(insec, species == "OT" & sex == "F")); olreprd = mean_mo_repro(subset(insec, species == "OL" & sex == "F"))

# proportion of reproductive females by month and year
doreprdyr = mo_repro(subset(het, species = "DO" & sex == "F"));

#track the number of times females uniquely reproduce within years
doirep = indiv_repro(subset(het, species == "DO" & sex == "F")); dmirep = indiv_repro(subset(het, species == "DM" & sex == "F")); pfirep = indiv_repro(subset(het, species == "PF" & sex == "F")); ppirep = indiv_repro(subset(het, species == "PP" & sex == "F")); pbirep = indiv_repro(subset(het, species == "PB" & sex == "F"));
peirep = indiv_repro(subset(cricet, species == "PE" & sex == "F")); pmirep = indiv_repro(subset(cricet, species == "PM" & sex == "F")); rmirep = indiv_repro(subset(cricet, species == "RM" & sex == "F"))
shirep = indiv_repro(subset(foliv, species == "SH" & sex == "F")); sfirep = indiv_repro(subset(foliv, species == "SF" & sex == "F")); naoirep = indiv_repro(subset(foliv, species == "NAO" & sex == "F"))
otirep = indiv_repro(subset(insec, species == "OT" & sex == "F")); olirep = indiv_repro(subset(insec, species == "OL" & sex == "F"))

#proportion of years they were seen in
doyr = length(unique(het[het$species=="DO",]$yr))/10; dmyr = length(unique(het[het$species=="DM",]$yr))/10; pfyr = length(unique(het[het$species=="PF",]$yr))/10; ppyr = length(unique(het[het$species=="PP",]$yr))/10; pbyr = length(unique(het[het$species=="PB",]$yr))/10
peyr = length(unique(cricet[cricet$species=="PE",]$yr))/10; pmyr = length(unique(cricet[cricet$species=="PM",]$yr))/10; rmyr = length(unique(cricet[cricet$species=="RM",]$yr))/10
shyr = length(unique(foliv[foliv$species=="SH",]$yr))/10; sfyr = length(unique(foliv[foliv$species=="SF",]$yr))/10; naoyr = length(unique(foliv[foliv$species=="NAO",]$yr))/10
otyr = length(unique(insec[insec$species=="OT",]$yr))/10; olyr = length(unique(insec[insec$species=="OL",]$yr))/10

# average number of months they were seen in during years in which they were present
domo = mean_win_yr_occ(subset(het, species == "DO")); dmmo = mean_win_yr_occ(subset(het, species == "DM")); pfmo = mean_win_yr_occ(subset(het, species == "PF")); ppmo = mean_win_yr_occ(subset(het, species == "PP")); pbmo = mean_win_yr_occ(subset(het, species == "PB"))
pemo = mean_win_yr_occ(subset(cricet, species == "PE")); pmmo = mean_win_yr_occ(subset(cricet, species == "PM")); rmmo = mean_win_yr_occ(subset(cricet, species == "RM"))
shmo = mean_win_yr_occ(subset(foliv, species == "SH")); sfmo = mean_win_yr_occ(subset(foliv, species == "SF")); naomo = mean_win_yr_occ(subset(foliv, species == "NAO"))
otmo = mean_win_yr_occ(subset(insec, species == "OT")); olmo = mean_win_yr_occ(subset(insec, species == "OL"))

#mean abundance within all years 
doabun = allyrs_abun(subset(het, species == "DO")); dmabun = allyrs_abun(subset(het, species == "DM")); pfabun = allyrs_abun(subset(het, species == "PF")); ppabun = allyrs_abun(subset(het, species == "PP")); pbabun = allyrs_abun(subset(het, species == "PB"))
peabun = allyrs_abun(subset(cricet, species == "PE")); pmabun = allyrs_abun(subset(cricet, species == "PM")); rmabun = allyrs_abun(subset(cricet, species == "RM"))
shabun = allyrs_abun(subset(foliv, species == "SH")); sfabun = allyrs_abun(subset(foliv, species == "SF")); naoabun = allyrs_abun(subset(foliv, species == "NAO"))
otabun = allyrs_abun(subset(insec, species == "OT")); olabun = allyrs_abun(subset(insec, species == "OL"))

abuns = cbind(doabun, dmabun, pbabun, ppabun, pfabun, peabun, pmabun, rmabun, shabun, sfabun, naoabun, otabun, olabun)

#---------------------------------------------------------------------------------
#          calculate movement distances, multi-state capture histories
#---------------------------------------------------------------------------------

# get a vector unique tags, then get a vector of distances moved for all recaptured individuals, by SPECIES
  #heteromyids
    dmtags = unique(het[het$species == "DM",]$tag); dotags = unique(het[het$species == "DO",]$tag); pbtags = unique(het[het$species == "PB",]$tag); pptags = unique(het[het$species == "PP",]$tag); pftags = unique(het[het$species == "PF",]$tag)
    dmmeters = distance_moved(het[het$species == "DM",], dmtags); dometers = distance_moved(het[het$species == "DO",], dotags); pbmeters = distance_moved(het[het$species == "PB",], pbtags); ppmeters = distance_moved(het[het$species == "PP",], pptags); pfmeters = distance_moved(het[het$species == "PF",], pftags)
#cricetids
    petags = unique(cricet[cricet$species == "PE",]$tag); pmtags = unique(cricet[cricet$species == "PM",]$tag); rmtags = unique(cricet[cricet$species == "RM",]$tag)
    pemeters = distance_moved(cricet[cricet$species == "PE",], petags); pmmeters = distance_moved(cricet[cricet$species == "PM",], pmtags); rmmeters = distance_moved(cricet[cricet$species == "RM",], rmtags)
#folivores
    shtags = unique(foliv[foliv$species == "SH",]$tag); sftags = unique(foliv[foliv$species == "SF",]$tag); naotags = unique(foliv[foliv$species == "NAO",]$tag)
    shmeters = distance_moved(foliv[foliv$species == "SH",], shtags); sfmeters = distance_moved(foliv[foliv$species == "SF",], sftags); naometers = distance_moved(foliv[foliv$species == "NAO",], naotags)
#insectivores
    oltags = unique(insec[insec$species == "OL",]$tag); ottags = unique(insec[insec$species == "OT",]$tag)
    olmeters = distance_moved(insec[insec$species == "OL",], oltags); otmeters = distance_moved(insec[insec$species == "OT",], ottags)

# concatenate distance vectors for recaptured individuals by GUILD
Hgran = c(dmmeters, dometers, pbmeters, ppmeters, pfmeters)
Cgran = c(pemeters, pmmeters, rmmeters)
foli = c(shmeters, sfmeters) #separate NAO because they use different strategy - MIDDENS
insectiv = c(otmeters, olmeters)

# find breakpoints to use in MARK data structure for future analyses
# data reasonably well fits a lognormal distribution (eyeball and J. Powell)
# breakpoint = mean(logdata) + sd(logdata) of all the distances traveled by recaptured individuals    
  # using log1p, and back transforming using expm1 should solve the problem of lots of zeros 
Cgran_brkpt = expm1(mean(log1p(Cgran)) + sd(log1p(Cgran)))
foli_brkpt = expm1(mean(log1p(foli)) + sd(log1p(foli)))
nao_brkpt = expm1(mean(log1p(naometers)) + sd(log1p(naometers)))
ins_brkpt = expm1(mean(log1p(insectiv)) + sd(log1p(insectiv)))

# Get MARK capture histories
## add unique breakpoints for each species based on histogram data of movement
periods = c(261:380)
exclosures = c(5, 7, 10, 16, 23, 24)
krat_excl = c(5, 7, 10, 16, 23, 24, 3, 6, 13, 15, 18, 19, 20, 21)
DO_MARK = noplacelikehome(subset(het, species == "DO"), periods, krat_excl, Hgran_brkpt)
DM_MARK = noplacelikehome(subset(het, species == "DM"), periods, krat_excl, Hgran_brkpt)
PB_MARK = noplacelikehome(subset(het, species == "PB"), periods, exclosures, Hgran_brkpt)
PP_MARK = noplacelikehome(subset(het, species == "PP"), periods, exclosures, Hgran_brkpt)
PF_MARK = noplacelikehome(subset(het, species == "PF"), periods, exclosures, Hgran_brkpt)
                          
PE_MARK = noplacelikehome(subset(cricet, species == "PE"), periods, exclosures, Cgran_brkpt) 
PM_MARK = noplacelikehome(subset(cricet, species == "PM"), periods, exclosures, Cgran_brkpt)
RM_MARK = noplacelikehome(subset(cricet, species == "RM"), periods, exclosures, Cgran_brkpt)
                          
SH_MARK = noplacelikehome(subset(foliv, species == "SH"), periods, exclosures, foli_brkpt)
SF_MARK = noplacelikehome(subset(foliv, species == "SF"), periods, exclosures, foli_brkpt)

NAO_MARK = noplacelikehome(subset(foliv, species == "NAO"), periods, exclosures, nao_brkpt)
                          
OT_MARK = noplacelikehome(subset(insec, species == "OT"), periods, exclosures, ins_brkpt)
OL_MARK = noplacelikehome(subset(insec, species == "OL"), periods, exclosures, ins_brkpt)

#---------------------------------------------------------------------------------
#          write files to folder for later analysis using RMark - .inp required
#---------------------------------------------------------------------------------

#write files to local folder
write.table(DO_MARK, file = "mark_datafiles//do_mark.inp", row.names = F, col.names = F)
write.table(DM_MARK, file = "mark_datafiles//dm_mark.inp", row.names = F, col.names = F)
write.table(PB_MARK, file = "mark_datafiles//pb_mark.inp", row.names = F, col.names = F)
write.table(PP_MARK, file = "mark_datafiles//pp_mark.inp", row.names = F, col.names = F)
write.table(PF_MARK, file = "mark_datafiles//pf_mark.inp", row.names = F, col.names = F)
write.table(PE_MARK, file = "mark_datafiles//pe_mark.inp", row.names = F, col.names = F)
write.table(PM_MARK, file = "mark_datafiles//pm_mark.inp", row.names = F, col.names = F)
write.table(RM_MARK, file = "mark_datafiles//rm_mark.inp", row.names = F, col.names = F)
write.table(SH_MARK, file = "mark_datafiles//sh_mark.inp", row.names = F, col.names = F)
write.table(SF_MARK, file = "mark_datafiles//sf_mark.inp", row.names = F, col.names = F)
write.table(NAO_MARK, file = "mark_datafiles//nao_mark.inp", row.names = F, col.names = F)
write.table(OT_MARK, file = "mark_datafiles//ot_mark.inp", row.names = F, col.names = F)
write.table(OL_MARK, file = "mark_datafiles//ol_mark.inp", row.names = F, col.names = F)

#---------------------------------------------------------------------------------
#          plot results
#---------------------------------------------------------------------------------

pdf("Fig1_guild_movement_hist.pdf", 8, 5, pointsize = 10)
par(mfrow=c(3,2), mar=c(3,1.5,2,0.5), oma=c(1.5,2,1,1))

#plot histogram of all consecutive movement for rodents within a species 2000-2009
#create vector of breaks, incrementing by 6 meters (represents approx. 1 stake) since data are not actually continuous
v6 = seq(-3,500,6)
Hgcount = hist(Hgran, breaks = v6, col = 'gray60', xlim = c(0,500), ylim = c(0, 3500), 
               xlab = "meters", main = 'Heteromyids - PF, PP, PB, DO, DM')      
            xline(Hgran_brkpt, lwd = 2, col = "indianred")
Cgcount = hist(Cgran, breaks = v6, col = 'gray60', xlim = c(0,500), ylim = c(0,40), 
               xlab = "meters", main = 'Cricetids - PE, PM, RM')
            xline(Cgran_brkpt, lwd = 2, col = "indianred")
focount = hist(foli, breaks = v6, col = 'gray60', xlim = c(0,500), ylim = c(0,25),
               xlab = "meters", main = 'folivores - SH, SF')
            xline(foli_brkpt, lwd = 2, col = "indianred")
nacount = hist(naometers, breaks = v6, col = 'gray60', xlim = c(0,500), ylim = c(0,25), 
               xlab = "meters", main = 'neotoma - NA')
            xline(nao_brkpt, lwd = 2, col = "indianred")
incount = hist(insectiv, breaks = v6, col = 'gray60', xlim = c(0,500), ylim = c(0,120), 
               xlab = "meters", main = 'insectivores - OT, OL')
            xline(ins_brkpt, lwd = 2, col = "indianred")
dev.off()

#NOTES: Hgran has no obvious breakpoint (everything stays "home"), minima at 54 (distance between plots?)
#       Cgran has a minima at 48 m (distance between plots?)
#       Foli has a minima at 48 m (artefact of about the distance to hit between plots?)
#       Na has a minima at 24, closer to where I would guess Hgran to be (middens, never really leaves?)
#       Insec has a minima at 60 m, greater than the distance across a plot (active hunters)


#------------------------------------------------------------
pdf("Fig2_avg_temporal_occ.pdf", 5, 5, pointsize = 10)
par(mfrow=c(1,1))

# Make an occupancy plot for 2000-2009 (similar to Morgan) 
# plot temporal occupancy - for month and year 
plot(pfyr, pfmo, xlim = c(0,1), ylim = c(0,1), xlab = "across-year occupancy", ylab = "within-year occupancy", pch = 19, col = "hotpink")
    textxy(pfyr, pfmo, "PF")
  points(ppyr, ppmo, pch = 19, col = "hotpink")
    textxy(ppyr, ppmo, "PP")
  points(pbyr, pbmo, pch = 19, col = "hotpink")
    textxy(pbyr, pbmo, "PB")
  points(doyr, domo, pch = 19, col = "hotpink")
    textxy(doyr, domo, "DO")
  points(dmyr, dmmo, pch = 19, col = "hotpink")
    textxy(dmyr, dmmo, "DM")
  points(peyr, pemo, pch = 19)
    textxy(peyr, pemo, "Cgran")
  points(pmyr, pmmo, pch = 19)
    textxy(pmyr, pmmo, "Cgran")
  points(otyr, otmo, pch = '*', cex = 1.5)
    textxy(otyr, otmo, "insectiv")
  points(olyr, olmo, pch = '*', cex = 1.5)
    textxy(olyr, olmo, "insectiv")
  points(shyr, shmo, pch = 19)
    textxy(shyr, shmo, "foliv")
  points(sfyr, sfmo, pch = 19)
    textxy(sfyr, sfmo, "foliv")
  points(naoyr, naomo, pch = 19, col = "purple")
    textxy(naoyr, naomo, "NA")
  points(rmyr, rmmo, pch = 19)
    textxy(rmyr, rmmo, "Cgran")
  abline(v = 0.5, lty = 2, col = 'gray40', lwd = 1)
  abline(h = 0.5, lty = 2, col = 'gray40', lwd = 1)
dev.off()

#---------------------------------------------
pdf("Fig3_avg_prop_reprodfemales.pdf", 7, 10, paper = "letter", pointsize = 10)
par(mfrow=c(5,3))

#plot mean fecundity by month for each species
plot(c(1:12), doreprd, type = "l", xlim = c(1,12), ylim = c(0,1), pch = 19, xlab = "month", 
     ylab = "proprotion reproductive fem.", bty = "n", main = "DO - krat")
plot(c(1:12), dmreprd, type = "l", xlim = c(1,12), ylim = c(0,1), pch = 19, xlab = "month", 
     ylab = "proprotion reproductive fem.", bty = "n", main = "DM - krat")
plot(c(1:12), pbreprd, type = "l", xlim = c(1,12), ylim = c(0,1), pch = 19, xlab = "month", 
     ylab = "proprotion reproductive fem.", bty = "n", main = "PB - pocket mouse")
plot(c(1:12), ppreprd, type = "l", xlim = c(1,12), ylim = c(0,1), pch = 19, xlab = "month", 
     ylab = "proprotion reproductive fem.", bty = "n", main = "PP - pocket mouse")
plot(c(1:12), pfreprd, type = "l", xlim = c(1,12), ylim = c(0,1), pch = 19, xlab = "month", 
     ylab = "proprotion reproductive fem.", bty = "n", main = "PF - pocket mouse")

plot(c(1:12), pereprd, type = "l", xlim = c(1,12), ylim = c(0,1), pch = 19, xlab = "month", 
     ylab = "proprotion reproductive fem.", bty = "n", main = "PE - cactus mouse")
plot(c(1:12), pmreprd, type = "l", xlim = c(1,12), ylim = c(0,1), pch = 19, xlab = "month", 
     ylab = "proprotion reproductive fem.", bty = "n", main = "PM - deer mouse")
plot(c(1:12), rmreprd, type = "l", xlim = c(1,12), ylim = c(0,1), pch = 19, xlab = "month", 
     ylab = "proprotion reproductive fem.", bty = "n", main = "RM - harvest mouse")

plot(c(1:12), shreprd, type = "l", xlim = c(1,12), ylim = c(0,1), pch = 19, xlab = "month", 
     ylab = "proprotion reproductive fem.", bty = "n", main = "SH - cotton rat")
plot(c(1:12), sfreprd, type = "l", xlim = c(1,12), ylim = c(0,1), pch = 19, xlab = "month", 
     ylab = "proprotion reproductive fem.", bty = "n", main = "SF - cotton rat")
plot(c(1:12), naoreprd, type = "l", xlim = c(1,12), ylim = c(0,1), pch = 19, xlab = "month", 
     ylab = "proprotion reproductive fem.", bty = "n", main = "NA - pack rat")

plot(c(1:12), otreprd, type = "l", xlim = c(1,12), ylim = c(0,1), pch = 19, xlab = "month", 
     ylab = "proprotion reproductive fem.", bty = "n", main = "OT - grasshopper mouse")
plot(c(1:12), olreprd, type = "l", xlim = c(1,12), ylim = c(0,1), pch = 19, xlab = "month", 
     ylab = "proprotion reproductive fem.", bty = "n", main = "OL - grasshopper mouse")
dev.off()

#------------------------------------------
pdf("Fig4_abun_across_yrs.pdf", 8, 5, pointsize = 10)
par(mfrow=c(2,2), mar=c(2,2,2,0.5), oma=c(1.5,2,1,1))


years = c(2000:2009)

plot(years, doabun, type = "l", bty = "n", ylab = "", xlim = c(2000, 2010), 
     ylim = c(0, 600), xaxp = c(2000, 2009, 9))
  points(years, dmabun, type = "l")
  points(years, pbabun, type = "l")
  points(years, ppabun, type = "l")
  points(years, pfabun, type = "l")
    mtext("Heteromyidae granivores", side = 3, adj = 0.15, line = -1)
    mtext("abundance", side = 2, line = 2)

plot(years, peabun, type = "l", bty = "n", ylab = "", xlim = c(2000, 2010), 
     ylim = c(0, 600), xaxp = c(2000, 2009, 9))
points(years, pmabun, type = "l")
points(years, rmabun, type = "l")
    mtext("Cricetidae granivores", side = 3, adj = 0.15, line = -1)

plot(years, shabun, type = "l", bty = "n", ylab = "", xlim = c(2000, 2010), 
     ylim = c(0, 600), xaxp = c(2000, 2009, 9))
points(years, sfabun, type = "l")
points(years, naoabun, type = "l")
    mtext("Folivores", side = 3, adj = 0.15, line = -1)
    mtext("abundance", side = 2, line = 2)
    mtext("years", side = 1, line = 2)

plot(years, otabun, type = "l", bty = "n", ylab = "", xlim = c(2000, 2010), 
     ylim = c(0, 600), xaxp = c(2000, 2009, 9))
points(years, olabun, type = "l")
    mtext("Insectivores", side = 3, adj = 0.15, line = -1)
    mtext("years", side = 1, line = 2)

dev.off()


#------------------------------------------
pdf("Fig5_rank_abundance.pdf", 7, 10, paper = "letter", pointsize = 10)
par(mfrow=c(4,3))

years = c(2000:2009)
ranks = c(1:13)

for (row in 1:nrow(abuns)){
  yrdat = abuns[row,]
  reldat = sort(yrdat/sum(yrdat), decreasing = TRUE)
    
  nonzero = reldat[reldat>0]
    labels = strtrim(as.character(names(nonzero)),2)
  
  plot(ranks, reldat, type = "b", pch = 19, ylim = c(0,0.6), 
       xlab = "Rank", ylab = "Relative Abundance", bty = "n", xaxp = c(1, 13, 12))
  mtext(years[row], side = 3)
  textxy(c(1:length(nonzero)), nonzero, labs = labels, cx = 0.75)
}

dev.off()


#------------------------------------------
pdf("Fig6_indiv_repro_trends.pdf", 6, 6, pointsize = 10)
par(mfrow=c(2,2))

#plot the relative abundance of females who represent each number of reproductive events per year
plot(NA, NA, xlim = c(0, 4), xaxp = c(0, 4, 4), xlab = "number reproductive events", 
     ylab = "number individuals", type = "b", pch = 19, ylim = c(0, 1), yaxp = c(0, 1, 4), bty = "n", main = "heteromyids")
  points(c(0:3), table(doirep$num_reprod)/sum(table(doirep$num_reprod)), type = "b", pch = 19, col = "indianred")
  points(c(0:4), table(dmirep$num_reprod)/sum(table(dmirep$num_reprod)), type = "b", pch = 19, col = "magenta")
  points(c(0:4), table(pbirep$num_reprod)/sum(table(pbirep$num_reprod)), type = "b", pch = 19, col = "red")
  points(c(0:4), table(ppirep$num_reprod)/sum(table(ppirep$num_reprod)), type = "b", pch = 19, col = "hotpink")
  points(c(0:2), table(pfirep$num_reprod)/sum(table(pfirep$num_reprod)), type = "b", pch = 19, col = "purple")

plot(NA, NA, xlim = c(0, 4), xaxp = c(0, 4, 4), xlab = "number reproductive events", 
     ylab = "number individuals", type = "b", pch = 19, ylim = c(0, 1), yaxp = c(0, 1, 4), bty = "n", main = "cricetids")
  points(c(0:2), table(peirep$num_reprod)/sum(table(peirep$num_reprod)), type = "b", pch = 18, col = "green")
  points(c(0:2), table(pmirep$num_reprod)/sum(table(pmirep$num_reprod)), type = "b", pch = 18, col = "darkgreen")
  points(c(0:1), table(rmirep$num_reprod)/sum(table(rmirep$num_reprod)), type = "b", pch = 18, col = "yellowgreen")

plot(NA, NA, xlim = c(0, 4), xaxp = c(0, 4, 4), xlab = "number reproductive events", 
     ylab = "number individuals", type = "b", pch = 19, ylim = c(0, 1), yaxp = c(0, 1, 4), bty = "n", main = "folivores")
  points(c(0:1), table(shirep$num_reprod)/sum(table(shirep$num_reprod)), type = "b", pch = 17, col = "brown")
  points(c(0:1), table(sfirep$num_reprod)/sum(table(sfirep$num_reprod)), type = "b", pch = 17, col = "brown4")
  points(c(0:3), table(naoirep$num_reprod)/sum(table(naoirep$num_reprod)), type = "b", pch = 17, col = "goldenrod4")

plot(NA, NA, xlim = c(0, 4), xaxp = c(0, 4, 4), xlab = "number reproductive events", 
     ylab = "number individuals", type = "b", pch = 19, ylim = c(0, 1), yaxp = c(0, 1, 4), main = "carnivores")
  points(c(0:3), table(otirep$num_reprod)/sum(table(otirep$num_reprod)), type = "b", pch = 15, col = "orange3")
  points(c(0:1), table(olirep$num_reprod)/sum(table(olirep$num_reprod)), type = "b", pch = 15, col = "orange4")

dev.off()

#-------------------------------------------------------------------
#          Print statments - descriptive info for the txt file
#-------------------------------------------------------------------


#close sink file
sink()
# 


# 
# ##------ histograms of the number of recaptures (some species are recaptured far less often), save in pdf file #FIXME
# pdf(file = "recaps_by_species.pdf", 11, 7.5)
# par(mfrow = c(2,4))
# 
# plot_recap_hist(PB, "PB"); plot_recap_hist(PP, "PP"); plot_recap_hist(PF, "PF"); plot_recap_hist(DM, "DM"); plot_recap_hist(DO, "DO")
# plot_recap_hist(PE, "PE"); plot_recap_hist(PM, "PM"); plot_recap_hist(RM, "RM")
# plot_recap_hist(NAO, "NAO"); plot_recap_hist(SF, "SF"); plot_recap_hist(SH, "SH")
# plot_recap_hist(OT, "OT"); plot_recap_hist(OL, "OL")
# 
# dev.off()

