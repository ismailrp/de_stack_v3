# Airflow API Connection Example
# This script demonstrates how to interact with Airflow REST API using R

library(httr)
library(jsonlite)

# Read connection details from .Renviron
host <- Sys.getenv("AIRFLOW_HOST", "localhost")
port <- Sys.getenv("AIRFLOW_PORT", "8080")
user <- Sys.getenv("AIRFLOW_USER", "admin")
password <- Sys.getenv("AIRFLOW_PASSWORD", "admin")

base_url <- paste0("http://", host, ":", port, "/api/v1")

# Create authenticated session
session <- httr::authenticate(user, password, type = "basic")

cat("✓ Connected to Airflow API\n")
cat(paste("Base URL:", base_url, "\n\n"))

# Function to make API requests
airflow_get <- function(endpoint, parse = TRUE) {
  url <- paste0(base_url, endpoint)
  response <- httr::GET(url, session)

  if (httr::http_error(response)) {
    warning(paste("API Error:", httr::status_code(response), httr::http_status(response)$reason))
    return(NULL)
  }

  if (parse) {
    return(httr::content(response, "text", encoding = "UTF-8") %>%
             jsonlite::fromJSON(flatten = FALSE))
  }
  return(response)
}

# Get DAGs list
cat("=== Listing All DAGs ===\n")
dags <- airflow_get("/dags")
if (!is.null(dags) && "dags" %in% names(dags)) {
  for (dag in dags$dags) {
    cat(paste("  -", dag$dag_id,
              "| State:", dag$is_active,
              "| Last parsed:", dag$last_parsed_time, "\n"))
  }
}

# Get DAG runs for a specific DAG (example_dag if exists)
cat("\n=== DAG Runs ===\n")
dag_runs <- airflow_get("/dags/example_bash_operator/dagRuns")
if (!is.null(dag_runs) && "dag_runs" %in% names(dag_runs)) {
  if (length(dag_runs$dag_runs) > 0) {
    cat("Recent DAG runs for 'example_bash_operator':\n")
    for (run in dag_runs$dag_runs[1:min(5, length(dag_runs$dag_runs))]) {
      cat(paste("  - Run ID:", run$dag_run_id,
                "| State:", run$state,
                "| Execution Date:", run$execution_date, "\n"))
    }
  } else {
    cat("No DAG runs found\n")
  }
}

# Get task instances for a DAG run
cat("\n=== Task Instances ===\n")
tasks <- airflow_get("/dags/example_bash_operator/dagRuns/%%7Bnow()%%7D/taskInstances")
if (!is.null(tasks) && "task_instances" %in% names(tasks)) {
  if (length(tasks$task_instances) > 0) {
    cat("Task instances:\n")
    for (task in tasks$task_instances[1:min(5, length(tasks$task_instances))]) {
      cat(paste("  -", task$task_id,
                "| State:", task$state,
                "| Try:", task$try_number, "\n"))
    }
  }
}

# Trigger a DAG run
cat("\n=== Triggering DAG Run ===\n")
# Uncomment to actually trigger a DAG
# trigger_response <- httr::POST(
#   paste0(base_url, "/dags/example_bash_operator/dagRuns"),
#   session,
#   body = toJSON(list(dag_run_id = paste0("manual_run_", format(Sys.time(), "%Y%m%d_%H%M%S")))),
#   content_type_json()
# )
# if (httr::http_error(trigger_response)) {
#   cat("Failed to trigger DAG\n")
# } else {
#   cat("✓ DAG triggered successfully\n")
# }

# Get connection list (useful for data sources)
cat("\n=== Airflow Connections ===\n")
connections <- airflow_get("/connections")
if (!is.null(connections) && "connections" %in% names(connections)) {
  cat("Available connections:\n")
  for (conn in connections$connections) {
    cat(paste("  -", conn$conn_id,
              "| Type:", conn$conn_type, "\n"))
  }
}

# Get variables
cat("\n=== Airflow Variables ===\n")
variables <- airflow_get("/variables")
if (!is.null(variables) && "variables" %in% names(variables)) {
  if (length(variables$variables) > 0) {
    cat("Airflow variables:\n")
    for (var in variables$variables) {
      cat(paste("  -", var$key, "=", var$value, "\n"))
    }
  } else {
    cat("No variables defined\n")
  }
}

# Get pool information
cat("\n=== Airflow Pools ===\n")
pools <- airflow_get("/pools")
if (!is.null(pools) && "pools" %in% names(pools)) {
  cat("Available pools:\n")
  for (pool in pools$pools) {
    cat(paste("  -", pool$name,
              "| Slots:", pool$slots,
              "| Used:", pool$open_slots, "\n"))
  }
}

cat("\n✓ Airflow API examples completed\n")
