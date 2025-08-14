# ESAME TELERILEVAMENTO GEO-ECOLOGICO IN R
> ## ALICE MORICOLI
>> ### matricola: 1178441

## L'alluvione delle Marche del 2022 vista da satellite
Tra il **15** e **16 settembre 2022**, nella regione **Marche** si verificò un'**alluvione di straordinaria gravità**, che coinvolse in particolar modo le province di **Ancona** e **Pesaro e Urbino**, provocando 13 vittime, 50 feriti, 150 persone sfollate e danni per 2 miliardi di euro.

I centri abitati maggiormente colpiti sono stati Arcevia, Barbara, Cantiano, Frontone, Cagli, Montecarotto, Pergola, Sassoferrato, Castelleone di Suasa, Ostra, Serra Sant'Abbondio, Senigallia e Trecastelli.

In misura minore sono state colpite anche alcune zone dell'Umbria, nella provincia di Perugia, come Gubbio, Pietralunga, Scheggia e Pascelupo e Umbertide.

Il progetto si concentra nella zona di Senigallia e dintorni, dove ingenti danni sono stati provocati dall'esondazione del fiume Mise.

## Acquisizione delle immagini satellitari 🛰️📡
### Download immagini ⬇️
I dati sono stati ricavati dal sito [Google Earth Engine](https://earthengine.google.com/), provenienti dalla missione [ESA Sentinel-2](https://developers.google.com/earth-engine/datasets/catalog/COPERNICUS_S2_SR_HARMONIZED?hl=it).

L'intervallo temporale scelto per l'aquisizione delle immagini va dal:
- **20 agosto 2022 al 10 settembre 2022** per la situazione pre-evento
- **20 settembre 2022 al 10 ottobre 2022** per la situazione post- evento.

Si ottengono quindi due immagini mediane (pre e post evento) con incluse le bande: B2 (blu), B3 (verde), B4 (rosso), B8 (NIR).

Sono stati applicati un filtro immagine per la correzione di nuvolosità (seleziona solo immagini con meno del 40% di copertura nuvolosa) e un filtro pixel con la funzione maskS2clouds (usa la banda QA60 per mascherare pixel singoli coperti da nuvole o cirri) al fine di ottenere immagini il più possibile libere da nuvole.

A seguire il codice in JavaScript utilizzato 

Il progetto analizza l’alluvione usando immagini telerilevate  prima e dopo l’evento nell'area di interesse, al fine di:
- Individuare le aree allagate dopo l'alluvione (indice NDWI per evidenziare la presenza di acqua)
- Individuare cambiamenti vegetazionali (indice NDVI per evidenziare perdita di vegetazione)
- Determinare e quantificare l’estensione delle aree colpite (combinazione di NDVI e NDWI)

## Pacchetti utilizzati in R
``` r
library(terra) #questo comando carica la libreria terra in R
library(imageRy) #pacchetto per la visualizzazione plot delle immagini; e le funzioni im.dvi() e im.ndvi()
library(viridis)  #pacchetto che permette di creare plot di immagini con differenti palette di colori di viridis
library(ggridges) #pacchetto che permette di creare i plot ridgeline
```
A seguire i codici in **Javascript** utilizzati su Google Earth Engine per ottenere le collection di immagini:
<details>
<summary>codici JavaScript (cliccare qui)</summary>
  
``` JavaScript

// === AOI: Senigallia, Marche ===
var aoi = ee.Geometry.Rectangle([13.00, 43.65, 13.20, 43.75]);

// === Funzione cloud mask ===
function maskS2clouds(image) {
  var qa = image.select('QA60');
  var cloudBitMask = 1 << 10;
  var cirrusBitMask = 1 << 11;

  var mask = qa.bitwiseAnd(cloudBitMask).eq(0)
               .and(qa.bitwiseAnd(cirrusBitMask).eq(0));

  // Mantiene solo le bande necessarie e applica la maschera
  return image.updateMask(mask)
              .select(['B2','B3','B4','B8'])
              .divide(10000);
}

// === Date pre e post evento ===
var preStart  = '2022-08-20';
var preEnd    = '2022-09-10';
var postStart = '2022-09-20';
var postEnd   = '2022-10-10';

// === Collezione pre-evento ===
var preCol = ee.ImageCollection('COPERNICUS/S2_SR_HARMONIZED')
                .filterDate(preStart, preEnd)
                .filterBounds(aoi)
                .filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE', 40))
                .map(maskS2clouds);

// === Collezione post-evento ===
var postCol = ee.ImageCollection('COPERNICUS/S2_SR_HARMONIZED')
                .filterDate(postStart, postEnd)
                .filterBounds(aoi)
                .filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE', 40))
                .map(maskS2clouds);

// === Conta immagini disponibili ===
print('Pre-evento count:', preCol.size());
print('Post-evento count:', postCol.size());

// === Compositi mediani ===
var preMedian  = preCol.median().clip(aoi);
var postMedian = postCol.median().clip(aoi);

// === Visualizza in RGB ===
Map.centerObject(aoi, 12);
Map.addLayer(preMedian,  {bands: ['B4','B3','B2'], min: 0, max: 0.3}, 'Pre-evento RGB');
Map.addLayer(postMedian, {bands: ['B4','B3','B2'], min: 0, max: 0.3}, 'Post-evento RGB');

// === Export pre-evento ===
Export.image.toDrive({
  image: preMedian,
  description: 'Senigallia_Pre_Bands',
  folder: 'GEE_exports',
  fileNamePrefix: 'senigallia_pre',
  region: aoi,
  scale: 10,
  crs: 'EPSG:4326',
  maxPixels: 1e10
});

// === Export post-evento ===
Export.image.toDrive({
  image: postMedian,
  description: 'Senigallia_Post_Bands',
  folder: 'GEE_exports',
  fileNamePrefix: 'senigallia_post',
  region: aoi,
  scale: 10,
  crs: 'EPSG:4326',
  maxPixels: 1e10
});

```
</details>


## Impostazione della working directory e importazione dei dati
setwd("~/Desktop/")

## Analisi dei dati

Di seguito viene riportato il codice utilizzato in R per l'analisi delle immagini pre e post alluvione.

### Caricamento e preparazione dati

```R
pre <- rast("C:/Users/User/Desktop/senigallia_pre.tif") #questa funzione viene utilizzata per leggere un file raster e appartiene al pacchetto terra
post <- rast("C:/Users/User/Desktop/senigallia_post.tif")
pre #richiamando l'oggeto appena creato ne visualizzo i dettagli
post
im.multiframe(1,2) #apro un pannello grafico ancora vuoto, di n° 1 righe e 2 colonne
plotRGB(pre, r = 3, g = 2, b = 1, stretch = "lin", main = "Pre-evento") #visualizzo l'immagine pre nel pannello grafico
plotRGB(post, r = 3, g = 2, b = 1, stretch = "lin", main = "Post-evento") #visualizzo l'immagine post nel pannello grafico

```
### Calcolo degli indici spettrali
Per analizzare l'alluvione, due indici spettrali sono molto utili:


- **NDWI**: individua l’acqua superficiale e aree allagate nelle immagini satellitari (valori positivi)

$` NDWI = \frac{(Green-NIR)}{(Green+NIR)} `$

Entrambi vengono calcolati per le immagini pre e post evento, per poi valutare la loro differenza.

#### NDVI: Normalized Difference Vegetation Index

L'**NDVI** è un indice che misura lo stato di salute della vegetazione usando le bande NIR (B8) e Red (B4).  I valori restituiti vengono normalizzati tra -1 e +1.
- NDVI vicino a +1--> vegetazione sana
- NDVI vicino a 0 o negativo--> suoli nudi, urbanizzati, danneggiati o sommersi da acqua

$` NDVI = \frac{(NIR - Red)}{(NIR + Red)} `$
```R
ndvi_pre  <- (pre[[4]] - pre[[3]]) / (pre[[4]] + pre[[3]])
ndvi_post <- (post[[4]] - post[[3]]) / (post[[4]] + post[[3]])
im.multiframe(1,2)
plot(ndvi_pre)
plot(ndvi_post)
im.multiframe(1,2) #in questo modo metto a confronto i valori di NDVI calcolati prima e dopo l'evento alluvionale
plot(ndvi_pre)
plot(ndvi_post)
ndvi_diff <- ndvi_post - ndvi_pre #calcolo la differenza nei valori di NDVI pre e post evento
plot(ndvi_diff) #un calo indica un danno nella vegetazione. Ci permette di capire dove la vegetazione è stata spazzata via

```
#### Normalized Difference Water Index 

```R
ndwi_pre  <- (pre[[2]] - pre[[4]]) / (pre[[2]] + pre[[4]])
ndwi_post <- (post[[2]] - post[[4]]) / (post[[2]] + post[[4]])
im.multiframe(1,2) #in questo modo metto a confronto i valori di NDWI calcolati prima e dopo l'evento alluvionale
plot(ndwi_pre)
plot(ndwi_post)
ndwi_diff <- ndwi_post - ndwi_pre #calcolo la differenza nei valori di NDVI pre e post evento
plot(ndwi_diff) #un aumento indica la presenza di acqua post-evento
```

#### Analisi combinata: NDVI e NDWI
L'obiettivo è valutare le aree che maggiormente hanno subito danni a seguito dell'alluvione, integrando le informazioni provenienti dai due indici spettrali: NDVI e NDWI.

```R

```



## Risultati
grafici

## Conclusioni
