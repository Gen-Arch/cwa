# frozen_string_literal: true

require 'cwa'
require 'thor'
require 'terminal-table'
require 'colorize'
require 'yaml'
require 'fileutils'

ASSUME_DIR  = File.join(Dir.home,   '.config', 'cwa').freeze
ASSUME_FILE = File.join(ASSUME_DIR, 'assume.yml').freeze

OUTPUT_KEYS = %i[
  namespace
  alarm_name
  actions_enabled
  dimensions
  alarm_arn
  alarm_description
].freeze


AWS_OPTIONS = %i[
  profile
  region
].freeze

OPTIONS = '--name ALARMNAME --regexp ALARMNAME --namespae NAMESPACE --dimensions KEY:VALUE'.freeze

module CWA
  # cli class
  class Cli < Thor
    begin
    class_option :verbose,      type: :boolean
    class_option :profile,      type: :string
    class_option :region,       type: :string
    class_option :assume_role,  type: :string

    desc "alarms  #{OPTIONS}", 'show cloudwatch alms'
    option :name,       type: :string, aliases: 'n'
    option :namespace,  type: :string, aliases: 's'
    option :regexp,     type: :string, aliases: 'r'
    option :dimensions, type: :hash,   aliases: 'd'
    def alarms
      enable_assume if options[:assume_role]

      alms  = output_alms
      raise 'not alarms' if alms.empty?

      head  = alms.first.keys
      rows  = alms.map{|alm| alm.values }
      table = Terminal::Table.new :headings => head, :rows => rows

      puts table
    end

    desc "enable  #{OPTIONS}", 'enable cloudwatch alms'
    option :name,       type: :string, aliases: 'n'
    option :namespace,  type: :string, aliases: 's'
    option :regexp,     type: :string, aliases: 'r'
    option :dimensions, type: :hash,   aliases: 'd'
    def enable
      begin
        enable_assume if options[:assume_role]

        cwa  = CWA.get(options)
        alms = cwa.alarms(options)
        alms = check_alm(alms, :enable)

        raise 'not alarms' if alms.empty?

        confirm('cloudwatch alarm enable?')

        alms.each do |alm|
          cwa.enable(alm)
          puts "#{'done'.colorize(:green)} => #{alm[:alarm_name]}"
        end
        puts
        alarms
      rescue StandardError => e
        puts "error => #{e}".colorize(:red)
        exit 1
      end
    end

    desc "disable #{OPTIONS}", 'disable cloudwatch alms'
    option :name,       type: :string, aliases: 'n'
    option :namespace,  type: :string, aliases: 's'
    option :regexp,     type: :string, aliases: 'r'
    option :dimensions, type: :hash,   aliases: 'd'
    def disable
      begin
        _enable_assume if options[:assume_role]

        cwa  = CWA.get(options)
        alms = cwa.alarms(options)
        alms = check_alm(alms, :disable)

        raise 'not alarms' if alms.empty?

        confirm('cloudwatch alarm disable?')

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

    desc 'configure', 'create config files'
    def configure
      configs     = %w[assume_role]

      puts configs
      print "create type? : "
      type = $stdin.gets.strip
      case type
      when 'assume_role'
        print "name?         : "
        name    = $stdin.gets.strip
        print "arn?          : "
        arn     = $stdin.gets.strip
        print "session_name? : "
        session = $stdin.gets.strip

        assume = {name => { arn: arn, session_name: session}}
        FileUtils.mkdir_p(ASSUME_DIR) unless Dir.exist?(ASSUME_DIR)
        file = open(ASSUME_FILE, "w")
        YAML.dump(assume, file)
        puts "create => #{ASSUME_FILE.colorize(:yellow)}"
      end
    end
      rescue StandardError => e
        puts "error => #{e}".colorize(:red)
        exit 1
      end

    private
    def output_alms
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

    def enable_assume
      raise 'not config file, pls "cwa configure"' unless File.exist?(ASSUME_FILE)

      assume = YAML.load_file(ASSUME_FILE)[options[:assume_role]]
      CWA.assume_role(assume)
    end

    def check_alm(alms, mode)
      check = false if mode == :enable
      check = true  if mode == :disable
      alms.map do |alm|
        puts '-' * 50
        puts "namespace       : #{alm[:namespace]}"
        puts "alarm_name      : #{alm[:alarm_name]}"
        puts "dimensions      : #{alm[:dimensions]}"
        puts "actions_enabled : #{alm[:actions_enabled]}"
        unless alm[:actions_enabled] == check
          puts "=> #{'skip'.colorize(:yellow)}"
          puts '-' * 50
          next
        end
        puts '-' * 50
        alm
      end.compact
    end

    def confirm(check_word, **_opt)
      true_word  = /yes|y/
      false_word = /no/

      while true
        print "#{check_word} (#{true_word.inspect.delete('/')}/#{false_word.inspect.delete('/')}) : "
        case $stdin.gets.strip
        when true_word  then return true
        when false_word then return false
        end
      end
    end
  end
end
