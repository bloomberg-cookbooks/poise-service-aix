#
# Cookbook: poise-service-aix
# License: Apache 2.0
#
# Copyright 2015, Noah Kantrowitz
# Copyright 2015, Bloomberg Finance L.P.
#

require 'chef/mash'

require 'poise_service/error'
require 'poise_service/service_providers/base'

module PoiseService
  module ServiceProviders
    # Poise-service provider for AIX.
    # @since 1.0.0
    class Provider < Base
      include Chef::Mixin::ShellOut
      provides(:aix_service, os: 'aix')

      # Parse the PID from `lssrc -s <name>` output.
      # @return [Integer]
      def pid
        service = shell_out!("lssrc -s #{@new_resource.service_name}").stdout
        service.split(' ')[-1].to_i
      end

      private

      def create_service
        Chef::Log.debug("Creating aix service #{new_resource.service_name}")
        command = new_resource.command.split(' ')
        aix_subsystem "create #{new_resource.service_name}" do
          subsystem_name new_resource.service_name
          program command.first
          arguments command.shift
          user new_resource.user
        end
      end

      def enable_service
        Chef::Log.debug("Enabling aix service #{new_resource.service_name}")
        options['inittab']['runlevel'] ||= 2
        aix_inittab "enable #{new_resource.service_name}" do
          runlevel options['inittab']['runlevel']
          command "/usr/bin/startsrc -s #{new_resource.service_name} >/dev/console 2>&1"
        end
      end

      def disable_service
        Chef::Log.debug("Disabling aix service #{new_resource.service_name}")
        options['inittab']['runlevel'] ||= 2
        aix_inittab "disable #{new_resource.service_name}" do
          runlevel options['inittab']['runlevel']
          command "/usr/bin/startsrc -s #{new_resource.service_name} >/dev/console 2>&1"
          action :disable
        end
      end

      def destroy_service
        Chef::Log.debug("Destroying aix service #{new_resource.service_name}")
        aix_subsystem "delete #{new_resource.service_name}" do
          subsystem_name new_resource.service_name
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
