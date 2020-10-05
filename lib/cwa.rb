require 'aws-sdk-core'
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
      @aws_opts[:region]  = opts[:region ] if opts[:region]

      Client.new(@aws_opts)
    end

    def assume_role(opts)
      role_credentials = Aws::AssumeRoleCredentials.new(
        client: Aws::STS::Client.new(opts),
        role_arn: opts[:arn],
        role_session_name: opts[:session_name]
      )
      @aws_opts[:credentials] = role_credentials
    end
  end
end
