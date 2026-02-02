# NiFi API Connection Example
# This script demonstrates how to interact with NiFi REST API using R
14/6
library(httr)
library(jsonlite)

# Read connection details from .Renviron
host <- Sys.getenv("NIFI_HOST", "localhost")
port <- Sys.getenv("NIFI_PORT", "19000")
user <- Sys.getenv("NIFI_USER", "admin")
password <- Sys.getenv("NIFI_PASSWORD", "AdminPass123!")

base_url <- paste0("http://", host, ":", port, "/nifi-api")

# Note: NiFi may require authentication token flow
# For single-user mode (as configured), basic auth should work

cat("✓ Connecting to NiFi API\n")
cat(paste("Base URL:", base_url, "\n\n"))

# Function to make API requests
nifi_get <- function(endpoint, parse = TRUE) {
  url <- paste0(base_url, endpoint)
  response <- httr::GET(url, httr::authenticate(user, password))

  if (httr::http_error(response)) {
    warning(paste("API Error:", httr::status_code(response)))
    return(NULL)
  }

  if (parse) {
    return(httr::content(response, "text", encoding = "UTF-8") %>%
             jsonlite::fromJSON(flatten = FALSE))
  }
  return(response)
}

# Get system diagnostics
cat("=== System Diagnostics ===\n")
diagnostics <- nifi_get("/system-diagnostics")
if (!is.null(diagnostics)) {
  if ("systemDiagnostics" %in% names(diagnostics)) {
    sys_diag <- diagnostics$systemDiagnostics
    if ("aggregateSnapshot" %in% names(sys_diag)) {
      agg <- sys_diag$aggregateSnapshot
      cat(paste("  Available Processors:", agg$availableProcessors, "\n"))
      cat(paste("  Total Memory:", round(agg$totalMemory / 1024 / 1024 / 1024, 2), "GB\n"))
      cat(paste("  Max Memory:", round(agg$maxMemory / 1024 / 1024 / 1024, 2), "GB\n"))
      cat(paste("  CPU Load:", paste(agg$processorLoadAverage, collapse = ", "), "\n"))
    }
  }
}

# Get flow status (root process group)
cat("\n=== Flow Status ===\n")
flow_status <- nifi_get("/flow/status/process-groups")
if (!is.null(flow_status) && "processGroupStatus" %in% names(flow_status)) {
  status <- flow_status$processGroupStatus
  cat(paste("  ID:", status$id, "\n"))
  cat(paste("  Name:", status$name, "\n"))
  cat(paste("  Running:", status$runningCount, "\n"))
  cat(paste("  Stopped:", status$stoppedCount, "\n"))
  cat(paste("  Invalid:", status$invalidCount, "\n"))
  cat(paste("  Disabled:", status$disabledCount, "\n"))
}

# Get root process group info
cat("\n=== Process Groups ===\n")
root_pg <- nifi_get("/process-groups/root")
if (!is.null(root_pg) && "processGroup" %in% names(root_pg)) {
  pg <- root_pg$processGroup
  cat(paste("  Root Process Group:", pg$component$name, "\n"))
  cat(paste("  ID:", pg$id, "\n"))
  cat(paste("  Version:", pg$revision$version, "\n"))

  # Get child process groups
  children <- nifi_get(paste0("/process-groups/", pg$id, "/process-groups"))
  if (!is.null(children) && "processGroups" %in% names(children)) {
    if (length(children$processGroups) > 0) {
      cat("\n  Child Process Groups:\n")
      for (child in children$processGroups) {
        cat(paste("    -", child$component$name,
                  "| ID:", child$id, "\n"))
      }
    }
  }
}

# Get connections
cat("\n=== Connections ===\n")
root_pg <- nifi_get("/process-groups/root")
if (!is.null(root_pg)) {
  pg_id <- root_pg$processGroup$id
  connections <- nifi_get(paste0("/process-groups/", pg_id, "/connections"))
  if (!is.null(connections) && "connections" %in% names(connections)) {
    if (length(connections$connections) > 0) {
      cat(paste("Found", length(connections$connections), "connections:\n"))
      for (conn in connections$connections[1:min(5, length(connections$connections))]) {
        source <- if (!is.null(conn$component$source$name)) conn$component$source$name else conn$component$source$id
        dest <- if (!is.null(conn$component$destination$name)) conn$component$destination$name else conn$component$destination$id
        cat(paste("  -", source, "->", dest, "\n"))
      }
    } else {
      cat("  No connections found\n")
    }
  }
}

# Get processors
cat("\n=== Processors ===\n")
root_pg <- nifi_get("/process-groups/root")
if (!is.null(root_pg)) {
  pg_id <- root_pg$processGroup$id
  processors <- nifi_get(paste0("/process-groups/", pg_id, "/processors"))
  if (!is.null(processors) && "processors" %in% names(processors)) {
    if (length(processors$processors) > 0) {
      cat(paste("Found", length(processors$processors), "processors:\n"))
      for (proc in processors$processors[1:min(10, length(processors$processors))]) {
        cat(paste("  -", proc$component$type,
                  "| Name:", proc$component$name,
                  "| State:", proc$component$state,
                  "| Run Status:", proc$component$runStatusFieldName, "\n"))
      }
    } else {
      cat("  No processors found\n")
    }
  }
}

# Get controller services
cat("\n=== Controller Services ===\n")
controller_services <- nifi_get("/controller/controller-services")
if (!is.null(controller_services) && "controllerServices" %in% names(controller_services)) {
  if (length(controller_services$controllerServices) > 0) {
    cat(paste("Found", length(controller_services$controllerServices), "controller services:\n"))
    for (svc in controller_services$controllerServices[1:min(5, length(controller_services$controllerServices))]) {
      cat(paste("  -", svc$component$type,
                "| Name:", svc$component$name,
                "| State:", svc$component$state, "\n"))
    }
  } else {
    cat("  No controller services found\n")
  }
}

# Get reporting tasks
cat("\n=== Reporting Tasks ===\n")
reporting_tasks <- nifi_get("/reporting-tasks")
if (!is.null(reporting_tasks) && "reportingTasks" %in% names(reporting_tasks)) {
  if (length(reporting_tasks$reportingTasks) > 0) {
    cat(paste("Found", length(reporting_tasks$reportingTasks), "reporting tasks:\n"))
    for (task in reporting_tasks$reportingTasks) {
      cat(paste("  -", task$component$type,
                "| Name:", task$component$name,
                "| State:", task$component$state,
                "| Running:", task$component$schedulingStrategy, "\n"))
    }
  } else {
    cat("  No reporting tasks found\n")
  }
}

cat("\n✓ NiFi API examples completed\n")
