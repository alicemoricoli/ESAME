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
Tra il **4** e **5 agosto 2017**, il **Parco Naturale del Monte San Bartolo** è stato interessato dsa un vasto **incendio**, che coinvolse tutta la falesia bruciando più di 150 ettari del parco a picco sul mare, distruggendo boschi, campi e case e arrivando a minacciare i borghi di **Fiorenzuola di Focara** e **Casteldimezzo**.
Per valutare gli impatti ambientali dell'incendio sono state utilizzate delle immagini satellitari relative all'area compresa tra Fiorenzuola e Casteldimezzo.

In particolare, per valutare i cambiamenti pre e post impatto, sono stati scelti i seguenti intervalli temporali per l'aquisizione delle immagini:
- **1 luglio 2017 al 1 agosto 2017** per la situazione pre-evento
- **10 agosto 2017 al 1 settembre 2017** per la situazione post- evento.

## 2. Acquisizione delle immagini satellitari 🛰️
I dati sono stati ricavati dal sito [Google Earth Engine](https://earthengine.google.com/), provenienti dalla missione [ESA Sentinel-2](https://developers.google.com/earth-engine/datasets/catalog/COPERNICUS_S2_SR_HARMONIZED?hl=it).

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

In entrambi i codici:
- si definisce un **poligono** con le coordinate nell'area di interesse (aoi);
- si defisce l'intervallo temporale desiderato;
- si "pulisono" le immaginicon la funzione **mask2clouds** di mascheramento delle nubi, escludendo i pixel in cui soon presenti nuvole o cirri (la banda QA60 di Sentinel-2 contiene informazioni sulla qualità dei pixel);
- si selezionano solo immagini con **<20% nuvolosità**;
- si mantengono solo le bande necessarie: **Blu, Verde, Rosso, NIR**;
- si crea un **composito mediano**, ossia una collezione di immagini in cui ciascun pixel rappresenta il valore mediano di tutti i pixel delle immagini disponibili nel periodo scelto. Questo riduce ulteriormente la presenza di nuvole o outlier.
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
Analogamente per l'immagine post incendio:

``` r
post = rast("post_incendio.tif") # per importare e nominare l'immagine
plot(post) # per visualizzare l'immagine importata
im.plotRGB(post, r = 1, g = 2, b = 3, title = "Post-incendio") #per visualizzare l'immagine a veri colori
dev.off() #per chiudere il pannello di visualizzazione delle immagini
```

Per visualizzare le due immagini a confronto:

``` r
im.multiframe(1,2) #apro un pannello grafico ancora vuoto, di n° 1 righe e n°2 colonne
im.plotRGB(pre, r = 1, g = 2, b = 3, title = "Pre-incendio")  #visualizzo l'immagine pre nel pannello grafico
im.plotRGB(post, r = 1, g = 2, b = 3, title = "Post-incendio") #visualizzo l'immagine post nel pannello grafico
```
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
> [!NOTE]
> *La banda più informativa in questo caso è il NIR, che mette in evidenza il suolo nudo nell'immagine post-incendio.*


## 4. Calcolo degli indici spettrali 📇
Per valutare l'impatto dell'incendio sono stati calcolati gli indici **DVI** e **NDVI** per l'analisi della vegetazione.
Il **DVI** (Difference Vegetation Index) misura la **densità e la biomassa della vegetazione**. Più è alto il valore del DVI, più abbondante è la vegetazione.
Si calcola come:

$` DVI = (NIR - Red)`$

L'**NDVI** (Normalized Difference Vegetation Index) invece è un indice che misura lo stato di **salute della vegetazione** anch'esso utilizzando le bande NIR (B8) e Red (B4) ma restituisce valori normalizzati tra -1 e +1: 
- NDVI vicino a +1--> vegetazione sana
- NDVI vicino a 0 o negativo--> suoli nudi, urbanizzati, danneggiati o sommersi da acqua
- 0.3<NDVI<0.6--> praterie, arbusteti o colture agricole in fase di crescita
- 0.6<NDVI<0.9--> foreste dense e rigogliose

Si calcola come:

$` NDVI = \frac{(NIR - Red)}{(NIR + Red)} `$

Per velocizzare il calcolo degli indici in R sono state usate le funzioni provenienti dal pacchetto imageRy.

#### DVI: Difference Vegetation Index

Per l'immagine **pre incendio**:

``` r
DVIpre = im.dvi(pre, 4, 1)  #per calcolare il DVI (immagine, banda NIR, banda R)
plot(DVIpre, stretch = "lin", main = "DVI-pre", col=inferno(100))  #per visualizzare graficamente il risultato, si specificano titolo e colore
dev.off()
```
Analogamente per l'immagine **post incendio**:

``` r
DVIpost = im.dvi(post, 4, 1) #per calcolare il DVI (immagine, banda NIR, banda R)
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
> [!NOTE]
> *Dal confronto tra le due immagini risulta evidente la diminuzione di DVI nel tratto di corsa dell'immagine post-incendio.*

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

## 5. Analisi multitemporale

Un'ulteriore analisi per visualizzare l'impatto dell'incendio è stata fatta calcolando la differenza tra le immagini del prima e del dopo per quanto riguarda la banda del **rosso** e dei valori di **NDVI**.

```R
diff_red = pre[[1]] - post[[1]]  #per calcolare differenza nella banda del rosso tra pre e post incendio
diff_ndvi = NDVIpre - NDVIpost  #per calcolare la differenza dei valori di NDVI

im.multiframe(1,2)  #per creare pannello multiframe per visualizzare entrambe le immagini a confronto
plot(diff_red, main = "Differenza banda del rosso")
plot(diff_ndvi, main = "Differenza valori NDVI")
dev.off()
```
> [!NOTE]
> *La zona interessata dall'incendio risulta evidente soprattutto se si visualizza la differenza nei valori di NDVI.*

Per visualizzare graficamente la frequenza dei pixel di ogni immagine per ciascun valore di NDVI è stata poi fatta un'analisi ridgeline dei valori di NDVI nel pre e nel post incendio. Questa permette appunto di creare due curve di distribuzione con cui diventa possibile osservare eventuali variazioni nel tempo della frequenza di NDVI.

```R

```



## Risultati e conclusioni
grafici

