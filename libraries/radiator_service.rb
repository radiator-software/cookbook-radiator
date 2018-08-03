# Copyright 2016-2018 Radiator Software Oy
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# Cookbook Name:: radiator
# Resource:: radiator_service
#

require 'iniparse'
require 'poise'
require 'poise_service/service_mixin'
require 'poise_service/service_providers/systemd'

require_relative 'utils'

module Radiator
  module Resource
    # A `radiator_service` resource which manages the service using Poise Service
    # @provides radiator_service
    # @action enable
    # @action disable
    # @action start
    # @action stop
    # @action restart
    class Service < Chef::Resource
      include Poise
      provides(:radiator_service)
      include PoiseService::ServiceMixin

      # @!attribute user
      # The user to run the Radiator instance(s) as.
      # @return [String]
      attribute(:user, kind_of: String, default: lazy { default_owner[0] })
      # @!attribute group
      # The group to run the Radiator instance(s) as.
      # @return [String]
      attribute(:group, kind_of: String, default: lazy { default_owner[1] })
      # @!attribute directory
      # The directory to start Radiator.
      # @return [String]
      attribute(:directory, kind_of: String, default: '/var/run/radiator')

      # @!attribute config_path
      attribute(:config_path, kind_of: String, default: lazy { "/etc/radiator/#{service_name.gsub(/@$/, '')}.cfg" })

      # @!attribute perl_bin
      attribute(:perl_bin, kind_of: String, default: '/usr/bin/env perl')
      # @!attribute radiusd_bin
      attribute(:radiusd_bin, kind_of: String, default: lazy { Radiator::Utils.find_radiusd_bin(node) })
      # @!attribute instances
      # If a number differing from 0 is provided, multiple instances of Radiator are started
      # as separate services with the same configuration file
      # This does not (yet) support SystemD's "@" syntax for the services
      attribute(:instances, kind_of: [Integer, Array], default: 0)
      # @!attribute args
      attribute(:args, kind_of: Array, default: [])
      # @!attribute includes
      attribute(:includes, kind_of: Array, default: [])
      # @!attribute modules
      attribute(:modules, kind_of: Array, default: [])
      # @!attribute dictionaries
      attribute(:dictionaries, kind_of: Array, default: lazy { default_dictionary })
      # @!attribute vars
      attribute(:vars, kind_of: Hash, default: {})
      # @!attribute environment
      attribute(:environment, kind_of: Hash, default: {})
      # @!attribute restart_mode
      # Service restart option for SystemD
      attribute(:restart_mode, kind_of: String, default: 'always')
      # @!attribute overrides
      # Service override configuration, currently only SystemD is supported.
      # A Hash or a string that is rendered to SystemD's ini format like Chef's systemd_unit.
      attribute(:overrides, kind_of: [String, Hash], default: '')

      def service_name
        return "#{name}@" unless service_instances.empty?

        # Fallback to resource name
        name
      end

      def service_instances
        # Instances currently only supported on systemd, with
        # instantiated systemd unit files
        return [] unless Radiator::Utils.systemd?

        if instances.is_a?(Integer)
          1.upto(instances).to_a
        elsif instances.is_a?(Array)
          instances
        end
      end

      def command
        default_args = ['-foreground', "-config_file #{config_path}"]
        service_args = default_args + ["-dictionary_file #{dictionaries.join(',')}"] + args

        service_includes = default_includes + includes
        service_includes = service_includes.map { |inc| "-I #{inc}" }

        service_modules = modules.map { |m| "-M#{m}" }

        service_vars = vars.map { |k, v| "#{k}=#{v}" }

        if instances.is_a?(Integer) && instances > 0
          service_vars += ['instance=%i']
        elsif instances.is_a?(Array) && !instances.empty?
          service_vars += ['instance=%i']
        end

        [perl_bin, service_includes, service_modules, radiusd_bin, service_args, service_vars].flatten.join(' ')
      end

      private

      def default_owner
        [node['radiator']['user'], node['radiator']['group']]
      end

      def default_dictionary
        ["#{::File.dirname(config_path)}/dictionary"]
      end

      def default_includes
        Radiator::Utils.find_radiator_includes(node)
      end
    end
  end

  module Provider
    class InstantiatedSystemd < PoiseService::ServiceProviders::Systemd
      provides(:systemd_instantiated)

      def action_enable
        include_recipe(*Array(recipes)) if recipes
        notifying_block do
          create_service
        end
        # Don't call enable_service & action_start here
      end

      def action_disable
        # Don't call action_stop & disable_service here
        notifying_block do
          destroy_service
        end
      end
    end

    # A `radiator_service` provider which manages the service using Poise Service
    # the node.
    # @provides radiator_service
    class Service < Chef::Provider
      include Poise
      provides(:radiator_service)
      include PoiseService::ServiceMixin

      def action_enable
        notifying_block do
          create_overrides unless new_resource.overrides.empty?
        end

        super

        notifying_block do
          unless new_resource.service_instances.empty?
            new_resource.service_instances.each do |i|
              service "#{new_resource.service_name}#{i}" do
                action [:enable, :start]
              end
            end
          end
        end
      end

      def action_disable
        super

        notifying_block do
          unless new_resource.service_instances.empty?
            new_resource.service_instances.each do |i|
              service "#{new_resource.service_name}#{i}" do
                action [:stop, :disable]
              end
            end
          end

          remove_overrides unless new_resource.overrides.empty?
        end
      end

      def action_start
        super

        notifying_block do
          new_resource.service_instances.each do |i|
            service "#{new_resource.service_name}#{i}" do
              action :start
            end
          end
        end
      end

      def action_stop
        super

        notifying_block do
          new_resource.service_instances.each do |i|
            service "#{new_resource.service_name}#{i}" do
              action :stop
            end
          end
        end
      end

      def action_restart
        super

        notifying_block do
          new_resource.service_instances.each do |i|
            service "#{new_resource.service_name}#{i}" do
              action :restart
            end
          end
        end
      end

      def action_reload
        super

        notifying_block do
          new_resource.service_instances.each do |i|
            service "#{new_resource.service_name}#{i}" do
              action :reload
            end
          end
        end
      end

      private

      def service_options(service)
        service.command(new_resource.command)
        service.directory(new_resource.directory)

        service.user(new_resource.user)
        service.group(new_resource.group)
        service.environment(new_resource.environment)

        service.restart_on_update(true)

        unless new_resource.service_instances.empty?
          # Use our subclassed provider
          service.provider(:systemd_instantiated)
          # Don't call start, stop, etc. on the main template of the service, that would explode
          # on some systems. We're handling the instances above ourselves.
          service.options.update(never_start: true, never_stop: true, never_restart: true, never_reload: true)
          # For the instantiated unit files we have a custom subclassed provider (above), in that case
          # poise-service won't find the template, since it's looking for it in this cookbook and not in poise-service.
          # Thus we default to the one in poise-service explicitly here.
          #
          # See: https://github.com/poise/poise-service/blob/master/lib/poise_service/service_providers/base.rb#L170
          #
          # For some reason, finding the template from node attributes breaks with the subclassed provider, so if
          # you want to override this, you need to spesify the template with a poise_service_options resource.
          #
          # See: https://github.com/poise/poise-service/tree/master#service-options
          service.options.update(template: 'poise-service:systemd.service.erb')
        end

        service.options.update(restart_mode: new_resource.restart_mode)
      end

      def create_overrides
        return unless Radiator::Utils.systemd?

        directory "/etc/systemd/system/#{new_resource.service_name}.service.d"

        ini_content = if new_resource.overrides.is_a?(String)
                        new_resource.overrides
                      else
                        # Stolen from: https://github.com/chef/chef/blob/master/lib/chef/resource/systemd_unit.rb
                        IniParse.gen do |doc|
                          new_resource.overrides.each_pair do |sect, opts|
                            doc.section(sect) do |section|
                              opts.each_pair do |opt, val|
                                section.option(opt, val)
                              end
                            end
                          end
                        end.to_s
                      end

        file "/etc/systemd/system/#{new_resource.service_name}.service.d/overrides.conf" do
          owner 'root'
          group 'root'
          mode '0644'

          content lazy { ini_content }
        end
      end

      def remove_overrides
        file "/etc/systemd/system/#{new_resource.service_name}.service.d/overrides.conf" do
          action :delete
        end

        directory "/etc/systemd/system/#{new_resource.service_name}.service.d" do
          action :delete
        end
      end
    end
  end
end
