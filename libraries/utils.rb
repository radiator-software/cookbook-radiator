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
# Library:: utils
#

require 'chef/platform/service_helpers'

module Radiator
  # These are utility methods internal to this cookbook, use with care elsewhere
  module Utils
    extend self # rubocop:disable Style/ModuleFunction:

    def find_radiusd_bin(node)
      # Default to the location for the package installation
      bin_path = '/usr/bin/radiusd'

      if node.run_state.key?('radiator') && node.run_state['radiator'].key?('installation')
        # This should be set by the radiator_installation providers
        bin_path = node.run_state['radiator']['installation']['radiusd_bin_path'] unless node.run_state['radiator']['installation']['radiusd_bin_path'].nil?
      end

      bin_path
    end

    def find_radiator_includes(node)
      # Default to the an empty list for package installation
      includes = []

      if node.run_state.key?('radiator') && node.run_state['radiator'].key?('installation')
        # This should be set by the radiator_installation providers
        includes = node.run_state['radiator']['installation']['perl_includes'] unless node.run_state['radiator']['installation']['perl_includes'].nil?
      end

      includes
    end

    def grep_log(command_output, warnings: %w(WARNING:), errors: %w(ERR:))
      # Skip license related warnings, as this is run from evaluation.rb recipe and these
      # shouldn't cause the configuration to not render
      command_output = command_output.split("\n").delete_if { |line| line.match('WARNING: .*license') }.join

      validation = command_output.split

      # Return false if the output from the config check command matches provided error and warning lines
      return false unless (validation & warnings).empty?
      return false unless (validation & errors).empty?

      true
    end

    def systemd?
      Chef::Platform::ServiceHelpers.service_resource_providers.include?(:systemd)
    end
  end
end
