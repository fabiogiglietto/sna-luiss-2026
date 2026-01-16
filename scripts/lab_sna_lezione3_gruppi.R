# =============================================================================
# Lab SNA Lezione 3 — Analisi di Reti Coordinate Italiane
# Master OSINT, AI & Security Studies — LUISS 2025/26
# =============================================================================
#
# Questo script guida l'analisi di due reti coordinate italiane:
# - TG24ore (Gruppo A)
# - Mag24 (Gruppo B)
#
# Le reti sono state rilevate per la prima volta durante lo studio sulle
# elezioni italiane 2018 e sono ancora attive oggi.
#
# ISTRUZIONI:
# 1. Seleziona il tuo dataset (commenta/decommenta la riga appropriata)
# 2. Esegui il codice sezione per sezione
# 3. Rispondi alle domande di interpretazione
# 4. Confronta i risultati con i report di investigazione
#
# =============================================================================

# -----------------------------------------------------------------------------
# 1. Setup e Librerie
# -----------------------------------------------------------------------------

library(data.table)
library(CooRTweet)
library(CooRTweetPost)
library(igraph)
library(ggraph)
library(tidyverse)

# Se non installati, esegui:
# install.packages(c("data.table", "igraph", "ggraph", "tidyverse"))
# devtools::install_github("nicolarighetti/CooRTweet")
# devtools::install_github("massimo-terenzi/CooRTweetPost")

# -----------------------------------------------------------------------------
# 2. Caricamento Dati
# -----------------------------------------------------------------------------
# IMPORTANTE: Seleziona il dataset assegnato al tuo gruppo!

# GRUPPO A: TG24ore
df <- fread("data/tg24ore_posts.csv")
dataset_name <- "TG24ore"

# GRUPPO B: Mag24 (decommenta le righe sotto e commenta quelle sopra)
# df <- fread("data/mag24_posts.csv")
# dataset_name <- "Mag24"

cat("=== Dataset:", dataset_name, "===\n")

# -----------------------------------------------------------------------------
# 3. Task 1: Esplorazione Dati
# -----------------------------------------------------------------------------

# Struttura del dataset
cat("\n--- Struttura Dataset ---\n")
print(dim(df))
print(names(df))

# Statistiche di base
cat("\n--- Statistiche di Base ---\n")
cat("Totale post:", nrow(df), "\n")
cat("Account unici:", uniqueN(df$surface.name), "\n")
cat("Testi unici:", uniqueN(df$text), "\n")

# Distribuzione temporale
df$date <- as.Date(df$creation_time)
date_range <- range(df$date, na.rm = TRUE)
cat("Periodo:", as.character(date_range[1]), "—", as.character(date_range[2]), "\n")

# Account più attivi
cat("\n--- Top 10 Account per Numero di Post ---\n")
posts_per_account <- df[, .N, by = surface.name][order(-N)]
print(head(posts_per_account, 10))

# TODO: Rispondi a queste domande
# Q1: Quanti account unici ci sono nel dataset?
# Q2: Qual è l'account più attivo? Quanti post ha pubblicato?
# Q3: Riconosci qualche nome dai report di investigazione?

# -----------------------------------------------------------------------------
# 4. Task 2: Preparazione Dati per CooRTweet
# -----------------------------------------------------------------------------

cat("\n--- Preparazione Dati ---\n")

# Prepara dati per CooRTweet
# Mappatura colonne:
#   object_id = ciò che viene condiviso (testo del post)
#   account_id = chi condivide (nome pagina)
#   content_id = ID unico del post
#   timestamp_share = quando viene condiviso

data_prepared <- prep_data(
  x = df,
  object_id       = "text",
  account_id      = "surface.name",
  content_id      = "mcl_url",
  timestamp_share = "creation_time"
)

# Pulizia: rimuovi testi vuoti
data_prepared <- data_prepared[trimws(object_id) != ""]

# Verifica
cat("Righe preparate:", nrow(data_prepared), "\n")
cat("Account:", uniqueN(data_prepared$account_id), "\n")
cat("Contenuti unici:", uniqueN(data_prepared$object_id), "\n")

