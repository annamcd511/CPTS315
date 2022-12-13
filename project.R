library(dplyr)
library(edgeR)
library(DESeq2)

key <- read.csv("key.csv")
sortedsampledata <- key[order(row.names(key)),]
data <- read.table("gene_count.txt")

# removing rows that add up to 0 or have a insufficient amount
data_filtered=data[rowSums(data)!=0,]
data_filterlist <- rowSums(cpm(data_filtered)>0.5) >= 3
length(which(data_filterlist == TRUE)) # 27877 genes past filtering
mypolisheddata <- data_filtered[data_filterlist,]

# sorting the data table to be in alphabetical order by sample name
sortedpolisheddata <- mypolisheddata[,order(names(mypolisheddata))]
# encoding the vector, column names, as a factor
group <- factor(colnames(sortedpolisheddata))
# creating a DGEList object from table with rows as features and columns as the samples
y <- DGEList(counts = sortedpolisheddata, group = group)
# calculating normalization factors to be used for scaling the raw library sizes
y <- calcNormFactors(y)

# top 10,000
plotMDS(y, top = 10000, gene.selection = "common", col=key$Infection, xlab = "MDS axis 1", ylab = "MDS axis 2", main = "MDS for Entire Dataset: Top 10,000", pch = c(15))

infection <- factor(key$Infection)
# designing matrices with pos/neg as the blocking factor
design <- model.matrix(~0+infection, data = y$samples)
design
y <- estimateDisp(y, design, robust=TRUE)
fit <- glmQLFit(y, design, robust=TRUE)
qlf <- glmQLFTest(fit, contrast=c(1,-1))
summary(dt_posvsneg <- decideTestsDGE(qlf, p.value = 0.05))

tt_DE<- topTags(qlf, n = summary(dt_posvsneg <- decideTestsDGE(qlf, p.value = 0.05))[1]+summary(dt_posvsneg <- decideTestsDGE(qlf, p.value = 0.05))[3], p.value = 0.05)
UP = rownames(tt_DE[tt_DE$table$logFC > 0,])
write.table(UP, file = "ALL-PosvsNeg-0.05.txt", quote=F, row.names = F, col.names = F)
DOWN = rownames(tt_DE[tt_DE$table$logFC < 0,])
write.table(DOWN, file = "DOWN-PosvsNeg-0.05.txt", quote=F, row.names = F, col.names = F)

ML <- mypolisheddata[rownames(mypolisheddata) %in% c("XAF1", "OAS2", "OAS3", "IFI44L", "IFIT1", "AC110741.3", "OR14L1P", "UBE2SP2", "IGKV1-8", "SCGB3A1", 
                                                 "HERC6", "GBP4", "CXCL10", "DDX58", "CMPK2"),]
ML_T <- as.data.frame(t(ML))
ML_T$Infection <- key$Infection
boxplot(ML_T$XAF1~ML_T$Infection, names = c("Positive", "Negative"), ylab = "Level of Expression", xlab = "", col = c(1, 2))
