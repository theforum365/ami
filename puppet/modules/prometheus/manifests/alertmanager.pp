# @summary This module manages prometheus alertmanager
# @param arch
#  Architecture (amd64 or i386)
# @param bin_dir
#  Directory where binaries are located
# @param config_file
#  The path to put the configuration file
# @param config_mode
#  The permissions of the configuration files
# @param download_extension
#  Extension for the release binary archive
# @param download_url
#  Complete URL corresponding to the where the release binary archive can be downloaded
# @param download_url_base
#  Base URL for the binary archive
# @param extra_groups
#  Extra groups to add the binary user to
# @param extra_options
#  Extra options added to the startup command
# @param global
#  The global alertmanager configuration.
#  Example (also default):
#  prometheus::alertmanager::global:
#    smtp_smarthost: 'localhost:25'
#    smtp_from: 'alertmanager@localhost'
# @param group
#  Group under which the binary is running
# @param inhibit_rules
#  An array of inhibit rules.
#  Example (also default):
#  prometheus::alertmanager::inhibit_rules:
#  - source_match:
#      severity: 'critical'
#      target_match:
#        severity: 'warning'
#      equal:
#      - 'alertname'
#      - 'cluster'
#      - 'service'
# @param init_style
#  Service startup scripts style (e.g. rc, upstart or systemd)
# @param install_method
#  Installation method: url or package (only url is supported currently)
# @param manage_group
#  Whether to create a group for or rely on external code for that
# @param manage_service
#  Should puppet manage the service? (default true)
# @param manage_user
#  Whether to create user or rely on external code for that
# @param os
#  Operating system (linux is the only one supported)
# @param package_ensure
#  If package, then use this for package ensure default 'latest'
# @param package_name
#  The binary package name - not available yet
# @param purge_config_dir
#  Purge config files no longer generated by Puppet
# @param receivers
#  An array of receivers.
#  Example (also default):
#  prometheus::alertmanager::receivers:
#  - name: 'Admin'
#    email_configs:
#      - to: 'root@localhost'
# @param restart_on_change
#  Should puppet restart the service on configuration change? (default true)
# @param route
#  The top level route.
#  Example (also default):
#  prometheus::alertmanager::route:
#    group_by:
#      - 'alertname'
#      - 'cluster'
#      - 'service'
#    group_wait: '30s'
#    group_interval: '5m'
#    repeat_interval: '3h'
#    receiver: 'Admin'
# @param service_enable
#  Whether to enable the service from puppet (default true)
# @param service_ensure
#  State ensured for the service (default 'running')
# @param service_name
#  Name of the alertmanager service (default 'alertmanager')
# @param storage_path
#  The storage path to pass to the alertmanager. Defaults to '/var/lib/alertmanager'
# @param templates
#  The array of template files. Defaults to [ "${config_dir}/*.tmpl" ]
# @param user
#  User which runs the service
# @param version
#  The binary release version
class prometheus::alertmanager (
  Stdlib::Absolutepath $config_dir,
  Stdlib::Absolutepath $config_file,
  String[1] $download_extension,
  Prometheus::Uri $download_url_base,
  Array $extra_groups,
  Hash $global,
  String[1] $group,
  Array $inhibit_rules,
  String[1] $package_ensure,
  String[1] $package_name,
  Array $receivers,
  Hash $route,
  Stdlib::Absolutepath $storage_path,
  Array $templates,
  String[1] $user,
  String[1] $version,
  Boolean $service_enable                 = true,
  Stdlib::Ensure::Service $service_ensure = 'running',
  String[1] $service_name                 = 'alertmanager',
  Boolean $restart_on_change              = true,
  Boolean $reload_on_change               = false,
  Boolean $purge_config_dir               = true,
  Boolean $manage_config                  = true,
  Prometheus::Initstyle $init_style       = $facts['service_provider'],
  String[1] $install_method               = $prometheus::install_method,
  Boolean $manage_group                   = true,
  Boolean $manage_service                 = true,
  Boolean $manage_user                    = true,
  String[1] $os                           = $prometheus::os,
  String $extra_options                   = '',
  Optional[String] $download_url          = undef,
  String[1] $config_mode                  = $prometheus::config_mode,
  String[1] $arch                         = $prometheus::real_arch,
  Stdlib::Absolutepath $bin_dir           = $prometheus::bin_dir,
) inherits prometheus {
  if( versioncmp($version, '0.3.0') == -1 ) {
    $real_download_url    = pick($download_url,
    "${download_url_base}/download/${version}/${package_name}-${version}.${os}-${arch}.${download_extension}")
  } else {
    $real_download_url    = pick($download_url,
    "${download_url_base}/download/v${version}/${package_name}-${version}.${os}-${arch}.${download_extension}")
  }
  $notify_service = $restart_on_change ? {
    true    => Service[$service_name],
    default => undef,
  }

  $alertmanager_reload = $prometheus::init_style ? {
    'systemd'                     => "systemctl reload-or-restart ${service_name}",
    /^(upstart|none)$/            => "service ${service_name} reload",
    /^(sysv|redhat|sles|debian)$/ => "/etc/init.d/${service_name} reload",
    'launchd'                     => "launchctl stop ${service_name} && launchctl start ${service_name}",
  }

  exec { 'alertmanager-reload':
    command     => $alertmanager_reload,
    path        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
    refreshonly => true,
  }

  if $reload_on_change {
    $_notify_service = Exec['alertmanager-reload']
  } else {
    $_notify_service = $notify_service
  }

  file { $config_dir:
    ensure  => 'directory',
    owner   => 'root',
    group   => $group,
    purge   => $purge_config_dir,
    recurse => $purge_config_dir,
  }

  if (( versioncmp($version, '0.10.0') >= 0 ) and ( $install_method == 'url' )) {
    # If version >= 0.10.0 then install amtool - Alertmanager validation tool
    file { "${bin_dir}/amtool":
      ensure => link,
      target => "/opt/${package_name}-${version}.${os}-${arch}/amtool",
    }

    if $manage_config {
      file { $config_file:
        ensure       => file,
        owner        => 'root',
        group        => $group,
        mode         => $config_mode,
        content      => template('prometheus/alertmanager.yaml.erb'),
        notify       => $_notify_service,
        require      => File["${bin_dir}/amtool", $config_dir],
        validate_cmd => "${bin_dir}/amtool check-config --alertmanager.url='' %",
      }
    }
  } else {
    if $manage_config {
      file { $config_file:
        ensure  => file,
        owner   => 'root',
        group   => $group,
        mode    => $config_mode,
        content => template('prometheus/alertmanager.yaml.erb'),
        notify  => $_notify_service,
        require => File[$config_dir],
      }
    }
  }

  if $facts['prometheus_alert_manager_running'] == 'running' {
    # This is here to stop the previous alertmanager that was installed in version 0.1.14
    service { 'alert_manager':
      ensure => 'stopped',
    }
  }

  if $storage_path {
    file { $storage_path:
      ensure => 'directory',
      owner  => $user,
      group  => $group,
      mode   => '0755',
    }

    if( versioncmp($version, '0.12.0') == 1 ) {
      $options = "--config.file=${prometheus::alertmanager::config_file} --storage.path=${prometheus::alertmanager::storage_path} ${prometheus::alertmanager::extra_options}"
    } else {
      $options = "-config.file=${prometheus::alertmanager::config_file} -storage.path=${prometheus::alertmanager::storage_path} ${prometheus::alertmanager::extra_options}"
    }
  } else {
    if( versioncmp($prometheus::alertmanager::version, '0.12.0') == 1 ) {
      $options = "--config.file=${prometheus::alertmanager::config_file} ${prometheus::alertmanager::extra_options}"
    } else {
      $options = "-config.file=${prometheus::alertmanager::config_file} ${prometheus::alertmanager::extra_options}"
    }
  }

  prometheus::daemon { $service_name:
    install_method     => $install_method,
    version            => $version,
    download_extension => $download_extension,
    os                 => $os,
    arch               => $arch,
    real_download_url  => $real_download_url,
    bin_dir            => $bin_dir,
    notify_service     => $notify_service,
    package_name       => $package_name,
    package_ensure     => $package_ensure,
    manage_user        => $manage_user,
    user               => $user,
    extra_groups       => $extra_groups,
    group              => $group,
    manage_group       => $manage_group,
    purge              => $purge_config_dir,
    options            => $options,
    init_style         => $init_style,
    service_ensure     => $service_ensure,
    service_enable     => $service_enable,
    manage_service     => $manage_service,
  }
}