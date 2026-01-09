# Social Network Analysis

**Modulo 6 — Master OSINT, AI e Security Studies**  
LUISS 2025/26

Prof. Fabio Giglietto  
📧 fabio.giglietto@uniurb.it

---

## 📋 Descrizione

Questo modulo introduce la Social Network Analysis (SNA) come strumento per l'intelligence e l'OSINT. Attraverso teoria e pratica, imparerai a:

- Rappresentare e analizzare reti sociali
- Calcolare metriche di centralità per identificare attori chiave
- Rilevare comunità e strutture nascoste
- Applicare SNA a dati social media (Twitter/X)

---

## 📅 Struttura del Modulo

### Lezione 1 — In presenza (5 ore)
*9 Gennaio 2026, 14:00-19:00*

| Blocco | Durata | Contenuto |
|--------|--------|-----------|
| 1 | 75 min | Rappresentazioni dei grafi, proprietà di base |
| 2 | 75 min | Centralità: degree, betweenness, closeness, eigenvector |
| 3 | 90 min | Laboratorio R/igraph + Gephi |

### Lezione 2 — Online (5 ore)
*16 Gennaio 2026, 14:00-19:00*

- Monitoraggio reti sociali
- API per la raccolta dati
- Visualizzazione grafica delle reti informative

---

## 🛠️ Setup

### 1. Installa R
Scarica da [cran.r-project.org](https://cran.r-project.org) (versione 4.3+)

### 2. Installa RStudio
Scarica da [posit.co](https://posit.co/download/rstudio-desktop/)

### 3. Installa i pacchetti R
Apri RStudio e esegui:

```r
install.packages(c(
  "igraph",
  "ggraph",
  "tidyverse",
  "readr",
  "corrplot",
  "ggpubr"
))
```

### 4. Installa Gephi
Scarica da [gephi.org](https://gephi.org) (richiede Java 11+)

### 5. Verifica
Esegui `scripts/setup_verifica.R` — se vedi "Setup completato!", sei pronto.

---

## 📁 Contenuto Repository

```
├── data/
│   ├── stormofswords.csv      # Dataset Game of Thrones (Lezione 1)
│   └── lezione2.RData         # Dati Twitter (Lezione 2)
├── scripts/
│   ├── setup_verifica.R       # Script verifica installazione
│   └── lab_sna_lezione1.R     # Script completo laboratorio
├── slides/
│   ├── SNA_00_Presentazione_Corso.pptx
│   ├── SNA_Blocco1_Rappresentazioni.pptx
│   ├── SNA_Blocco2_Centralita.pptx
│   └── SNA_Blocco3_Laboratorio.pptx
└── docs/
    └── index.html             # Sito web del corso
```

---

## 📚 Risorse

| Risorsa | Link |
|---------|------|
| **Libro** (gratuito) | [networkatlas.eu](https://networkatlas.eu) — M. Coscia, 2nd ed. 2025 |
| **igraph R** | [igraph.org/r](https://igraph.org/r/doc/) |
| **Gephi Tutorial** | [gephi.org/users](https://gephi.org/users/) |
| **R for Data Science** | [r4ds.hadley.nz](https://r4ds.hadley.nz) |

### Capitoli consigliati dal libro

**Lezione 1:**
- Parte III (cap. 7-9): Degree, Paths, Components
- Parte IV (cap. 13-15): Centrality measures

**Lezione 2:**
- Parte V (cap. 16-20): Community Detection
- Parte II (cap. 6): Bipartite Networks

---

## ⚡ Quick Start

```r
# Carica i pacchetti
library(igraph)
library(ggraph)
library(tidyverse)

# Importa il dataset
edges <- read_csv("data/stormofswords.csv")  # o il percorso completo
g <- graph.data.frame(edges, directed = FALSE)

# Info di base
vcount(g)  # 107 nodi
ecount(g)  # 352 archi

# Visualizza
ggraph(g, layout = "nicely") +
  geom_edge_link(color = "gray", alpha = 0.5) +
  geom_node_point(aes(size = degree(g))) +
  theme_graph()
```

---

## 📄 Licenza

Materiali didattici © 2025 Fabio Giglietto  
Dataset "Storm of Swords" da [A. Beveridge & J. Shan](https://github.com/mathbeveridge/asoiaf)
