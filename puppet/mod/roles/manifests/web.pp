# defines an nginx webserver
class roles::web() inherits roles::base {

  class { 'nginx':
    gzip            => 'on',
    gzip_proxied    => 'any',
    gzip_comp_level => 6,
    gzip_buffers    => '16 8k',
    package_name    => 'nginx', # installed by the script
    log_format      => {
      proxy => '$http_x_forwarded_for - [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent"'
    },
    gzip_types      =>
      'text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript',

  }
  -> file { ['/srv/http/', '/srv/http/theforum365.com', '/srv/http/theforum365.com/root', '/srv/http/theforum365.com/root/html' ]:
    ensure => 'directory',
    group  => 'nginx',
    owner  => 'nginx',
  }
  -> class { 'php':
    ensure       => 'present',
    manage_repos => false,
    fpm          => true,
    dev          => false,
    composer     => false,
    pear         => true,
    phpunit      => false,
    fpm_user     => 'nginx',
    fpm_group    => 'nginx',
    extensions   => {
      gd       => {},
      mbstring => {},
      mysqlnd  => {},
      redis    => {},
    },
    fpm_pools    => {
      'www' => {
        user            => 'nginx',
        group           => 'nginx',
        listen          => '/var/run/php-fpm_webapp.sock',
        listen_owner    => 'nginx',
        listen_group    => 'nginx',
        pm_status_path  => '/php_fpm_status',
        php_flag        => {
          display_errors => 'off'
        },
        php_admin_value => {
          log_errors          => 'on',
          upload_max_filesize => '100M',
          post_max_size       => '100M',
          memory_limit        => '512M',
          max_execution_time  => '30',
          'cgi.fix_pathinfo'  => '0',
          'disable_functions' => 'exec,system,popen,proc_open,shell_exec,passthru',
          'open_basedir'      => '/tmp/:/usr/bin/:/srv/http/theforum365.com/root/html/',
        }
      }
    }
  }

  nginx::resource::upstream { 'php-backend':
    ensure  => present,
    members => {
      'php-webapp' => {
        server => 'unix:/var/run/php-fpm_webapp.sock',
      },
    }
  }

  nginx::resource::server { 'theforum365':
    use_default_location => false,
    listen_port          => 80,
    server_name          => ['theforum365.com',  'www.theforum365.com', 'test.theforum365.com' ],
    www_root             => '/srv/http/theforum365.com/root/html',
    index_files          => [ 'index.php' ],
    client_max_body_size => '100M',
    access_log           => '/var/log/nginx/theforum365.access.log',
    format_log           => 'proxy',
  }

  nginx::resource::location { '/':
    location  => '/',
    server    => 'theforum365',
    try_files => [ '$uri', '$uri/', '@ips'],
  }

  nginx::resource::location { 'images':
    server    => 'theforum365',
    location  => '~* ^.+\.(?:jpg|jpeg|gif|css|png|js|ico|xml|htm|swf|cur)$',
    try_files => [ '$uri', '@ips404' ],
    expires   => '2w',
  }

  nginx::resource::location { 'admin':
    server    => 'theforum365',
    location  => '~ ^/admin/.+\.php$',
    try_files => [ '$uri', '@ips404' ],
    fastcgi   => 'unix:/var/run/php-fpm_webapp.sock',
    include   => [ '/etc/nginx/fastcgi_params' ],
  }

  nginx::resource::location { 'php':
    server              => 'theforum365',
    location            => '~ \.php$',
    include             => [ '/etc/nginx/fastcgi_params' ],
    fastcgi             => 'unix:/var/run/php-fpm_webapp.sock',
    location_custom_cfg => {
      'fastcgi_buffers'     => '38 4k',
      'fastcgi_buffer_size' => '16k',
    }
  }

  nginx::resource::location { 'ips':
    server              => 'theforum365',
    location            => '@ips',
    include             => [ '/etc/nginx/fastcgi_params' ],
    fastcgi             => 'unix:/var/run/php-fpm_webapp.sock',
    fastcgi_param       => {
      'SCRIPT_FILENAME' => '$document_root/index.php',
      'SCRIPT_NAME'     => '/index.php',
    },
    location_custom_cfg => {
      'fastcgi_buffers'     => '38 4k',
      'fastcgi_buffer_size' => '16k',
    }
  }

  nginx::resource::location { '404':
    server              => 'theforum365',
    location            => '@ips404',
    include             => [ '/etc/nginx/fastcgi_params' ],
    fastcgi             => 'unix:/var/run/php-fpm_webapp.sock',
    fastcgi_param       => {
      'SCRIPT_FILENAME' => '$document_root/404error.php',
      'SCRIPT_NAME'     => '404error.php',
    },
    location_custom_cfg => {
      'fastcgi_buffers'     => '38 4k',
      'fastcgi_buffer_size' => '16k',
    }
  }

  nginx::resource::location { 'status':
    server         => 'theforum365',
    location       => '/ngx_server_status',
    stub_status    => true,
    location_allow => [ '127.0.0.1', '172.16.0.0/24' ],
    location_deny  => [ all ],
  }

  nginx::resource::location { 'php-fpm-status':
    server         => 'theforum365',
    location       => '/php_fpm_status',
    include        => [ '/etc/nginx/fastcgi_params' ],
    fastcgi        => 'unix:/var/run/php-fpm_webapp.sock',
    location_allow => [ '127.0.0.1', '172.16.0.0/24' ],
    location_deny  => [ all ],
  }

  nginx::resource::location { 'uploads':
    server        => 'theforum365',
    location      => '~ ^/uploads/.*\.(?:php\d*|phtml)$',
    location_deny => [ all ],
  }

  nginx::resource::location { 'datastore':
    server        => 'theforum365',
    location      => '~ ^/datastore/.*\.(?:php\d*|phtml)$',
    location_deny => [ all ],
  }

  nginx::resource::location { 'dotfiles':
    server        => 'theforum365',
    location      => '~ /\.',
    location_deny => [ all ],
  }


  include ::logrotate

  logrotate::rule { 'nginx':
    path          => '/var/log/nginx/*.log',
    rotate        => 5,
    size          => '500k',
    sharedscripts => true,
    postrotate    => '[ ! -f /var/run/nginx.pid ] || kill -USR1 $(cat /var/run/nginx.pid)',
  }



}
