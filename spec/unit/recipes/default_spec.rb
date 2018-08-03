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
# Spec:: default
#

require 'spec_helper'

describe 'radiator::default' do
  context 'When all attributes are default' do
    context 'on Ubuntu 16.04' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04').converge(described_recipe)
      end

      include_examples 'standard chef run expectations'
    end

    context 'on CentOS 7.4' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'centos', version: '7.4.1708').converge(described_recipe)
      end

      include_examples 'standard chef run expectations'
    end
  end
end
