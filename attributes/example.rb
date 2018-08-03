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
# Attribute:: example
#

# radius.cfg
default['radiator']['configuration']['Trace'] = 2
default['radiator']['configuration']['AuthPort'] = 1812
default['radiator']['configuration']['AcctPort'] = 1813
default['radiator']['configuration']['LogDir'] = '/var/log/radiator'
default['radiator']['configuration']['Log']['FILE']['Identifier'] = 'radiator-log'
default['radiator']['configuration']['Log']['FILE']['Trace'] = 2
default['radiator']['configuration']['Log']['FILE']['Filename'] = '%L/radiator.log'
default['radiator']['configuration']['Client'] = {
  'DEFAULT' => {
    'Secret' => 'chef',
    'Identifier' => 'chef',
  },
}
