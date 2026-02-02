# R Profile for Data Engineering Stack
# This file runs automatically when R starts

# Set default repos
options(repos = c(CRAN = "https://cloud.r-project.org/"))

# Load .Renviron if it exists
if (file.exists(".Renviron")) {
  readRenviron(".Renviron")
}

# Commonly used packages
.required_packages <- c(
  "DBI",
  "RPostgres",
  "elastic",
  "httr",
  "jsonlite",
  "dplyr",
  "tidyr",
  "readr",
  "data.table",
  "ggplot2",
  "plotly"
)

# Function to install missing packages
install_if_missing <- function(packages) {
  for (pkg in packages) {
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      message(paste("Installing package:", pkg))
      install.packages(pkg, dependencies = TRUE)
    }
  }
}

# Auto-install missing packages on startup (comment out if not desired)
# install_if_missing(.required_packages)

# Custom prompt
options(prompt = "R> ", continue = "+ ")

# Set options
options(
  digits = 4,
  scipen = 10,
  stringsAsFactors = FALSE,
  width = 100
)

# Welcome message
cat("\n")
cat("==============================================\n")
cat("  Data Engineering Stack - R Environment\n")
cat("==============================================\n")
cat(paste("  PostgreSQL:", Sys.getenv("POSTGRES_HOST"), ":", Sys.getenv("POSTGRES_PORT"), "\n"))
cat(paste("  Elasticsearch:", Sys.getenv("ES_HOST"), ":", Sys.getenv("ES_PORT"), "\n"))
cat(paste("  Airflow:", Sys.getenv("AIRFLOW_HOST"), ":", Sys.getenv("AIRFLOW_PORT"), "\n"))
cat("==============================================\n\n")
