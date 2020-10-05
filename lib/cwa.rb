require "cwa/client"
require "cwa/version"

module CWA
  class Error < StandardError; end

  class << self
    def configure(**opts)
      @aws_opts = opts
    end

    def get(opts = {})
      @aws_opts         ||= {}
      @aws_opts[:profile] = opts[:profile] if opts[:profile]
      @aws_opts[:region]  = opts[:profile] if opts[:region]

      Client.new(@aws_opts)
    end
  end
end
