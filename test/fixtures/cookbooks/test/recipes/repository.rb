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
# Cookbook Name:: test
# Recipe:: repository
#

unless node['test']['repository'].nil?
  node['test']['repository'].each_key do |repo|
    case node['platform_family']
    when 'rhel'
      yum_repository repo do
        node['test']['repository'][repo].each do |key, value|
          send(key.to_sym, value) unless value.nil?
        end
      end
    when 'debian'
      apt_repository repo do
        node['test']['repository'][repo].each do |key, value|
          send(key.to_sym, value) unless value.nil?
        end
      end
    end
  end
end

radiator_installation 'radiator-repository' do
  provider 'package'

  # Any version is OK
  version nil
end

config = radiator_configuration 'radius' do
  config_template 'etc/radiator/example.cfg.erb'
  config_variables(
    config: node['radiator']['configuration']
  )
end

radiator_service 'radiator' do
  config_path config.config_path
end

include_recipe 'test::instances'
