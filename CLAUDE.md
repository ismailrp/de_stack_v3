# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Docker Compose-based Data Engineering stack that orchestrates a complete data pipeline with Airflow, NiFi, Elasticsearch, Kibana, and PostgreSQL.

## Common Commands

```bash
# Start all services
docker compose up -d

# View logs for all services
docker compose logs -f

# View logs for specific service
docker compose logs -f airflow-webserver
docker compose logs -f nifi

# Stop all services
docker compose down

# Stop and remove volumes (reset data)
docker compose down -v

# Restart a specific service
docker compose restart airflow-scheduler
```

## Service Access

| Service | URL | Credentials |
|---------|-----|-------------|
| Airflow Web UI | http://localhost:8080 | admin/admin |
| NiFi Web UI | http://localhost:19000/nifi | admin/AdminPass123! |
| Elasticsearch | http://localhost:9200 | (none) |
| Kibana | http://localhost:5601 | (none) |
| PostgreSQL | localhost:5432 | airflow/airflow |

**Important:** Access all services from Windows browser (not WSL) when using Docker Desktop on WSL2.

## Architecture

**Startup Order & Dependencies:**
1. `postgres` must be healthy before `airflow-init` runs
2. `airflow-init` must complete (runs DB migrations, creates admin user) before `airflow-webserver` and `airflow-scheduler`
3. `elasticsearch` must be healthy before `kibana` starts
4. `nifi` starts independently

**Network:** All services communicate via `de_network` bridge network. Use service names as hostnames (e.g., `postgres:5432`, `elasticsearch:9200`).

**Key Volume Mounts for Development:**
- `./dags` → Airflow DAGs (auto-loaded)
- `./airflow-logs` → Airflow task logs
- `./airflow-plugins` → Custom Airflow plugins

## Airflow Configuration

- **Executor:** LocalExecutor (suitable for single-node development)
- **Examples:** Disabled (`LOAD_EXAMPLES=false`)
- **Python Version:** 3.11 (slim-based image)
- **Image:** apache/airflow:2.8.0-python3.11

When adding DAGs, place Python files in `./dags/`. They will be automatically picked up by the scheduler.

## NiFi Configuration

- **Version:** 1.24.0
- **HTTP Port:** 8080 (mapped to host port 9300)
- **HTTPS Port:** 8443
- **Auth:** Single-user mode (admin/admin123)

## Elasticsearch Configuration

- **Version:** 8.11.0
- **Mode:** Single-node (development)
- **Security:** Disabled (`xpack.security.enabled=false`)
- **Heap:** 512m min/max

## Development Notes

- The `airflow-init` service is a one-time job that exits after completion. It must be re-run if the database is reset.
- Airflow uses an empty `FERNET_KEY` for development. Change this for production.
- NiFi data persists across container restarts via named volumes.
- All containers have `restart: unless-stopped` except `airflow-init` which is a one-time job.

## R Development Stack

The project includes an R development environment for data analysis and API interaction with the Docker services.

### Setup

```bash
# Install R packages (run from R console in project directory)
Rscript -e "source('R/install_r_packages.R')"
```

### Project Structure

```
R/
├── install_r_packages.R       # Package installation script
├── examples/
│   ├── postgres_connection.R      # PostgreSQL connection examples
│   ├── elasticsearch_connection.R # Elasticsearch examples
│   ├── airflow_api.R              # Airflow REST API examples
│   └── nifi_api.R                 # NiFi REST API examples
└── README.md
```

### Environment Variables

Connection details are loaded from `.Renviron` in the project root:

```r
# Access connection details from R
host <- Sys.getenv("POSTGRES_HOST")  # "localhost"
port <- Sys.getenv("POSTGRES_PORT")  # "5432"
```

### Example: PostgreSQL Query from R

```r
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

result <- dbGetQuery(con, "SELECT * FROM dag_run LIMIT 10")
dbDisconnect(con)
```

### Example: Elasticsearch Query from R

```r
library(elastic)

es <- elastic::connect("http://localhost:9200")
health <- elastic::cluster_health(es)
```

### VS Code Setup

1. Install the **R Extension for Visual Studio Code** (REDCap)
2. Open `.R` files - the extension provides IntelliSense and debugging
3. Use `Ctrl+Enter` to send code to the R terminal
