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
# Attribute:: default
#

default['radiator']['user'] = 'radiator'
default['radiator']['group'] = 'radiator'
default['radiator']['user_home'] = '/home/radiator'
default['radiator']['user_shell'] = '/bin/false'

default['radiator']['supported_packs'] = %w(sim telco carrier gba-bsf)
default['radiator']['install_packs'] = []

default['radiator']['evaluation']['install_version'] = '4.21'
default['radiator']['evaluation']['download_username'] = ''
default['radiator']['evaluation']['download_password'] = ''
default['radiator']['evaluation']['show_license'] = true
default['radiator']['evaluation']['accept_license'] = false

# The dependencies recipe installs CPANM from a repository if needed,
# perl::default would get it from Github
default['perl']['cpanm']['path'] = '/usr/bin/cpanm'