# -----------------------------------------------------------------------------
# 5. Task 2: Detection Coordinamento
# -----------------------------------------------------------------------------

cat("\n--- Detection Coordinamento ---\n")

# Rileva gruppi coordinati
# min_participation = 2: almeno 2 contenuti condivisi in comune
# time_window = 60: entro 60 secondi

coordinated_groups <- detect_groups(
  x = data_prepared,
  min_participation = 2,
  time_window = 60
)

# Esplora risultati
print(coordinated_groups)

# TODO: Annota i risultati
# Numero di coppie coordinate rilevate: ___
# Numero totale di co-condivisioni: ___

# -----------------------------------------------------------------------------
# 6. Task 3: Generare Network di Coordinamento
# -----------------------------------------------------------------------------

cat("\n--- Generazione Network ---\n")

# Genera network
# edge_weight = 0.5: mantieni archi sopra la mediana
# subgraph = 1: solo account coordinati
# objects = FALSE: solo account, non contenuti

g <- generate_coordinated_network(
  coordinated_groups,
  edge_weight = 0.5,
  subgraph = 1,
  objects = FALSE
)

# Statistiche network
cat("Nodi (account coordinati):", vcount(g), "\n")
cat("Archi (relazioni):", ecount(g), "\n")
cat("Componenti connesse:", components(g)$no, "\n")
cat("Densità:", round(edge_density(g), 4), "\n")

# TODO: Annota le statistiche
# Account coordinati: ___
# Archi: ___
# Componenti: ___

# -----------------------------------------------------------------------------
# 7. Task 3: Community Detection
# -----------------------------------------------------------------------------

cat("\n--- Community Detection ---\n")

# Rileva comunità con Louvain
communities <- cluster_louvain(g)
V(g)$community <- membership(communities)

# Statistiche comunità
cat("Numero comunità:", max(V(g)$community), "\n")
cat("\nDimensioni comunità:\n")
print(sizes(communities))

# Modularità
mod <- modularity(communities)
cat("\nModularità:", round(mod, 3), "\n")
cat("(Q > 0.3 indica struttura comunitaria significativa)\n")

# TODO: Rispondi
# Q4: Quante comunità avete identificato?
# Q5: La modularità indica una struttura significativa?

# -----------------------------------------------------------------------------
# 8. Task 3: Top Account per Comunità
# -----------------------------------------------------------------------------

cat("\n--- Top Account per Comunità ---\n")

# Calcola centralità
V(g)$degree <- degree(g)
V(g)$strength <- strength(g)
V(g)$betweenness <- betweenness(g)

# Crea dataframe con metriche
account_metrics <- data.frame(
  account = V(g)$name,
  community = V(g)$community,
  degree = V(g)$degree,
  strength = V(g)$strength,
  betweenness = round(V(g)$betweenness, 1)
)

# Top 3 per ogni comunità
top_per_community <- account_metrics %>%
  group_by(community) %>%
  slice_max(degree, n = 3) %>%
  arrange(community, desc(degree))

print(top_per_community, n = 30)

# TODO: Rispondi
# Q6: Chi sono i top 3 account nella comunità più grande?
# Q7: Li riconoscete dai report di investigazione?

# -----------------------------------------------------------------------------
# 9. Task 4: Visualizzazione
# -----------------------------------------------------------------------------

cat("\n--- Visualizzazione Network ---\n")

# Crea visualizzazione
p <- ggraph(g, layout = "fr") +
  geom_edge_link(aes(alpha = weight), color = "gray50") +
  geom_node_point(aes(size = degree, color = as.factor(community))) +
  geom_node_text(
    aes(label = ifelse(degree > quantile(degree, 0.95), name, "")),
    size = 2.5, repel = TRUE
  ) +
  scale_color_brewer(palette = "Set2") +
  scale_size_continuous(range = c(2, 8)) +
  theme_graph() +
  labs(
    title = paste("Network di Coordinamento -", dataset_name),
    subtitle = paste("Nodi:", vcount(g), "| Archi:", ecount(g),
                     "| Comunità:", max(V(g)$community),
                     "| Modularità:", round(mod, 2)),
    color = "Comunità",
    size = "Degree"
  )

