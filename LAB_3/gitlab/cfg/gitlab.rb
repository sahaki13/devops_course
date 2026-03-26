# runners receives 409 conflict on each attempt when session_server.listen_address
# Admin Area → Settings → Network → Outbound requests
gitlab_rails['allow_local_requests_from_web_hooks_and_services'] = true
# http://gitlab/api/v4/application/settings # check current settings
gitlab_rails['registry_enabled'] = false
gitlab_rails['smtp_enable'] = false
gitlab_rails['gitlab_email_enabled'] = false
gitlab_rails['terraform_state_enabled'] = false
gitlab_rails['usage_ping_enabled'] = false
gitlab_rails['gitlab_kas_enabled'] = false
gitlab_kas['enable'] = false
monitoring_role['enable'] = false
prometheus['enable'] = false
alertmanager['enable'] = false
node_exporter['enable'] = false
redis_exporter['enable'] = false
postgres_exporter['enable'] = false
gitlab_exporter['enable'] = false
prometheus_monitoring['enable'] = false
grafana['enable'] = false
gitlab_rails['packages_enabled'] = false
gitlab_rails['dependency_proxy_enabled'] = false

