#
# Cookbook: poise-service-aix
# License: Apache 2.0
#
# Copyright 2015, Noah Kantrowitz
# Copyright 2015-2017, Bloomberg Finance L.P.
#

module PoiseService
  # A plugin for poise-service to manage AIX inittab.
  # @since 1.0.0
  module AIX
    autoload :Provider, 'poise_service/aix/provider'
    autoload :VERSION, 'poise_service/aix/version'
  end
end
