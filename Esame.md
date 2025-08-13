# ESAME TELERILEVAMENTO GEO-ECOLOGICO IN R
## ALICE MORICOLI
>matricola: 1178441

## Introduzione
Tra il **15** e **16 settembre 2022**, nella regione **Marche** si verificò un'**alluvione di straordinaria gravità**, che ha coinvolto in particolar modo le province di **Ancona** e **Pesaro e Urbino**, provocando 13 vittime, 50 feriti, 150 persone sfollate e danni per 2 miliardi di euro.

I centri abitati maggiormente colpiti sono stati Arcevia, Barbara, Cantiano, Frontone, Cagli, Montecarotto, Pergola, Sassoferrato, Castelleone di Suasa, Ostra, Serra Sant'Abbondio, Senigallia e Trecastelli.

In misura minore sono state colpite anche alcune zone dell'Umbria, nella provincia di Perugia, come Gubbio, Pietralunga, Scheggia e Pascelupo e Umbertide.

Il progetto si concentra nella zona di Senigallia e dintorni, dove ingenti danni sono stati provocati dall'esondazione del fiume Mise.

## Dati e metodi
I dati sono stati ricavati dal [sito di Google Earth Engine](https://earthengine.google.com/), provenienti dalla collezione [Sentinel2](https://developers.google.com/earth-engine/datasets/catalog/COPERNICUS_S2_SR_HARMONIZED?hl=it) della missione Copernicus.

L'intervallo temporale scelto per l'aquisizione delle immagini va dal:
- **20 agosto 2022 al 10 settembre 2022** per la situazione pre-evento
- **20 settembre 2022 al 10 ottobre 2022** per la situazione post- evento.

Si ottengono quindi due immagini mediane (pre e post evento) con incluse le bande: B2 (blu), B3 (verde), B4 (rosso), B8 (NIR).

Sono stati applicati un filtro immagine per la correzione di nuvolosità (seleziona solo immagini con meno del 40% di copertura nuvolosa) e un filtro pixel con la funzione maskS2clouds (usa la banda QA60 per mascherare pixel singoli coperti da nuvole o cirri) al fine di ottenere immagini il più possibile libere da nuvole.

Il progetto analizza l’alluvione usando immagini telerilevate  prima e dopo l’evento nell'area di interesse, al fine di:
- Individuare le aree allagate dopo l'alluvione (indice NDWI per evidenziare la presenza di acqua)
- Individuare cambiamenti vegetazionali (indice NDVI per evidenziare perdita di vegetazione)
- Determinare e quantificare l’estensione delle aree colpite (combinazione di NDVI e NDWI)

## Pacchetti utilizzati in R
``` r
library(terra) #pacchetto per l'utilizzo della funzione rast() per SpatRaster
library(imageRy) #pacchetto per la visualizzazione plot delle immagini; e le funzioni im.dvi() e im.ndvi()
library(viridis)  #pacchetto che permette di creare plot di immagini con differenti palette di colori di viridis
library(ggridges) #pacchetto che permette di creare i plot ridgeline
```
A seguire i codici in **Javascript** utilizzati su Google Earth Engine per ottenere le collection di immagini:
``` r
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


## Impostazione della working directory e importazione dei dati
setwd("~/Desktop/")

## Analisi dei dati
>  
## Risultati
grafici

## Conclusioni
