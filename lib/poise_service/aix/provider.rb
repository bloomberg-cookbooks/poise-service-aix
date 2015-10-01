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
  module Aix
    # Poise-service provider for AIX.
    # @since 1.0.0
    class Provider
      provides(:aix_service, os: 'aix')

      # Reload action for the AIX service provider.
      def action_reload
        return if options['never_reload']
      end

      def pid
      end

      private

      def create_service
        command = new_resource.command.split(' ')

        check_signals!

        aix_subsystem "create #{new_resource.service_name}" do
          subsystem_name new_resource.service_name
          program command.first
          arguments command.shift
          user new_resource.user
        end

        template "/etc/rc.d/init.d/#{new_resource.service_name}" do
          mode '0755'
          source 'service.sh.erb'
          variables(
            name: new_resource.service_name,
            directory: new_resource.directory,
            arguments: command.shift,
            environment: new_resource.environment,
            pid_file: new_resource.pid_file)
        end
      end

      def enable_service
        aix_inittab "enable #{new_resource.service_name}" do
          runlevel '2'
          command "/etc/rc.d/init.d/#{new_resource.service_name} start >/dev/null 2>&1"
        end
      end

      def disable_service
        aix_inittab "disable #{new_resource.service_name}" do
          runlevel '2'
          command "/etc/rc.d/init.d/#{new_resource.service_name} start >/dev/null 2>&1"
          action :disable
        end
      end

      def destroy_service
        aix_subsystem "disable #{new_resource.service_name}" do
          subsystem_name new_resource.service_name
          action :delete
        end

        file "/etc/rc.d/init.d/#{new_resource.service_name}" do
          action :delete
        end
      end

      def service_provider
        Chef::Provider::Service::Aix
      end

      def service_resource
        @service_resource ||= Chef::Resource::AixInittab.new(new_resource.name, run_context).tap do |r|
          r.identifier = new_resource.service_name
        end
      end
    end
  end
end
