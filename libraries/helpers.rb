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
# Library:: helpers
#

module Radiator
  module Helpers
    module Configuration
      extend self # rubocop:disable Style/ModuleFunction

      def print_value(config, key, default: nil, indent: 0)
        format_line = lambda do |param, value, spaces|
          ' ' * spaces + "#{param} #{value}\n"
        end

        if !config.nil? && config.key?(key)
          if config[key].is_a?(String) || config[key].is_a?(Integer) || config[key].is_a?(Float)
            format_line.call(key, config[key].to_s, indent)
          elsif config[key].is_a?(Array)
            config[key].map { |s| format_line.call(key, s, indent) }.join('')
          elsif config[key].is_a?(Hash) || config[key].is_a?(Mash)
            Chef::Log.warn("The provided key: #{key} had a hash value. Printing a hash is not yet supported, please use the config parameter with the subhash.")
          elsif config[key].nil? || config[key].empty?
            if default.nil?
              Chef::Log.warn("The provided key: #{key} had a nil or empty value and no provided.")
            else
              # Print the default
              print_value({ key => default }, key, indent: indent)
            end
          end
        else
          print_value({ key => default }, key, indent: indent) unless default.nil? # Print the default
        end
      end
    end
  end
end

::Chef::Recipe.send(:include, Radiator::Helpers::Configuration)
