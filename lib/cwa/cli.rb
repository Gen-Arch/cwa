require 'cwa'
require 'thor'
require 'terminal-table'
require 'colorize'

OUTPUT_KEYS = %i(
  namespace
  alarm_name
  actions_enabled
  dimensions
  alarm_arn
  alarm_description
)


AWS_OPTIONS = %i(
  profile
  region
)

OPTIONS = "--name ALARMNAME --regexp ALARMNAME --namespae NAMESPACE --dimensions KEY:VALUE"

module CWA
  class Cli < Thor
    class_option :verbose, type: :boolean
    class_option :profile, type: :string
    class_option :region,  type: :string

    desc "alarms  #{OPTIONS}", "show cloudwatch alms"
    option :name,       type: :string, aliases: "n"
    option :namespace,  type: :string, aliases: "s"
    option :regexp,     type: :string, aliases: "r"
    option :dimensions, type: :hash,   aliases: "d"
    def alarms
      begin
        alms  = _output_alms
        raise "not alarms" if alms.empty?

        head  = alms.first.keys
        rows  = alms.map{|alm| alm.values }
        table = Terminal::Table.new :headings => head, :rows => rows

        puts table
      rescue => err
        puts "error => #{err}".colorize(:red)
        exit 1
      end
    end

    desc "enable  #{OPTIONS}", "enable cloudwatch alms"
    option :name,       type: :string, aliases: "n"
    option :namespace,  type: :string, aliases: "s"
    option :regexp,     type: :string, aliases: "r"
    option :dimensions, type: :hash,   aliases: "d"
    def enable
      begin
        cwa  = CWA.get(options)
        alms = cwa.alarms(options)
        alms = _check_alm(alms, :enable)

        raise "not alarms" if alms.empty?
        _confirm("cloudwatch alarm enable?")

        alms.each do |alm|
          cwa.enable(alm)
          puts "#{'done'.colorize(:green)} => #{alm[:alarm_name]}"
        end
        puts
        alarms
      rescue => err
        puts "error => #{err}".colorize(:red)
        exit 1
      end
    end

    desc "disable #{OPTIONS}", "disable cloudwatch alms"
    option :name,       type: :string, aliases: "n"
    option :namespace,  type: :string, aliases: "s"
    option :regexp,     type: :string, aliases: "r"
    option :dimensions, type: :hash,   aliases: "d"
    def disable
      begin
        cwa  = CWA.get(options)
        alms = cwa.alarms(options)
        alms = _check_alm(alms, :disable)

        raise "not alarms" if alms.empty?
        _confirm("cloudwatch alarm disable?")

        alms.each do |alm|
          cwa.disable(alm)
          puts "#{'done'.colorize(:green)} => #{alm[:alarm_name]}"
        end
        puts
        alarms
      rescue => err
        puts "error => #{err}".colorize(:red)
        exit 1
      end
    end

    private
    def _output_alms
      cwa  = CWA.get(options)
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
