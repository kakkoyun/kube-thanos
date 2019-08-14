local g = import '../lib/thanos-grafana-builder/builder.libsonnet';

{
  grafanaDashboards+:: {
    'receive.json':
      g.dashboard($._config.grafanaThanos.dashboardReceiveTitle)
      .addTemplate('namespace', 'kube_pod_info', 'namespace')
      .addRow(
        g.row('Incoming Request')
        .addPanel(
          g.panel('Rate') +
          g.httpQpsPanel('thanos_http_requests_total', 'namespace="$namespace",%(thanosReceiveSelector)s' % $._config)
        )
        .addPanel(
          g.panel('Errors') +
          g.httpErrPanel('thanos_http_requests_total', 'namespace="$namespace",%(thanosReceiveSelector)s' % $._config)
        )
        .addPanel(
          g.panel('Duration') +
          g.latencyPanel('thanos_http_request_duration_seconds', 'namespace="$namespace",%(thanosReceiveSelector)s' % $._config)
        )
      )
      .addRow(
        g.row('Detailed')
        .addPanel(
          g.panel('Rate') +
          g.httpQpsPanelDetailed('thanos_http_requests_total', 'namespace="$namespace",%(thanosReceiveSelector)s' % $._config)
        )
        .addPanel(
          g.panel('Errors') +
          g.httpErrDetailsPanel('thanos_http_requests_total', 'namespace="$namespace",%(thanosReceiveSelector)s' % $._config)
        )
        .addPanel(
          g.panel('Duration') +
          g.httpLatencyDetailsPanel('thanos_http_request_duration_seconds', 'namespace="$namespace",%(thanosReceiveSelector)s' % $._config)
        ) +
        g.collapse
      )
      .addRow(
        g.row('Forward Request')
        .addPanel(
          g.panel('Rate') +
          g.queryPanel(
            'sum(rate(thanos_receive_forward_requests_total{namespace="$namespace",%(thanosReceiveSelector)s}[$interval]))' % $._config,
            'all',
          )
        )
        .addPanel(
          g.panel('Errors') +
          g.qpsErrTotalPanel(
            'thanos_receive_forward_requests_total{namespace="$namespace",%(thanosReceiveSelector)s,result="error"}' % $._config,
            'thanos_receive_forward_requests_total{namespace="$namespace",%(thanosReceiveSelector)s}' % $._config,
          )
        )
      )
      .addRow(
        g.row('gRPC (Unary)')
        .addPanel(
          g.panel('Rate') +
          g.grpcQpsPanel('server', 'namespace="$namespace",%(thanosReceiveSelector)s,grpc_type="unary"' % $._config)
        )
        .addPanel(
          g.panel('Errors') +
          g.grpcErrorsPanel('server', 'namespace="$namespace",%(thanosReceiveSelector)s,grpc_type="unary"' % $._config)
        )
        .addPanel(
          g.panel('Duration') +
          g.grpcLatencyPanel('server', 'namespace="$namespace",%(thanosReceiveSelector)s,grpc_type="unary"' % $._config)
        )
      )
      .addRow(
        g.row('Detailed')
        .addPanel(
          g.panel('Rate') +
          g.grpcQpsPanelDetailed('server', 'namespace="$namespace",%(thanosReceiveSelector)s,grpc_type="unary"' % $._config)
        )
        .addPanel(
          g.panel('Errors') +
          g.grpcErrDetailsPanel('server', 'namespace="$namespace",%(thanosReceiveSelector)s,grpc_type="unary"' % $._config)
        )
        .addPanel(
          g.panel('Duration') +
          g.grpcLatencyPanelDetailed('server', 'namespace="$namespace",%(thanosReceiveSelector)s,grpc_type="unary"' % $._config)
        ) +
        g.collapse
      )
      .addRow(
        g.row('gRPC (Stream)')
        .addPanel(
          g.panel('Rate') +
          g.grpcQpsPanel('server', 'namespace="$namespace",%(thanosReceiveSelector)s,grpc_type="server_stream"' % $._config)
        )
        .addPanel(
          g.panel('Errors') +
          g.grpcErrorsPanel('server', 'namespace="$namespace",%(thanosReceiveSelector)s,grpc_type="server_stream"' % $._config)
        )
        .addPanel(
          g.panel('Duration') +
          g.grpcLatencyPanel('server', 'namespace="$namespace",%(thanosReceiveSelector)s,grpc_type="server_stream"' % $._config)
        )
      )
      .addRow(
        g.row('Detailed')
        .addPanel(
          g.panel('Rate') +
          g.grpcQpsPanelDetailed('server', 'namespace="$namespace",%(thanosReceiveSelector)s,grpc_type="server_stream"' % $._config)
        )
        .addPanel(
          g.panel('Errors') +
          g.grpcErrDetailsPanel('server', 'namespace="$namespace",%(thanosReceiveSelector)s,grpc_type="server_stream"' % $._config)
        )
        .addPanel(
          g.panel('Duration') +
          g.grpcLatencyPanelDetailed('server', 'namespace="$namespace",%(thanosReceiveSelector)s,grpc_type="server_stream"' % $._config)
        ) +
        g.collapse
      )
      .addRow(
        g.row('Last Updated')
        .addPanel(
          g.panel('Successful Upload') +
          g.tablePanel(
            ['time() - max(thanos_objstore_bucket_last_successful_upload_time{namespace="$namespace",%(thanosReceiveSelector)s}) by (bucket)' % $._config],
            {
              Value: {
                alias: 'Uploaded Ago',
                unit: 's',
                type: 'number',
              },
            },
          )
        )
      )
      .addRow(
        g.resourceUtilizationRow('%(thanosReceiveSelector)s' % $._config)
      ) +
      g.podTemplate('namespace="$namespace",created_by_name=~"%(thanosReceive)s.*"' % $._config),
  },
}
