require "cwa/client"
require "cwa/version"

module CWA
  class Error < StandardError; end

  class << self
    def configure(**opts)
      @aws_opts = opts
    end

    def get
      @aws_opts = {} unless @aws_opts
      Client.new(@aws_opts)
    end
  end
end
