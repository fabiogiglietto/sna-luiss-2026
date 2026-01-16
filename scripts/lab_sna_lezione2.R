# =============================================================================
# Social Network Analysis - Lezione 2
# Master OSINT, AI & Security Studies - LUISS 2025/26
# Prof. Fabio Giglietto
# =============================================================================

# 1. SETUP --------------------------------------------------------------------
library(igraph)
library(ggraph)
library(patchwork)
library(tidyverse)

# Carica i dati
load("data/lezione2.RData")

# 2. ESPLORAZIONE DEI DATI ----------------------------------------------------
# Visualizza le prime righe
head(tweets)

# Nomi delle colonne disponibili
names(tweets)

# 3. COSTRUZIONE RETE RETWEET -------------------------------------------------
# Filtra i retweet e crea la rete delle menzioni
filter(tweets, retweet_count > 0) %>%
  select(screen_name, mentions_screen_name) %>%
  unnest(mentions_screen_name) %>%
  filter(!is.na(mentions_screen_name)) %>%
  graph_from_data_frame(directed = TRUE) -> rt_g

# 4. COSTRUZIONE RETE HASHTAG -------------------------------------------------
# Crea rete utente-hashtag (bipartita)
tweets %>%
  select(screen_name, hashtags) %>%
  unnest(hashtags) %>%
  filter(str_to_lower(hashtags) != "twittamibeautiful") %>%
  graph_from_data_frame(directed = TRUE) -> h_g

# 5. STATISTICHE DI BASE ------------------------------------------------------
# Calcola degree per entrambe le reti
V(h_g)$degree <- degree(h_g)
V(rt_g)$degree <- degree(rt_g)

# Densità delle reti
graph.density(h_g)
graph.density(rt_g)

# 6. DISTRIBUZIONE DEL GRADO --------------------------------------------------
deg_t <- data.frame(degree = degree(rt_g))

ggplot(deg_t) +
  geom_histogram(aes(x = degree), binwidth = 1) +
  scale_y_continuous(trans = 'log10') +
  labs(title = "Distribuzione del grado (rete retweet)",
       x = "Degree", y = "Frequenza (log10)") +
  theme_minimal()

# 7. COMMUNITY DETECTION ------------------------------------------------------
# Algoritmo Edge Betweenness
com_eb <- cluster_edge_betweenness(as.undirected(rt_g))

# Algoritmo Louvain (più veloce)
com_lou <- cluster_louvain(as.undirected(rt_g))

# Confronto tra le partizioni (Normalized Mutual Information)
compare(com_eb, com_lou, method = "nmi")

# Salva le community come attributo dei nodi
V(rt_g)$com_eb <- com_eb$membership
V(rt_g)$com_lou <- com_lou$membership

# 8. VISUALIZZAZIONE COMMUNITY ------------------------------------------------
# Plot Edge Betweenness
plot_eb <- ggraph(rt_g, layout = "fr") +
  geom_edge_link(color = "gray", alpha = 0.3) +
  geom_node_point(aes(color = as.factor(com_eb))) +
  theme_graph() +
  labs(color = "Community")

# Plot Louvain
plot_lou <- ggraph(rt_g, layout = "fr") +
  geom_edge_link(color = "gray", alpha = 0.3) +
  geom_node_point(aes(color = as.factor(com_lou))) +
  theme_graph() +
  labs(color = "Community")

# Confronto side by side
plot_eb + plot_lou +
  plot_annotation(tag_levels = list(c("Edge Betweenness", "Louvain")))

# 9. RETI BIPARTITE -----------------------------------------------------------
# Verifica se la rete è bipartita
is.bipartite(h_g)

# Calcola in-degree per identificare il tipo di nodo
# Utenti hanno in-degree = 0 (solo archi uscenti verso hashtag)
V(h_g)$indegree <- degree(h_g, mode = "in")

# Assegna il tipo: TRUE = utenti, FALSE = hashtag
V(h_g)[indegree == 0]$type <- TRUE
V(h_g)[indegree > 0]$type <- FALSE

# Verifica che ora sia bipartita
is.bipartite(h_g)

# Visualizza la rete bipartita
ggraph(h_g, layout = "fr") +
  geom_edge_link(color = "gray", alpha = 0.3) +
  geom_node_point(aes(color = type)) +
  scale_color_manual(values = c("TRUE" = "#0072B2", "FALSE" = "#E69F00"),
                     labels = c("TRUE" = "Utenti", "FALSE" = "Hashtag")) +
  theme_graph() +
  labs(color = "Tipo nodo")

# 10. PROIEZIONI BIPARTITE ----------------------------------------------------
# Calcola le due proiezioni
proj <- bipartite.projection(h_g)

# Rete hashtag-hashtag (hashtag connessi se usati dallo stesso utente)
HH_g <- proj$proj1

# Rete utente-utente (utenti connessi se usano stessi hashtag)
UU_g <- proj$proj2

# Visualizza la proiezione hashtag
ggraph(HH_g, layout = "nicely") +
  geom_edge_link(color = "gray", alpha = 0.5) +
  geom_node_label(aes(label = name), repel = FALSE, size = 2) +
  theme_graph() +
  labs(title = "Proiezione Hashtag-Hashtag")

# Visualizza la proiezione utenti
ggraph(UU_g, layout = "fr") +
  geom_edge_link(color = "gray", alpha = 0.3) +
  geom_node_point(size = 2) +
  theme_graph() +
  labs(title = "Proiezione Utente-Utente")

# 11. EXPORT PER GEPHI --------------------------------------------------------
write.graph(rt_g, "rt_g.graphml", format = "graphml")
write.graph(h_g, "h_g.graphml", format = "graphml")

# =============================================================================
# ESERCIZI
# =============================================================================
# 1. Calcola le metriche di centralità sulla rete retweet. Chi sono i nodi
#    più importanti secondo degree, betweenness e eigenvector?
#
# 2. Confronta le community trovate con Edge Betweenness e Louvain.
#    Quali differenze noti? Quale algoritmo preferisci e perché?
#
# 3. Sulla proiezione utente-utente, calcola il degree. Chi sono gli utenti
#    che condividono più hashtag con altri? Cosa potrebbe indicare?
#
# 4. Esporta la rete in Gephi e crea una visualizzazione che evidenzi
#    le community e i nodi più centrali.
# =============================================================================
