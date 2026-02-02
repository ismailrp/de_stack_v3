# R Development Stack

This directory contains R scripts and configuration for developing with the Data Engineering Stack on your host machine using VS Code.

## Prerequisites

1. **Install R**: Download from [https://www.r-project.org/](https://www.r-project.org/)
2. **Install VS Code**: Download from [https://code.visualstudio.com/](https://code.visualstudio.com/)
3. **Install VS Code R Extension**: Install the "R Extension for Visual Studio Code" by REDCap

## Setup

### 1. Install R Packages

Run the installation script to install all required R packages:

```r
source("R/install_r_packages.R")
```

Or manually install required packages:

```r
install.packages(c(
  "DBI", "RPostgres", "elastic", "httr", "jsonlite",
  "dplyr", "tidyr", "readr", "data.table", "ggplot2", "plotly"
))
```

### 2. Configure Environment

The project includes a `.Renviron` file with connection details to all Docker services. These environment variables are automatically loaded when you start R in this directory.

### 3. VS Code Configuration

Install these VS Code extensions for R development:

- **R Extension for Visual Studio Code** (REDCap)
- **R Debugger** (Manuel Hentschel)
- **R LSP** (R Editor Support)

## Project Structure

```
R/
├── install_r_packages.R    # Install all required R packages
├── examples/
│   ├── postgres_connection.R      # PostgreSQL connection examples
│   ├── elasticsearch_connection.R # Elasticsearch examples
│   ├── airflow_api.R              # Airflow REST API examples
│   └── nifi_api.R                 # NiFi REST API examples
└── README.md                # This file
```

## Usage Examples

### PostgreSQL Connection

```r
# Run the PostgreSQL example
source("R/examples/postgres_connection.R")

# Or connect directly
library(DBI)
library(RPostgres)

con <- dbConnect(
  RPostgres::Postgres(),
  host = Sys.getenv("POSTGRES_HOST"),
  port = as.integer(Sys.getenv("POSTGRES_PORT")),
  user = Sys.getenv("POSTGRES_USER"),
  password = Sys.getenv("POSTGRES_PASSWORD"),
  dbname = Sys.getenv("POSTGRES_DB")
)

# Query data
result <- dbGetQuery(con, "SELECT * FROM dag_run LIMIT 10")
dbDisconnect(con)
```

### Elasticsearch Connection

```r
# Run the Elasticsearch example
source("R/examples/elasticsearch_connection.R")

# Or connect directly
library(elastic)

es <- elastic::connect("http://localhost:9200")
health <- elastic::cluster_health(es)
print(health)
```

### Airflow API

```r
# Run the Airflow API example
source("R/examples/airflow_api.R")

# Or use httr directly
library(httr)

response <- GET(
  "http://localhost:8080/api/v1/dags",
  authenticate("admin", "admin")
)

dags <- content(response)
print(dags)
```

### NiFi API

```r
# Run the NiFi API example
source("R/examples/nifi_api.R")

# Or use httr directly
library(httr)

response <- GET(
  "http://localhost:19000/nifi-api/flow/status",
  authenticate("admin", "AdminPass123!")
)

status <- content(response)
print(status)
```

## Available Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRES_HOST` | localhost | PostgreSQL host |
| `POSTGRES_PORT` | 5432 | PostgreSQL port |
| `POSTGRES_USER` | airflow | PostgreSQL user |
| `POSTGRES_PASSWORD` | airflow | PostgreSQL password |
| `POSTGRES_DB` | airflow | PostgreSQL database |
| `ES_HOST` | localhost | Elasticsearch host |
| `ES_PORT` | 9200 | Elasticsearch port |
| `ES_PROTO` | http | Elasticsearch protocol |
| `AIRFLOW_HOST` | localhost | Airflow host |
| `AIRFLOW_PORT` | 8080 | Airflow port |
| `AIRFLOW_USER` | admin | Airflow username |
| `AIRFLOW_PASSWORD` | admin | Airflow password |
| `NIFI_HOST` | localhost | NiFi host |
| `NIFI_PORT` | 19000 | NiFi port |
| `NIFI_USER` | admin | NiFi username |
| `NIFI_PASSWORD` | AdminPass123! | NiFi password |
| `KIBANA_HOST` | localhost | Kibana host |
| `KIBANA_PORT` | 5601 | Kibana port |

## Tips for VS Code

### Running R Code

1. **Send code to terminal**: Select code and press `Ctrl+Enter`
2. **Send file to terminal**: Press `Ctrl+Shift+S`
3. **View plots**: Use the R plot viewer panel

### Debugging

1. Set breakpoints by clicking the line number
2. Press `F5` to start debugging
3. Use the debug console to inspect variables

### Code Completion

The R extension provides:
- Auto-completion for R functions
- Snippet support
- IntelliSense for loaded packages

## Troubleshooting

### Connection Refused

Make sure Docker services are running:
```bash
docker compose ps
```

### Package Installation Issues

If packages fail to install, try:
```r
options(repos = c(CRAN = "https://cloud.r-project.org/"))
install.packages("package_name")
```

### VS Code R Extension Not Working

1. Reload VS Code
2. Check R is in your PATH: `which R`
3. Install the R LSP extension
