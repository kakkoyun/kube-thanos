{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'thanos-sidecar.rules',
        rules: [
          {
            alert: 'ThanosSidecarAllUnhealthy',
            annotations: {
              message: 'All Thanos Sidecars are unhealthy for {{ $value }} seconds.',
            },
            expr: |||
              count(time() - max(thanos_sidecar_last_heartbeat_success_time_seconds{%(thanosSidecarSelector)s}) by (pod) > 300) == 0
            ||| % $._config,
            'for': '5m',
            labels: {
              severity: 'warning',
            },
          },
        ],
      },
    ],
  },
}
