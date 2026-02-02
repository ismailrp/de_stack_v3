airflow
nifi
elasticsearch
kibana
postgres

based on book "Data Enginerring with python"
  Final Status - All Services Up:
  ┌───────────────┬──────────┬─────────────────────────────┬───────────────────────┐
  │    Service    │  Status  │    URL (Windows Browser)    │      Credentials      │
  ├───────────────┼──────────┼─────────────────────────────┼───────────────────────┤
  │ Airflow       │ Healthy  │ http://localhost:8080       │ admin / admin         │
  ├───────────────┼──────────┼─────────────────────────────┼───────────────────────┤
  │ PostgreSQL    │ Healthy  │ localhost:5432              │ airflow / airflow     │
  ├───────────────┼──────────┼─────────────────────────────┼───────────────────────┤
  │ Elasticsearch │ Healthy  │ http://localhost:9200       │ (none)                │
  ├───────────────┼──────────┼─────────────────────────────┼───────────────────────┤
  │ Kibana        │ Running  │ http://localhost:5601       │ (none)                │
  ├───────────────┼──────────┼─────────────────────────────┼───────────────────────┤
  │ NiFi          │ Starting │ http://localhost:19000/nifi │ admin / AdminPass123! │
  └───────────────┴──────────┴─────────────────────────────┴───────────────────────┘
  Summary of fixes applied:
  1. Changed PostgreSQL to version 16
  2. Changed NiFi ports to 19000/19001 (WSL conflict)
  3. Fixed NiFi password (minimum 12 characters)
  4. Changed Airflow logs to use named volume (WSL permission issue)
  5. Removed stale PID file to fix Airflow webserver


    # Update package list
  sudo apt update

  # Install R (base version)
  sudo apt install -y r-base r-base-dev

  # Verify installation
  R --version

  Optional - Install recommended packages:

  # For RPostgres (PostgreSQL)
  sudo apt install -y libpq-dev

  # For elastic (Elasticsearch)
  sudo apt install -y libcurl4-openssl-dev libssl-dev

  # For common data science packages
  sudo apt install -y libxml2-dev libgit2-dev libfontconfig1-dev

  Install RStudio Desktop (optional):

  If you want a full IDE, you can install RStudio Desktop for Ubuntu:

  # Download and install RStudio
  wget https://download1.rstudio.org/electron/jammy/amd64/rstudio-2024.09.0-674-amd64.deb
  sudo gdebi rstudio-2024.09.0-674-amd64.deb

  Or use VS Code (recommended for WSL):

  1. Install the R Extension for Visual Studio Code (REDCap) in VS Code
  2. Install languageserver in R for IntelliSense:

  Rscript -e "install.packages('languageserver')"

  After installation, you can run R interactively with R or execute scripts with Rscript script.R.

  sudo apt update && sudo apt install -y libpq-dev libcurl4-openssl-dev libssl-dev