# ESAME TELERILEVAMENTO GEO-ECOLOGICO IN R
> ## ALICE MORICOLI
>> ### matricola: 1178441

# Incendio sul San Bartolo: valutazione dell'impatto da immagini satellitari

## Indice 📑
1. Introduzione e obiettivi dello studio
2. Acquisizione delle immagini satellitari 
3. Analisi delle immagini
4. Calcolo degli indici spettrali
5. Analisi multitemporale
6. Risultati e conclusioni


## 1. Introduzione e obiettivi dello studio ✔️
Tra il **4** e **5 agosto 2017**, il **Parco Naturale del Monte San Bartolo** è stato interessato da un vasto **incendio**, che ha coinvolto tutta la falesia bruciando più di 150 ettari del parco a picco sul mare, distruggendo boschi, campi e case e arrivando a minacciare i borghi di **Fiorenzuola di Focara** e **Casteldimezzo**.
Per valutare gli impatti ambientali dell'incendio sono state utilizzate delle immagini satellitari relative all'area compresa tra Fiorenzuola e Casteldimezzo.

In particolare, per valutare i cambiamenti pre e post impatto, sono stati scelti i seguenti intervalli temporali per l'aquisizione delle immagini:
- **1 luglio 2017 al 1 agosto 2017** per la situazione pre-evento
- **10 agosto 2017 al 1 settembre 2017** per la situazione post- evento.

<p align="center">
  <img src="https://github.com/alicemoricoli/Telerilevamento_2025/blob/main/Pics/incendio-sul-san-bartolo-il-giorno-dopo-fotoprint.jpeg" alt="image" width="600">
</p>

> Monte San Bartolo il giorno successivo all'incendio

