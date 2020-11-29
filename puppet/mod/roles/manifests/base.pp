class roles::base {

    # It looks like there's a bug with the Amazon Linux 2
    # service specification with the prometheus module
    # We'll use a resource collector to patch all services
    Service <|  |> {
        provider  => 'systemd',
    }

    class { 'prometheus::node_exporter':
      version            => '1.0.1',
      collectors_disable => ['mdadm'],
    }

}
