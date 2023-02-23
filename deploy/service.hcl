variable "datadog_api_key" {
  type        = string
  description = "DataDog API key"
}

locals {
  # renovate: source=github-releases name=DataDog/datadog-agent
  datadog_agent_version = "7.43.0"
}

# https://www.nomadproject.io/docs/job-specification/job
job "monitoring" {
  type        = "system"
  datacenters = ["primary-dc"]
  namespace   = "apps"

  # https://www.nomadproject.io/docs/job-specification/group
  group "datadog" {
    count = 1

    network {
      port "metrics_port" { static = 8125 }
    }

    task "agent" {
      driver = "docker"

      # https://www.nomadproject.io/docs/drivers/docker
      config {
        image   = "gcr.io/datadoghq/agent:${ local.datadog_agent_version }"
        volumes = [
          "/etc/os-release:/host/etc/os-release:ro",
          "/var/run/docker.sock:/var/run/docker.sock:ro",
          "/var/lib/docker/containers/:/var/lib/docker/containers/:ro",
          "/proc/:/host/proc/:ro",
          "/opt/datadog-agent/run/:/opt/datadog-agent/run/:rw",
          "/sys/fs/cgroup/:/host/sys/fs/cgroup/:ro",
          "/run/systemd/:/host/run/systemd/:ro", # https://bit.ly/3Qlemcf
        ]
        ports = ["metrics_port"]
      }

      # https://www.nomadproject.io/docs/job-specification/template#consul-kv
      template {
        data = <<-EOH
        {{ range ls "apps/monitoring/datadog/agent/environment" }}
        {{ .Key }}={{ .Value }}
        {{ end }}
        EOH

        destination = "local/environment"
        env         = true
      }

      # https://app.datadoghq.com/logs/onboarding/container
      env {
        DD_API_KEY                           = var.datadog_api_key
        DD_PROCESS_AGENT_ENABLED             = "true"
        DD_LOGS_ENABLED                      = "true"
        DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL = "true"
        DD_DOGSTATSD_NON_LOCAL_TRAFFIC       = "true"
        DD_CONTAINER_EXCLUDE_LOGS            = "image:gcr.io/datadoghq/agent"
        DD_SITE                              = "datadoghq.eu"
      }

      # https://www.nomadproject.io/docs/job-specification/resources
      resources {
        cpu        = 150 # in MHz
        memory     = 300 # in MB
        memory_max = 550 # in MB
      }

      # https://www.nomadproject.io/docs/job-specification/service
      service {
        name = "datadog-agent"
        tags = ["monitoring"]
      }
    }
  }
}
