# Social Network Analysis

**Modulo 6 — Master OSINT, AI e Security Studies**
LUISS 2025/26

Prof. Fabio Giglietto
📧 fabio.giglietto@uniurb.it

🌐 **Sito del corso:** [fabiogiglietto.github.io/sna-luiss-2026](https://fabiogiglietto.github.io/sna-luiss-2026/)

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

| Blocco | Contenuto |
|--------|-----------|
| 1 | **Reti da Social Media Data** — Rete retweet, rete utente-hashtag |
| 2 | **Community Detection** — Edge Betweenness, Louvain, modularità, NMI |
| 3 | **Reti Bipartite** — Due tipi di nodi, proiezioni |
| 4 | **Coordinated Sharing Detection** — [coortweet](https://github.com/nicolarighetti/coortweet) |

---

## 🛠️ Setup

### Opzione A: Posit Cloud (consigliata per principianti)

Se preferisci non installare software sul tuo computer, puoi usare [Posit Cloud](https://posit.cloud/), un ambiente RStudio completo accessibile dal browser.

**Come iniziare:**

1. Vai su [posit.cloud](https://posit.cloud/) e clicca **Sign Up**
2. Registrati con email o account Google/GitHub
3. Dalla dashboard, clicca **New Project** → **New RStudio Project**
4. Attendi il caricamento dell'ambiente (circa 30 secondi)
5. Installa i pacchetti necessari nella Console (vedi punto 3 sotto)

> **Nota:** Il piano gratuito offre 25 ore/mese di utilizzo, sufficienti per il corso.

---

### Opzione B: Installazione locale

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
│   ├── 00_presentazione.qmd   # Presentazione corso
│   ├── 01_rappresentazioni.qmd
│   ├── 02_centralita.qmd
│   ├── 03_laboratorio.qmd
│   └── 04_lezione2.qmd
└── docs/
    ├── index.html             # Sito web del corso
    └── slides/                # Slide renderizzate (HTML)
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
