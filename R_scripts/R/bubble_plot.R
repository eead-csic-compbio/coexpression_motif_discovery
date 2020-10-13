
```{r}
# Load the libraries
library(plotly)
library(ggplot2)
library(plotly)
library(viridis)

#setwd("~/your/path")

#read data
data <- read.table("bubble_athaliana.csv", header=T, sep="\t")
data <-as.data.frame(data)

############################################################    
## Create static bubble plot with ggplot2
############################################################
bubble_classic <- ggplot(data) + 
      geom_point(aes(x=Upstream_regions, y=Modules, size = N.cor,colour = Significance)) +
      scale_size(range = c(8, 19)) + 
      scale_color_viridis(option = "D", direction = -1, begin = 0, end=1)+
      theme(legend.position = "right") +
      theme_bw(base_size = 14, base_line_size = 1)+ scale_x_discrete(position = "top") +  
      theme(axis.text.x=element_text(color="black", size = 11, face = "bold", angle = 360, hjust = 0.5)) +
      theme(axis.text.y=element_text(color="black", size = 11,face = "bold", angle = 360))
bubble_classic

############################################################    
## Convert ggplot static plot to interactive with plotly
############################################################

bubble_interactive <- ggplotly(bubble_classic, tooltip = c("Significance","N.cor"))
bubble_interactive

# save the widget
library(htmlwidgets)
saveWidget(bubble_interactive, "Plotly_bubble_chart.html")
```
