# @summary This module manages prometheus node redis_exporter
# @param arch
#  Architecture (amd64 or i386)
# @param bin_dir
#  Directory where binaries are located
# @param addr
#  Array of address of one or more redis nodes. Defaults to redis://localhost:6379
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
#  For a full list of the exporter's supported extra options
#  please refer to https://github.com/oliver006/redis_exporter
# @param group
#  Group under which the binary is running
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
# @param namespace
#  Namespace for the metrics, defaults to `redis`.
# @param os
#  Operating system (linux is the only one supported)
# @param package_ensure
#  If package, then use this for package ensure default 'latest'
# @param package_name
#  The binary package name - not available yet
# @param purge_config_dir
#  Purge config files no longer generated by Puppet
# @param restart_on_change
#  Should puppet restart the service on configuration change? (default true)
# @param service_enable
#  Whether to enable the service from puppet (default true)
# @param service_ensure
#  State ensured for the service (default 'running')
# @param service_name
#  Name of the node exporter service (default 'redis_exporter')
# @param user
#  User which runs the service
# @param version
#  The binary release version
class prometheus::redis_exporter (
  Array[String] $addr,
  String[1] $download_extension,
  String[1] $download_url_base,
  Array[String] $extra_groups,
  String[1] $group,
  String[1] $package_ensure,
  String[1] $package_name,
  String[1] $user,
  String[1] $version,
  Boolean $purge_config_dir               = true,
  Boolean $restart_on_change              = true,
  Boolean $service_enable                 = true,
  Stdlib::Ensure::Service $service_ensure = 'running',
  String[1] $service_name                 = 'redis_exporter',
  Prometheus::Initstyle $init_style       = $facts['service_provider'],
  Prometheus::Install $install_method     = $prometheus::install_method,
  Boolean $manage_group                   = true,
  Boolean $manage_service                 = true,
  Boolean $manage_user                    = true,
  String[1] $namespace                    = 'redis',
  String[1] $os                           = downcase($facts['kernel']),
  String $extra_options                   = '',
  Optional[String] $download_url          = undef,
  String[1] $arch                         = $prometheus::real_arch,
  String[1] $bin_dir                      = $prometheus::bin_dir,
  Boolean $export_scrape_job              = false,
  Optional[Stdlib::Host] $scrape_host     = undef,
  Stdlib::Port $scrape_port               = 9121,
  String[1] $scrape_job_name              = 'redis',
  Optional[Hash] $scrape_job_labels       = undef,
) inherits prometheus {
  $release = "v${version}"

  $real_download_url = pick($download_url, "${download_url_base}/download/${release}/${package_name}-${release}.${os}-${arch}.${download_extension}")
  $notify_service = $restart_on_change ? {
    true    => Service[$service_name],
    default => undef,
  }

  $str_addresses = join($addr, ',')
  $options = "-redis.addr=${str_addresses} -namespace=${namespace} ${extra_options}"

  if $install_method == 'url' {
    if versioncmp($version, '1.0.0') >= 0 {
      # From version 1.0.0 the tarball format changed to be consistent with most other exporters
      $real_install_method = $install_method
    } else {
      # Not a big fan of copypasting but prometheus::daemon takes for granted
      # a specific path embedded in the prometheus *_exporter tarball, which
      # redis_exporter lacks before version 1.0.0
      # TODO: patch prometheus::daemon to support custom extract directories
      $real_install_method = 'none'
      $install_dir = "/opt/${service_name}-${version}.${os}-${arch}"
      file { $install_dir:
        ensure => 'directory',
        owner  => 'root',
        group  => 0, # 0 instead of root because OS X uses "wheel".
        mode   => '0555',
      }
      -> archive { "/tmp/${service_name}-${version}.${download_extension}":
        ensure          => present,
        extract         => true,
        extract_path    => $install_dir,
        source          => $real_download_url,
        checksum_verify => false,
        creates         => "${install_dir}/${service_name}",
        cleanup         => true,
      }
      -> file { "${bin_dir}/${service_name}":
        ensure => link,
        notify => $notify_service,
        target => "${install_dir}/${service_name}",
        before => Prometheus::Daemon[$service_name],
      }
    }
  } else {
    $real_install_method = $install_method
  }

  prometheus::daemon { $service_name:
    install_method     => $real_install_method,
    version            => $release,
    download_extension => $download_extension,
    os                 => $os,
    arch               => $arch,
    bin_dir            => $bin_dir,
    notify_service     => $notify_service,
    package_name       => $package_name,
    package_ensure     => $package_ensure,
    manage_user        => $manage_user,
    user               => $user,
    extra_groups       => $extra_groups,
    real_download_url  => $real_download_url,
    group              => $group,
    manage_group       => $manage_group,
    purge              => $purge_config_dir,
    options            => $options,
    init_style         => $init_style,
    service_ensure     => $service_ensure,
    service_enable     => $service_enable,
    manage_service     => $manage_service,
    export_scrape_job  => $export_scrape_job,
    scrape_host        => $scrape_host,
    scrape_port        => $scrape_port,
    scrape_job_name    => $scrape_job_name,
    scrape_job_labels  => $scrape_job_labels,
  }
}