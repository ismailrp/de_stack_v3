# Logstash Configuration

This directory contains Logstash pipeline configurations for the ELK stack.

## Directory Structure

```
logstash/
├── config/
│   └── logstash.yml          # Main Logstash settings
└── pipeline/
    └── sample-pipeline.conf  # Sample pipeline configuration
```

## Ports

| Port | Purpose |
|------|---------|
| 15044 | Beats input (Filebeat, Metricbeat, etc.) |
| 5000 | TCP input for raw log shipping |
| 8080 | HTTP input for webhook-based log shipping |
| 19600 | Logstash monitoring API |

## Testing Logstash

### Send test log via HTTP:
```bash
curl -X POST http://localhost:8080 \
  -H "Content-Type: application/json" \
  -d '{"message": "Test log entry", "level": "info", "service": "test"}'
```

### Send test log via TCP:
```bash
echo '{"message": "Test TCP log", "level": "debug"}' | nc localhost 5000
```

### Check Logstash status:
```bash
curl http://localhost:19600/_node/stats
```

## Pipeline Configuration

The sample pipeline accepts logs from:
- **Beats** (Filebeat, Metricbeat, Packetbeat) on port 5044
- **TCP** on port 5000 (JSON lines format)
- **HTTP** on port 8080 (JSON format)

All logs are:
1. Parsed as JSON if applicable
2. Enriched with metadata
3. Timestamped
4. Sent to Elasticsearch index `logstash-YYYY.MM.dd`

## Creating Custom Pipelines

1. Create a new `.conf` file in `pipeline/`
2. Define your `input`, `filter`, and `output` blocks
3. Restart Logstash:

```bash
docker compose restart logstash
```

## Example: Apache Log Pipeline

```conf
input {
  file {
    path => "/var/log/apache2/access.log"
    start_position => "beginning"
  }
}

filter {
  grok {
    match => { "message" => "%{COMBINEDAPACHELOG}" }
  }
}

output {
  elasticsearch {
    hosts => ["http://elasticsearch:9200"]
    index => "apache-%{+YYYY.MM.dd}"
  }
}
```
