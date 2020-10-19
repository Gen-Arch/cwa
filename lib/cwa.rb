# frozen_string_literal: true

require 'aws-sdk-core'
require 'cwa/client'
require 'cwa/version'

#--
# Copyright (c) 2021 Ito Toshifumi
# cloudwatch alarm cli
#++
module CWA
  class Error < StandardError; end

  class << self
    def get(opts = {})
      Client.new(opts)
    end
  end
end
