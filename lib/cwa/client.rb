# frozen_string_literal: true

require 'aws-sdk-cloudwatch'
require 'cwa/alarms'

module CWA
  # AWS client class
  class Client
    class Error < StandardError; end

    def initialize(opts)
      @client = Aws::CloudWatch::Client.new(opts)
    end

    def alarms(query)
      @alarms ||= Alarms.new(@client)
      alms      = @alarms.filter(query)
      alms.each { |alm| yield alm } if block_given?
      alms
    end

    def refresh
      @alarms.refresh
    end

    def enable(alm)
      alm = alm[:alarm_name]
      @client.enable_alarm_actions({ alarm_names: [alm] })
    end

    def disable(alm)
      alm = alm[:alarm_name]
      @client.disable_alarm_actions({ alarm_names: [alm] })
    end
  end
end
