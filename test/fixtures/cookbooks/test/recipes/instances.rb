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
# Recipe:: instances
#

instance_ports = {
  'AuthPort' => '%{GlobalVar:auth_port_instance_%{GlobalVar:instance}}',
  'AcctPort' => '%{GlobalVar:acct_port_instance_%{GlobalVar:instance}}'
}

instanced_config = radiator_configuration 'instances' do
  config_template 'etc/radiator/example.cfg.erb'
  config_variables(
    config: node['radiator']['configuration'].merge(instance_ports)
  )
end

radiator_service 'radiator-instance' do
  config_path instanced_config.config_path

  vars(
    auth_port_instance_1: 11812,
    acct_port_instance_1: 11813,
    auth_port_instance_2: 21812,
    acct_port_instance_2: 21813,
  )

  instances 2
end
