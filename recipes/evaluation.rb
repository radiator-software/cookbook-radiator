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
# Recipe:: evaluation
#

include_recipe 'radiator::dependencies'

eval_download_url = nil
eval_version = node['radiator']['evaluation']['install_version']
eval_username = node['radiator']['evaluation']['download_username']
eval_password = node['radiator']['evaluation']['download_password']

if eval_username.nil? || eval_username.empty? || eval_password.nil? || eval_password.empty?
  raise 'You have not provided the username and password for downloading the evaluation version. ' \
        "Please set node['radiator']['evaluation']['download_username'] and node['radiator']['evaluation']['download_password']"
end

eval_auth = Base64.encode64("#{eval_username}:#{eval_password}")

ruby_block 'show-radiator-license' do
  block do
    require 'chef/http'

    Chef::Log.info(Chef::HTTP.new('https://www.open.com.au').get('/radiator/LICENSE').to_s)
  end

  only_if { node['radiator']['evaluation']['show_license'] }
end

if node['radiator']['evaluation']['accept_license']
  Chef::Log.info('You have chosen to accept the Radiator license.')
else
  raise 'You have not accepted the license. The software download will fail. ' \
        "Please read https://radiatorsoftware.com/license/ and set node['radiator']['evaluation']['accept_license'] to true."
end

ruby_block 'get-radiator-download-url' do
  block do
    require 'chef/http'
    require 'uri'

    uri = URI.parse("https://www.open.com.au/radiator/demo-downloads/dl.cgi/Radiator-Locked-#{eval_version}.tgz")
    eval_download_url = Chef::HTTP.new(uri.scheme + '://' + uri.host).get(uri.path, 'Authorization' => "Basic #{eval_auth}".gsub('\n', '')).match(%r{.*href.*(https://.*dl\.cgi.*\.tgz).*})[1]
  end

  only_if { node['radiator']['evaluation']['accept_license'] }
end

radiator_installation 'radiator-evaluation' do
  provider 'archive'

  version eval_version

  install_options do
    path lazy { eval_download_url }
    destination '/opt/radiator-locked'

    source_properties('headers' => { 'Authorization' => "Basic #{eval_auth}".gsub('\n', '') })
  end

  only_if { node['radiator']['evaluation']['accept_license'] }
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
