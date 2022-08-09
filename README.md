# Cluster monitoring tools

[![Tests Status][badge_tests]][link_actions]
[![Deploy Status][badge_deploy]][link_deploy]

Observability is an important part of any solution. And for cluster monitoring, I prefer to use a free solution - DataDog.

This repository contains its deploying manifest.

## Environment

For environment values management, you can use the Consul KV. This is very simple, your variables will be automatically passed to the container with the application _(containers will be restarted automatically)_. KV namespace is `apps/monitoring/datadog/agent/environment`.

> For example, you create a key `apps/monitoring/datadog/agent/environment/DD_LOGS_ENABLED` with a value `false` - the environment variable `DD_LOGS_ENABLED` will be available inside the container with a value `false`.

List with all supported environment variables you can [find here](../.env.example).

### Links

- [DataDog containers onboarding](https://app.datadoghq.com/logs/onboarding/container)

[badge_tests]:https://img.shields.io/github/workflow/status/iddqd-uk/monitoring/tests/main?logo=github&logoColor=white&label=tests
[badge_deploy]:https://img.shields.io/github/workflow/status/iddqd-uk/monitoring/deploy/main?logo=github&logoColor=white&label=deploy

[link_actions]:https://github.com/iddqd-uk/monitoring/actions
[link_deploy]:https://github.com/iddqd-uk/monitoring/actions/workflows/deploy.yml
