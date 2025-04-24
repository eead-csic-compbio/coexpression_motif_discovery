#=====================================================================================
#
#  Code chunk 1
#
#=====================================================================================

# install packages
install.packages("WGCNA")

# set the working directory
workingDir = "~/wgcna/test/";
setwd(workingDir); 

# Load the WGCNA package
library(WGCNA);
library("dendextend")

# The following setting is important, do not omit.
options(stringsAsFactors = FALSE);

# Read in the data set
rawData = read.csv("final_list_degs_annotated.csv", sep = "\t");

# Take a quick look at what is in the data set:
dim(rawData);
names(rawData);


#=====================================================================================
#
#  Code chunk 2
#
#=====================================================================================


datExpr0 = as.data.frame(t(rawData[1:11335,2:29]));

#=====================================================================================
#
#  Code chunk 3
#
#=====================================================================================


gsg = goodSamplesGenes(datExpr0, verbose = 3);
gsg$allOK


#=====================================================================================
#
#  Code chunk 4
#
#=====================================================================================


if (!gsg$allOK)
{
  # Optionally, print the gene and sample names that were removed:
  if (sum(!gsg$goodGenes)>0) 
     printFlush(paste("Removing genes:", paste(names(datExpr0)[!gsg$goodGenes], collapse = ", ")));
  if (sum(!gsg$goodSamples)>0) 
     printFlush(paste("Removing samples:", paste(rownames(datExpr0)[!gsg$goodSamples], collapse = ", ")));
  # Remove the offending genes and samples from the data:
  datExpr0 = datExpr0[gsg$goodSamples, gsg$goodGenes]
}


#=====================================================================================
#
#  Code chunk 5
#
#=====================================================================================


sampleTree = hclust(dist(datExpr0), method = "average");
# Plot the sample tree: Open a graphic output window of size 12 by 9 inches
# The user should change the dimensions if the window is too large or too small.
sizeGrWindow(12,9)

hc<-as.dendrogram(sampleTree)

jpeg("samples clustering to detect outliners.jpeg", width = 8, height = 5, units = 'in', res = 300)
par(cex = 1.1);
par(mar = c(6,5,1,1))
plot((hc), main = "", sub="", xlab="hclust (*, average)", cex.lab = 0.8, 
     cex.axis =0.8, cex.main = 1.5, lwd=0.5, col = "black", hang = -1, ylab = "Height")
dev.off()


#=====================================================================================
#
#  Code chunk 6
#
#=====================================================================================


# Plot a line to show the cut
abline(h = 15, col = "red");
# Determine cluster under the line
clust = cutreeStatic(sampleTree, cutHeight = 15, minSize = 10)
table(clust)
# clust 1 contains the samples we want to keep.
keepSamples = (clust==0)
datExpr = datExpr0[keepSamples, ]
nGenes = ncol(datExpr)
nSamples = nrow(datExpr)


#=====================================================================================
#
#  Code chunk 7
#
#=====================================================================================



save(datExpr, file = "clean-01-dataInput.RData")


# Load the data saved in the first part
options(stringsAsFactors = FALSE);
# Allow multi-threading within WGCNA
enableWGCNAThreads()
# load
lnames = load(file = "clean-01-dataInput.RData");
#The variable lnames contains the names of loaded variables.
lnames

#=====================================================================================
#
#  Code chunk 8
#
#=====================================================================================


# Choose a set of soft-thresholding powers
powers = c(c(1:10), seq(from = 12, to=20, by=2))
# Call the network topology analysis function
sft = pickSoftThreshold(datExpr, powerVector = powers, verbose = 5,networkType = "unsigned")
# Plot the results:
sizeGrWindow(9, 5)
par(mfrow = c(1,2));
cex1 = 0.8;

jpeg("~/wgcna/Figures/soft_threshold", width = 8, height = 5, units = 'in', res = 300)
# Scale-free topology fit index as a function of the soft-thresholding power
plot(sft$fitIndices[,1], -sign(sft$fitIndices[,3])*sft$fitIndices[,2],
     xlab="Soft Threshold (power)",ylab="Scale Free Topology Model Fit,signed R^2",type="n",
     main = paste("Scale independence"));
