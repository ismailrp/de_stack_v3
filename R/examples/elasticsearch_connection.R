# Elasticsearch Connection Example
# This script demonstrates how to connect to Elasticsearch using R

library(elastic)
library(httr)
library(jsonlite)

# Read connection details from .Renviron
host <- Sys.getenv("ES_HOST", "localhost")
port <- Sys.getenv("ES_PORT", "9200")
base_url <- paste0(Sys.getenv("ES_PROTO", "http"), "://", host, ":", port)

# Initialize elastic connection
es <- elastic::connect(base_url)

cat("✓ Connected to Elasticsearch\n")

# Check cluster health
cat("\n=== Cluster Health ===\n")
health <- elastic::cluster_health(es)
print(health)

# Get cluster info
cat("\n=== Cluster Info ===\n")
info <- elastic::cluster_info(es)
cat(paste("Cluster Name:", info$cluster_name, "\n"))
cat(paste("Number of Nodes:", info$number_of_nodes, "\n"))

# List all indices
cat("\n=== Existing Indices ===\n")
indices <- elastic::indices_get(es)
if (length(indices) > 0) {
  print(names(indices))
} else {
  cat("No indices found\n")
}

# Create a sample index
cat("\n=== Creating Sample Index ===\n")
index_name <- "sample_data"

# Define mapping
mapping <- list(
  properties = list(
    name = list(type = "text"),
    value = list(type = "double"),
    category = list(type = "keyword"),
    timestamp = list(type = "date")
  )
)

# Create index with mapping
elastic::index_create(es, index_name, mapping = mapping)
cat(paste("✓ Created index:", index_name, "\n"))

# Index sample documents
cat("\n=== Indexing Sample Documents ===\n")
docs <- list(
  list(name = "Document A", value = 100.5, category = "Type1", timestamp = Sys.time()),
  list(name = "Document B", value = 200.3, category = "Type2", timestamp = Sys.time()),
  list(name = "Document C", value = 150.7, category = "Type1", timestamp = Sys.time())
)

for (i in seq_along(docs)) {
  elastic::docs_create(es, index_name, doc_id = i, doc = docs[[i]])
}
cat(paste("✓ Indexed", length(docs), "documents\n"))

# Search documents
cat("\n=== Searching Documents ===\n")
search_result <- elastic::search(es, index_name, q = "*")
cat(paste("Found", search_result$hits$total$value, "documents\n"))

# Print documents
if (search_result$hits$total$value > 0) {
  for (hit in search_result$hits$hits) {
    doc <- hit$`_source`
    cat(paste("  -", doc$name, ": Value =", doc$value, ", Category =", doc$category, "\n"))
  }
}

# Aggregate query example
cat("\n=== Aggregation Query (by category) ===\n")
agg_query <- list(
  aggs = list(
    category_stats = list(
      terms = list(field = "category"),
      aggs = list(
        avg_value = list(avg = list(field = "value"))
      )
    )
  )
)

agg_result <- elastic::search(es, index_name, body = agg_query, size = 0)
if (!is.null(agg_result$aggregations)) {
  for (bucket in agg_result$aggregations$category_stats$buckets) {
    cat(paste("  Category:", bucket$key,
              "| Avg Value:", round(bucket$avg_value$value, 2), "\n"))
  }
}

# Update a document
cat("\n=== Updating Document ===\n")
elastic::docs_update(es, index_name, doc_id = 1,
                    doc = list(doc = list(value = 999.9)))
cat("✓ Updated document 1\n")

# Verify update
updated_doc <- elastic::docs_get(es, index_name, doc_id = 1)
cat(paste("New value:", updated_doc$`_source`$value, "\n"))

cat("\n✓ Elasticsearch examples completed\n")
