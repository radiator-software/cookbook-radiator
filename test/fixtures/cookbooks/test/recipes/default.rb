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
# Recipe:: default
#

#
# Save node attributes
#

ruby_block 'Save node attributes' do
  block do
    if Dir.exist?('/tmp/kitchen')
      IO.write('/tmp/kitchen/chef_node.json',
               Chef::JSONCompat.to_json_pretty(node))
    end
  end
end