text(sft$fitIndices[,1], -sign(sft$fitIndices[,3])*sft$fitIndices[,2],
     labels=powers,cex=cex1,col="red");
# this line corresponds to using an R^2 cut-off of h
abline(h=0.82,col="red")
dev.off()
jpeg("~/wgcna/Figures/mean_connectivety", width = 8, height = 5, units = 'in', res = 300)
# Mean connectivity as a function of the soft-thresholding power
plot(sft$fitIndices[,1], sft$fitIndices[,5],
     xlab="Soft Threshold (power)",ylab="Mean Connectivity", type="n",
     main = paste("Mean connectivity"))
text(sft$fitIndices[,1], sft$fitIndices[,5], labels=powers, cex=cex1,col="red")
dev.off()

#=====================================================================================
#
#  Code chunk 9
#
#=====================================================================================


softPower = 7;
adjacency = adjacency(datExpr, power = softPower,type = "unsigned");

#=====================================================================================
#
#  Code chunk 10
#
#=====================================================================================


# Turn adjacency into topological overlap
TOM = TOMsimilarity(adjacency,TOMType="unsigned");
dissTOM = 1-TOM

#=====================================================================================
#
#  Code chunk 11
#
#=====================================================================================


# Call the hierarchical clustering function
geneTree = hclust(as.dist(dissTOM), method = "average");
# Plot the resulting clustering tree (dendrogram)
sizeGrWindow(12,9)
plot(geneTree, xlab="", sub="", main = "Gene clustering on TOM-based dissimilarity",
     labels = FALSE, hang = 0.04);

#=====================================================================================
#
#  Code chunk 12
#
#=====================================================================================


# We set the minimum module size relatively high:
minModuleSize = 22;

# Module identification using dynamic tree cut:
dynamicMods = cutreeDynamic(dendro = geneTree, distM = dissTOM,
                            deepSplit = 2, pamRespectsDendro = FALSE,
                            minClusterSize = minModuleSize);
table(dynamicMods)

#=====================================================================================
#
#  Code chunk 13
#
#=====================================================================================


# Convert numeric labels into colors
dynamicColors = labels2colors(dynamicMods)
table(dynamicColors)
# Plot the dendrogram and colors underneath
sizeGrWindow(8,6)
jpeg("~/wgcna/Figures/Gene dendrogram and module colors", width = 8, height = 5, units = 'in', res = 300)

plotDendroAndColors(geneTree, dynamicColors, "Dynamic Tree Cut",
                    dendroLabels = FALSE, hang = 0.03,
                    addGuide = TRUE, guideHang = 0.05,
                    main = "")

dev.off()
#=====================================================================================
#
#  Code chunk 14
#
#=====================================================================================
# Calculate eigengenes
MEList = moduleEigengenes(datExpr, colors = dynamicColors)
MEs = MEList$eigengenes
# Calculate dissimilarity of module eigengenes
MEDiss = 1-cor(MEs);
# Cluster module eigengenes
METree = hclust(as.dist(MEDiss), method = "average");
# Plot the result
sizeGrWindow(7, 6)
plot(METree, main = "Clustering of module eigengenes",
     xlab = "", sub = "")

#=====================================================================================
#
#  Code chunk 15
#
#=====================================================================================


MEDissThres = 0.25
# Plot the cut line into the dendrogram
abline(h=MEDissThres, col = "red")
# Call an automatic merging function
merge = mergeCloseModules(datExpr, dynamicColors, cutHeight = MEDissThres, verbose = 3)
# The merged module colors
mergedColors = merge$colors;
# Eigengenes of the new merged modules:
mergedMEs = merge$newMEs;


#=====================================================================================
#
#  Code chunk 16
#
#=====================================================================================


sizeGrWindow(12, 9)
#pdf(file = "Plots/geneDendro-3.pdf", wi = 9, he = 6)
plotDendroAndColors(geneTree, cbind(dynamicColors, mergedColors),
                    c("Dynamic Tree Cut", "Merged dynamic"),
                    dendroLabels = FALSE, hang = 0.03,
                    addGuide = TRUE, guideHang = 0.05)
#dev.off()

