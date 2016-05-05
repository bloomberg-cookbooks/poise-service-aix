#
# Cookbook: poise-service-aix
# License: Apache 2.0
#
# Copyright 2015, Noah Kantrowitz
# Copyright 2015-2016, Bloomberg Finance L.P.
#

require 'chef/mash'

require 'poise_service/error'
require 'poise_service/service_providers/base'

module PoiseService
  module ServiceProviders
    # Poise-service provider for AIX.
    # @since 1.0
    class Provider < Base
      include Chef::Mixin::ShellOut
      provides(:aix_service)

      # proritize this provider on aix
      Chef::Platform::ProviderPriorityMap.instance.priority(:poise_service, [self])

      DEFAULT_RUN_LEVEL = '2'
      DEFAULT_PROCESS_ACTION = 'once'

      def self.provides_auto?(node, _)
        node['platform_family'] == 'aix'
      end

      # Parse the PID from `lssrc -s <name>` output.
      # @return [Integer]
      def pid
        service = shell_out!("lssrc -s #{@new_resource.service_name}").stdout
        service.split(' ')[-1].to_i
      end

      def action_reload
        if service_resource.current_value.running
          Chef::Log.info("Reloading AIX service #{new_resource.service_name} by restarting")
          action_restart
        else
          Chef::Log.info("Reloading AIX service #{new_resource.service_name} - not running ")
        end
      end

      private

      def create_service
        Chef::Log.debug("Creating aix service #{new_resource.service_name}")
        command = new_resource.command.split(' ')
        aix_subsystem new_resource.service_name do
          program command.first
          arguments command.drop(1).join(' ')
          user new_resource.user
          auto_restart true
        end
      end

      def enable_service
        Chef::Log.debug("Enabling aix service #{new_resource.service_name}")
        aix_inittab new_resource.service_name do
          runlevel options['runlevel'] ||= DEFAULT_RUN_LEVEL
          processaction options['processaction'] ||= DEFAULT_PROCESS_ACTION
          command "/usr/bin/startsrc -s #{new_resource.service_name} >/dev/console 2>&1"
        end
      end

      def disable_service
        Chef::Log.debug("Disabling aix service #{new_resource.service_name}")
        aix_inittab new_resource.service_name do
          runlevel options['runlevel'] ||= DEFAULT_RUN_LEVEL
          processaction options['processaction'] ||= DEFAULT_PROCESS_ACTION
          command "/usr/bin/startsrc -s #{new_resource.service_name} >/dev/console 2>&1"
          action :remove
        end
      end

      def destroy_service
        Chef::Log.debug("Destroying aix service #{new_resource.service_name}")
        aix_subsystem new_resource.service_name do
          action :delete
        end
      end

      def service_provider
        super.tap do |r|
          r.provider(Chef::Provider::Service::Aix)
        end
      end
    end
  end
end
