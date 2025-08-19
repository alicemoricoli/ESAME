# Codice - esame Telerilevamento Geo-Ecologico in R

# Incendio sul San Bartolo: valutazione dell'impatto da immagini satellitari prima e dopo. 

# Carichiamo in R i pacchetti necessari per l'analisi

library(terra) # pacchetto utilizzato per l'analisi di dati spaziali con dati vettoriali e raster 
library(imageRy) # pacchetto per la visualizzazione e manipolazione delle immagini raster 
library(viridis) # pacchetto per creare immagini con differenti palette di colori
library(ggridges) # pacchetto per la creazione di plot ridgeline
library(ggplot2) # pacchetto per la creazione di grafici a barre
library(patchwork) # pacchetto per l'unione dei grafici creati con ggplot2

#Vengono poi importate e visualizzate le immagini 

setwd("C:/Users/User/Desktop") # per impostare la working directory

pre = rast("pre_incendio.tif") # per importare e nominare l'immagine
plot(pre) # per visualizzare l'immagine importata
im.plotRGB(pre, r = 1, g = 2, b = 3, title = "Pre-incendio") #per visualizzare l'immagine a veri colori
dev.off() #per chiudere il pannello di visualizzazione delle immagini

post = rast("post_incendio.tif") # per importare e nominare l'immagine
plot(post) # per visualizzare l'immagine importata
im.plotRGB(post, r = 1, g = 2, b = 3, title = "Post-incendio") #per visualizzare l'immagine a veri colori
dev.off() #per chiudere il pannello di visualizzazione delle immagini

im.multiframe(1,2) #apro un pannello grafico ancora vuoto, di n° 1 righe e n°2 colonne
im.plotRGB(pre, r = 1, g = 2, b = 3, title = "Pre-incendio")  #visualizzo l'immagine pre nel pannello grafico
im.plotRGB(post, r = 1, g = 2, b = 3, title = "Post-incendio") #visualizzo l'immagine post nel pannello grafico

im.multiframe(2,4) #apro un pannello multiframe, ancora vuoto, di n°2 righe e n°4 colonne
plot(pre[[1]], col = magma(100), main = "Pre - Red") #viene specificata la banda, il colore e il titolo
plot(pre[[2]], col = magma(100), main = "Pre - Green")
plot(pre[[3]], col = magma(100), main = "Pre - Blue")
plot(pre[[4]], col = magma(100), main = "Pre - NIR")

plot(post[[1]], col = magma(100), main = "Post - Red")
plot(post[[2]], col = magma(100), main = "Post - Green")
plot(post[[3]], col = magma(100), main = "Post - Blue")
plot(post[[4]], col = magma(100), main = "Post - NIR")
dev.off()

# Calcolo degli indici spettrali per valutare il danno alla vegetazione
# Indice DVI

DVIpre = im.dvi(pre, 4, 1)  #per calcolare il DVI (immagine, banda NIR, banda R)
plot(DVIpre, stretch = "lin", main = "DVI-pre", col=inferno(100))  #per visualizzare graficamente il risultato, si specificano titolo e colore
dev.off()

DVIpost = im.dvi(post, 4, 1) #per calcolare il DVI (immagine, banda NIR, banda R)
plot(DVIpost, stretch = "lin", main = "NDVI-post", col=inferno(100)) #per visualizzare graficamente il risultato, si specificano titolo e colore
dev.off()

im.multiframe(1,2)  #per creare pannello multiframe con il DVI pre e post incendio
plot(DVIpre, stretch = "lin", main = "DVI-pre", col=inferno(100))  
plot(DVIpost, stretch = "lin", main = "DVI-post", col=inferno(100))
dev.off()

# Indice NDVI

NDVIpre = im.ndvi(pre, 4, 1)   #per calcolare l'NDVI pre-incendio
plot(NDVIpre, stretch = "lin", main = "NDVIpre", col=inferno(100))  #per visualizzare graficamente il risultato, si specificano titolo e colore 
dev.off()

NDVIpost = im.ndvi(post, 4, 1)  #per calcolare l'NDVI pre-incendio
plot(NDVIpost, stretch = "lin", main = "NDVIpost", col=inferno(100))  #per visualizzare graficamente il risultato, si specificano titolo e colore
dev.off()

im.multiframe(1,2)  #per creare pannello multiframe con l'NDVI pre e post incendio
plot(NDVIpre, stretch = "lin", main = "NDVI-pre", col=inferno(100))
plot(NDVIpost, stretch = "lin", main = "NDVI-post", col=inferno(100))
dev.off()

im.multiframe(2,2) #apre un pannello grafico ancora vuoto, con n°2 righe e n°2 colonne 
plot(DVIpre, stretch = "lin", main = "DVI-pre", col=inferno(100))
plot(DVIpost, stretch = "lin", main = "DVI-post", col=inferno(100))
plot(NDVIpre, stretch = "lin", main = "NDVI-pre", col=inferno(100))
plot(NDVIpost, stretch = "lin", main = "NDVI-post", col=inferno(100))
dev.off()

# Analisi Multitemporale

diff_red = pre[[1]] - post[[1]]  #per calcolare differenza nella banda del rosso tra pre e post incendio
diff_ndvi = NDVIpre - NDVIpost  #per calcolare la differenza dei valori di NDVI

im.multiframe(1,2)  #per creare pannello multiframe per visualizzare entrambe le immagini a confronto
plot(diff_red, main = "Differenza banda del rosso")
plot(diff_ndvi, main = "Differenza valori NDVI")
dev.off()

incendio = c(NDVIpre, NDVIpost)  #per creare vettore che ha come elementi le due immagini NDVI
names(incendio) =c("NDVI_pre", "NDVI_post")  #per creare vettore con i nomi relativi alle immagini

im.ridgeline(incendio, scale=1, palette="viridis")  #per creare grafico ridgelines 
dev.off()



