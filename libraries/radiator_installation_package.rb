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
# Resource:: radiator_installation_package
#

require 'uri'
require 'base64'

require 'chef/provider/package/dpkg'

require 'poise'

module Radiator
  module Provider
    # A `radiator_installation` provider which manages the installation using Radiator from a
    # package source.
    #
    # @action create
    # @action remove
    # @provides radiator_installation
    # @example
    #   radiator_installation '2.0' do
    #     provider 'package'
    #   end
    class InstallationPackage < Radiator::Provider::Installation
      include Poise(inversion: :radiator_installation)
      provides(:package)
      inversion_attribute('radiator')

      # The package resource has an options attribute,
      # so we create our own here as an alias
      alias resource_options options

      # Set the default inversion options.
      # @return [Hash]
      # @api private
      def self.default_inversion_options(node, resource)
        super.merge(
          version: resource.install_version,
          packs: resource.packs,
          install_options: resource.install_options
        )
      end

      def action_create
        notifying_block do
          create_user
          create_home
          create_directories

          version = resource_options[:version]
          source = nil
          provider = nil
          package_options = nil
          action = :install

          if resource_options.key?(:install_options)
            provider = resource_options[:install_options][:provider] if resource_options[:install_options].key?(:provider)
            package_options = resource_options[:install_options][:options] if resource_options[:install_options].key?(:options)
            action = resource_options[:install_options][:action] if resource_options[:install_options].key?(:action)

            # Download package if source is spesified
            if resource_options[:install_options].key?(:source) && !resource_options[:install_options][:source].nil?
              source = download_file(resource_options[:install_options][:source],
                                     resource_options[:install_options][:source_properties])

              # apt_package does not support installation from source, select dpkg here
              provider = Chef::Provider::Package::Dpkg if node['platform_family'] == 'debian'
            end
          end

          package 'radiator' do # ~FC109
            version version
            source source
            provider provider
            options package_options
            action action
          end

          # Save our binary path to the run_state, so Radiator::Utils.find_radiusd_bin can find it.
          node.run_state['radiator'] ||= {}
          node.run_state['radiator']['installation'] ||= {}
          node.run_state['radiator']['installation']['radiusd_bin_path'] = radiusd_bin_path
          # We don't need any special includes since everything is installed under Perl's library
          node.run_state['radiator']['installation']['perl_includes'] = []

          install_packs unless resource_options[:packs].nil? || resource_options[:packs].empty?
        end
      end

      def action_remove
        notifying_block do
          remove_directories
          remove_home
          remove_user

          package 'radiator' do
            action :remove
          end

          remove_packs unless resource_options[:packs].nil? || resource_options[:packs].empty?
        end
      end

      # Handle installation of packs,
      # see all the possible ways of defining the packs in the radiator_installation resource
      def install_packs
        if resource_options[:packs].is_a?(Array)
          resource_options[:packs].each do |pack|
            package "radiator-#{pack}" if node['radiator']['supported_packs'].include?(pack)
          end
        else
          # Loop key, value pairs from the Hash
          resource_options[:packs].each do |pack, pack_options|
            if node['radiator']['supported_packs'].include?(pack)
              if pack_options.is_a?(Hash)
                version = nil
                source = nil
                provider = nil
                package_options = nil
                action = :install

                # rubocop:disable Metrics/BlockNesting
                if pack_options.key?(:version)
                  version = pack_options[:version]
                elsif pack_options.key?(:install_options)
                  version = pack_options[:install_options][:version] if pack_options[:install_options].key?(:version)
                  provider = pack_options[:install_options][:provider] if pack_options[:install_options].key?(:provider)
                  package_options = pack_options[:install_options][:options] if pack_options[:install_options].key?(:options)
                  action = pack_options[:install_options][:action] if pack_options[:install_options].key?(:action)

                  # Download package if source is spesified
                  if pack_options[:install_options].key?(:source) && !pack_options[:install_options][:source].nil?
                    source = download_file(pack_options[:install_options][:source],
                                           pack_options[:install_options][:source_properties])

                    # apt_package does not support installation from source, select dpkg here
                    provider = :dpkg_package if node['platform_family'] == 'debian'
                  end
                end
                # rubocop:enable Metrics/BlockNesting

                package "radiator-#{pack}" do # ~FC109
                  version version
                  source source
                  provider provider
                  options package_options
                  action action
                end
              else
                package "radiator-#{pack}" do
                  version resource_options[:packs][pack]
                end
              end
            end
          end
        end
      end

      def remove_packs
        if resource_options[:packs].is_a?(Array)
          resource_options[:packs].each do |pack|
            next unless node['radiator']['supported_packs'].include?(pack)
            package "radiator-#{pack}" do
              action :remove
            end
          end
        else
          resource_options[:packs].each_key do |pack|
            next unless node['radiator']['supported_packs'].include?(pack)
            package "radiator-#{pack}" do
              action :remove
            end
          end
        end
      end

      def download_file(source, source_properties)
        # If the source is a URI, use remote_file to download
        if source =~ URI::DEFAULT_PARSER.make_regexp
          # This is largely based on the functionality of poise_archive, which is used in the radiator_installation archive provider for download

          # Use the last path component without the query string plus the name
          # of the resource in Base64. This should be both mildly readable and
          # also unique per invocation.
          url_part = URI(source).path.split(%r{/}).last
          base64_name = Base64.strict_encode64(new_resource.name).delete('=')

          file_path = ::File.join(Chef::Config[:file_cache_path], "#{base64_name}_#{url_part}")

          remote_file file_path do
            source source

            source_properties.each do |key, value|
              send(key, value)
            end unless source_properties.nil?

            owner 'root'
            group 'root'
            mode '0640'
          end

          file_path
        else
          # If the source wasn't an URI, return path relative to the file_cache_path
          ::File.expand_path(source, Chef::Config[:file_cache_path])
        end
      end

      def radiusd_bin_path
        resource_options.fetch(:bin_path, '/usr/bin/radiusd')
      end
    end
  end
end
