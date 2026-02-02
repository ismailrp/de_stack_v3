# Install Required R Packages for Data Engineering Stack
# Run this script to install all required packages: source("R/install_r_packages.R")

cat("Installing R packages for Data Engineering Stack...\n\n")

# List of required packages
packages <- list(
  # Database connections
  dbi = "DBI",
  rpostgres = "RPostgres",
  rsqlite = "RSQLite",

  # Elasticsearch
  elastic = "elastic",
  httr = "httr",

  # Airflow API
  airflow = "apache-airflow-R",  # or use httr for API calls

  # Data manipulation
  dplyr = "dplyr",
  tidyr = "tidyr",
  readr = "readr",
  data_table = "data.table",
  dbplyr = "dbplyr",

  # Data visualization
  ggplot2 = "ggplot2",
  plotly = "plotly",
  rmarkdown = "rmarkdown",

  # NiFi (via REST API)
  jsonlite = "jsonlite",

  # Utilities
  glue = "glue",
  lubridate = "lubridate",
  purrr = "purrr",
  stringr = "stringr"
)

# Function to install packages if not already installed
install_if_missing <- function(package_name, package_desc = package_name) {
  if (!require(package_name, character.only = TRUE, quietly = TRUE)) {
    cat(paste("Installing", package_desc, "...\n"))
    install.packages(package_name, dependencies = TRUE)

    if (require(package_name, character.only = TRUE, quietly = TRUE)) {
      cat(paste("  ✓", package_desc, "installed successfully\n"))
    } else {
      cat(paste("  ✗ Failed to install", package_desc, "\n"))
      return(FALSE)
    }
  } else {
    cat(paste("  ✓", package_desc, "already installed\n"))
  }
  return(TRUE)
}

# Install all packages
cat("\n=== Installing Required Packages ===\n\n")
results <- sapply(packages, install_if_missing)

# Summary
cat("\n=== Installation Summary ===\n")
total <- length(packages)
installed <- sum(results)
cat(paste("Installed:", installed, "/", total, "packages\n"))

if (installed == total) {
  cat("\n✓ All packages installed successfully!\n")
} else {
  cat("\n⚠ Some packages failed to install. Please check the errors above.\n")
}

# Load DBI and test connection
cat("\n=== Testing PostgreSQL Connection ===\n")
tryCatch({
  library(DBI)
  library(RPostgres)

  host <- Sys.getenv("POSTGRES_HOST", "localhost")
  port <- as.integer(Sys.getenv("POSTGRES_PORT", "5432"))
  user <- Sys.getenv("POSTGRES_USER", "airflow")
  password <- Sys.getenv("POSTGRES_PASSWORD", "airflow")
  dbname <- Sys.getenv("POSTGRES_DB", "airflow")

  con <- dbConnect(
    RPostgres::Postgres(),
    host = host,
    port = port,
    user = user,
    password = password,
    dbname = dbname
  )

  cat("✓ Successfully connected to PostgreSQL!\n")
  dbDisconnect(con)
}, error = function(e) {
  cat(paste("✗ Failed to connect to PostgreSQL:", e$message, "\n"))
  cat("  Make sure Docker services are running.\n")
})

cat("\n=== Installation Complete ===\n")
