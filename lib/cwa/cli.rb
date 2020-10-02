require 'cwa'
require 'thor'
require 'terminal-table'


OUTPUT_KEYS = [
  :alarm_name,
  :actions_enabled,
  :dimensions,
  :alarm_arn,
  :alarm_description,
]

module CWA
  class Cli < Thor
    class_option :verbose, :type => :boolean

    desc "alams   --name ALARMNAME --ambiguous ALARMNAME --namespae NAMESPACE --dimensions KEY:VALUE", "show cloudwatch alms"
    option :name
    option :ambiguous
    option :namespace
    option :dimensions
    def alarms
      cwa  = CWA.get
      alms = cwa.alarms(options)

      alms = alms.map do |alm|
        v = Hash.new
        OUTPUT_KEYS.each do |key|
          v[key] = alm.method(key).call
        end
        v
      end

      head = alms.first.keys
      rows = alms.map{|alm| alm.values }
      table = Terminal::Table.new :headings => head, :rows => rows
      puts table
    end

    desc "enable  --name ALARMNAME --namespae NAMESPACE --dimensions KEY:VALUE", "enable cloudwatch alms"
    option :name
    option :namespace
    option :dimensions
    def enable
      cwa  = CWA.get
      cwa.alarms(options).each do |alm|
        cwa.enable(alm)
      end
    end

    desc "disable --name ALARMNAME --namespae NAMESPACE --dimensions KEY:VALUE", "disable cloudwatch alms"
    option :name
    option :namespace
    option :dimensions
    def disable
      cwa  = CWA.get
      cwa.alarms(options).each do |alm|
        cwa.disable(alm)
      end
    end
  end
end
