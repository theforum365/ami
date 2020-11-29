# #sammary This module manages prometheus
# @param configname
#  the name of the configfile, defaults to prometheus.yaml or prometheus.yml on most operating systems
# @param manage_user
#  Whether to create user for prometheus or rely on external code for that
# @param user
#  User running prometheus
# @param manage_group
#  Whether to create user for prometheus or rely on external code for that
# @param purge_config_dir
#  Purge config files no longer generated by Puppet
# @param group
#  Group under which prometheus is running
# @param bin_dir
#  Directory where binaries are located
# @param shared_dir
#  Directory where shared files are located
# @param arch
#  Architecture (amd64 or i386)
# @param version
#  Prometheus release
# @param install_method
#  Installation method: url or package (only url is supported currently)
# @param os
#  Operating system (linux is supported)
# @param download_url
#  Complete URL corresponding to the Prometheus release, default to undef
# @param download_url_base
#  Base URL for prometheus
# @param download_extension
#  Extension of Prometheus binaries archive
# @param package_name
#  Prometheus package name - not available yet
# @param package_ensure
#  If package, then use this for package ensurel default 'latest'
# @param config_dir
#  Prometheus configuration directory (default /etc/prometheus)
# @param localstorage
#  Location of prometheus local storage (storage.local argument)
# @param extra_options
#  Extra options added to prometheus startup command
# @param config_hash
#  Startup config hash
# @param config_defaults
#  Startup config defaults
# @param config_template
#  Configuration template to use (template/prometheus.yaml.erb)
# @param config_mode
#  Configuration file mode (default 0660)
# @param service_enable
#  Whether to enable or not prometheus service from puppet (default true)
# @param service_ensure
#  State ensured from prometheus service (default 'running')
# @param service_name
#  Name of the prometheus service (default 'prometheus')
# @param manage_service
#  Should puppet manage the prometheus service? (default true)
# @param restart_on_change
#  Should puppet restart prometheus on configuration change? (default true)
#  Note: this applies only to command-line options changes. Configuration
#  options are always *reloaded* without restarting.
# @param init_style
#  Service startup scripts style (e.g. rc, upstart or systemd)
# @param global_config
#  Prometheus global configuration variables
# @param rule_files
#  Prometheus rule files
# @param scrape_configs
#  Prometheus scrape configs
# @param remote_read_configs
#  Prometheus remote_read config to scrape prometheus 1.8+ instances
# @param remote_write_configs
#  Prometheus remote_write config to scrape prometheus 1.8+ instances
# @param alerts
#  alert rules to put in alerts.rules
# @param extra_alerts
#  Hash with extra alert rules to put in separate files.
# @param alert_relabel_config
#  Prometheus alert relabel config under alerting
# @param alertmanagers_config
#  Prometheus managers config under alerting
# @param storage_retention
#  How long to keep timeseries data. This is given as a duration like "100h" or "14d". Until
#  prometheus 1.8.*, only durations understood by golang's time.ParseDuration are supported. Starting
#  with prometheus 2, durations can also be given in days, weeks and years.
# @param external_url
#  The URL under which Alertmanager is externally reachable (for example, if Alertmanager is served
#  via a reverse proxy). Used for generating relative and absolute links back to Alertmanager itself.
#  If omitted, relevant URL components will be derived automatically.
# @param extract_command
#  Custom command passed to the archive resource to extract the downloaded archive.
# @param collect_tag
#  Only collect scrape jobs tagged with this label. Allowing to split jobs over multiple prometheuses.
# @param collect_scrape_jobs
#  Array of scrape_configs. Format, e.g.:
#  - job_name: some_exporter
#    scheme: https
#  The jobs defined here will be used to collect resources exported via prometheus::daemon,
#  creating the appropriate prometheus scrape configs for each endpoint. All scrape_config
#  options can be passed as hash elements. Only the job_name is mandatory.
# @param max_open_files
#  The maximum number of file descriptors for the prometheus server.
#  Defaults to `undef`, but set to a large integer to override your default OS limit.
#  Currently only implemented for systemd based service.
# @param usershell
#  if requested, we create a user for prometheus or the exporters. The default
#  shell is nologin. It can be overwritten to any valid path.
# @param web_listen_address
#  --web.listen-address="0.0.0.0:9090"
#  Address to listen on for UI, API, and telemetry.
# @param web_read_timeout
#  --web.read-timeout=5m
#  Maximum duration before timing out read of the request, and closing idle connections.
# @param web_max_connections
#  --web.max-connections=512
#  Maximum number of simultaneous connections.
# @param web_route_prefix
#  --web.route-prefix=<path>
#  Prefix for the internal routes of web endpoints. Defaults to path of --web.external-url.
# @param web_user_assets
#  --web.user-assets=<path>
#  Path to static asset directory, available at /user.
# @param web_enable_lifecycle
#  --web.enable-lifecycle
#  Enable shutdown and reload via HTTP request
# @param web_enable_admin_api
#  --web.enable-admin-api
#  Enable API endpoints for admin control actions.
# @param web_page_title
#  --web.page-title="Prometheus Time Series Collection and Processing Server"
#  Document title of Prometheus instance.
# @param web_cors_origin
#  --web.cors.origin=".*"
#  Regex for CORS origin. It is fully anchored. Example: 'https?://(domain1|domain2)\.com'
# @param storage_retention_size
#  --storage.tsdb.retention.size=STORAGE.TSDB.RETENTION.SIZE
#  [EXPERIMENTAL] Maximum number of bytes that can be stored for blocks. Units supported: KB,
#  MB, GB, TB, PB. This flag is experimental and can be changed in future releases.
# @param storage_no_lockfile
#  --storage.tsdb.no-lockfile
#  Do not create lockfile in data directory.
# @param storage_allow_overlapping_blocks
#  --storage.tsdb.allow-overlapping-blocks
#  [EXPERIMENTAL] Allow overlapping blocks, which in turn enables vertical compaction and
#  vertical query merge.
# @param storage_wal_compression
#  --storage.tsdb.wal-compression
#  Compress the tsdb WAL.
# @param storage_flush_deadline
#  --storage.remote.flush-deadline=<duration>
#  How long to wait flushing sample on shutdown or config reload.
# @param storage_read_sample_limit
#  --storage.remote.read-sample-limit=5e7
#  Maximum overall number of samples to return via the remote read interface, in a single
#  query. 0 means no limit. This limit is ignored for streamed response types.
# @param storage_read_concurrent_limit
#  --storage.remote.read-concurrent-limit=10
#  Maximum number of concurrent remote read calls. 0 means no limit.
# @param storage_read_max_bytes_in_frame
#  --storage.remote.read-max-bytes-in-frame=1048576
#  Maximum number of bytes in a single frame for streaming remote read response types before
#  marshalling. Note that client might have limit on frame size as well. 1MB as recommended
#  by protobuf by default.
# @param alert_for_outage_tolerance
#  --rules.alert.for-outage-tolerance=1h
#  Max time to tolerate prometheus outage for restoring "for" state of alert.
# @param alert_for_grace_period
#  --rules.alert.for-grace-period=10m
#  Minimum duration between alert and restored "for" state. This is maintained only for
#  alerts with configured "for" time greater than grace period.
# @param alert_resend_delay
#  --rules.alert.resend-delay=1m
#  Minimum amount of time to wait before resending an alert to Alertmanager.
# @param alertmanager_notification_queue_capacity
#  --alertmanager.notification-queue-capacity=10000
#  The capacity of the queue for pending Alertmanager notifications.
# @param alertmanager_timeout
#  --alertmanager.timeout=10s
#  Timeout for sending alerts to Alertmanager.
# @param alertmanager_url
#  [REMOVED, v1 ONLY] -alertmanager.url
#  Comma-separated list of Alertmanager URLs to send notifications to.
#  In Prometheus v2, Alertmanager must be discovered via service discovery
# @param query_lookback_delta
#  --query.lookback-delta=5m
#  The maximum lookback duration for retrieving metrics during expression evaluations.
# @param query_timeout
#  --query.timeout=2m
#  Maximum time a query may take before being aborted.
# @param query_max_concurrency
#  --query.max-concurrency=20
#  Maximum number of queries executed concurrently.
# @param query_max_samples
#  --query.max-samples=50000000
#  Maximum number of samples a single query can load into memory. Note that queries will fail
#  if they try to load more samples than this into memory, so this also limits the number of
#  samples a query can return.
# @param query_staleness_delta
#  [REMOVED, v1 ONLY] -query.staleness-delta=5m0s
#  Staleness delta allowance during expression evaluations.
# @param web_telemetry_path
#  [REMOVED, v1 ONLY] -web.telemetry-path="/metrics"
#  Path under which to expose metrics
# @param web_enable_remote_shutdown
#  [REMOVED, v1 ONLY] -web.enable-remote-shutdown=false
#  Enable remote service shutdown.
# @param log_level
#  --log.level=info
#  Only log messages with the given severity or above. One of: [debug, info, warn, error]
#  Value of 'fatal' is also allowed in prometheus v1
# @param log_format
#  --log.format=logfmt
#  Output format of log messages. One of: [logfmt, json]
# @param config_show_diff
#  Whether to show prometheus configuration file diff in the Puppet logs.
# @param extra_groups Extra groups of which the user should be a part
class prometheus (
  String $user,
  String $group,
  Array $extra_groups,
  Stdlib::Absolutepath $bin_dir,
  Stdlib::Absolutepath $shared_dir,
  String $version,
  String $install_method,
  Prometheus::Uri $download_url_base,
  String $download_extension,
  String $package_name,
  String $package_ensure,
  String $service_name,
  String $config_dir,
  Stdlib::Absolutepath $localstorage,
  String $config_template,
  String $config_mode,
  Hash $global_config,
  Array $rule_files,
  Array $scrape_configs,
  Array $remote_read_configs,
  Array $remote_write_configs,
  Variant[Array,Hash] $alerts,
  Array $alert_relabel_config,
  Array $alertmanagers_config,
  String $storage_retention,
  Stdlib::Absolutepath $env_file_path,
  Boolean $manage_prometheus_server,
  Optional[String[1]] $extra_options,
  Optional[String] $download_url,
  Optional[String[1]] $extract_command,
  Boolean $manage_config,
  Stdlib::Absolutepath $usershell,
  Optional[String[1]] $web_listen_address                                       = undef,
  Optional[String[1]] $web_read_timeout                                         = undef,
  Optional[String[1]] $web_max_connections                                      = undef,
  Optional[String[1]] $web_route_prefix                                         = undef,
  Optional[String[1]] $web_user_assets                                          = undef,
  Boolean $web_enable_lifecycle                                                 = false,
  Boolean $web_enable_admin_api                                                 = false,
  Optional[String[1]] $web_page_title                                           = undef,
  Optional[String[1]] $web_cors_origin                                          = undef,
  Optional[String[1]] $storage_retention_size                                   = undef,
  Boolean $storage_no_lockfile                                                  = false,
  Boolean $storage_allow_overlapping_blocks                                     = false,
  Boolean $storage_wal_compression                                              = false,
  Optional[String[1]] $storage_flush_deadline                                   = undef,
  Optional[String[1]] $storage_read_sample_limit                                = undef,
  Optional[String[1]] $storage_read_concurrent_limit                            = undef,
  Optional[String[1]] $storage_read_max_bytes_in_frame                          = undef,
  Optional[String[1]] $alert_for_outage_tolerance                               = undef,
  Optional[String[1]] $alert_for_grace_period                                   = undef,
  Optional[String[1]] $alert_resend_delay                                       = undef,
  Optional[String[1]] $alertmanager_notification_queue_capacity                 = undef,
  Optional[String[1]] $alertmanager_timeout                                     = undef,
  Optional[String[1]] $alertmanager_url                                         = undef, #v1 only
  Optional[String[1]] $query_lookback_delta                                     = undef,
  Optional[String[1]] $query_timeout                                            = undef,
  Optional[String[1]] $query_max_concurrency                                    = undef,
  Optional[String[1]] $query_max_samples                                        = undef,
  Optional[String[1]] $query_staleness_delta                                    = undef, #v1 only
  Optional[String[1]] $web_telemetry_path                                       = undef, #v1 only
  Boolean $web_enable_remote_shutdown                                           = false, #v1 only
  Optional[Enum['debug', 'info', 'warn', 'error', 'fatal']] $log_level          = undef,
  Optional[Enum['logfmt', 'json']] $log_format                                  = undef,
  Hash $extra_alerts                                                            = {},
  Hash $config_hash                                                             = {},
  Hash $config_defaults                                                         = {},
  String[1] $os                                                                 = downcase($facts['kernel']),
  Optional[Variant[Stdlib::HTTPUrl, Stdlib::Unixpath, String[1]]] $external_url = undef,
  Optional[Array[Hash[String[1], Any]]] $collect_scrape_jobs                    = [],
  Optional[String[1]] $collect_tag                                              = undef,
  Optional[Integer] $max_open_files                                             = undef,
  String[1] $configname                                                         = 'prometheus.yaml',
  Boolean $service_enable                                                       = true,
  Boolean $manage_service                                                       = true,
  Stdlib::Ensure::Service $service_ensure                                       = 'running',
  Boolean $restart_on_change                                                    = true,
  Prometheus::Initstyle $init_style                                             = $facts['service_provider'],
  String[1] $arch                                                               = $facts['os']['architecture'],
  Boolean $manage_group                                                         = true,
  Boolean $purge_config_dir                                                     = true,
  Boolean $manage_user                                                          = true,
  Boolean $config_show_diff                                                     = true,
) {
  case $arch {
    'x86_64', 'amd64': { $real_arch = 'amd64' }
    'i386':            { $real_arch = '386' }
    'aarch64':         { $real_arch = 'arm64' }
    'armv7l':          { $real_arch = 'armv7' }
    'armv6l':          { $real_arch = 'armv6' }
    'armv5l':          { $real_arch = 'armv5' }
    'ppc64le':         { $real_arch = 'ppc64le' }
    default:           {
      fail("Unsupported kernel architecture: ${arch}")
    }
  }

  if $manage_prometheus_server {
    include prometheus::server
  }
}
