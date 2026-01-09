# =============================================================================
# Social Network Analysis - Script di Setup e Verifica
# Master OSINT, AI & Security Studies - LUISS 2025/26
# =============================================================================
# 
# ISTRUZIONI:
# 1. Apri RStudio
# 2. Copia e incolla questo script nella Console
# 3. Premi Invio per eseguire
# 4. Segui i messaggi per verificare che tutto sia installato correttamente
#
# =============================================================================

cat("\n")
cat("=============================================================\n")
cat("   VERIFICA SETUP - Social Network Analysis\n")
cat("=============================================================\n\n")

# 1. Verifica versione R
cat("1. Versione R:\n")
cat("   ", R.version$version.string, "\n")
if (as.numeric(R.version$major) >= 4) {
  cat("   [OK] Versione R compatibile\n\n")
} else {
  cat("   [!] Aggiorna R alla versione 4.x o superiore\n\n")
}

# 2. Installa pacchetti se necessario
cat("2. Verifica pacchetti...\n")

pacchetti_necessari <- c("igraph", "ggraph", "tidyverse", "readr", "corrplot", "ggpubr")

pacchetti_mancanti <- pacchetti_necessari[!(pacchetti_necessari %in% installed.packages()[,"Package"])]

if (length(pacchetti_mancanti) > 0) {
  cat("   Installazione pacchetti mancanti:", paste(pacchetti_mancanti, collapse = ", "), "\n")
  install.packages(pacchetti_mancanti)
  cat("   [OK] Pacchetti installati\n\n")
} else {
  cat("   [OK] Tutti i pacchetti sono gia installati\n\n")
}

# 3. Carica i pacchetti
cat("3. Caricamento pacchetti...\n")
suppressPackageStartupMessages({
  library(igraph)
  library(ggraph)
  library(tidyverse)
  library(readr)
  library(corrplot)
  library(ggpubr)
})
cat("   [OK] Pacchetti caricati correttamente\n\n")

# 4. Test creazione grafo
cat("4. Test creazione grafo...\n")
g <- make_ring(5)
cat("   Grafo creato: ", vcount(g), " nodi, ", ecount(g), " archi\n", sep = "")
cat("   [OK] igraph funziona correttamente\n\n")

# 5. Test visualizzazione
cat("5. Test visualizzazione (aprira una finestra grafica)...\n")
p <- ggraph(g, layout = "circle") +
  geom_edge_link() +
  geom_node_point(size = 5, color = "#3182ce") +
  theme_graph() +
  labs(title = "Test: Grafo ad Anello")
print(p)
cat("   [OK] ggraph funziona correttamente\n\n")

# Riepilogo
cat("=============================================================\n")
cat("   SETUP COMPLETATO CON SUCCESSO!\n")
cat("=============================================================\n")
cat("\n")
cat("Sei pronto per il corso di Social Network Analysis.\n")
cat("\n")
cat("Prossimi passi:\n")
cat("- Installa Gephi da https://gephi.org\n")
cat("- Scarica il dataset stormofswords.csv\n")
cat("- Leggi Cap. 7 di networkatlas.eu (opzionale)\n")
cat("\n")
