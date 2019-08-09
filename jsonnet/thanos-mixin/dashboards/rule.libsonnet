local b = import '../lib/thanos-grafana-builder/builder.libsonnet';
local g = import 'grafana-builder/grafana.libsonnet';

{
  grafanaDashboards+:: {
    'rule.json':
      g.dashboard(
        '%(dashboardNamePrefix)sRule' % $._config.grafanaThanos,
      )
      .addTemplate('cluster', 'kube_pod_info', 'cluster', hide=if $._config.showMultiCluster then 0 else 2)
      .addTemplate('namespace', 'kube_pod_info{%(clusterLabel)s="$cluster"}' % $._config, 'namespace')
      .addRow(
        g.row('gRPC (Unary)')
        .addPanel(
          g.panel('Rate') +
          b.grpcQpsPanel('server', 'namespace="$namespace",%(thanosRuleSelector)s,grpc_type="unary"' % $._config)
        )
        .addPanel(
          g.panel('Errors') +
          b.grpcErrorsPanel('server', 'namespace="$namespace",%(thanosRuleSelector)s,grpc_type="unary"' % $._config)
        )
        .addPanel(
          g.panel('Duration') +
          b.grpcLatencyPanel('server', 'namespace="$namespace",%(thanosRuleSelector)s,grpc_type="unary"' % $._config)
        )
      )
      .addRow(
        g.row('Detailed')
        .addPanel(
          g.panel('Rate') +
          b.grpcQpsPanelDetailed('server', 'namespace="$namespace",%(thanosRuleSelector)s,grpc_type="unary"' % $._config)
        )
        .addPanel(
          g.panel('Errors') +
          b.grpcErrorDetailsPanel('server', 'namespace="$namespace",%(thanosRuleSelector)s,grpc_type="unary"' % $._config)
        )
        .addPanel(
          g.panel('Duration') +
          b.grpcLatencyPanelDetailed('server', 'namespace="$namespace",%(thanosRuleSelector)s,grpc_type="unary"' % $._config)
        ) +
        b.collapse
      )
      .addRow(
        g.row('gRPC (Stream)')
        .addPanel(
          g.panel('Rate') +
          b.grpcQpsPanel('server', 'namespace="$namespace",%(thanosRuleSelector)s,grpc_type="server_stream"' % $._config)
        )
        .addPanel(
          g.panel('Errors') +
          b.grpcErrorsPanel('server', 'namespace="$namespace",%(thanosRuleSelector)s,grpc_type="server_stream"' % $._config)
        )
        .addPanel(
          g.panel('Duration') +
          b.grpcLatencyPanel('server', 'namespace="$namespace",%(thanosRuleSelector)s,grpc_type="server_stream"' % $._config)
        )
      )
      .addRow(
        g.row('Detailed')
        .addPanel(
          g.panel('Rate') +
          b.grpcQpsPanelDetailed('server', 'namespace="$namespace",%(thanosRuleSelector)s,grpc_type="server_stream"' % $._config)
        )
        .addPanel(
          g.panel('Errors') +
          b.grpcErrorDetailsPanel('server', 'namespace="$namespace",%(thanosRuleSelector)s,grpc_type="server_stream"' % $._config)
        )
        .addPanel(
          g.panel('Duration') +
          b.grpcLatencyPanelDetailed('server', 'namespace="$namespace",%(thanosRuleSelector)s,grpc_type="server_stream"' % $._config)
        ) +
        b.collapse
      )
      .addRow(
        g.row('Alert Sent')
        .addPanel(
          g.panel('Dropped Rate') +
          g.queryPanel(
            'sum(rate(thanos_alert_sender_alerts_dropped_total{namespace=~"$namespace",%(thanosRuleSelector)s}[$interval])) by (alertmanager)' % $._config,
            '{{alertmanager}}'
          )
        )
        .addPanel(
          g.panel('Sent Rate') +
          g.queryPanel(
            'sum(rate(thanos_alert_sender_alerts_sent_total{namespace=~"$namespace",%(thanosRuleSelector)s}[$interval])) by (alertmanager)' % $._config,
            '{{alertmanager}}'
          ) +
          g.stack
        )
        .addPanel(
          g.panel('Sent Errors') +
          g.queryPanel(
            |||
              sum(rate(thanos_alert_sender_errors_total{namespace=~"$namespace",%(thanosRuleSelector)s}[$interval]))
              /
              sum(rate(thanos_alert_sender_alerts_sent_total{namespace=~"$namespace",%(thanosRuleSelector)s}[$interval]))
            ||| % $._config,
            'error'
          ) +
          { aliasColors: { 'error': '#E24D42' } } +
          g.stack
        )
        .addPanel(
          g.panel('Sent Duration') +
          b.latencyPanel('thanos_alert_sender_latency_seconds', 'namespace=~"$namespace",%(thanosRuleSelector)s' % $._config),
        )
      )
      .addRow(
        g.row('Compaction')
        .addPanel(
          g.panel('Rate') +
          g.queryPanel(
            'sum(rate(prometheus_tsdb_compactions_total{namespace=~"$namespace",%(thanosRuleSelector)s}[$interval]))' % $._config,
            'compaction'
          )
        )
        .addPanel(
          g.panel('Errors') +
          g.queryPanel(
            'sum(rate(prometheus_tsdb_compactions_failed_total{namespace=~"$namespace",%(thanosRuleSelector)s}[$interval]))' % $._config,
            'error'
          ) +
          { aliasColors: { 'error': '#E24D42' } }
        )
        .addPanel(
          g.panel('Duration') +
          b.latencyPanel('prometheus_tsdb_compaction_duration_seconds', 'namespace=~"$namespace",%(thanosRuleSelector)s' % $._config)
        )
      )
      .addRow(
        g.row('Resources')
        .addPanel(
          g.panel('Memory Used') +
          g.queryPanel(
            [
              'go_memstats_alloc_bytes{namespace="$namespace",%(thanosRuleSelector)s,kubernetes_pod_name=~"$pod"}' % $._config,
              'go_memstats_heap_alloc_bytes{namespace="$namespace",%(thanosRuleSelector)s,kubernetes_pod_name=~"$pod"}' % $._config,
              'rate(go_memstats_alloc_bytes_total{namespace="$namespace",%(thanosRuleSelector)s,kubernetes_pod_name=~"$pod"}[30s])' % $._config,
              'rate(go_memstats_heap_alloc_bytes{namespace="$namespace",%(thanosRuleSelector)s,kubernetes_pod_name=~"$pod"}[30s])' % $._config,
              'go_memstats_stack_inuse_bytes{namespace="$namespace",%(thanosRuleSelector)s,kubernetes_pod_name=~"$pod"}' % $._config,
              'go_memstats_heap_inuse_bytes{namespace="$namespace",%(thanosRuleSelector)s,kubernetes_pod_name=~"$pod"}' % $._config,
            ],
            [
              'alloc all {{pod}}',
              'alloc heap {{pod}}',
              'alloc rate all {{pod}}',
              'alloc rate heap {{pod}}',
              'inuse stack {{pod}}',
              'inuse heap {{pod}}',
            ]
          )
        )
        .addPanel(
          g.panel('Goroutines') +
          g.queryPanel(
            'go_goroutines{namespace="$namespace",%(thanosRuleSelector)s}' % $._config,
            '{{pod}}'
          )
        )
        .addPanel(
          g.panel('GC Time Quantiles') +
          g.queryPanel(
            'go_gc_duration_seconds{namespace="$namespace",%(thanosRuleSelector)s,kubernetes_pod_name=~"$pod"}' % $._config,
            '{{quantile}} {{pod}}'
          )
        )
        + { collapse: true }
      ) +
      b.podTemplate('namespace="$namespace",created_by_name=~"%(thanosRule)s.*"' % $._config),
  },
}
