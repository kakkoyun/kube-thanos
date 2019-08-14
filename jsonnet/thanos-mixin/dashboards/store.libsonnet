local g = import '../lib/thanos-grafana-builder/builder.libsonnet';

{
  grafanaDashboards+:: {
    'store.json':
      g.dashboard($._config.grafanaThanos.dashboardStoreTitle)
      .addTemplate('namespace', 'kube_pod_info', 'namespace')
      .addRow(
        g.row('gRPC (Unary)')
        .addPanel(
          g.panel('Rate') +
          g.grpcQpsPanel('server', 'namespace="$namespace",%(thanosStoreSelector)s,grpc_type="unary"' % $._config)
        )
        .addPanel(
          g.panel('Errors') +
          g.grpcErrorsPanel('server', 'namespace="$namespace",%(thanosStoreSelector)s,grpc_type="unary"' % $._config)
        )
        .addPanel(
          g.panel('Duration') +
          g.grpcLatencyPanel('server', 'namespace="$namespace",%(thanosStoreSelector)s,grpc_type="unary"' % $._config)
        )
      )
      .addRow(
        g.row('Detailed')
        .addPanel(
          g.panel('Rate') +
          g.grpcQpsPanelDetailed('server', 'namespace="$namespace",%(thanosStoreSelector)s,grpc_type="unary"' % $._config)
        )
        .addPanel(
          g.panel('Errors') +
          g.grpcErrDetailsPanel('server', 'namespace="$namespace",%(thanosStoreSelector)s,grpc_type="unary"' % $._config)
        )
        .addPanel(
          g.panel('Duration') +
          g.grpcLatencyPanelDetailed('server', 'namespace="$namespace",%(thanosStoreSelector)s,grpc_type="unary"' % $._config)
        ) +
        g.collapse
      )
      .addRow(
        g.row('gRPC (Stream)')
        .addPanel(
          g.panel('Rate') +
          g.grpcQpsPanel('server', 'namespace="$namespace",%(thanosStoreSelector)s,grpc_type="server_stream"' % $._config)
        )
        .addPanel(
          g.panel('Errors') +
          g.grpcErrorsPanel('server', 'namespace="$namespace",%(thanosStoreSelector)s,grpc_type="server_stream"' % $._config)
        )
        .addPanel(
          g.panel('Duration') +
          g.grpcLatencyPanel('server', 'namespace="$namespace",%(thanosStoreSelector)s,grpc_type="server_stream"' % $._config)
        )
      )
      .addRow(
        g.row('Detailed')
        .addPanel(
          g.panel('Rate') +
          g.grpcQpsPanelDetailed('client', 'namespace="$namespace",%(thanosStoreSelector)s,grpc_type="server_stream"' % $._config)
        )
        .addPanel(
          g.panel('Errors') +
          g.grpcErrDetailsPanel('client', 'namespace="$namespace",%(thanosStoreSelector)s,grpc_type="server_stream"' % $._config)
        )
        .addPanel(
          g.panel('Duration') +
          g.grpcLatencyPanelDetailed('client', 'namespace="$namespace",%(thanosStoreSelector)s,grpc_type="server_stream"' % $._config)
        ) +
        g.collapse
      )
      .addRow(
        g.row('Bucket Operations')
        .addPanel(
          g.panel('Rate') +
          g.queryPanel(
            'sum(rate(thanos_objstore_bucket_operations_total{namespace="$namespace",%(thanosStoreSelector)s}[$interval])) by (operation)' % $._config,
            '{{operation}}'
          ) +
          g.stack
        )
        .addPanel(
          g.panel('Errors') +
          g.qpsErrTotalPanel(
            'thanos_objstore_bucket_operation_failures_total{namespace="$namespace",%(thanosStoreSelector)s}' % $._config,
            'thanos_objstore_bucket_operations_total{namespace="$namespace",%(thanosStoreSelector)s}' % $._config,
          )
        )
        .addPanel(
          g.panel('Duration') +
          g.latencyPanel('thanos_objstore_bucket_operation_duration_seconds', 'namespace="$namespace",%(thanosStoreSelector)s' % $._config,)
        )
      )
      .addRow(
        g.row('Block Operations')
        .addPanel(
          g.panel('Block Load Rate') +
          g.queryPanel(
            'sum(rate(thanos_bucket_store_block_loads_total{namespace="$namespace",%(thanosStoreSelector)s}[$interval]))' % $._config,
            'block loads'
          ) +
          g.stack
        )
        .addPanel(
          g.panel('Block Load Errors') +
          g.qpsErrTotalPanel(
            'thanos_bucket_store_block_load_failures_total{namespace="$namespace",%(thanosStoreSelector)s}' % $._config,
            'thanos_bucket_store_block_loads_total{namespace="$namespace",%(thanosStoreSelector)s}' % $._config,
          )
        )
        .addPanel(
          g.panel('Block Drop Rate') +
          g.queryPanel(
            'sum(rate(thanos_bucket_store_block_drops_total{namespace="$namespace",%(thanosStoreSelector)s}[$interval])) by (operation)' % $._config,
            'block drops'
          ) +
          g.stack
        )
        .addPanel(
          g.panel('Block Drop Errors') +
          g.qpsErrTotalPanel(
            'thanos_bucket_store_block_drop_failures_total{namespace="$namespace",%(thanosStoreSelector)s}' % $._config,
            'thanos_bucket_store_block_drops_total{namespace="$namespace",%(thanosStoreSelector)s}' % $._config,
          )
        )
      )
      .addRow(
        g.row('Cache Operations')
        .addPanel(
          g.panel('Requests') +
          g.queryPanel(
            'sum(rate(thanos_store_index_cache_requests_total{namespace="$namespace",%(thanosStoreSelector)s}[$interval])) by (namespace, item_type)' % $._config,
            '{{item_type}}',
          ) +
          g.stack
        )
        .addPanel(
          g.panel('Hits') +
          g.queryPanel(
            'sum(rate(thanos_store_index_cache_hits_total{namespace="$namespace",%(thanosStoreSelector)s}[$interval])) by (namespace, item_type)' % $._config,
            '{{item_type}}',
          ) +
          g.stack
        )
        .addPanel(
          g.panel('Added') +
          g.queryPanel(
            'sum(rate(thanos_store_index_cache_items_added_total{namespace="$namespace",%(thanosStoreSelector)s}[$interval])) by (namespace, item_type)' % $._config,
            '{{item_type}}',
          ) +
          g.stack
        )
        .addPanel(
          g.panel('Evicted') +
          g.queryPanel(
            'sum(rate(thanos_store_index_cache_items_evicted_total{namespace="$namespace",%(thanosStoreSelector)s}[$interval])) by (namespace, item_type)' % $._config,
            '{{item_type}}',
          ) +
          g.stack
        )
      )
      .addRow(
        g.row('Store Sent')
        .addPanel(
          g.panel('Chunk Size') +
          g.queryPanel(
            [
              'histogram_quantile(0.99, sum(rate(thanos_bucket_store_sent_chunk_size_bytes_bucket{namespace="$namespace",%(thanosStoreSelector)s}[$interval])) by (le))' % $._config,
              'sum(rate(thanos_bucket_store_sent_chunk_size_bytes_sum{namespace="$namespace",%(thanosStoreSelector)s}[$interval])) / sum(rate(thanos_bucket_store_sent_chunk_size_bytes_count{namespace="$namespace",%(thanosStoreSelector)s}[$interval]))' % $._config,
              'histogram_quantile(0.99, sum(rate(thanos_bucket_store_sent_chunk_size_bytes_bucket{namespace="$namespace",%(thanosStoreSelector)s}[$interval])) by (le))' % $._config,
            ],
            [
              'P99',
              'mean',
              'P50',
            ],
          )
        ) +
        { yaxes: g.yaxes('decbytes') },
      )
      .addRow(
        g.row('Series Operations')
        .addPanel(
          g.panel('Block queried') +
          g.queryPanel(
            [
              'thanos_bucket_store_series_blocks_queried{namespace="$namespace",%(thanosStoreSelector)s,quantile="0.99"}' % $._config,
              'sum(rate(thanos_bucket_store_series_blocks_queried_sum{namespace="$namespace",%(thanosStoreSelector)s}[$interval])) / sum(rate(thanos_bucket_store_series_blocks_queried_count{namespace="$namespace",%(thanosStoreSelector)s}[$interval]))' % $._config,
              'thanos_bucket_store_series_blocks_queried{namespace="$namespace",%(thanosStoreSelector)s,quantile="0.50"}' % $._config,
            ], [
              'P99',
              'mean',
              'P50',
            ],
          )
        )
        .addPanel(
          g.panel('Data Fetched') +
          g.queryPanel(
            [
              'thanos_bucket_store_series_data_fetched{namespace="$namespace",%(thanosStoreSelector)s,quantile="0.99"}' % $._config,
              'sum(rate(thanos_bucket_store_series_data_fetched_sum{namespace="$namespace",%(thanosStoreSelector)s}[$interval])) / sum(rate(thanos_bucket_store_series_data_fetched_count{namespace="$namespace",%(thanosStoreSelector)s}[$interval]))' % $._config,
              'thanos_bucket_store_series_data_fetched{namespace="$namespace",%(thanosStoreSelector)s,quantile="0.50"}' % $._config,
            ], [
              'P99',
              'mean',
              'P50',
            ],
          )
        )
        .addPanel(
          g.panel('Result series') +
          g.queryPanel(
            [
              'thanos_bucket_store_series_result_series{namespace="$namespace",%(thanosStoreSelector)s,quantile="0.99"}' % $._config,
              'sum(rate(thanos_bucket_store_series_result_series_sum{namespace="$namespace",%(thanosStoreSelector)s}[$interval])) / sum(rate(thanos_bucket_store_series_result_series_count{namespace="$namespace",%(thanosStoreSelector)s}[$interval]))' % $._config,
              'thanos_bucket_store_series_result_series{namespace="$namespace",%(thanosStoreSelector)s,quantile="0.50"}' % $._config,
            ], [
              'P99',
              'mean',
              'P50',
            ],
          )
        )
      )
      .addRow(
        g.row('Series Operation Durations')
        .addPanel(
          g.panel('Get All') +
          g.latencyPanel('thanos_bucket_store_series_get_all_duration_seconds', 'namespace="$namespace",%(thanosStoreSelector)s' % $._config,)
        )
        .addPanel(
          g.panel('Merge') +
          g.latencyPanel('thanos_bucket_store_series_merge_duration_seconds_bucket', 'namespace="$namespace",%(thanosStoreSelector)s' % $._config,)
        )
        .addPanel(
          g.panel('Gate') +
          g.latencyPanel('thanos_bucket_store_series_gate_duration_seconds_bucket', 'namespace="$namespace",%(thanosStoreSelector)s' % $._config,)
        )
      )
      .addRow(
        g.resourceUtilizationRow('%(thanosStoreSelector)s' % $._config)
      ) +
      g.podTemplate('namespace="$namespace",created_by_name=~"%(thanosStore)s.*"' % $._config),
  },
}
