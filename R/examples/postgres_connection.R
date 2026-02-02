# PostgreSQL Connection Example
# This script demonstrates how to connect to PostgreSQL using R

library(DBI)
library(RPostgres)
library(dplyr)

# Read connection details from .Renviron
host <- Sys.getenv("POSTGRES_HOST", "localhost")
port <- as.integer(Sys.getenv("POSTGRES_PORT", "5432"))
user <- Sys.getenv("POSTGRES_USER", "airflow")
password <- Sys.getenv("POSTGRES_PASSWORD", "airflow")
dbname <- Sys.getenv("POSTGRES_DB", "airflow")

# Connect to PostgreSQL
con <- dbConnect(
  RPostgres::Postgres(),
  host = host,
  port = port,
  user = user,
  password = password,
  dbname = dbname
)

cat("✓ Connected to PostgreSQL\n")

# List all tables
tables <- dbListTables(con)
cat("Available tables:\n")
print(tables)

# Query example: Get Airflow DAG runs
if ("dag_run" %in% tables) {
  cat("\n=== Recent DAG Runs ===\n")
  dag_runs <- dbGetQuery(con, "
    SELECT
      dag_id,
      state,
      execution_date,
      start_date,
      end_date
    FROM dag_run
    ORDER BY execution_date DESC
    LIMIT 10
  ")
  print(dag_runs)
}

# Create a custom table (example)
cat("\n=== Creating Sample Table ===\n")
dbExecute(con, "
  CREATE TABLE IF NOT EXISTS sample_data (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    value NUMERIC,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )
")

# Insert sample data
dbExecute(con, "
  INSERT INTO sample_data (name, value)
  VALUES
    ('Record A', 100.5),
    ('Record B', 200.3),
    ('Record C', 150.7)
  ON CONFLICT DO NOTHING
")

# Query using dplyr
cat("\n=== Query with dplyr ===\n")
sample_data <- tbl(con, "sample_data")
result <- sample_data %>%
  filter(value > 100) %>%
  arrange(desc(value)) %>%
  collect()

print(result)

# Always close the connection when done
dbDisconnect(con)
cat("\n✓ Connection closed\n")
