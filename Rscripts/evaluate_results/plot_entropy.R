# ------------------------------------------
# Plots of entropy, by k, Seurat is excluded as f the number of k
# ------------------------------------------

suppressPackageStartupMessages({
  require(plyr)
  require(dplyr)
  require(tidyr)
  require(ggplot2)
})

res <-  readRDS(file="output/clustering_summary/clustering_summary.rds")

shanon_entropy <- function(cluster){
  p <-c(table(cluster)) / length(cluster)
  s <- -1*sum(p*log2(p))
  return(s)
}

# ------------------------------------
# compute Entropy, 
# ------------------------------------
res_summary <- res %>% dplyr::group_by( dataset, method, run, k) %>% dplyr::filter(!is.na(cluster)) %>% 
  dplyr::summarize(s = shanon_entropy(cluster),
                   s.true= shanon_entropy(trueclass),
                   truenclust = length(unique(trueclass)),
                   estnclust = unique(est_k)
                   )  %>%
  tidyr::separate( dataset, sep = "_", into = c("sce", "filtering", "dataset")) %>%
  dplyr::select(-sce) %>% dplyr::ungroup()
# ------------------------------------
# compute Entropy, for truenclust 
# ------------------------------------
res_summary <- res %>% dplyr::group_by(dataset, method, run, k) %>% dplyr::filter(!is.na(cluster)) %>% 
  dplyr::summarize(s = shanon_entropy(cluster),
                   truenclust = length(unique(trueclass)),
                   estnclust = unique(est_k)
  )  %>%
  tidyr::separate( dataset, sep = "_", into = c("sce", "filtering", "dataset")) %>%
  dplyr::select(-sce) %>% dplyr::ungroup()

res %>% group_by( dataset, method, run, k ) %>% dplyr::summarize( s.true = shanon_entropy(trueclass) )
  # plot entropy per k
# ------------------------------------
pdf("plots/performance/plot_entropy_by_k.pdf", width = 12, height = 6)

print( ggplot(data = res_summary%>%filter( !is.na(s)), aes(x = k, y = s, group=method, color=method))+       
         geom_smooth()+  
         facet_grid(filtering~dataset)+
         geom_vline(aes(xintercept = truenclust), linetype = "dashed")+ 
         geom_point(aes( truenclust , s.true ), color=1, shape=4)+
         scale_color_brewer(palette = "Set3")+
         theme_bw()+
         labs(x="method", y="entropy") 
)
dev.off()
date()
sessionInfo()