print(p)

# -----------------------------------------------------------------------------
# 10. Task 4: Export Risultati
# -----------------------------------------------------------------------------

cat("\n--- Export Risultati ---\n")

# Crea cartella output
output_dir <- paste0("output/", tolower(dataset_name))
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

# Salva visualizzazione
ggsave(paste0(output_dir, "/network.png"), p, width = 12, height = 10)
cat("Salvato:", paste0(output_dir, "/network.png"), "\n")

# Esporta per Gephi
write_graph(g, paste0(output_dir, "/network.graphml"), format = "graphml")
cat("Salvato:", paste0(output_dir, "/network.graphml"), "\n")

# Esporta metriche account
write_csv(account_metrics, paste0(output_dir, "/account_metrics.csv"))
cat("Salvato:", paste0(output_dir, "/account_metrics.csv"), "\n")

# Export completo con CooRTweetPost
export_all_results(
  coordinated_groups = coordinated_groups,
  network_graph = g,
  output_dir = paste0(output_dir, "/coortweet_results")
)
cat("Salvato:", paste0(output_dir, "/coortweet_results/"), "\n")

# -----------------------------------------------------------------------------
# 11. Task 5: Interpretazione
# -----------------------------------------------------------------------------

cat("\n")
cat("=============================================================================\n")
cat("                    TASK 5: INTERPRETAZIONE\n")
cat("=============================================================================\n")
cat("\n")
cat("Confrontate i vostri risultati con i report di investigazione.\n")
cat("Rispondete alle seguenti domande:\n")
cat("\n")
cat("1. Quante comunità avete identificato? Corrispondono ai gruppi nel report?\n")
cat("\n")
cat("2. Chi sono gli account più centrali? Li riconoscete dal report?\n")
cat("\n")
cat("3. La modularità (Q =", round(mod, 3), ") indica struttura significativa?\n")
cat("\n")
cat("4. Che tipo di contenuti vengono condivisi? (controllate df$text)\n")
cat("\n")
cat("5. I vostri risultati confermano le conclusioni dell'investigazione?\n")
cat("\n")
cat("=============================================================================\n")

# -----------------------------------------------------------------------------
# 12. Riepilogo Risultati
# -----------------------------------------------------------------------------

cat("\n=== RIEPILOGO", dataset_name, "===\n")
cat("Account totali nel dataset:", uniqueN(df$surface.name), "\n")
cat("Account coordinati rilevati:", vcount(g), "\n")
cat("Percentuale coordinati:", round(vcount(g) / uniqueN(df$surface.name) * 100, 1), "%\n")
cat("Comunità identificate:", max(V(g)$community), "\n")
cat("Modularità:", round(mod, 3), "\n")
cat("Output salvati in:", output_dir, "\n")

# -----------------------------------------------------------------------------
# 13. BONUS: Esplora Parametri Diversi
# -----------------------------------------------------------------------------

# Prova con time_window diversi e confronta i risultati
#
# coord_120 <- detect_groups(data_prepared, min_participation = 2, time_window = 120)
# coord_300 <- detect_groups(data_prepared, min_participation = 2, time_window = 300)
#
# g_120 <- generate_coordinated_network(coord_120, edge_weight = 0.5, subgraph = 1)
# g_300 <- generate_coordinated_network(coord_300, edge_weight = 0.5, subgraph = 1)
#
# cat("time_window = 60:", vcount(g), "account\n")
# cat("time_window = 120:", vcount(g_120), "account\n")
# cat("time_window = 300:", vcount(g_300), "account\n")
#
# DOMANDA BONUS: Come cambia il numero di account coordinati?
# Quale time_window è più realistico per distinguere bot da umani?

# =============================================================================
# Fine Lab
# =============================================================================
