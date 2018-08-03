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
# Resource:: radiator_installation
#

require 'poise'
require 'poise_service/resources/poise_service_user'

module Radiator
  module Resource
    # A `radiator_installation` which installs the Radiator Diameter Proxy.
    #
    # @action create
    # @action remove
    class Installation < Chef::Resource
      include Poise(inversion: true)
      provides(:radiator_installation)
      actions(:create, :remove)
      default_action(:create)

      attribute(:version, kind_of: [String, NilClass])
      attribute(:user, kind_of: [String, FalseClass], default: lazy { default_owner[0] })
      attribute(:user_home, kind_of: String, default: lazy { default_home })
      attribute(:user_shell, kind_of: String, default: lazy { default_shell })
      attribute(:group, kind_of: String, default: lazy { default_owner[1] })

      # Install additional Radiator packs, currently supported: sim, telco, carrier, gba-bsf and cloud
      # See below in the comments of install_version for ways of defining packs and their installation options
      attribute(:packs, kind_of: [Array, Hash], default: lazy { node['radiator']['install_packs'] })

      # Options passed directly to the installing resource
      attribute(:install_options, option_collector: true, forced_keys: %i(action), default: {})

      def radiusd_bin_path
        # Get bin_path from the actual provider
        @bin_path ||= provider_for_action(:radiusd_bin_path).radiusd_bin_path
      end

      def install_version
        # This is probably a bit more complicated than it should be, but allows for parameters
        # like this to install the same version '1.2.3':
        #
        # 1. radiator_installation '1.2.3'
        #
        # 2. radiator_installation 'version-in-params' do
        #      version '1.2.3'
        #    end
        #
        # 3. radiator_installation 'version-in-options' do
        #      install_options do
        #        version '1.2.3'
        #      end
        #    end
        #
        # 4. node.default['my-radiator']['install_opts']['version'] = '1.2.3'
        #    # Any other option to the install resource works too
        #    node.default['my-radiator']['install_opts']['action'] = 'upgrade'
        #    radiator_installation 'version-in-options-from-attributes' do
        #      install_options node['my-radiator']['install_opts']
        #    end
        #
        # Most of the above work for the installation of packs too:
        #
        # 1. radiator_installation '1.2.3' do
        #      packs ['sim', 'carrier']
        #    end
        #
        # 2. radiator_installation '1.2.3' do
        #      packs(
        #        {
        #          sim: '3.2.1',
        #          carrier: '4.5.6'
        #        }
        #      )
        #    end
        #
        # 3. radiator_installation '1.2.3' do
        #      packs(
        #        {
        #          sim: {
        #            version: '3.2.1'
        #          },
        #          carrier: {
        #            version: '4.5.6'
        #          }
        #        }
        #      )
        #    end
        #
        # 4. radiator_installation '1.2.3' do
        #      packs(
        #        {
        #          sim: {
        #            install_options: {
        #               version: '3.2.1'
        #            }
        #          },
        #          carrier: {
        #             install_options: {
        #               version: '4.5.6'
        #             }
        #          }
        #        }
        #      )
        #    end
        #

        if instance_variable_defined?(:@version)
          version
        elsif install_options.key?('version')
          install_options['version']
        else
          name
        end
      end

      private

      def default_owner
        [node['radiator']['user'], node['radiator']['group']]
      end

      def default_home
        node['radiator']['user_home']
      end

      def default_shell
        node['radiator']['user_shell']
      end
    end
  end

  module Provider
    # A `radiator_installation` provider which installs the Radiator Diameter Proxy.
    # Actual implementation in the providers through Poise's inversion.
    #
    # @provides diameter_proxy_configuration
    class Installation < Chef::Provider
      include Poise
      provides(:radiator_installation)

      private

      def create_user
        poise_service_user new_resource.user do
          group new_resource.group
          home new_resource.user_home unless new_resource.user_home.nil?
          shell new_resource.user_shell unless new_resource.user_shell.nil?
        end if new_resource.user
      end

      def create_home
        directory new_resource.user_home do
          owner new_resource.user
          group new_resource.group
          mode '0750'
        end if new_resource.user && !new_resource.user_home.nil?
      end

      def create_directories
        %w(/var/run/radiator /var/log/radiator).each do |dir|
          directory dir do
            owner new_resource.user
            group new_resource.group
            mode '0755'
          end if new_resource.user
        end

        file '/etc/tmpfiles.d/radiator.conf' do
          content "d     /var/run/radiator   0755 #{new_resource.user} #{new_resource.group} - -"
        end if new_resource.user
      end

      def remove_user
        create_user.tap do |r|
          r.action(:remove)
        end if new_resource.user
      end

      def remove_home
        create_home.tap do |r|
          r.action(:delete)
        end if new_resource.user && !new_resource.user_home.nil?
      end

      def remove_directories
        %w(/var/run/radiator /var/log/radiator).each do |dir|
          directory dir do
            recursive true
            action :delete
          end
        end if new_resource.user

        file '/etc/tmpfiles.d/radiator.conf' do
          action :delete
        end if new_resource.user
      end
    end
  end
end
