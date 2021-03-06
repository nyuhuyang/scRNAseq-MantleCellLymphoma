########################################################################
#
#  0 setup environment, install libraries if necessary, load libraries
# 
# ######################################################################

library(Seurat)
library(dplyr)
library(cowplot)
library(magrittr)
library(DoubletFinder)
library(kableExtra)
source("../R/Seurat3_functions.R")
path <- paste0("output/",gsub("-","",Sys.Date()),"/")
if(!dir.exists(path))dir.create(path, recursive = T)
########################################################################
#
#  2. DoubletFinder 
# 
# ######################################################################
#======1.2 load  Seurat =========================
(load(file="data/MCL_V3_Harmony_43_20190627.Rda"))
set.seed(100)
Idents(object) = "orig.ident"
(samples = unique(Idents(object)))
object %<>% NormalizeData()
object %<>% FindVariableFeatures(selection.method = "vst", nfeatures = 2000)
object %<>% ScaleData
object %<>% RunPCA(features = VariableFeatures(object), npcs = 100, verbose = F)
object@assays$RNA@scale.data = matrix(0,0,0)
save(object, file = "data/MCL_V3_Harmony_43_20190627.Rda")

object_list <- lapply(samples,function(x) subset(object,idents=x))
GC()
## pK Identification (no ground-truth) ---------------------------------------------------------------------------------------
npcs =75
sweep.res_list <- lapply(object_list, function(x) paramSweep_v3(x, PCs = 1:npcs, sct = FALSE))
sweep_list <- lapply(sweep.res_list, function(x) summarizeSweep(x, GT = FALSE))
bcmvn_list <- lapply(sweep_list,find.pK)
(maximal_pk <- sapply(bcmvn_list,function(x) {
    as.numeric(as.character(x[find.localMaxima(x$BCmetric),"pK"]))
    }))
maximal_pk
# find histgram local maximam
find.localMaxima <- function(x) {
    # Use -Inf instead if x is numeric (non-integer)
    y <- diff(c(-.Machine$integer.max, x)) > 0L
    rle(y)$lengths
    y <- cumsum(rle(y)$lengths)
    y <- y[seq.int(1L, length(y), 2L)]
    if (x[[1]] == x[[2]]) {
        y <- y[-1]
    }
    which(x == max(x[y]))
}

# http://rstudio-pubs-static.s3.amazonaws.com/329613_f53e84d1a18840d5a1df55efb90739d9.html
qplot_2axis <- function(data,x = "pK", y1 = "MeanBC", y2 = "BCmetric"){
    if(class(data[,x]) == "factor") data[,x] <- as.numeric(as.character(data[,x]))
    data_y1 <- data[,y1]
    data_y2 <- data[,y2]
    a <- range(data_y1)
    b <- range(data_y2)
    scale_factor <- diff(a)/diff(b)
    data_y2 <- ((data_y2 - b[1]) * scale_factor) + a[1]
    trans <- ~ ((. - a[1]) / scale_factor) + b[1]
    
    g <- ggplot(data = data, aes_string(x = x, y = y1))+
        geom_line()+geom_point()+
        geom_point(aes(y = data_y2),colour = "blue")+
        geom_line(aes(y = data_y2),colour = "blue")+
        scale_y_continuous(name = y1,
                           sec.axis = sec_axis(trans=trans, name=y2))+
        theme(axis.text.y.right = element_text(color = "blue"))
    
    g
    
}
qplot_2axis(data = bcmvn_list[[2]])

Multiplet_Rate <- function(object, numBatches = 1, num10xRuns = 1){
    
    numCellsRecovered = 1.0 * ncol(object)
    m = 4.597701e-06
    r = 0.5714286
    
    numCellsLoaded = numCellsRecovered / r
    multipletRate = m * numCellsLoaded / num10xRuns
    
    singletRate = 1.0 - multipletRate;
    numSinglet = singletRate * numCellsRecovered
    numMultiplet = numCellsRecovered - numSinglet
    numIdentMultiplet = numMultiplet * (numBatches - 1) / numBatches
    numNonIdentMultiplet = numMultiplet - numIdentMultiplet
    numCells = numSinglet + numNonIdentMultiplet
    
    return(numNonIdentMultiplet/numCells)
}
Multiplet_Rate(object_list[[1]])
## Homotypic Doublet Proportion Estimate -------------------------------------------------------------------------------------
for(i in 1:length(object_list)){
    print(paste("processing",unique(object_list[[i]]$orig.ident)))
    homotypic.prop <- modelHomotypic(object_list[[i]]@meta.data$manual)
    nExp_poi <- round(Multiplet_Rate(object_list[[i]])*length(colnames(object_list[[i]])))  ## Assuming 7.5% doublet formation rate - tailor for your dataset
    nExp_poi.adj <- round(nExp_poi*(1-homotypic.prop))
    
    ## Run DoubletFinder with varying classification stringencies ----------------------------------------------------------------
    object_list[[i]] <- doubletFinder_v3(object_list[[i]], PCs = 1:50, 
                                                     pN = 0.25, pK = maximal_pk[i], 
                                                     nExp = nExp_poi, reuse.pANN = FALSE, sct = FALSE)
    object_list[[i]] <- doubletFinder_v3(object_list[[i]], PCs = 1:50, pN = 0.25, maximal_pk[i],
                                   nExp = nExp_poi.adj, reuse.pANN = grep("pANN",colnames(object_list[[i]]@meta.data),value = T),
                                   sct = FALSE)
    colName = colnames(object_list[[i]]@meta.data)
    colName[grep("DF.classifications",colName)] = c("Low_confident_doublets",
                                                    "High_confident_doublets")
    colnames(object_list[[i]]@meta.data) = colName
}
meta.data_list <- lapply(object_list, function(x) x@meta.data)
meta.data = bind_rows(meta.data_list)
rownames(meta.data) = paste0(meta.data$orig.ident,"_",meta.data$Barcode)
meta.data = meta.data[colnames(object),]
meta.data$doublets = gsub("Doublet","Doublet-Low Confidence",meta.data$Low_confident_doublets)
meta.data[meta.data$High_confident_doublets %in% "Doublet","doublets"] = "Doublet-High Confidence "
meta.data = cbind(object@meta.data,meta.data$doublets)
colnames(meta.data)[ncol(meta.data)] = "Doublets"
object@meta.data = meta.data

TSNEPlot.1(object, group.by = "Doublets",cols = c("red","orange","black"), 
           title = "Singlets and possible Doublets", do.print = T,pt.size = 0.1)

UMAPPlot.1(object, group.by = "Doublets",cols = c("red","orange","black"), 
           title = "Singlets and possible Doublets", do.print = T,pt.size = 0.1)

table(object$Doublets) %>% prop.table %>% kable %>% kable_styling()
table(object$Doublets, object$manual) %>% kable %>% kable_styling()

save(object,file="data/MCL_V3_Harmony_43_20190627.Rda")
