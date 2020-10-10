# frozen_string_literal: true

module CWA
  class Alarms
    class Error < StandardError; end

    DEFAULT_OPTS = {
      alarm_name_prefix: '*',
      max_records:       100
    }.freeze

    def initialize(client, **opts)
      @opts   = opts
      @client = client
    end

    def filter(query)
      alms = alarms

      # querys
      name_query       = ->(alm) { alm.alarm_name == query[:name]        }
      regexp_query     = ->(alm) { alm.alarm_name =~ /#{query[:regexp]}/ }
      namespace_query  = ->(alm) { alm.namespace  == query[:namespace]   }

      alms = alms.select(&name_query)             if query[:name      ]
      alms = alms.select(&regexp_query)           if query[:regexp    ]
      alms = alms.select(&namespace_query)        if query[:namespace ]
      alms = dimension?(alms, query[:dimensions]) if query[:dimensions]
      alms
    end

    def refresh
      @alms = nil
      alarms
    end

    private
    def alarms(**opts)
      opts = DEFAULT_OPTS unless opts

      unless @alms
        @alms      = Array.new
        alms       = @client.describe_alarms(opts)
        next_token = alms.next_token
        @alms     << alms

        while next_token
          opts[:next_token] = next_token
          alms              = @client.describe_alarms(opts)
          next_token        = alms.next_token

          @alms << alms
        end
      end

      @alms.map {|e| e.metric_alarms }.flatten
    end

    def dimension?(alms, dimensions)
      alms.select do |alm|
        alm.dimensions.any? do |dims|
          dimensions.keys.any?(dims.name) && dimensions.values.any?(dims.value)
        end
      end
    end
  end
end

