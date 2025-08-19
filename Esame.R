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

soglia = 0.3  #definisce la soglia per distinguere le due classi: se NDVI>0.3 si ha vegetazione elevata, se NDVI<0.3 si ha vegetazione scarsa o assente

classi_pre = classify(NDVIpre, rcl = matrix(c(-Inf, soglia, 0, soglia, Inf, 1), ncol = 3, byrow = TRUE)) #effettua una classificazione dei valori NDVI contenuti nel raster NDVIpre (immagine pre-incendio). La funzione classify della libreria terra permette di trasformare i valori di un raster secondo regole definite dall'utente: Classe 0: NDVI ≤ 0.3 (assenza o bassa vegetazione); Classe 1: NDVI > 0.3 (presenza di vegetazione).
plot(classi_pre, col = c("brown", "green")) #per visualizzare la classificazione

classi_post = classify(NDVIpost, rcl = matrix(c(-Inf, soglia, 0, soglia, Inf, 1), ncol = 3, byrow = TRUE)) #effettua una classificazione dei valori NDVI contenuti nel raster NDVIpost (immagine post-incendio). La funzione classify della libreria terra permette di trasformare i valori di un raster secondo regole definite dall'utente: Classe 0: NDVI ≤ 0.3 (assenza o bassa vegetazione); Classe 1: NDVI > 0.3 (presenza di vegetazione).
plot(classi_post, col = c("brown", "green")) #per visualizzare la classificazione

im.multiframe(1,3)
plot(classi_pre, main = "Pixel NDVI pre-incendio")
plot(classi_post, main = "Pixel NDVI post-incendio")
plot(classi_pre - classi_post, main = "Differenza NDVI pre e post incendio")
dev.off()

perc_pre = freq(classi_pre) * 100 / ncell(classi_pre)  #per calcolare la frequenza percentuale di ciascuna classe
perc_pre  #per visualizzare la frequenza percentuale

perc_post = freq(classi_post) * 100 / ncell(classi_post)  #per calcolare la frequenza percentuale di ciascuna classe
perc_post  #per visualizzare la frequenza percentuale


NDVI = c("elevato", "basso") #per creare un vettore con i nomi delle due classi
pre = c(67.58, 32.42)  #per creare un vettore con le percentuali pre incendio
post = c(44.39, 55.61)  #per creare un vettore con le percentuali post incendio
table = data.frame(NDVI, pre, post)  #per creare un dataframe con i valori di NDVI pre e post
table #per visualizzare il dataframe

ggplotpreincendio = ggplot(table, aes(x=NDVI, y=pre, fill=NDVI, color=NDVI)) + geom_bar(stat="identity") + ylim(c(0,100))  #per creare ggplot con i valori di NDVI ottenuti 
ggplotpostincendio = ggplot(table, aes(x=NDVI, y=post, fill=NDVI, color=NDVI)) + geom_bar(stat="identity") + ylim(c(0,100))
ggplotpreincendio + ggplotpostincendio + plot_annotation(title = "Valori NDVI (espressi in superficie) nell'area interessata dall’incendio")    #per unire i grafici crati, si specifica il titolo 
dev.off()




