# =============================================================================
# Social Network Analysis - Laboratorio
# Master OSINT, AI & Security Studies - LUISS 2025/26
# Prof. Fabio Giglietto
# =============================================================================

# 1. SETUP --------------------------------------------------------------------
library(igraph)
library(readr)
library(ggraph)
library(ggpubr)
library(corrplot)

# 2. IMPORT DEI DATI ----------------------------------------------------------
# Importa il file CSV
edges <- read_csv("stormofswords.csv")

# Visualizza i dati
edges

# Crea il grafo igraph (non diretto perché le interazioni sono simmetriche)
g <- graph.data.frame(d = edges, directed = FALSE)

# 3. STATISTICHE DI BASE ------------------------------------------------------
# Numero di nodi (personaggi)
vcount(g)  # 107

# Numero di archi (interazioni)
ecount(g)  # 352

# Densità della rete
graph.density(g)  # 0.062

# Componenti connesse
components(g)$no  # 1 (rete connessa)

# 4. PRIMA VISUALIZZAZIONE ----------------------------------------------------
# Visualizzazione base
ggraph(g) +
  geom_edge_link() +
  geom_node_point(size = 5)

# Con layout specifico
ggraph(g, layout = "nicely") +
  geom_edge_link(color = "gray", alpha = 0.5) +
  geom_node_point(size = 3) +
  theme_graph()

# 5. ACCESSO A NODI E ARCHI ---------------------------------------------------
# Seleziona un nodo per nome
V(g)[V(g)$name == "Bran"]

# Archi con peso > 20
E(g)[Weight > 20]

# Arco con peso massimo
E(g)[Weight == max(E(g)$Weight)]  # Jaime -- Brienne (88)

# 6. CENTRALITÀ: DEGREE -------------------------------------------------------
# Calcola degree per tutti i nodi
degree(g)

# Degree per un personaggio specifico
degree(g, v = "Arya")

# Salva come attributo dei nodi
V(g)$deg <- degree(g)

# Chi ha più di 10 connessioni?
V(g)[V(g)$deg > 10]

# 7. ALTRE MISURE DI CENTRALITÀ -----------------------------------------------
# Betweenness
V(g)$bet <- betweenness(g)
V(g)[which.max(V(g)$bet)]  # Jon

# Closeness
V(g)$clos <- closeness(g)
V(g)[which.max(V(g)$clos)]  # Tyrion

# Eigenvector centrality
V(g)$eigen <- eigen_centrality(g)$vector
V(g)[which.max(V(g)$eigen)]  # Tyrion

# 8. DATAFRAME DI CENTRALITÀ --------------------------------------------------
centrality_df <- data.frame(
  actor = V(g)$name,
  degree = V(g)$deg,
  betweenness = V(g)$bet,
  closeness = V(g)$clos,
  eigenvector = V(g)$eigen
)

# Ordina per degree
centrality_df[order(-centrality_df$degree), ][1:10, ]

# Ordina per betweenness
centrality_df[order(-centrality_df$betweenness), ][1:10, ]

# 9. CORRELAZIONE TRA METRICHE ------------------------------------------------
cor_matrix <- cor(centrality_df[, -1])
corrplot(cor_matrix, method = "number")

# 10. VISUALIZZAZIONE CON CENTRALITÀ ------------------------------------------
# Size = degree, color = betweenness
ggraph(g, layout = "nicely") +
  geom_edge_link(color = "gray", alpha = 0.3) +
  geom_node_point(aes(size = deg, color = bet)) +
  scale_color_viridis_c() +
  theme_graph() +
  labs(title = "Storm of Swords Network",
       subtitle = "Size = Degree, Color = Betweenness")

# Con etichette per i nodi principali
ggraph(g, layout = "nicely") +
  geom_edge_link(color = "gray", alpha = 0.3) +
  geom_node_point(aes(size = deg, color = bet)) +
  geom_node_text(
    aes(label = ifelse(deg > 15, name, "")),
    repel = TRUE, size = 3
  ) +
  scale_color_viridis_c() +
  theme_graph()

# 11. EXPORT PER GEPHI --------------------------------------------------------
write.graph(g, "stormofswords_analyzed.graphml", format = "graphml")

# =============================================================================
# ESERCIZIO
# =============================================================================
# 1. Qual è il personaggio con betweenness massima? Perché?
# 2. Trova l'arco con peso massimo. Cosa significa per la storia?
# 3. Crea una visualizzazione con size = degree e color = community
#    (suggerimento: usa cluster_louvain per le community nella Lezione 2)
# =============================================================================
