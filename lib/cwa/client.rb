# frozen_string_literal: true

require 'aws-sdk-cloudwatch'
require 'cwa/alarms'

module CWA
  # AWS client class
  class Client
    class Error < StandardError; end

    def initialize(opts)
      if opts[:assume_role]
        role = opts.delete(:assume_role)
        opts[:credentials] = assume_role(role)
      end

      @client = Aws::CloudWatch::Client.new(opts)
    end

    def alarms(query)
      @alarms ||= Alarms.new(@client)
      alms      = @alarms.filter(query)
      alms.each { |alm| yield alm } if block_given?

      @query_cache = query
      alms
    end

    def update(cache: true)
      if cache
        @alarms.refresh(@query_cache)
      else
        @alarms.refresh
      end
    end

    def enable(alm)
      alm = alm[:alarm_name]
      @client.enable_alarm_actions({ alarm_names: [alm] })
    end

    def disable(alm)
      alm = alm[:alarm_name]
      @client.disable_alarm_actions({ alarm_names: [alm] })
    end

    private
    def assume_role(opts)
      Aws::AssumeRoleCredentials.new(
        client: Aws::STS::Client.new,
        role_arn: opts[:arn],
        role_session_name: opts[:session_name]
      )
    end
  end
end
