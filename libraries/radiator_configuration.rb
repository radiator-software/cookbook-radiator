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
# Resource:: radiator_configuration
#

require 'poise'
require 'poise/utils'

require_relative 'helpers'
require_relative 'utils'

module Radiator
  module Resource
    # A `radiator_configuration` resource which manages the configuration of Radiator Diameter Proxy
    #
    # @provides radiator_configuration
    # @action create
    # @action remove
    class Configuration < Chef::Resource
      include Poise
      provides(:radiator_configuration)
      actions(:create, :remove)
      default_action(:create)

      # @!attribute user
      # The user to use for the configuration directory and files.
      # @return [String]
      attribute(:user, kind_of: String, default: lazy { default_owner[0] })
      # @!attribute group
      # The group to use for the configuration directory and files.
      # @return [String]
      attribute(:group, kind_of: String, default: lazy { default_owner[1] })

      # @!attribute config_file
      attribute(:config_directory, kind_of: String, default: '/etc/radiator')
      # @!attribute config_file
      attribute(:config_file, kind_of: String, default: lazy { default_config_file })
      # @!attribute config_template
      attribute(:config_template, kind_of: String, default: 'etc/radiator/example.cfg.erb')
      # @!attribute config_variables
      attribute(:config_variables, kind_of: Hash, default: lazy { Mash.new })
      # @!attribute config_helpers
      attribute(:config_helpers, kind_of: Array, default: [])
      # @!attribute config_mode
      attribute(:config_mode, kind_of: String, default: '0644')
      # @!attribute config_verify
      attribute(:config_verify, kind_of: [TrueClass, FalseClass], default: true)
      # @!attribute config_sensitive
      attribute(:config_sensitive, kind_of: [TrueClass, FalseClass], default: false)

      def template_source
        # This gets the template's source and cookbook from
        # the format <cookbook>:<source> or if the : is missing
        # defaults to the caller's cookbook and falls back to this cookbook
        parts = config_template.split(/:/, 2)

        if parts.length == 2
          source = parts[1]
          cookbook = parts[0]
        else
          source = parts[0]
          caller_filename = caller.first.split(':').first
          begin
            cookbook = Poise::Utils.find_cookbook_name(run_context, caller_filename)
          rescue Poise::Error
            cookbook = 'radiator'
          end
        end

        [cookbook, source]
      end

      def template_variables
        default_variables.merge(config_variables)
      end

      def template_helpers
        default_helpers + config_helpers
      end

      def config_path
        ::File.join(config_directory, config_file)
      end

      private

      def default_config_file
        if name.end_with?('.cfg')
          name
        else
          "#{name}.cfg"
        end
      end

      def default_owner
        [node['radiator']['user'], node['radiator']['group']]
      end

      def default_helpers
        [Radiator::Helpers::Configuration]
      end

      def default_variables
        {}
      end
    end
  end

  module Provider
    # A `radiator_configuration` provider which manages the configuration of Radiator Diameter Proxy
    #
    # @provides radiator_configuration
    class Configuration < Chef::Provider
      include Poise
      include Poise::Utils::ShellOut
      provides(:radiator_configuration)

      def action_create
        notifying_block do
          create_directory
          create_config
        end
      end

      def action_remove
        notifying_block do
          create_config.tap do |r|
            r.action(:delete)
          end

          create_directory.tap do |r|
            r.action(:delete)
          end
        end
      end

      private

      def create_config
        template new_resource.config_path do
          cookbook new_resource.template_source[0]
          source new_resource.template_source[1]

          variables lazy { new_resource.template_variables }

          owner new_resource.user
          group new_resource.group
          mode new_resource.config_mode

          sensitive new_resource.config_sensitive

          new_resource.template_helpers.each do |helper|
            helpers(helper)
          end

          verify do |path|
            perl_includes = Radiator::Utils.find_radiator_includes(node).map { |inc| "-I #{inc}" }.join(' ')
            validation_cmd = poise_shell_out("/usr/bin/env perl #{Radiator::Utils.find_radiusd_bin(node)} " \
                                             "#{perl_includes} " \
                                             "-c -log_stdout -trace 4 -config_file #{path} instance=config-validation")

            validation_stdout = validation_cmd.stdout
            validation_stderr = validation_cmd.stderr

            # if something apperead in stderr, then there's no reason to check stdout
            if validation_stderr.empty?
              # Currently we can't count on the config checker to always return a sane exit code,
              # we're using a method from the Utils module here to match WARNING: and ERR: lines
              unless Radiator::Utils.grep_log(validation_stdout)
                Chef::Log.error("Radiator config validation failed:\n#{validation_stdout}")
                false
              end
            else
              Chef::Log.error("Radiator config validation failed:\n#{validation_stderr}")
              false
            end

            Chef::Log.info('Radiator config validation succeeded')
            true
          end if new_resource.config_verify
        end
      end

      def create_directory
        directory new_resource.config_directory do
          owner new_resource.user
          group new_resource.group
          mode '0755'

          not_if { new_resource.config_directory == '/etc' }
        end
      end
    end
  end
end
