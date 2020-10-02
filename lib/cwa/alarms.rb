module CWA
  class Alarms
    class Error < StandardError; end

    def initialize(client, **opts)
      @opts   = opts
      @client = client
    end

    def alarms(**opts)
      opts[:alarm_name_prefix] = "*" unless opts
      @alms ||= @client.describe_alarms(opts)
    end

    def filter(query)
      pp query
      alms = alarms.metric_alarms

      # querys
      name_query       = ->(alm) { alm.alarm_name == query[:name]           }
      ambiguous_query  = ->(alm) { alm.alarm_name =~ /#{query[:ambiguous]}/ }
      namespace_query  = ->(alm) { alm.namespace  == query[:namespace]      }

      alms = alms.select(&name_query)              if query[:name      ]
      alms = alms.select(&ambiguous_query)         if query[:ambiguous ]
      alms = alms.select(&namespace_query)         if query[:namespace ]
      alms = _dimension?(alms, query[:dimensions]) if query[:dimensions]
      alms
    end

    def refresh
      @alms = nil
      alarms
    end

    private
    def _dimension?(alms, dimensions)
      alms.select do |alm|
        alm.dimensions.any? do |dims|
          dimensions.keys.any?(dims.name.to_sym) && dimensions.values.any?(dims.value)
        end
      end
    end
  end
end

