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
# Resource:: radiator_installation_archive
#

require 'poise'
require 'poise_archive'
require 'poise_archive/archive_providers/gnu_tar'

module Radiator
  module Provider
    # A `radiator_installation` provider which manages the installation using Radiator from a
    # archive source.
    #
    # @action create
    # @action remove
    # @provides radiator_installation
    # @example
    #   radiator_installation '2.0' do
    #     provider 'archive'
    #   end
    class InstallationArchive < Radiator::Provider::Installation
      include Poise(inversion: :radiator_installation)
      provides(:archive)
      inversion_attribute('radiator')

      # Set the default inversion options.
      # @return [Hash]
      # @api private
      def self.default_inversion_options(node, resource)
        super.merge(
          version: resource.install_version,
          user: resource.user,
          group: resource.group,
          packs: resource.packs,
          install_options: resource.install_options,
          install_directory: '/opt/radiator'
        )
      end

      def action_create
        notifying_block do
          create_user
          create_home
          create_directories

          source = nil
          version = options[:version]
          install_dir = options[:install_directory]
          keep_existing = false
          strip_components = 1
          source_properties = { retries: 5 }

          if options.key?(:install_options)
            install_dir = options[:install_options][:destination] if options[:install_options].key?(:destination)
            source = options[:install_options][:path] if options[:install_options].key?(:path)
            keep_existing = options[:install_options][:keep_existing] if options[:install_options].key?(:keep_existing)
            strip_components = options[:install_options][:strip_components] if options[:install_options].key?(:strip_components)
            source_properties = options[:install_options][:source_properties] if options[:install_options].key?(:source_properties)
          end

          Chef::Log.error('Source path is required for archive install.') if source.nil?

          poise_archive 'radiator' do
            provider PoiseArchive::ArchiveProviders::GnuTar

            user options[:user]
            group options[:group]

            path source
            # Unpack into a versioned directory if spesified
            destination version.nil? ? install_dir : "#{install_dir}-#{version}"

            keep_existing keep_existing
            strip_components strip_components
            source_properties source_properties

            action :unpack
          end

          # Link directory to versioned one if spesified
          unless version.nil?
            link install_dir do
              to "#{install_dir}-#{version}"
            end
          end

          link radiusd_bin_path do
            to "#{install_dir}/radiusd"
          end

          # Save our binary path to the run_state, so Radiator::Utils.find_radiusd_bin can find it.
          node.run_state['radiator'] ||= {}
          node.run_state['radiator']['installation'] ||= {}
          node.run_state['radiator']['installation']['radiusd_bin_path'] = radiusd_bin_path
          # Save our installation path to run_state
          node.run_state['radiator']['installation']['perl_includes'] = [install_dir]

          install_packs unless options[:packs].nil? || options[:packs].empty?
        end
      end

      def action_remove
        notifying_block do
          remove_directories
          remove_home
          remove_user

          version = options[:version]
          install_dir = options[:install_directory]

          if options.key?(:install_options)
            install_dir = options[:install_options][:install_dir] if options[:install_options].key?(:install_dir)
          end

          unless version.nil?
            link install_dir do
              action :delete
            end

            install_dir = "#{install_dir}-#{version}"
          end

          directory install_dir do
            recursive true
            action :delete
          end

          link radiusd_bin_path do
            action :delete
          end

          remove_packs unless options[:packs].nil? || options[:packs].empty?
        end
      end

      # Handle installation of packs,
      # see all the possible ways of defining the packs in the radiator_installation resource
      #
      # TODO: This is a bit too complex currently, all the different ways of providing properties to poise_archive
      # for the packs can be confusing. Perhaps source / path, at least, should be a mandatory property.
      #
      # All this comes from the package provider, in which the below work a bit more cleanly.
      def install_packs
        if options[:packs].is_a?(Array)
          Chef::Log.error('Packs cannot be defined as an array when installing from archive. Please spesify a Hash with source and other needed parameters.')
        else
          # Loop key, value pairs from the Hash
          options[:packs].each do |pack, pack_options|
            next unless node['radiator']['supported_packs'].include?(pack)
            next unless pack_options.is_a?(Hash)

            source = nil
            version = nil
            install_dir = "#{node['radiator']['archive']['install_directory']}-#{pack}"
            keep_existing = false
            strip_components = 1
            source_properties = { retries: 5 }
            version = pack_options[:version] if pack_options.key?(:version)

            if pack_options.key?(:install_options)
              install_dir = pack_options[:install_options][:destination] if pack_options[:install_options].key?(:destination)
              source = pack_options[:install_options][:path] if pack_options[:install_options].key?(:path)
              version = pack_options[:install_options][:version] if pack_options[:install_options].key?(:version)
              keep_existing = pack_options[:install_options][:keep_existing] if pack_options[:install_options].key?(:keep_existing)
              strip_components = pack_options[:install_options][:strip_components] if pack_options[:install_options].key?(:strip_components)
              source_properties = pack_options[:install_options][:source_properties] if pack_options[:install_options].key?(:source_properties)

              Chef::Log.error('Source path is required for archive install.') if source.nil?

              poise_archive "radiator-#{pack}" do
                provider PoiseArchive::ArchiveProviders::GnuTar

                user options[:user]
                group options[:group]

                path source
                # Unpack into a versioned directory if spesified
                destination version.nil? ? install_dir : "#{install_dir}-#{version}"

                keep_existing keep_existing
                strip_components strip_components
                source_properties source_properties

                action :unpack
              end

              # Link directory to versioned one if spesified
              unless version.nil?
                link install_dir do
                  to "#{install_dir}-#{version}"
                end
              end

              node.run_state['radiator'] ||= {}
              node.run_state['radiator']['installation'] ||= {}
              # Save our installation path to run_state
              node.run_state['radiator']['installation']['perl_includes'] << install_dir
            else
              Chef::Log.error('Packs cannot be defined with just a version when installing from archive. Please spesify a Hash with source and other needed parameters.')
            end
          end
        end
      end

      def remove_packs
        if options[:packs].is_a?(Array)
          Chef::Log.error('Packs cannot be defined as an array when installing from archive. Please spesify a Hash with source and other needed parameters.')
        else
          version = nil

          options[:packs].each do |pack, pack_options|
            if node['radiator']['supported_packs'].include?(pack)
              if pack_options.is_a?(Hash)
                install_dir = "#{node['radiator']['archive']['install_directory']}-#{pack}"

                # rubocop:disable Metrics/BlockNesting
                version = pack_options[:version] if pack_options.key?(:version)

                if pack_options.key?(:install_options)
                  install_dir = pack_options[:install_options][:install_dir] if pack_options[:install_options].key?(:install_dir)
                  version = pack_options[:install_options][:version] if pack_options[:install_options].key?(:version)
                end

                unless version.nil?
                  link install_dir do
                    action :delete
                  end

                  install_dir = "#{install_dir}-#{version}"
                end
                # rubocop:enable Metrics/BlockNesting

                directory install_dir do
                  recursive true
                  action :delete
                end
              else
                Chef::Log.error('Packs cannot be defined with just a version when installing from archive. Please spesify a Hash with source and other needed parameters.')
              end
            end
          end
        end
      end

      def radiusd_bin_path
        options.fetch(:bin_path, '/usr/local/bin/radiusd')
      end
    end
  end
end
