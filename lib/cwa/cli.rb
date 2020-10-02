require 'cwa'
require 'thor'
require 'terminal-table'
require 'colorize'


OUTPUT_KEYS = [
  :namespace,
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
      alms  = _output_alms
      head  = alms.first.keys
      rows  = alms.map{|alm| alm.values }
      table = Terminal::Table.new :headings => head, :rows => rows

      puts table
    end

    desc "enable  --name ALARMNAME --namespae NAMESPACE --dimensions NAME:VALUE", "enable cloudwatch alms"
    option :name
    option :namespace
    option :dimensions
    def enable
      cwa  = CWA.get
      alms = cwa.alarms(options)
      alms = _check_alm(alms, :enable)

      exit(0) if alms.empty?
      _confirm("cloudwatch alarm enable?")

      alms.each do |alm|
        cwa.enable(alm)
        puts "#{'done'.colorize(:green)} => #{alm[:alarm_name]}"
      end
      puts
      alarms
    end

    desc "disable --name ALARMNAME --namespae NAMESPACE --dimensions KEY:VALUE", "disable cloudwatch alms"
    option :name
    option :namespace
    option :dimensions
    def disable
      cwa  = CWA.get
      alms = cwa.alarms(options)
      alms = _check_alm(alms, :disable)

      exit(0) if alms.empty?
      _confirm("cloudwatch alarm disable?")

      alms.each do |alm|
        cwa.disable(alm)
        puts "#{'done'.colorize(:green)} => #{alm[:alarm_name]}"
      end
      puts
      alarms
    end

    private

    def _output_alms
      cwa  = CWA.get
      alms = cwa.alarms(options)

      alms.map do |alm|
        v = Hash.new
        OUTPUT_KEYS.each do |key|
          v[key] = alm.method(key).call
        end
        v
      end
    end

    def _check_alm(alms, mode)
      check = false if mode == :enable
      check = true  if mode == :disable
      alms.map do |alm|
        puts "-" * 50
        puts "namespace       : #{alm[:namespace      ]}"
        puts "alarm_name      : #{alm[:alarm_name     ]}"
        puts "dimensions      : #{alm[:dimensions     ]}"
        puts "actions_enabled : #{alm[:actions_enabled]}"
        unless alm[:actions_enabled] == check
          puts "=> #{'skip'.colorize(:yellow)}"
          puts "-" * 50
          next
        end
        puts "-" * 50
        alm
      end.compact
    end

    def _confirm(check_word, **opt)
      true_word  = ( opt[:true] || /yes|y/ )
      false_word = ( opt[:false] || /no/ )

      while true
        print "#{check_word} (#{true_word.inspect.delete("/")}/#{false_word.inspect.delete("/")}) : "
        case anser = $stdin.gets.strip
        when true_word then return true
        when false_word then return false
        end
      end
    end
  end
end
