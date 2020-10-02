require 'aws-sdk-cloudwatch'
require "cwa/alarms"

module CWA
  class Client
    class Error < StandardError; end

    def initialize(opts)
      @client = Aws::CloudWatch::Client.new(opts)
    end

    def alarms(query)
      @alarms ||= Alarms.new(@client)
      alms      = @alarms.filter(query)
      if block_given?
        alms.each{|alm| yield alm }
      end
      alms
    end

    def enable(alm)
      alm = alm[:alarm_name]
      @client.enable_alarm_actions({alarm_names: [alm] })
    end

    def disable(alm)
      alm = alm[:alarm_name]
      @client.disable_alarm_actions({alarm_names: [alm] })
    end
  end
end
