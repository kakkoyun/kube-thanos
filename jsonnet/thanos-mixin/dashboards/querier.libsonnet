local g = import 'grafana-builder/grafana.libsonnet';

{
  grafanaDashboards+:: {
    'querier.json':
      g.dashboard(
        '%(dashboardNamePrefix)sQuerier' % $._config.grafanaThanos,
      )
      .addTemplate('thanos', 'thanos', 'thanos')  // TODO: !!
      .addRow(
        g.row('Thanos Query')
        .addPanel(
          g.panel('GRPC Error rate') +
          g.queryPanel(  // TODO: Maybe something else
            |||
              sum(
                rate(grpc_server_handled_total{grpc_code=~"Unknown|ResourceExhausted|Internal|Unavailable", %(thanosQuerierSelector)s}[5m])
                /
                rate(grpc_server_started_total{%(thanosQuerierSelector)s}[5m])
              ) > 0.05
            ||| % $._config,
            '{{grpc_code}} {{grpc_method}} {{kubernetes_pod_name}}'
          )
        )
        .addPanel(
          g.panel('DNS Failure Rate') +
          g.queryPanel(  // TODO: Maybe something else
            |||
              sum(
                rate(thanos_querier_store_apis_dns_failures_total{%(thanosQuerierSelector)s}[5m])
              /
                rate(thanos_querier_store_apis_dns_lookups_total{%(thanosQuerierSelector)s}[5m])
              ) > 1
            ||| % $._config,
            ''
          )
        )
        .addPanel(
          g.panel('Request RPS') +
          g.queryPanel(
            'sum(rate(grpc_client_handled_total{namespace="$namespace",%(thanosQuerierSelector)s,kubernetes_pod_name=~"$pod"}[$interval])) by (kubernetes_pod_name, grpc_code, grpc_method)' % $._config,
            '{{grpc_code}} {{grpc_method}} {{kubernetes_pod_name}}'
          )
        )
        .addPanel(
          g.panel('Response Time Quantile [$interval]') +
          g.queryPanel(
            'histogram_quantile(0.99, sum(rate(grpc_client_handling_seconds_bucket{namespace="$namespace",%(thanosQuerierSelector)s,kubernetes_pod_name=~"$pod"}[$interval])) by (grpc_method,kubernetes_pod_name, le))' % $._config,
            '99.99 {{grpc_method}} {{kubernetes_pod_name}}'
          )
        )
        .addPanel(
          g.panel('Thanos Query 99 Quantile [$interval]') +
          g.queryPanel(
            [
              'histogram_quantile(0.99, sum(rate(thanos_query_api_instant_query_duration_seconds_bucket{namespace="$namespace",%(thanosQuerierSelector)s,kubernetes_pod_name=~"$pod"}[$interval])) by (kubernetes_pod_name, le))' % $._config,
              'histogram_quantile(0.99, sum(rate(thanos_query_api_range_query_duration_seconds_bucket{namespace="$namespace",%(thanosQuerierSelector)s,kubernetes_pod_name=~"$pod"}[$interval])) by (kubernetes_pod_name, le))' % $._config,

            ],
            [
              '99.99 {{grpc_method}} {{kubernetes_pod_name}}',
              'range_query {{kubernetes_pod_name}}',
            ]
          )
        )
        .addPanel(
          g.panel('Prometheus Query 99 Quantile') +
          g.queryPanel(
            'prometheus_engine_query_duration_seconds{namespace="$namespace",%(thanosQuerierSelector)s,kubernetes_pod_name=~"$pod",quantile="0.99"}' % $._config,
            '{{kubernetes_pod_name}} {{slice}}'
          )
        )
        .addPanel(
          g.panel('Prometheus Queries/s') +
          g.queryPanel(
            'prometheus_engine_queries{namespace="$namespace",%(thanosQuerierSelector)s,kubernetes_pod_name=~"$pod"}' % $._config,
            '{{kubernetes_pod_name}}'
          )
        )
        .addPanel(
          g.panel('Gossip Info') +
          g.tablePanel(
            ['min(thanos_store_node_info{namespace="$namespace",%(thanosQuerierSelector)s}) by (external_labels)' % $._config],
            {
              'Value #A': {
                alias: 'Peer',
                decimals: 2,
                colors: [
                  'rgba(245, 54, 54, 0.9)',
                  'rgba(237, 129, 40, 0.89)',
                  'rgba(50, 172, 45, 0.97)',
                ],
              },
              'Value #B': {
                alias: 'Replicas',
                decimals: 2,
                type: 'hidden',
                colors: [
                  'rgba(245, 54, 54, 0.9)',
                  'rgba(237, 129, 40, 0.89)',
                  'rgba(50, 172, 45, 0.97)',
                ],
              },
            },
          )
        )
        .addPanel(
          g.panel('Memory Used') +
          g.queryPanel(
            'go_memstats_heap_alloc_bytes{namespace="$namespace",%(thanosQuerierSelector)s,kubernetes_pod_name=~"$pod"}' % $._config,
            '{{kubernetes_pod_name}}'
          )
        )
        .addPanel(
          g.panel('Goroutines') +
          g.queryPanel(
            'go_goroutines{namespace="$namespace",%(thanosQuerierSelector)s}' % $._config,
            '{{kubernetes_pod_name}}'
          )
        )
        .addPanel(
          g.panel('GC Time Quantiles') +
          g.queryPanel(
            'go_gc_duration_seconds{namespace="$namespace",%(thanosQuerierSelector)s,kubernetes_pod_name=~"$pod"}' % $._config,
            '{{quantile}} {{kubernetes_pod_name}}'
          )
        )
      ) + { tags: $._config.grafanaThanos.dashboardTags },
  },
}
