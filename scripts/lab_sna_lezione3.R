# =============================================================================
# Lab SNA Lezione 3 — Coordinated Sharing Detection
# Master OSINT, AI & Security Studies — LUISS 2025/26
# =============================================================================
#
# Questo script accompagna le slide "Coordinated Sharing Detection"
# e dimostra come i concetti di reti bipartite, proiezioni e community
# detection vengono applicati nel rilevamento di comportamenti coordinati.
#
# Basato su: rawmat/CooRTweet_walkthrough.R
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

# Se non installati:
# install.packages("data.table")
# devtools::install_github("nicolarighetti/CooRTweet")
# devtools::install_github("massimo-terenzi/CooRTweetPost")

# -----------------------------------------------------------------------------
# 2. Il Concetto di Coordinated Sharing
# -----------------------------------------------------------------------------
#
# DEFINIZIONE:
# Due o più account sono "coordinati" quando eseguono la STESSA AZIONE
# ripetutamente entro una finestra temporale ristretta.
#
# Una sharing action può essere formalizzata come:
#   a = (p, t)  dove account 'a' posta contenuto 'p' al tempo 't'
#
# PARAMETRI CHIAVE:
#   - min_participation: quante volte devono co-condividere (default: 2)
#   - time_window: entro quanti secondi (default: 60)
#
# IMPORTANTE: Coordinamento ≠ Inauthenticità
# L'autenticità va sempre verificata con investigazione OSINT manuale!

# -----------------------------------------------------------------------------
# 3. Caricare i Dati
# -----------------------------------------------------------------------------

# Impostiamo la working directory (modifica secondo il tuo setup)
# setwd("~/path/to/project")

# I dati provengono dalla Meta Content Library
# Colonne chiave:
#   - text: contenuto testuale del post
#   - surface.name: nome della pagina/gruppo Facebook
#   - mcl_url: URL del post nella Content Library
#   - creation_time: timestamp di creazione

# Carica i dati (esempio con due file CSV)
df1 <- fread("data/tg24ore_posts.csv")
# df2 <- fread("data/mag24_posts.csv")

# Se hai più file, uniscili
# df <- rbind(df1, df2, fill = TRUE)
df <- df1

# Esplora la struttura
head(df)
names(df)
print(paste("Totale post:", nrow(df)))

# -----------------------------------------------------------------------------
# 4. Preparare i Dati con prep_data()
# -----------------------------------------------------------------------------
#
# CooRTweet richiede 4 colonne standardizzate:
#
# | Colonna         | Significato                          | Esempio MCL        |
# |-----------------|--------------------------------------|-------------------|
# | object_id       | Cosa viene condiviso                 | text              |
# | account_id      | Chi condivide                        | surface.name      |
# | content_id      | ID unico del post                    | mcl_url           |
# | timestamp_share | Quando viene condiviso               | creation_time     |
#
# NOTA: object_id definisce cosa consideriamo "stessa azione":
#   - "text" → stesso testo = coordinati
#   - potrebbe essere URL, hashtag, etc.

data_prepared <- prep_data(
  x = df,
  object_id       = "text",
  account_id      = "surface.name",
  content_id      = "mcl_url",
  timestamp_share = "creation_time"
)

# Pulizia: rimuovi testi vuoti o solo spazi
data_prepared <- data_prepared[trimws(object_id) != ""]

# Verifica
print(paste("Righe preparate:", nrow(data_prepared)))
print(paste("Account unici:", uniqueN(data_prepared$account_id)))
print(paste("Contenuti unici:", uniqueN(data_prepared$object_id)))

# -----------------------------------------------------------------------------
# 5. Rilevare Gruppi Coordinati
# -----------------------------------------------------------------------------
#
# detect_groups() identifica coppie di account che hanno condiviso
# lo stesso contenuto entro la time_window, almeno min_participation volte.
#
# INTERNAMENTE:
# 1. Per ogni object_id, trova tutti gli account che l'hanno condiviso
# 2. Per ogni coppia di account, verifica se i timestamp sono entro time_window
# 3. Conta quante volte questa co-condivisione avviene
# 4. Filtra coppie con count >= min_participation

coordinated_groups <- detect_groups(
  x = data_prepared,
  min_participation = 2,    # Almeno 2 contenuti co-condivisi

time_window = 60          # Entro 60 secondi l'uno dall'altro
)

# Esplora i risultati
print(coordinated_groups)

# -----------------------------------------------------------------------------
# 6. Generare il Network Coordinato
# -----------------------------------------------------------------------------
#
# generate_coordinated_network() crea un grafo igraph dove:
#   - NODI = account
#   - ARCHI = relazioni di co-sharing (pesati per frequenza)
#
# COLLEGAMENTO CON LE SLIDE:
# Internamente, CooRTweet costruisce una RETE BIPARTITA account-contenuti
# e poi calcola la PROIEZIONE sugli account (come visto nelle slide!)
#
# Il peso dell'arco = numero di contenuti co-condivisi
#
# PARAMETRI:
#   - edge_weight: quantile per filtrare archi deboli (0.5 = mediana, 0.7 = 70°)
#   - subgraph: 1 = solo account coordinati, 0 = tutti
#   - objects: TRUE = includi anche contenuti (rete bipartita)

