library(qtl2)

########################
### MOUSE IRON DATA ####
########################
dir.create(path = "plots")

# Load data
iron <- qtl2::read_cross2(file = system.file("extdata", "iron.zip", package="qtl2") )
# myQTLdata <- read_cross2(file = "/Users/myUserName/qtlProject/data/myqtldata.yaml" )

# Summarize cross data
summary(iron)
names(iron)

# List markers on the first six chromosomes
head(iron$gmap)

# Insert pseudomarkers onto genetic map
map <- qtl2::insert_pseudomarkers(map=iron$gmap, step=1)
head(map,2)

# Calculate QTL genotype probabilities
pr <- qtl2::calc_genoprob(cross=iron, 
                    map=map, 
                    error_prob=0.002)
# Result is a 3D array: individuals, genotypes, positions
# Names of probabilities object are chromosomes 

# individuals
dimnames(pr$`19`)[[1]]
# genotypes
dimnames(pr$`19`)[[2]]
# positiions (on the chromosome referenced)
dimnames(pr$`19`)[[3]]

# View genotypes for first 3 individuals for first marker on Chr 19
pr$`19`[1:3,,"D19Mit68"]
# SS          SB           BB
# 1 0.0009976995 0.003298162 0.9957041387
# 2 0.2500000000 0.500000000 0.2500000000
# 3 0.0003029243 0.999394151 0.0003029243

pr$`19`[1:3,,"c19.loc4"]
# SS         SB          BB
# 1 0.001080613 0.03581825 0.963101136
# 2 0.250000000 0.50000000 0.250000000
# 3 0.006141104 0.98771779 0.006141104

# Plot gentoyep probabilities for first individual on chromosome 19
png(file="plots/geno.probs.png")
qtl2::plot_genoprob(probs = pr, # probability array
              map = map, # genetic map
              ind = 1, # individual
              chr = 19) # chromosome
dev.off()

Xcovar <- qtl2::get_x_covar(cross = iron)
head(Xcovar)


# Perform a genome scan
out <- qtl2::scan1(genoprobs = pr, pheno = iron$pheno, Xcovar=Xcovar, cores = 4)
head(out, 10)

png(file="plots/liver.scan.png")
qtl2::plot_scan1(out, map = map, lodcolumn = "liver")
dev.off()

png(file="plots/spleen.scan.png")
qtl2::plot_scan1(out, map = map, lodcolumn = "spleen")
dev.off()

options(scipen = 99999)
# Idenitfy top LOD scores
tail(sort(out[,"liver"]))
tail(sort(out[,"spleen"]))


# Permutation testing
operm <- qtl2::scan1perm(genoprobs = pr, 
                         pheno = iron$pheno, 
                         Xcovar = Xcovar,
                         n_perm = 1000,
                         cores = 4)
# Distribution of max LOD scores among permutations
png(file="plots/perm.dist.png")
hist(operm[,'liver'], breaks = 50, xlab = "LOD", main = "LOD scores for liver scan with threshold in red")
dev.off()
# Summary of LOD scores
thr <- summary(operm)

# Find QTL peaks
qtl2::find_peaks(scan1_output = out, 
                 map = map, 
                 threshold = thr, 
                 prob = 0.95, 
                 expand2markers = FALSE)

# Calculate kinship and perform according scans
kinship <- qtl2::calc_kinship(probs = pr, use_allele_probs = F)
n_samples <- 25

png(file="plots/kinship.heatmap.png")
heatmap(kinship[1:n_samples, 1:n_samples], symm = TRUE)
dev.off()

out_pg <- qtl2::scan1(genoprobs = pr, 
                      pheno = iron$pheno, 
                      kinship = kinship, 
                      Xcovar=Xcovar, 
                      cores=4)

kinship_loco <- calc_kinship(pr, "loco")
out_pg_loco <- scan1(genoprobs = pr, 
                     pheno = iron$pheno, 
                     kinship = kinship_loco, 
                     Xcovar=Xcovar, 
                     cores = 4)

# Plot overlaid results
png(file="plots/overlay.scan.png")
plot_scan1(out_pg_loco, map = map, lodcolumn = "liver", col = "black")
plot_scan1(out_pg,      map = map, lodcolumn = "liver", col = "blue",  add = TRUE)
plot_scan1(out,         map = map, lodcolumn = "liver", col = "green", add = TRUE)
dev.off()
# QTL effect calculations
c2eff <- qtl2::scan1coef(genoprobs = pr[,"2"], 
                         pheno = iron$pheno[,"liver"]) # just chromosome 2
head(c2eff)
qtl2::plot_coef(x = c2eff, 
          map = map, 
          columns = 1:3, 
          scan1_output = out,
          main = "Chromosome 2 QTL effects and LOD scores",
          legend = "topright")
# Additive and dominance effects
c2effB <- qtl2::scan1coef(genoprobs = pr[,"2"], 
                    pheno = iron$pheno[,"liver"],
                    contrasts= cbind(mu=c(1,1,1), # average phenotype
                                     a=c(-1, 0, 1), # additive effects
                                     d=c(-0.5, 1, -0.5) # dominance effects
                                     ))
head(c2effB)
qtl2::plot_coef(c2effB, map["2"], columns=2:3)

# Plot PxG plots
g <- qtl2::maxmarg(probs = pr, 
             map = map, 
             chr=2, 
             pos=28.6, 
             return_char=TRUE)
par(mar=c(4.1, 4.1, 0.6, 0.6))

png(file="plots/pxg.png")
plot_pxg(g, iron$pheno[,"liver"], ylab="Liver phenotype")
dev.off()