# Rename to moduleColors
moduleColors = mergedColors
# Construct numerical labels corresponding to the colors
colorOrder = c("grey", standardColors(50));
moduleLabels = match(moduleColors, colorOrder)-1;
MEs = mergedMEs;
# Save module colors and labels for use in subsequent parts
save(dynamicColors, dynamicMods, geneTree, file = "modules-02-networkConstruction-stepByStep.RData")

#discard the unassigned genes, and focus on the rest
restGenes= (dynamicColors != "grey")
diss1=1-TOMsimilarityFromExpr(datExpr[,restGenes], power = softPower)

hier1=hclust(as.dist(diss1), method="average" )
plotDendroAndColors(hier1, dynamicColors[restGenes], "Dynamic Tree Cut", dendroLabels = FALSE, hang = 0.03, addGuide = TRUE, guideHang = 0.05, main = "Gene dendrogram and module colors")


jpeg("~/wgcna/Figures/TOMplot", width =7 , height = 7, units = 'in', res = 300)
#set the diagonal of the dissimilarity to NA 
diag(dissTOM) = NA;

#Visualize the Tom plot. Raise the dissimilarity matrix to the power of 4 to bring out the module structure
sizeGrWindow(10,10)
TOMplot(diss1, hier1, as.character(dynamicColors[restGenes]))
TOMplot(dissTOM, geneTree, as.character(dynamicColors))
dev.off()

#extract modules
data1 <- read.table("~/wgcna/final_list_degs_annotated.csv", sep = "\t", header = T)
data1 <- cbind(data1,dynamicMods)

#extract modules
for (i in 0:max(dynamicMods)){
  write.table(subset(data1[30],dynamicMods==i),
              paste("~/wgcna/Modules_id/_",i, ".txt",sep=""), sep="\t", row.names=FALSE, col.names=T,quote=FALSE)
}

## Plot a PDF with each cluster profile
##

# lee en un directorio, la lista entera de ficheros (acabados en TMPs.tab, cada uno de ellos es un subcluster)



files = list.files(path = "~/wgcna/power_7/", pattern = ".txt", 
                   full.names=TRUE);
library(gtools)
files <- mixedsort(files)

# recorre cada uno de los ficheros de cluster
# crea el fichero PDF de salida
pd
pdf(file="~/wgcna/power_7/plotfile_7");
for (i in 1:length(files)) {
  
  # lee el fichero del cluster actual
  data = read.table(files[i], header=T, row.names=1);
  data = data [,-c(29:30)]
  data <- as.matrix(data)
  
  # maximo y minimo TPM para poder declarar el tamaño de los ejes
  ymin = min(data); ymax = max(data);
  
  # nombre del fichero a generar
  plotfile = paste(files[i], ".pdf", sep='');
  
  # quita el sufijo, para quedarse solo con el nombre del cluster (deberes, mirar gsub)
  
  subcluster=gsub("~/wgcna/power_7/", "", files[i]);
  
  # quita el nombre del directorio, para quedarse solo con el nombre del cluster
  
  subcluster=gsub("cluster",i, "", subcluster);
  
  # nombre de la etiqueta a poner en el plot
  plot_label = paste("cluster",i, ";", sep=' ', "N.transcripts=",length(data[,1]));
  
  
  # genera el plot, pintando ya la primera linea de TMPs
  
  plot(as.numeric(data[1,]), type='l', ylim=c(ymin,ymax),
       main=plot_label, col='light gray', xaxt='n', xlab='',
       ylab='TPMs');
  
  # define el eje inferior, con los nombres de las muestras
  # length(data[1,]) es el numero de transcritos
  
  axis(side=1, at=1:length(data[1,]), labels=c(as.matrix(names(data[1,]))), las=2);
  
  # para el resto de lineas de TMPs (la primera ya la hemos pintado arriba):
  # (length(data[,1]) es el numero de tratamientos
  
  for(r in 2:length(data[,1])) {
    # pinta los datos de esa linea de TPMs
    points(as.numeric(data[r,]), type='l', col='gray');
  }
  # pinta los datos de los promedios
  points(as.numeric(colMeans(data)), type='o', col='blue');
  
  # cierra este pdf antes de empezar con el siguiente cluster
  
}

null <- dev.off()