# Network solo account (proiezione)
g <- generate_coordinated_network(
  coordinated_groups,
  edge_weight = 0.5,   # Mantieni archi sopra la mediana
  subgraph = 1,        # Solo account coordinati
  objects = FALSE      # Solo la proiezione sugli account
)

# Network con oggetti (rete bipartita originale)
g_bipartite <- generate_coordinated_network(
  coordinated_groups,
  edge_weight = 0.5,
  subgraph = 1,
  objects = TRUE       # Mantieni la struttura bipartita
)

# Statistiche di base
print(paste("Nodi:", vcount(g)))
print(paste("Archi:", ecount(g)))
print(paste("Componenti connesse:", components(g)$no))

# -----------------------------------------------------------------------------
# 7. Community Detection sui Gruppi Coordinati
# -----------------------------------------------------------------------------
#
# COLLEGAMENTO CON LE SLIDE:
# Applichiamo Louvain per identificare CLUSTER di account coordinati.
# Ogni cluster rappresenta un potenziale gruppo che opera insieme.

# Calcola comunità con Louvain
communities <- cluster_louvain(g)

# Aggiungi come attributo dei nodi
V(g)$community <- membership(communities)

# Statistiche
print(paste("Comunità rilevate:", max(V(g)$community)))
print("Dimensioni comunità:")
print(sizes(communities))

# Modularità (qualità della partizione)
mod <- modularity(communities)
print(paste("Modularità:", round(mod, 3)))
# Q > 0.3 indica struttura comunitaria significativa

# -----------------------------------------------------------------------------
# 8. Analisi delle Centralità
# -----------------------------------------------------------------------------

# Calcola metriche di centralità
V(g)$degree <- degree(g)
V(g)$strength <- strength(g)  # Degree pesato
V(g)$betweenness <- betweenness(g)

# Top account per degree (più connessioni di coordinamento)
top_accounts <- data.frame(
  account = V(g)$name,
  degree = V(g)$degree,
  strength = V(g)$strength,
  community = V(g)$community
) %>%
  arrange(desc(degree))

print("Top 10 account più coordinati:")
print(head(top_accounts, 10))

# Top account per comunità
top_per_community <- top_accounts %>%
  group_by(community) %>%
  slice_max(degree, n = 3) %>%
  ungroup()

print("Top 3 account per comunità:")
print(top_per_community)

# -----------------------------------------------------------------------------
# 9. Visualizzazione
# -----------------------------------------------------------------------------

# Visualizzazione base con ggraph
p <- ggraph(g, layout = "fr") +
  geom_edge_link(aes(alpha = weight), color = "gray50") +
  geom_node_point(aes(size = degree, color = as.factor(community))) +
  geom_node_text(
    aes(label = ifelse(degree > quantile(degree, 0.9), name, "")),
    size = 2.5, repel = TRUE
  ) +
  scale_color_brewer(palette = "Set2") +
  scale_size_continuous(range = c(2, 8)) +
  theme_graph() +
  labs(
    title = "Network di Coordinamento",
    subtitle = paste("Nodi:", vcount(g), "| Archi:", ecount(g),
                     "| Comunità:", max(V(g)$community)),
    color = "Comunità",
    size = "Degree"
  )

print(p)

# Salva
ggsave("output/coordinated_network.png", p, width = 12, height = 10)

# -----------------------------------------------------------------------------
# 10. Post-processing con CooRTweetPost
# -----------------------------------------------------------------------------
#
# CooRTweetPost estende l'analisi con funzionalità avanzate:
#   - Analisi temporale
#   - Estrazione contenuti condivisi per cluster
#   - Report automatici

# Esporta tutti i risultati in una cartella
dir.create("output/lezione3_results", recursive = TRUE, showWarnings = FALSE)

export_all_results(
  coordinated_groups = coordinated_groups,
  network_graph = g,
  output_dir = "output/lezione3_results"
)

# Esporta anche per Gephi
write_graph(g, "output/lezione3_results/network.graphml", format = "graphml")

# -----------------------------------------------------------------------------
# 11. Interpretazione dei Risultati
# -----------------------------------------------------------------------------
#
# DOMANDE DA PORSI:
#
# 1. Chi sono gli account nel cluster?
#    - Pagine ufficiali? Fan page? Account anonimi?
#
# 2. Quali contenuti hanno condiviso?
#    - Notizie vere? Disinformazione? Propaganda?
#
# 3. C'è un pattern temporale?
#    - Condivisioni sempre alla stessa ora?
#    - Burst improvvisi?
#
# 4. Il coordinamento ha senso?
#    - Media outlet che ripubblicano la stessa notizia = normale
#    - Account diversi che postano lo stesso testo identico in 10 sec = sospetto
#
# RICORDA: CooRTweet rileva PATTERN, l'interpretazione è umana!

# -----------------------------------------------------------------------------
# 12. Esercizio
# -----------------------------------------------------------------------------
#
# TASK:
# 1. Carica il dataset mag24_posts.csv
# 2. Esegui la detection con time_window = 120 secondi
# 3. Confronta il numero di comunità con time_window = 60 vs 120
# 4. Identifica il cluster più grande e ispeziona i primi 5 account
# 5. Esporta il network per visualizzarlo in Gephi
#
# BONUS:
# - Prova a cambiare object_id (es. usa URL invece di text)
# - Cosa cambia nei risultati?

# =============================================================================
# Fine Lab Lezione 3
# =============================================================================