## 2. Acquisizione delle immagini satellitari 🛰️
I dati utilizzati provengono dalla missione [Sentinel-2](https://developers.google.com/earth-engine/datasets/catalog/COPERNICUS_S2_SR_HARMONIZED?hl=it) dell'ESA (all'interno del programma Copernicus) e sono stati scaricati ed elaborati tramite la piattaforma [Google Earth Engine](https://earthengine.google.com/).
Per ottenere le immagini dell'area di interesse **prima** dell'incendio è stato utilizzato il seguente codice in **Javascript**:
<details>
<summary>codici JavaScript (cliccare qui)</summary>
  
``` JavaScript
var aoi = 
    /* color: #d63000 */
    /* shown: false */
    /* displayProperties: [
      {
        "type": "rectangle"
      }
    ] */
    ee.Geometry.Polygon(
        [[[12.803180046205446,43.94852282252429],
        [12.829701728944704,43.94852282252429],
        [12.829701728944704,43.95902703966519],
        [12.803180046205446,43.95902703966519],
        [12.803180046205446,43.94852282252429]]], null, false);
// ==============================================
// Sentinel-2 Surface Reflectance - Cloud Masking and Visualization
// https://developers.google.com/earth-engine/datasets/catalog/COPERNICUS_S2_SR_HARMONIZED
// ==============================================

// ==============================================
// Function to mask clouds using the QA60 band
// Bits 10 and 11 correspond to opaque clouds and cirrus
// ==============================================
function maskS2clouds(image) {
  var qa = image.select('QA60');
  var cloudBitMask = 1 << 10;
  var cirrusBitMask = 1 << 11;

  // Keep only pixels where both cloud and cirrus bits are 0
  var mask = qa.bitwiseAnd(cloudBitMask).eq(0)
               .and(qa.bitwiseAnd(cirrusBitMask).eq(0));

  // Apply the cloud mask and scale reflectance values (0–10000 ➝ 0–1)
  return image.updateMask(mask).divide(10000);
}

// ==============================================
// Load and Prepare the Image Collection
// ==============================================

// Load Sentinel-2 SR Harmonized collection (atmospherical correction already done)
var collection = ee.ImageCollection('COPERNICUS/S2_SR_HARMONIZED')
                   .filterDate('2017-07-01', '2017-08-01')              // Filter by date
                   .filterBounds(aoi)                                   // Filter by AOI
                   .filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE', 20)) // Only images with <20% cloud cover
                   .map(maskS2clouds) // Apply cloud masking
                  .select(['B2', 'B3', 'B4', 'B8', 'B12']);  // Blu, Verde, Rosso, NIR, SWIR2

// Print number of images available after filtering
print('Number of images in collection:', collection.size());

// ==============================================
// Create a median composite from the collection
// Useful when the AOI overlaps multiple scenes or frequent cloud cover
// ==============================================
var composite = collection.median().clip(aoi);

// ==============================================
// Visualization on the Map
// ==============================================

Map.centerObject(aoi, 10); // Zoom to the AOI

// Display the first image of the collection (GEE does this by default)
Map.addLayer(collection, {
  bands: ['B4', 'B3', 'B2'],  // True color: Red, Green, Blue
  min: 0,
  max: 0.3
}, 'First image of collection');

// Display the median composite image
Map.addLayer(composite, {
  bands: ['B4', 'B3', 'B2'],
  min: 0,
  max: 0.3
}, 'Median composite');

// ==============================================
// Export to Google Drive
// ==============================================

// Export the median composite
Export.image.toDrive({
  image: composite.select(['B4', 'B3', 'B2', 'B8', 'B12']),  // Select RGB bands
  description: 'Sentinel2_Median_Composite',
  folder: 'GEE_exports',                        // Folder in Google Drive
  fileNamePrefix: 'sentinel2_median_2020',
  region: aoi,
  scale: 10,                                    // Sentinel-2 resolution
  crs: 'EPSG:4326',
  maxPixels: 1e13
});

```
</details>

In maniera analoga è stato utilizzato il seguente codice per l'acquisizione dell'immagine **post** incendio:
<details>
<summary>codici JavaScript (cliccare qui)</summary>
  
``` JavaScript
var aoi = 
    /* color: #d63000 */
    /* shown: false */
    /* displayProperties: [
      {
        "type": "rectangle"
      }
    ] */
    ee.Geometry.Polygon(
        [[[12.803180046205446,43.94852282252429],
        [12.829701728944704,43.94852282252429],
        [12.829701728944704,43.95902703966519],
        [12.803180046205446,43.95902703966519],
        [12.803180046205446,43.94852282252429]]], null, false);
// ==============================================
// Sentinel-2 Surface Reflectance - Cloud Masking and Visualization
// https://developers.google.com/earth-engine/datasets/catalog/COPERNICUS_S2_SR_HARMONIZED
// ==============================================

// ==============================================
// Function to mask clouds using the QA60 band
// Bits 10 and 11 correspond to opaque clouds and cirrus
// ==============================================
function maskS2clouds(image) {
  var qa = image.select('QA60');
  var cloudBitMask = 1 << 10;
  var cirrusBitMask = 1 << 11;

  // Keep only pixels where both cloud and cirrus bits are 0
  var mask = qa.bitwiseAnd(cloudBitMask).eq(0)
               .and(qa.bitwiseAnd(cirrusBitMask).eq(0));

  // Apply the cloud mask and scale reflectance values (0–10000 ➝ 0–1)
  return image.updateMask(mask).divide(10000);
}

// ==============================================
// Load and Prepare the Image Collection
// ==============================================

// Load Sentinel-2 SR Harmonized collection (atmospherical correction already done)
var collection = ee.ImageCollection('COPERNICUS/S2_SR_HARMONIZED')
                   .filterDate('2017-08-10', '2017-09-01')              // Filter by date
                   .filterBounds(aoi)                                   // Filter by AOI
                   .filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE', 20)) // Only images with <20% cloud cover
                   .map(maskS2clouds) // Apply cloud masking
                  .select(['B2', 'B3', 'B4', 'B8', 'B12']);  // Blu, Verde, Rosso, NIR, SWIR2

// Print number of images available after filtering
print('Number of images in collection:', collection.size());

// ==============================================
// Create a median composite from the collection
// Useful when the AOI overlaps multiple scenes or frequent cloud cover
// ==============================================
var composite = collection.median().clip(aoi);

// ==============================================
// Visualization on the Map
// ==============================================

Map.centerObject(aoi, 10); // Zoom to the AOI

// Display the first image of the collection (GEE does this by default)
Map.addLayer(collection, {
  bands: ['B4', 'B3', 'B2'],  // True color: Red, Green, Blue
  min: 0,
  max: 0.3
}, 'First image of collection');

// Display the median composite image
Map.addLayer(composite, {
  bands: ['B4', 'B3', 'B2'],
  min: 0,
  max: 0.3
}, 'Median composite');

// ==============================================
// Export to Google Drive
// ==============================================

// Export the median composite
Export.image.toDrive({
  image: composite.select(['B4', 'B3', 'B2', 'B8', 'B12']),  // Select RGB bands
  description: 'Sentinel2_Median_Composite',
  folder: 'GEE_exports',                        // Folder in Google Drive
  fileNamePrefix: 'sentinel2_median_2020',
  region: aoi,
  scale: 10,                                    // Sentinel-2 resolution
  crs: 'EPSG:4326',
  maxPixels: 1e13
});

```
</details>

In entrambi i codici:
- si definisce un **poligono** con le coordinate nell'area di interesse (aoi);
- si defisce l'intervallo temporale desiderato;
- si "pulisono" le immagini con la funzione **mask2clouds** di mascheramento delle nubi, escludendo i pixel in cui soon presenti nuvole o cirri (la banda QA60 di Sentinel-2 contiene informazioni sulla qualità dei pixel);
- si selezionano solo immagini con **<20% nuvolosità**;
- si mantengono solo le bande necessarie: **Blu, Verde, Rosso, NIR, SWIR2**;
- si crea un **composito mediano**, ossia una collezione di immagini in cui ciascun pixel rappresenta il valore mediano di tutti i pixel delle immagini disponibili nel periodo scelto. Questo riduce ulteriormente la presenza di nuvole o outlier;
- si salva l’immagine composita in **Google Drive**, dentro la cartella GEE_exports
  
  
## 3. Importazione e visualizzazione delle immagini 🖼️
Una volta ottenute le immagini satellitari, queste sono state importate su R per poter fare un'analisi dettagliata.
Per farlo, sono stati installati e richiamati in R i seguenti pacchetti:
``` r
library(terra) #pacchetto utilizzato per l'analisi di dati spaziali con dati vettoriali e raster 
library(imageRy) #pacchetto per la visualizzazione e manipolazione delle immagini raster 
library(viridis) #pacchetto per creare immagini con differenti palette di colori
library(ggridges) #pacchetto per la creazione di plot ridgeline
library(ggplot2) #pacchetto per la creazione di grafici a barre
library(patchwork) #pacchetto per l'unione dei grafici creati con ggplot2
```
Per prima cosa è stata impostata la working directory e poi sono state importate e visualizzate le immagini. 

``` r
setwd("C:/Users/User/Desktop") # in questo caso le immagini scaricate da GEE sono salvate sul Desktop
```

``` r
pre = rast("pre_incendio.tif") # per importare e nominare l'immagine
plot(pre) # per visualizzare l'immagine importata
im.plotRGB(pre, r = 1, g = 2, b = 3, title = "Pre-incendio") #per visualizzare l'immagine a veri colori
dev.off() #per chiudere il pannello di visualizzazione delle immagini
```
<p align="center">
  <img src="https://github.com/alicemoricoli/Telerilevamento_2025/blob/main/Pics/1.pre-incendio.jpeg">
</p>

> Immagine pre-incendio nelle 4 bande

<p align="center">
  <img src="https://github.com/alicemoricoli/Telerilevamento_2025/blob/main/Pics/2.RBG_pre.jpeg" alt="image" width="700">
</p>

> Immagine pre-incendio a veri colori

Analogamente per l'immagine post incendio:

``` r
post = rast("post_incendio.tif") # per importare e nominare l'immagine
plot(post) # per visualizzare l'immagine importata
im.plotRGB(post, r = 1, g = 2, b = 3, title = "Post-incendio") #per visualizzare l'immagine a veri colori
dev.off() #per chiudere il pannello di visualizzazione delle immagini
```
<p align="center">
  <img src="https://github.com/alicemoricoli/Telerilevamento_2025/blob/main/Pics/2.post-incendio.jpg">
</p>

> Immagine post-incendio nelle 4 bande

<p align="center">
  <img src="https://github.com/alicemoricoli/Telerilevamento_2025/blob/main/Pics/2.post-incendio.jpeg"alt="image" width="700">
</p>

> Immagine post-incendio a veri colori

Per visualizzare le due immagini a confronto:

``` r
im.multiframe(1,2) #apro un pannello grafico ancora vuoto, di n° 1 righe e n°2 colonne
im.plotRGB(pre, r = 1, g = 2, b = 3, title = "Pre-incendio")  #visualizzo l'immagine pre nel pannello grafico
im.plotRGB(post, r = 1, g = 2, b = 3, title = "Post-incendio") #visualizzo l'immagine post nel pannello grafico
```
<p align="center">
  <img src="https://github.com/alicemoricoli/Telerilevamento_2025/blob/main/Pics/3.pre-post.jpeg"alt="image" width="900">
</p>

> Immagini pre e post-incendio a veri colori a confronto


> [!NOTE]
> *Nella seconda immagine è chiaramente visibile la costa interessata dall'incendio.*

Infine possiamo visualizzare in un pannello multiframe, le 4 bande a confronto:

``` r
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
```
<p align="center">
  <img src="https://github.com/alicemoricoli/Telerilevamento_2025/blob/main/Pics/4.bande-pre-post.jpeg" alt="image" width="1000">
</p>

> Immagini pre e post-incendio nelle 4 bande a confronto


> [!NOTE]
> *La banda più informativa in questo caso è il NIR, che mette in evidenza il suolo nudo nell'immagine post-incendio.*


## 4. Calcolo degli indici spettrali 📇
Per valutare l'impatto dell'incendio sono stati calcolati gli indici **DVI** e **NDVI** per l'analisi della vegetazione.

Il **DVI** (Difference Vegetation Index) misura la **densità e la biomassa della vegetazione**. Più è alto il valore del DVI, più abbondante è la vegetazione.
Si calcola come:

$$
DVI = (NIR - Red)
$$

L'**NDVI** (Normalized Difference Vegetation Index) invece è un indice che misura lo stato di **salute della vegetazione** anch'esso utilizzando le bande NIR (B8) e Red (B4) ma restituisce valori normalizzati tra -1 e +1: 
- NDVI vicino a +1--> vegetazione sana
- NDVI vicino a 0 o negativo--> suoli nudi, urbanizzati, danneggiati o sommersi da acqua
- 0.3<NDVI<0.6--> praterie, arbusteti o colture agricole in fase di crescita
- 0.6<NDVI<0.9--> foreste dense e rigogliose

Si calcola come:

$$
NDVI = \frac{(NIR - Red)}{(NIR + Red)} 
$$

Per velocizzare il calcolo degli indici in R sono state usate le funzioni provenienti dal pacchetto imageRy.

#### DVI: Difference Vegetation Index

Per l'immagine **pre incendio**:

``` r
DVIpre = im.dvi(pre, 4, 1)  #per calcolare il DVI (immagine, banda NIR, banda Red)
plot(DVIpre, stretch = "lin", main = "DVI-pre", col=inferno(100))  #per visualizzare graficamente il risultato, si specificano titolo e colore
dev.off()
```
Analogamente per l'immagine **post incendio**:

``` r
DVIpost = im.dvi(post, 4, 1) #per calcolare il DVI (immagine, banda NIR, banda Red)
plot(DVIpost, stretch = "lin", main = "NDVI-post", col=inferno(100)) #per visualizzare graficamente il risultato, si specificano titolo e colore
dev.off()
```
Ora per confrontare graficamente i risultati creiamo un pannello multiframe:

``` r
im.multiframe(1,2)  #per creare pannello multiframe con il DVI pre e post incendio
plot(DVIpre, stretch = "lin", main = "DVI-pre", col=inferno(100))  
plot(DVIpost, stretch = "lin", main = "DVI-post", col=inferno(100))
dev.off()
```

<p align="center">
  <img src="https://github.com/alicemoricoli/Telerilevamento_2025/blob/main/Pics/5.DVIpre-post.jpeg" alt="image" width="900">
</p>

> Indice DVI pre e post incendio a confronto

> [!NOTE]
> *Dal confronto tra le due immagini risulta evidente la diminuzione di DVI nel tratto di costa dell'immagine post-incendio.*

#### NDVI: Normalized Difference Vegetation Index

Analogamente è stato fatto per il calcolo dell'NDVI:

``` r
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
```

<p align="center">
  <img src="https://github.com/alicemoricoli/Telerilevamento_2025/blob/main/Pics/6.NDVI-pre-post.jpeg" alt="image" width="900">
</p>

> Indice NDVI pre e post incendio a confronto

> [!NOTE]
> *Anche in questo caso si nota che in corrispondenza della costa l'immagine post-incendio risulta più scura, ad indicare che i valori di NDVI sono diminuiti e quindi la vegetazione è stata danneggiata dalle fiamme.*

Per visualizzare entrambi gli indici pre e post-incendio in un unico pannello multiframe:

```R
im.multiframe(2,2) #apre un pannello grafico ancora vuoto, con n°2 righe e n°2 colonne 
plot(DVIpre, stretch = "lin", main = "DVI-pre", col=inferno(100))
plot(DVIpost, stretch = "lin", main = "DVI-post", col=inferno(100))
plot(NDVIpre, stretch = "lin", main = "NDVI-pre", col=inferno(100))
plot(NDVIpost, stretch = "lin", main = "NDVI-post", col=inferno(100))
dev.off()
```

<p align="center">
  <img src="https://github.com/alicemoricoli/Telerilevamento_2025/blob/main/Pics/7.DVI-NDVI-pre-post.jpeg" alt="image" width="900">
</p>

> Indici DVI e NDVI (pre e post incendio) a confronto


Inoltre, per valutare l'impatto dell'incendio, è stato calcolato l'indice **NBR**, **prima e dopo** l'incendio, e poi la **differenza** tra questi due.

#### NBR: Normalized Bur Ratio
L'NBR è un indice spettrale progettato per **rilevare, mappare e valutare** gli incendi usando immagini satellitari.
Si calcola come:

$$
NBR = \frac{NIR - SWIR}{NIR + SWIR}
$$

- Valori alti di NBR (vicini a +1) → vegetazione sana e densa (molto NIR, poco SWIR-Short Wawe Infrared)

- Valori bassi o negativi (0 → -1) → aree bruciate o con poca vegetazione (SWIR alto, NIR basso)

Il NBR da solo è utile, ma il vero indicatore di severità è il dNBR (differenced NBR):

<p align="center">
$dNBR = NBRpre - NBRpost$
</p>

- dNBR alto → forte cambiamento, area bruciata severamente

- dNBR basso o vicino a 0 → poca o nessuna variazione

- dNBR negativo → aumento della vegetazione (es. ricrescita post-incendio)

``` r
nbr_pre= (pre[[4]]-pre[[5]])/ (pre[[4]]+pre[[5]]) # calcolo NBR pre-incendio
plot(nbr_pre, main=”NBR pre-incendio”) # visualizzazione NBR pre-incendio
```

<p align="center">
  <img src="https://github.com/alicemoricoli/Telerilevamento_2025/blob/main/Pics/nbr_pre.jpeg" alt="image" width="900">
</p>

``` r
nbr_post= (post[[4]]-post[[5]])/ (post[[4]]+post[[5]]) # calcolo NBR post-incendio
plot(nbr_post, main=”NBR post-incendio”) # visualizzazione NBR post-incendio
```
<p align="center">
  <img src="https://github.com/alicemoricoli/Telerilevamento_2025/blob/main/Pics/nbr_post.jpeg" alt="image" width="900">
</p>

``` r
difnbr=nbr_pre-nbr_post # calcolo differenza pre-post incendio dei valori NBR
plot(difnbr, main=”Differenza NBR pre e post incendio”) # visualizzazione differenza NBR
```

<p align="center">
  <img src="https://github.com/alicemoricoli/Telerilevamento_2025/blob/main/Pics/difnbr.jpeg" alt="image" width="900">
</p>

Pre visualizzare tutto in un unico pannello multiframe:
``` r
im.multiframe(1,3)
plot(nbr_pre, main="NBR pre-incendio")
plot(nbr_post, main="NBR post-incendio")
plot(difnbr, main="Differenza NBR pre-post")
dev.off()
```
<p align="center">
  <img src="https://github.com/alicemoricoli/Telerilevamento_2025/blob/main/Pics/pannello.jpeg" width="900">
</p>

> [!NOTE]
> *Si nota chiaramente in giallo la zona interessata dall'incendio. Valori positivi (Vicini a 1) indicano le aree bruciate.*
  
## 5. Analisi multitemporale ⏲️

Un'ulteriore analisi per visualizzare l'impatto dell'incendio è stata fatta calcolando la differenza tra le immagini del prima e del dopo per quanto riguarda la banda del **rosso** e dei valori di **NDVI**.

```R
diff_red = pre[[1]] - post[[1]]  #per calcolare differenza nella banda del rosso tra pre e post incendio
diff_ndvi = NDVIpre - NDVIpost  #per calcolare la differenza dei valori di NDVI

im.multiframe(1,2)  #per creare pannello multiframe per visualizzare entrambe le immagini a confronto
plot(diff_red, main = "Differenza banda del rosso")
plot(diff_ndvi, main = "Differenza valori NDVI")
dev.off()
```
<p align="center">
  <img src="https://github.com/alicemoricoli/Telerilevamento_2025/blob/main/Pics/8.diff_rosso%2BNDVI.jpeg" alt="image" width="900">
</p>

> Differenza (pre e post incendio) nella banda del rosso e dei valori NDVI

> [!NOTE]
> *La zona interessata dall'incendio risulta evidente soprattutto se si visualizza la differenza nei valori di NDVI.*

Per visualizzare graficamente la frequenza dei pixel di ogni immagine per ciascun valore di NDVI è stata poi fatta un'**analisi ridgeline** dei valori di NDVI nel pre e nel post incendio. Questa permette di creare due curve di distribuzione con cui diventa possibile osservare eventuali variazioni nel tempo della frequenza di NDVI.

```R
incendio = c(NDVIpre, NDVIpost)  #per creare vettore che ha come elementi le due immagini NDVI
names(incendio) =c("NDVI_pre", "NDVI_post")  #per creare vettore con i nomi relativi alle immagini

im.ridgeline(incendio, scale=1, palette="viridis")  #per creare grafico ridgelines 
dev.off()
```
<p align="center">
  <img src="https://github.com/alicemoricoli/Telerilevamento_2025/blob/main/Pics/9.ridgeline.jpeg">
</p>

> Grafico ridgeline

> [!NOTE]
> *Il grafico ridgeline mostra la distribuzione dei valori di NDVI. Prima dell'incendio si ha un picco di valori di NDVI >0.75. Successivamente all'incendio invece aumentano i valori di NDVI più bassi (intorno a 0.25 e -0.25) e ciò conferma l'impatto dell'incendio sulla vegetazione.*

Per visualizzare la variazione percentuale di NDVI nell'area interessata dall'incendio è stato creato un **grafico a barre** tramite il pacchetto **ggplot2**. Questo permette di suddividere tutti i pixel di ciascuna immagine in due classi a seconda dei loro valori, in questo caso valori elevati di NDVI (vegetazione sana) e bassi (vegetazione scarsa/assente), per poi confrontarli graficamente.

```R
soglia = 0.3  #definisce la soglia per distinguere le due classi: se NDVI>0.3 si ha vegetazione elevata, se NDVI<0.3 si ha vegetazione scarsa o assente

classi_pre = classify(NDVIpre, rcl = matrix(c(-Inf, soglia, 0, soglia, Inf, 1), ncol = 3, byrow = TRUE)) #effettua una classificazione dei valori NDVI contenuti nel raster NDVIpre (immagine pre-incendio). La funzione classify della libreria terra permette di trasformare i valori di un raster secondo regole definite dall'utente: Classe 0: NDVI ≤ 0.3 (assenza o bassa vegetazione); Classe 1: NDVI > 0.3 (presenza di vegetazione).

plot(classi_pre, col = c("brown", "green")) #per visualizzare la classificazione

classi_post = classify(NDVIpost, rcl = matrix(c(-Inf, soglia, 0, soglia, Inf, 1), ncol = 3, byrow = TRUE)) #effettua una classificazione dei valori NDVI contenuti nel raster NDVIpost (immagine post-incendio). La funzione classify della libreria terra permette di trasformare i valori di un raster secondo regole definite dall'utente: Classe 0: NDVI ≤ 0.3 (assenza o bassa vegetazione); Classe 1: NDVI > 0.3 (presenza di vegetazione).

plot(classi_post, col = c("brown", "green")) #per visualizzare la classificazione

im.multiframe(1,3)
plot(classi_pre, main = "Pixel NDVI pre-incendio")
plot(classi_post, main = "Pixel NDVI post-incendio")
plot(classi_pre - classi_post, main = "Differenza NDVI pre-post")
dev.off()
```
<p align="center">
  <img src="https://github.com/alicemoricoli/Telerilevamento_2025/blob/main/Pics/10.ggplot.jpeg"alt="image" width="1000">
</p>

> Distribuzione dei pixel nelle due classi (1 e 0) nell'immagine pre, post e differenza

> [!NOTE]
> *I pixel vengono distinti in due classi: 1 vegetazione sana; 0 vegetazione assente o scarsa. Si nota come nell'immagine post-incendio i pixel relativi al tratto bruciato vengano riclassificati nella classe 0. Di conseguenza, visualizzando la differenza tra i due plot, in giallo (classe 1), si distingue la zona bruciata*

Visualizziamo ora questo risultato con un **grafico a barre**.

```R
perc_pre = freq(classi_pre) * 100 / ncell(classi_pre)  #per calcolare la frequenza percentuale di ciascuna classe
perc_pre  #per visualizzare la frequenza percentuale

 layer       value    count
1 0.002863033 0.000000000 32.41525
2 0.002863033 0.002863033 67.58475

perc_post = freq(classi_post) * 100 / ncell(classi_post)  #per calcolare la frequenza percentuale di ciascuna classe
perc_post  #per visualizzare la frequenza percentuale

  layer       value    count
1 0.002863033 0.000000000 55.60582
2 0.002863033 0.002863033 44.39418

NDVI = c("elevato", "basso") #per creare un vettore con i nomi delle due classi
pre = c(67.58, 32.42)  #per creare un vettore con le percentuali pre incendio
post = c(44.39, 55.61)  #per creare un vettore con le percentuali post incendio
table = data.frame(NDVI, pre, post)  #per creare un dataframe con i valori di NDVI pre e post
table #per visualizzare il dataframe

 NDVI     pre  post
1 elevato 67.58 44.39
2 basso   32.42 55.61

ggplotpreincendio = ggplot(table, aes(x=NDVI, y=pre, fill=NDVI, color=NDVI)) + geom_bar(stat="identity") + ylim(c(0,100))  #per creare ggplot con i valori di NDVI ottenuti 
ggplotpostincendio = ggplot(table, aes(x=NDVI, y=post, fill=NDVI, color=NDVI)) + geom_bar(stat="identity") + ylim(c(0,100))
ggplotpreincendio + ggplotpostincendio + plot_annotation(title = "Valori NDVI nell'area interessata dall’incendio")    #per unire i grafici crati, si specifica il titolo 
dev.off()
```
<p align="center">
  <img src="https://github.com/alicemoricoli/Telerilevamento_2025/blob/main/Pics/11.2ggplot.jpeg">
</p>

> Distribuzione dei pixel nelle due classi (1 e 0) mostrata con grafico a barre

> [!NOTE]
> *Questo grafico a barre permette di vedere come nell'immagine pre i valori di NDVI siano maggiormente elevati, mentre nell'immagine post la situazione è inversa, con più valori di NDVI bassi rispetto a quelli elevati. Questo conferma l'impatto dell'incendio sulla vegetazione.*

Per valutare quale sia stata la rispesa dell'area dopo l'incendio, si è confronta la situazione a due anni dall'incendio con quella pre incendio, per capire se la vegetazione sia tornata ai livelli pre-impatto. Pertanto è stata scaricata da GEE un'immagine mediana del periodo **1 luglio - 1 agosto 2019** utilizzando il codice **Javascript**:

<details>
<summary>codici JavaScript (cliccare qui)</summary>
  
``` JavaScript
var aoi = 
    /* color: #d63000 */
    /* shown: false */
    /* displayProperties: [
      {
        "type": "rectangle"
      }
    ] */
    ee.Geometry.Polygon(
        [[[12.803180046205446,43.94852282252429],
        [12.829701728944704,43.94852282252429],
        [12.829701728944704,43.95902703966519],
        [12.803180046205446,43.95902703966519],
        [12.803180046205446,43.94852282252429]]], null, false);
// ==============================================
// Sentinel-2 Surface Reflectance - Cloud Masking and Visualization
// https://developers.google.com/earth-engine/datasets/catalog/COPERNICUS_S2_SR_HARMONIZED
// ==============================================

// ==============================================
// Function to mask clouds using the QA60 band
// Bits 10 and 11 correspond to opaque clouds and cirrus
// ==============================================
function maskS2clouds(image) {
  var qa = image.select('QA60');
  var cloudBitMask = 1 << 10;
  var cirrusBitMask = 1 << 11;

  // Keep only pixels where both cloud and cirrus bits are 0
  var mask = qa.bitwiseAnd(cloudBitMask).eq(0)
               .and(qa.bitwiseAnd(cirrusBitMask).eq(0));

  // Apply the cloud mask and scale reflectance values (0–10000 ➝ 0–1)
  return image.updateMask(mask).divide(10000);
}

// ==============================================
// Load and Prepare the Image Collection
// ==============================================

// Load Sentinel-2 SR Harmonized collection (atmospherical correction already done)
var collection = ee.ImageCollection('COPERNICUS/S2_SR_HARMONIZED')
                   .filterDate('2019-07-01', '2019-08-01')              // Filter by date
                   .filterBounds(aoi)                                   // Filter by AOI
                   .filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE', 20)) // Only images with <20% cloud cover
                   .map(maskS2clouds) // Apply cloud masking
                  .select(['B2', 'B3', 'B4', 'B8']);  // Blu, Verde, Rosso, NIR

// Print number of images available after filtering
print('Number of images in collection:', collection.size());

// ==============================================
// Create a median composite from the collection
// Useful when the AOI overlaps multiple scenes or frequent cloud cover
// ==============================================
var composite = collection.median().clip(aoi);

// ==============================================
// Visualization on the Map
// ==============================================

Map.centerObject(aoi, 10); // Zoom to the AOI

// Display the first image of the collection (GEE does this by default)
Map.addLayer(collection, {
  bands: ['B4', 'B3', 'B2'],  // True color: Red, Green, Blue
  min: 0,
  max: 0.3
}, 'First image of collection');

// Display the median composite image
Map.addLayer(composite, {
  bands: ['B4', 'B3', 'B2'],
  min: 0,
  max: 0.3
}, 'Median composite');

// ==============================================
// Export to Google Drive
// ==============================================

// Export the median composite
Export.image.toDrive({
  image: composite.select(['B4', 'B3', 'B2', 'B8']),  // Select RGB bands
  description: 'Sentinel2_Median_Composite',
  folder: 'GEE_exports',                        // Folder in Google Drive
  fileNamePrefix: 'sentinel2_median_2020',
  region: aoi,
  scale: 10,                                    // Sentinel-2 resolution
  crs: 'EPSG:4326',
  maxPixels: 1e13
});
```
</details>

Eseguiamo un'analisi analoga per la nuova immagine relativa all'anno 2019.

```R
twoyears = rast("2019.tif") # per importare e nominare l'immagine
plot(twoyears) # per visualizzare l'immagine importata
im.plotRGB(twoyears, r = 1, g = 2, b = 3, title = "2 anni dopo") #per visualizzare l'immagine a veri colori
dev.off() #per chiudere il pannello di visualizzazione delle immagini

NDVItwoyears = im.ndvi(twoyears, 4, 1)   #per calcolare l'NDVI dopo due anni dall'incendio
plot(NDVItwoyears, stretch = "lin", main = "NDVIpre", col=inferno(100))  #per visualizzare graficamente il risultato, si specificano titolo e colore 
dev.off()

classi_twoyears = classify(NDVItwoyears, rcl = matrix(c(-Inf, soglia, 0, soglia, Inf, 1), ncol = 3, byrow = TRUE)) #effettua una classificazione dei valori NDVI contenuti nel raster NDVItwoyears (immagine a due anni dall'incendio). La funzione classify della libreria terra permette di trasformare i valori di un raster secondo regole definite dall'utente: Classe 0: NDVI ≤ 0.3 (assenza o bassa vegetazione); Classe 1: NDVI > 0.3 (presenza di vegetazione).

perc_twoyears = freq(classi_twoyears) * 100 / ncell(classi_twoyears)  #per calcolare la frequenza percentuale di ciascuna classe
perc_twoyears  #per visualizzare la frequenza percentuale

twoyears = c(72.11 , 27.89)  #per creare un vettore con le percentuali a due anni dall'incendio incendio
table = data.frame(NDVI, pre, post, twoyears)  #per creare un dataframe con i valori di NDVI pre e post
table #per visualizzare il dataframe

ggplottwoyears = ggplot(table, aes(x=NDVI, y=twoyears, fill=NDVI, color=NDVI)) + geom_bar(stat="identity") + ylim(c(0,100))
ggplotpreincendio + ggplotpostincendio + ggplottwoyears + plot_annotation(title = "Valori NDVI nell'area interessata dall’incendio")    #per unire i grafici crati, si specifica il titolo 
dev.off()
```
<p align="center">
  <img src="https://github.com/alicemoricoli/Telerilevamento_2025/blob/main/Pics/12.ggplottwoyears.jpeg">
</p>

> Distribuzione dei pixel nelle due classi (1 e 0) nell'immagine pre, post e a due anni dall'incendio (2019)

> [!NOTE]
> *Dal grafico è possibile osservare come, a due anni dall'incendio, la vegetazione si sia ripresa, ossia i valori di NDVI sopra il valore soglia sono aumentati e quelli sotto il valore soglia diminuiti. Pare anche che la vegetazione nel 2019 sia addirittura più presente rispetto al 2017 nella situazione pre incendio*

## 6. Risultati e conclusioni ⚓
L'analisi delle immagini satellitari mostra chiaramente l'impatto dell'incendio sull'area del San Bartolo. 
Inizialmente gran parte della vegetazione è stata distrutta, riducendone nettamente l’attività fotosintetica. Tuttavia, dopo due anni, l’area ha mostrato una forte capacità di rigenerazione: l’NDVI indica che la vegetazione non solo è tornata ai livelli pre-incendio, ma in alcuni punti li ha addirittura superati. Ciò dimostra l’elevata **resilienza** dell’ecosistema e la sua capacità di adattarsi e riprendersi dopo eventi di disturbo.
È plausibile che l’incendio abbia favorito la germinazione di specie pioniere e ridotto la competizione, determinando un apparente incremento della vigoria vegetativa rispetto al periodo antecedente il disturbo.
Ad ogni modo potrebbe trattarsi di una risposta temporanea, perciò andrebbero analizzati i valori di NDVI nel lungo tempo per capire se l'area si sia davvero ripristinata o se un possibile intervento possa risultare utile. 

<p align="center">
  <img src="https://github.com/alicemoricoli/Telerilevamento_2025/blob/main/Pics/foto_post.webp" alt="image" width="800">
</p>


## Grazie per l'attenzione! 
