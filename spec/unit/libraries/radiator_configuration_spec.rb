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
# Spec:: radiator_configuration
#

require_relative '../../spec_helper'
require_relative '../../../libraries/radiator_configuration'

describe Radiator::Resource::Configuration do
  let(:default_attributes) do
    {
      'radiator' => {
        'user' => 'radiator',
        'group' => 'radiator',
        'user_home' => '/home/radiator',
        'user_shell' => '/bin/false',
      },
    }
  end

  step_into(:radiator_configuration)

  shared_examples_for 'configure' do
    it 'creates directory' do
      is_expected.to create_directory('/etc/radiator')
    end

    it 'renders configuration' do
      is_expected.to create_radiator_configuration('test.cfg')
      is_expected.to create_template('/etc/radiator/test.cfg')
    end
  end

  shared_examples_for 'configure with path' do
    it 'creates directory' do
      is_expected.to create_directory('/etc/myconfig')
    end

    it 'renders configuration' do
      is_expected.to create_radiator_configuration('not-this.cfg')
      is_expected.to create_template('/etc/myconfig/really-test-this.cfg')
    end
  end

  shared_examples_for 'removal' do
    it 'creates directory' do
      is_expected.to delete_directory('/etc/radiator')
    end

    it 'renders configuration' do
      is_expected.to remove_radiator_configuration('test.cfg')
      is_expected.to delete_template('/etc/radiator/test.cfg')
    end
  end

  context 'When defaults are provided' do
    recipe do
      radiator_configuration 'test.cfg'
    end

    context 'on Ubuntu 16.04' do
      let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

      it_behaves_like 'configure'
    end

    context 'on CentOS 7.4' do
      let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

      it_behaves_like 'configure'
    end
  end

  context 'When different configuration file path' do
    recipe do
      radiator_configuration 'not-this.cfg' do
        config_directory '/etc/myconfig'
        config_file 'really-test-this.cfg'
      end
    end

    context 'on Ubuntu 16.04' do
      let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

      it_behaves_like 'configure with path'
    end

    context 'on CentOS 7.4' do
      let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

      it_behaves_like 'configure with path'
    end
  end

  context 'When removal is requested' do
    recipe do
      radiator_configuration 'test.cfg' do
        action :remove
      end
    end

    context 'on Ubuntu 16.04' do
      let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

      it_behaves_like 'removal'
    end

    context 'on CentOS 7.4' do
      let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

      it_behaves_like 'removal'
    end
  end
end
