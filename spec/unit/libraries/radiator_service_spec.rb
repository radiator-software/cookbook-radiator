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
# Spec:: radiator_service
#

require_relative '../../spec_helper'
require_relative '../../../libraries/radiator_service'

describe Radiator::Resource::Service do
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

  step_into(:radiator_service)

  shared_examples_for 'enable' do
    it 'enables service' do
      is_expected.to enable_radiator_service('test-service').with(
        command: '/usr/bin/env perl /usr/bin/radiusd -foreground -config_file /etc/radiator/test-service.cfg -dictionary_file /etc/radiator/dictionary'
      )
      # This doesn't work for some reason, and the resource still pops up during the run
      # is_expected.to enable_poise_service('test-service')
    end
  end

  shared_examples_for 'enable with args' do
    it 'enables service' do
      is_expected.to enable_radiator_service('test-service').with(
        command: '/usr/bin/env perl /usr/bin/radiusd -foreground -config_file /etc/radiator/test-service.cfg -dictionary_file /etc/radiator/dictionary --extra param --hello there'
      )
      # This doesn't work for some reason, and the resource still pops up during the run
      # is_expected.to enable_poise_service('test-service')
    end
  end

  shared_examples_for 'enable with multiple instances' do
    it 'enables service' do
      is_expected.to enable_radiator_service('test-service').with(
        command: '/usr/bin/env perl /usr/bin/radiusd -foreground -config_file /etc/radiator/test-service.cfg -dictionary_file /etc/radiator/dictionary instance=%i',
        instances: 4
      )
      is_expected.to_not start_service('test-service@')
      is_expected.to start_service('test-service@1')
      is_expected.to start_service('test-service@2')
      is_expected.to start_service('test-service@3')
      is_expected.to start_service('test-service@4')
      is_expected.to_not enable_service('test-service@')
      is_expected.to enable_service('test-service@1')
      is_expected.to enable_service('test-service@2')
      is_expected.to enable_service('test-service@3')
      is_expected.to enable_service('test-service@4')
    end
  end

  shared_examples_for 'enable with multiple instances with names' do
    it 'enables service' do
      is_expected.to enable_radiator_service('test-service').with(
        command: '/usr/bin/env perl /usr/bin/radiusd -foreground -config_file /etc/radiator/test-service.cfg -dictionary_file /etc/radiator/dictionary instance=%i',
        instances: %w(one two three four)
      )
      is_expected.to_not start_service('test-service@')
      is_expected.to start_service('test-service@one')
      is_expected.to start_service('test-service@two')
      is_expected.to start_service('test-service@three')
      is_expected.to start_service('test-service@four')
      is_expected.to_not enable_service('test-service@')
      is_expected.to enable_service('test-service@one')
      is_expected.to enable_service('test-service@two')
      is_expected.to enable_service('test-service@three')
      is_expected.to enable_service('test-service@four')
    end
  end

  shared_examples_for 'enable with multiple instances and overrides' do
    it 'enables service' do
      is_expected.to enable_radiator_service('test-service').with(
        command: '/usr/bin/env perl /usr/bin/radiusd -foreground -config_file /etc/radiator/test-service.cfg -dictionary_file /etc/radiator/dictionary instance=%i',
        instances: 4
      )
      is_expected.to_not start_service('test-service@')
      is_expected.to start_service('test-service@1')
      is_expected.to start_service('test-service@2')
      is_expected.to start_service('test-service@3')
      is_expected.to start_service('test-service@4')
      is_expected.to_not enable_service('test-service@')
      is_expected.to enable_service('test-service@1')
      is_expected.to enable_service('test-service@2')
      is_expected.to enable_service('test-service@3')
      is_expected.to enable_service('test-service@4')
    end

    it 'creates directory' do
      is_expected.to create_directory('/etc/systemd/system/test-service@.service.d')
    end

    it 'creates override file' do
      is_expected.to create_file('/etc/systemd/system/test-service@.service.d/overrides.conf').with(
        content: "[Service]\nRestart = always\n"
      )
    end
  end

  shared_examples_for 'disable' do
    it 'disables service' do
      is_expected.to disable_radiator_service('test-service')
      # This doesn't work for some reason, and the resource still pops up during the run
      # is_expected.to disable_poise_service('test-service')
    end
  end

  shared_examples_for 'start' do
    it 'starts service' do
      is_expected.to start_radiator_service('test-service')
      # This doesn't work for some reason, and the resource still pops up during the run
      # is_expected.to start_poise_service('test-service')
    end
  end

  shared_examples_for 'stop' do
    it 'stops service' do
      is_expected.to stop_radiator_service('test-service')
      # This doesn't work for some reason, and the resource still pops up during the run
      # is_expected.to stop_poise_service('stopped-test-service')
    end
  end

  shared_examples_for 'restart' do
    it 'restarts service' do
      is_expected.to restart_radiator_service('test-service')
      # This doesn't work for some reason, and the resource still pops up during the run
      # is_expected.to restart_poise_service('test-service')
    end
  end

  shared_examples_for 'reload' do
    it 'reloads service' do
      is_expected.to reload_radiator_service('test-service')
      # This doesn't work for some reason, and the resource still pops up during the run
      # is_expected.to disable_poise_service('disabled-test-service')
    end
  end

  shared_examples_for 'disable instances' do
    it 'disables services' do
      is_expected.to disable_radiator_service('test-service')

      is_expected.to_not stop_service('test-service@')
      is_expected.to stop_service('test-service@1')
      is_expected.to stop_service('test-service@2')
      is_expected.to stop_service('test-service@3')
      is_expected.to stop_service('test-service@4')
      is_expected.to_not disable_service('test-service@')
      is_expected.to disable_service('test-service@1')
      is_expected.to disable_service('test-service@2')
      is_expected.to disable_service('test-service@3')
      is_expected.to disable_service('test-service@4')
    end
  end

  shared_examples_for 'start instances' do
    it 'starts services' do
      is_expected.to start_radiator_service('test-service')

      is_expected.to_not start_service('test-service@')
      is_expected.to start_service('test-service@1')
      is_expected.to start_service('test-service@2')
      is_expected.to start_service('test-service@3')
      is_expected.to start_service('test-service@4')
    end
  end

  shared_examples_for 'reload instances' do
    it 'reloads services' do
      is_expected.to reload_radiator_service('test-service')

      is_expected.to_not reload_service('test-service@')
      is_expected.to reload_service('test-service@1')
      is_expected.to reload_service('test-service@2')
      is_expected.to reload_service('test-service@3')
      is_expected.to reload_service('test-service@4')
    end
  end

  shared_examples_for 'stop instances' do
    it 'stops services' do
      is_expected.to stop_radiator_service('test-service')

      is_expected.to_not stop_service('test-service@')
      is_expected.to stop_service('test-service@1')
      is_expected.to stop_service('test-service@2')
      is_expected.to stop_service('test-service@3')
      is_expected.to stop_service('test-service@4')
    end
  end

  shared_examples_for 'restart instances' do
    it 'restarts services' do
      is_expected.to restart_radiator_service('test-service')
      # This doesn't work for some reason, and the resource still pops up during the run
      # is_expected.to restart_poise_service('test-service')

      is_expected.to_not restart_service('test-service@')
      is_expected.to restart_service('test-service@1')
      is_expected.to restart_service('test-service@2')
      is_expected.to restart_service('test-service@3')
      is_expected.to restart_service('test-service@4')
    end
  end

  shared_examples_for 'service with overrides' do
    it 'creates directory' do
      is_expected.to create_directory('/etc/systemd/system/test-service.service.d')
    end

    it 'creates override file' do
      is_expected.to create_file('/etc/systemd/system/test-service.service.d/overrides.conf').with(
        content: "[Service]\nRestart = always\n"
      )
    end
  end

  shared_examples_for 'disable with overrides' do
    it 'creates directory' do
      is_expected.to delete_directory('/etc/systemd/system/test-service.service.d')
    end

    it 'creates override file' do
      is_expected.to delete_file('/etc/systemd/system/test-service.service.d/overrides.conf')
    end
  end

  context 'When defaults are provided' do
    recipe do
      radiator_service 'test-service'
    end

    context 'on Ubuntu 16.04' do
      let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

      it_behaves_like 'enable'
    end

    context 'on CentOS 7.4' do
      let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

      it_behaves_like 'enable'
    end
  end

  context 'When additional arguments are provided' do
    recipe do
      radiator_service 'test-service' do
        args ['--extra param', '--hello', 'there']
      end
    end

    context 'on Ubuntu 16.04' do
      let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

      it_behaves_like 'enable with args'
    end

    context 'on CentOS 7.4' do
      let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

      it_behaves_like 'enable with args'
    end
  end

  context 'When disable is requested' do
    recipe do
      radiator_service 'test-service' do
        action :disable
      end
    end

    context 'on Ubuntu 16.04' do
      let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

      it_behaves_like 'disable'
    end

    context 'on CentOS 7.4' do
      let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

      it_behaves_like 'disable'
    end
  end

  context 'When start is requested' do
    recipe do
      radiator_service 'test-service' do
        action :start
      end
    end

    context 'on Ubuntu 16.04' do
      let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

      it_behaves_like 'start'
    end

    context 'on CentOS 7.4' do
      let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

      it_behaves_like 'start'
    end
  end

  context 'When stop is requested' do
    recipe do
      radiator_service 'test-service' do
        action :stop
      end
    end

    context 'on Ubuntu 16.04' do
      let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

      it_behaves_like 'stop'
    end

    context 'on CentOS 7.4' do
      let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

      it_behaves_like 'stop'
    end
  end

  context 'When restart is requested' do
    recipe do
      radiator_service 'test-service' do
        action :restart
      end
    end

    context 'on Ubuntu 16.04' do
      let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

      it_behaves_like 'restart'
    end

    context 'on CentOS 7.4' do
      let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

      it_behaves_like 'restart'
    end
  end

  context 'When reload is requested' do
    recipe do
      radiator_service 'test-service' do
        action :reload
      end
    end

    context 'on Ubuntu 16.04' do
      let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

      it_behaves_like 'reload'
    end

    context 'on CentOS 7.4' do
      let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

      it_behaves_like 'reload'
    end
  end

  context 'When service overrides are spesified' do
    before do
      set_systemd!
    end

    context 'and overrides is a Hash' do
      recipe do
        radiator_service 'test-service' do
          overrides(
            Service: {
              Restart: 'always',
            }
          )
        end
      end

      context 'on Ubuntu 16.04' do
        let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

        it_behaves_like 'enable'
        it_behaves_like 'service with overrides'
      end

      context 'on CentOS 7.4' do
        let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

        it_behaves_like 'enable'
        it_behaves_like 'service with overrides'
      end
    end

    context 'and overrides is a String' do
      recipe do
        radiator_service 'test-service' do
          overrides <<-EOS.gsub(/^\s+/, '')
            [Service]
            Restart = always
          EOS
        end
      end

      context 'on Ubuntu 16.04' do
        let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

        it_behaves_like 'enable'
        it_behaves_like 'service with overrides'
      end

      context 'on CentOS 7.4' do
        let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

        it_behaves_like 'enable'
        it_behaves_like 'service with overrides'
      end
    end

    context 'and disable is requested' do
      recipe do
        radiator_service 'test-service' do
          overrides(
            Service: {
              Restart: 'always',
            }
          )

          action :disable
        end
      end

      context 'on Ubuntu 16.04' do
        let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

        it_behaves_like 'disable'
        it_behaves_like 'disable with overrides'
      end

      context 'on CentOS 7.4' do
        let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

        it_behaves_like 'disable'
        it_behaves_like 'disable with overrides'
      end
    end
  end

  context 'When multiple instances are configured' do
    before do
      set_systemd!
    end

    context 'as an integer' do
      recipe do
        radiator_service 'test-service' do
          instances 4
        end
      end

      context 'on Ubuntu 16.04' do
        let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

        it_behaves_like 'enable with multiple instances'
      end

      context 'on CentOS 7.4' do
        let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

        it_behaves_like 'enable with multiple instances'
      end
    end

    context 'as an array of names' do
      recipe do
        radiator_service 'test-service' do
          instances %w(one two three four)
        end
      end

      context 'on Ubuntu 16.04' do
        let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

        it_behaves_like 'enable with multiple instances with names'
      end

      context 'on CentOS 7.4' do
        let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

        it_behaves_like 'enable with multiple instances with names'
      end
    end

    context 'and overrides are provided' do
      recipe do
        radiator_service 'test-service' do
          instances 4
          overrides(
            Service: {
              Restart: 'always',
            }
          )
        end
      end

      context 'on Ubuntu 16.04' do
        let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

        it_behaves_like 'enable with multiple instances and overrides'
      end

      context 'on CentOS 7.4' do
        let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

        it_behaves_like 'enable with multiple instances and overrides'
      end
    end

    context 'and disable is requested' do
      recipe do
        radiator_service 'test-service' do
          instances 4

          action :disable
        end
      end

      context 'on Ubuntu 16.04' do
        let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

        it_behaves_like 'disable instances'
      end

      context 'on CentOS 7.4' do
        let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

        it_behaves_like 'disable instances'
      end
    end

    context 'and stop is requested' do
      recipe do
        radiator_service 'test-service' do
          instances 4

          action :stop
        end
      end

      context 'on Ubuntu 16.04' do
        let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

        it_behaves_like 'stop instances'
      end

      context 'on CentOS 7.4' do
        let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

        it_behaves_like 'stop instances'
      end
    end

    context 'and start is requested' do
      recipe do
        radiator_service 'test-service' do
          instances 4

          action :start
        end
      end

      context 'on Ubuntu 16.04' do
        let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

        it_behaves_like 'start instances'
      end

      context 'on CentOS 7.4' do
        let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

        it_behaves_like 'start instances'
      end
    end

    context 'and restart is requested' do
      recipe do
        radiator_service 'test-service' do
          instances 4

          action :restart
        end
      end

      context 'on Ubuntu 16.04' do
        let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

        it_behaves_like 'restart instances'
      end

      context 'on CentOS 7.4' do
        let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

        it_behaves_like 'restart instances'
      end
    end

    context 'and reload is requested' do
      recipe do
        radiator_service 'test-service' do
          instances 4

          action :reload
        end
      end

      context 'on Ubuntu 16.04' do
        let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

        it_behaves_like 'reload instances'
      end

      context 'on CentOS 7.4' do
        let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

        it_behaves_like 'reload instances'
      end
    end
  end
end
