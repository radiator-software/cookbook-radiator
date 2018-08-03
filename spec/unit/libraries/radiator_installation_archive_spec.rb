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
# Spec:: radiator_installation_archive
#

require_relative '../../spec_helper'
require_relative '../../../libraries/radiator_installation'
require_relative '../../../libraries/radiator_installation_archive'

describe Radiator::Resource::Installation do
  let(:default_attributes) do
    {
      'radiator' => {
        'user' => 'radiator',
        'group' => 'radiator',
        'user_home' => '/home/radiator',
        'user_shell' => '/bin/false',
        'supported_packs' => %w(sim telco carrier gba-bsf),
        'archive' => {
          'install_directory' => '/opt/radiator',
        },
      },
    }
  end

  step_into(:radiator_installation)

  shared_examples_for 'install' do
    it 'installs archive' do
      is_expected.to create_radiator_installation('1.2.3')
      is_expected.to unpack_poise_archive('radiator').with(
        path: '/tmp/radiator.tgz'
      )
      is_expected.to create_link('/opt/radiator').with(
        to: '/opt/radiator-1.2.3'
      )
      is_expected.to create_link('/usr/local/bin/radiusd').with(
        to: '/opt/radiator/radiusd'
      )
    end
  end

  shared_examples_for 'install with nil' do
    it 'installs archive with any version' do
      is_expected.to create_radiator_installation('version-defined-as-nil')
      is_expected.to unpack_poise_archive('radiator').with(
        path: '/tmp/radiator.tgz'
      )
      is_expected.to_not create_link('/opt/radiator').with(
        to: '/opt/radiator-1.2.3'
      )
      is_expected.to create_link('/usr/local/bin/radiusd').with(
        to: '/opt/radiator/radiusd'
      )
    end
  end

  shared_examples_for 'install with version' do
    it 'installs archive with version' do
      is_expected.to create_radiator_installation('version-defined-as-1.2.3')
      is_expected.to unpack_poise_archive('radiator').with(
        path: '/tmp/radiator.tgz'
      )
      is_expected.to create_link('/opt/radiator').with(
        to: '/opt/radiator-1.2.3'
      )
      is_expected.to create_link('/usr/local/bin/radiusd').with(
        to: '/opt/radiator/radiusd'
      )
    end
  end

  shared_examples_for 'install with options' do
    it 'upgrades archive with options' do
      is_expected.to create_radiator_installation('1.2.3')
      is_expected.to unpack_poise_archive('radiator').with(
        path: 'https://www.example.com/tmp/radiator.tgz',
        source_properties: {
          'headers' => { 'Authorization' => 'Testing One Two Three' },
        }
      )
      is_expected.to create_link('/opt/radiator').with(
        to: '/opt/radiator-1.2.3'
      )
      is_expected.to create_link('/usr/local/bin/radiusd').with(
        to: '/opt/radiator/radiusd'
      )
    end
  end

  shared_examples_for 'install with version in options' do
    it 'installs archive with version' do
      is_expected.to create_radiator_installation('version-defined-in-options')
      is_expected.to unpack_poise_archive('radiator').with(
        path: '/tmp/radiator.tgz'
      )
      is_expected.to create_link('/opt/radiator').with(
        to: '/opt/radiator-3.2.1'
      )
      is_expected.to create_link('/usr/local/bin/radiusd').with(
        to: '/opt/radiator/radiusd'
      )
    end
  end

  shared_examples_for 'pack install' do
    it 'installs archives' do
      is_expected.to create_radiator_installation('1.2.3')
      # TODO: Can we test for the error message here?
    end
  end

  shared_examples_for 'pack install with versions' do
    it 'installs archives' do
      is_expected.to create_radiator_installation('1.2.3')
      is_expected.to unpack_poise_archive('radiator').with(
        path: '/tmp/radiator.tgz'
      )
      is_expected.to create_link('/opt/radiator').with(
        to: '/opt/radiator-1.2.3'
      )
      is_expected.to create_link('/usr/local/bin/radiusd').with(
        to: '/opt/radiator/radiusd'
      )
      is_expected.to unpack_poise_archive('radiator-sim').with(
        path: '/tmp/radiator-sim.tgz'
      )
      is_expected.to create_link('/opt/radiator-sim').with(
        to: '/opt/radiator-sim-3.2.1'
      )
      is_expected.to unpack_poise_archive('radiator-carrier').with(
        path: '/tmp/radiator-carrier.tgz'
      )
      is_expected.to create_link('/opt/radiator-carrier').with(
        to: '/opt/radiator-carrier-5.4.3'
      )
      is_expected.to_not unpack_poise_archive('radiator-notsupported')
    end
  end

  shared_examples_for 'pack install with options' do
    it 'installs archives' do
      is_expected.to create_radiator_installation('1.2.3')
      is_expected.to unpack_poise_archive('radiator').with(
        path: '/tmp/radiator.tgz'
      )
      is_expected.to create_link('/opt/radiator').with(
        to: '/opt/radiator-1.2.3'
      )
      is_expected.to create_link('/usr/local/bin/radiusd').with(
        to: '/opt/radiator/radiusd'
      )
      is_expected.to unpack_poise_archive('radiator-sim').with(
        path: 'https://www.example.com/tmp/radiator-sim.tgz',
        source_properties: {
          'headers' => { 'Authorization' => 'Testing One Two Three' },
        }
      )
      is_expected.to create_link('/opt/radiator-sim').with(
        to: '/opt/radiator-sim-3.2.1'
      )
      is_expected.to unpack_poise_archive('radiator-carrier').with(
        path: 'https://www.example.com/tmp/radiator-carrier.tgz',
        source_properties: {
          'headers' => { 'Authorization' => 'Testing One Two Three' },
        }
      )
      is_expected.to create_link('/opt/radiator-carrier').with(
        to: '/opt/radiator-carrier-5.4.3'
      )
      is_expected.to_not unpack_poise_archive('radiator-notsupported')
    end
  end

  shared_examples_for 'uninstall' do
    it 'removes archive' do
      is_expected.to remove_radiator_installation('1.2.3')
      is_expected.to delete_directory('/opt/radiator-1.2.3')
      is_expected.to delete_link('/opt/radiator')
      is_expected.to delete_link('/usr/local/bin/radiusd')
    end
  end

  shared_examples_for 'pack uninstall' do
    it 'uninstalls archives' do
      is_expected.to remove_radiator_installation('1.2.3')
      is_expected.to delete_directory('/opt/radiator-1.2.3')
      is_expected.to delete_link('/opt/radiator')
      is_expected.to delete_link('/usr/local/bin/radiusd')
      is_expected.to delete_directory('/opt/radiator-sim-3.2.1')
      is_expected.to delete_link('/opt/radiator-sim')
      is_expected.to delete_directory('/opt/radiator-carrier-5.4.3')
      is_expected.to delete_link('/opt/radiator-carrier')
      is_expected.to_not delete_directory('/opt/radiator-notsupported')
    end
  end

  shared_examples_for 'setup' do
    it 'creates user' do
      is_expected.to create_poise_service_user('radiator')
    end

    it 'creates directories' do
      is_expected.to create_directory('/home/radiator')
      is_expected.to create_directory('/var/log/radiator')
      is_expected.to create_directory('/var/run/radiator')
      is_expected.to create_file('/etc/tmpfiles.d/radiator.conf')
    end
  end

  shared_examples_for 'setup without user' do
    it 'does not create user' do
      is_expected.to_not create_poise_service_user('radiator')
    end

    it 'does not create directories' do
      is_expected.to_not create_directory('/home/radiator')
      is_expected.to_not create_directory('/var/log/radiator')
      is_expected.to_not create_directory('/var/run/radiator')
      is_expected.to_not create_file('/etc/tmpfiles.d/radiator.conf')
    end
  end

  shared_examples_for 'cleanup' do
    it 'removes user' do
      is_expected.to remove_poise_service_user('radiator')
    end

    it 'removes directories' do
      is_expected.to delete_directory('/home/radiator')
      is_expected.to delete_directory('/var/log/radiator')
      is_expected.to delete_directory('/var/run/radiator')
      is_expected.to delete_file('/etc/tmpfiles.d/radiator.conf')
    end
  end

  shared_examples_for 'cleanup without user' do
    it 'removes user' do
      is_expected.to_not remove_poise_service_user('radiator')
    end

    it 'removes directories' do
      is_expected.to_not delete_directory('/home/radiator')
      is_expected.to_not delete_directory('/var/log/radiator')
      is_expected.to_not delete_directory('/var/run/radiator')
      is_expected.to_not delete_file('/etc/tmpfiles.d/radiator.conf')
    end
  end

  context 'When defaults are provided' do
    recipe do
      radiator_installation '1.2.3' do
        provider 'archive'

        install_options do
          path '/tmp/radiator.tgz'
        end
      end
    end

    context 'on Ubuntu 16.04' do
      let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

      it_behaves_like 'install'
      it_behaves_like 'setup'
    end

    context 'on CentOS 7.4' do
      let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

      it_behaves_like 'install'
      it_behaves_like 'setup'
    end
  end

  context 'When version is explicitly set' do
    recipe do
      radiator_installation 'version-defined-as-1.2.3' do
        provider 'archive'
        version '1.2.3'

        install_options do
          path '/tmp/radiator.tgz'
        end
      end
    end

    context 'on Ubuntu 16.04' do
      let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

      it_behaves_like 'install with version'
      it_behaves_like 'setup'
    end

    context 'on CentOS 7.4' do
      let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

      it_behaves_like 'install with version'
      it_behaves_like 'setup'
    end
  end

  context 'When version is explicitly nil' do
    recipe do
      radiator_installation 'version-defined-as-nil' do
        provider 'archive'
        version nil

        install_options do
          path '/tmp/radiator.tgz'
        end
      end
    end

    context 'on Ubuntu 16.04' do
      let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

      it_behaves_like 'install with nil'
      it_behaves_like 'setup'
    end

    context 'on CentOS 7.4' do
      let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

      it_behaves_like 'install with nil'
      it_behaves_like 'setup'
    end
  end

  context 'When install options are provided' do
    recipe do
      radiator_installation '1.2.3' do
        provider 'archive'

        install_options do
          path 'https://www.example.com/tmp/radiator.tgz'
          source_properties(headers: { 'Authorization' => 'Testing One Two Three' })
        end
      end
    end

    context 'on Ubuntu 16.04' do
      let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

      it_behaves_like 'install with options'
      it_behaves_like 'setup'
    end

    context 'on CentOS 7.4' do
      let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

      it_behaves_like 'install with options'
      it_behaves_like 'setup'
    end
  end

  context 'When version is defined in install options' do
    recipe do
      radiator_installation 'version-defined-in-options' do
        provider 'archive'

        install_options do
          path '/tmp/radiator.tgz'
          version '3.2.1'
        end
      end
    end

    context 'on Ubuntu 16.04' do
      let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

      it_behaves_like 'install with version in options'
      it_behaves_like 'setup'
    end

    context 'on CentOS 7.4' do
      let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

      it_behaves_like 'install with version in options'
      it_behaves_like 'setup'
    end
  end

  context 'When user creation is disabled' do
    recipe do
      radiator_installation '1.2.3' do
        provider 'archive'
        user false

        install_options do
          path '/tmp/radiator.tgz'
        end
      end
    end

    context 'on Ubuntu 16.04' do
      let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

      it_behaves_like 'install'
      it_behaves_like 'setup without user'
    end

    context 'on CentOS 7.4' do
      let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

      it_behaves_like 'install'
      it_behaves_like 'setup without user'
    end
  end

  context 'When removal is requested' do
    recipe do
      radiator_installation '1.2.3' do
        provider 'archive'
        action :remove
      end
    end

    context 'on Ubuntu 16.04' do
      let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

      it_behaves_like 'uninstall'
      it_behaves_like 'cleanup'
    end

    context 'on CentOS 7.4' do
      let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

      it_behaves_like 'uninstall'
      it_behaves_like 'cleanup'
    end
  end

  context 'When removal is requested without user' do
    recipe do
      radiator_installation '1.2.3' do
        provider 'archive'
        user false

        action :remove
      end
    end

    context 'on Ubuntu 16.04' do
      let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

      it_behaves_like 'uninstall'
      it_behaves_like 'cleanup without user'
    end

    context 'on CentOS 7.4' do
      let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

      it_behaves_like 'uninstall'
      it_behaves_like 'cleanup without user'
    end
  end

  context 'When packs are installed' do
    context 'and packs are provided as an array' do
      recipe do
        radiator_installation '1.2.3' do
          provider 'archive'

          install_options do
            path '/tmp/radiator.tgz'
          end

          # TODO: This is not supported for archives, needs better tests
          packs %w(sim carrier notsupported)
        end
      end

      context 'on Ubuntu 16.04' do
        let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

        it_behaves_like 'install'
        it_behaves_like 'setup'
      end

      context 'on CentOS 7.4' do
        let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

        it_behaves_like 'install'
        it_behaves_like 'setup'
      end
    end

    context 'and packs are provided as a simple hash' do
      recipe do
        radiator_installation '1.2.3' do
          provider 'archive'

          install_options do
            path '/tmp/radiator.tgz'
          end

          # TODO: This is not supported for archives, needs better tests
          packs('sim' => '3.2.1',
                carrier: '5.4.3',
                notsupported: '6.6.6')
        end
      end

      context 'on Ubuntu 16.04' do
        let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

        it_behaves_like 'install'
        it_behaves_like 'setup'
      end

      context 'on CentOS 7.4' do
        let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

        it_behaves_like 'install'
        it_behaves_like 'setup'
      end
    end

    context 'and packs are provided as a more complex hash' do
      recipe do
        radiator_installation '1.2.3' do
          provider 'archive'

          install_options do
            path '/tmp/radiator.tgz'
          end

          packs('sim' => {
                  'version' => '3.2.1',
                  'install_options' => {
                    'path' => '/tmp/radiator-sim.tgz',
                  },
                },
                carrier: {
                  version: '5.4.3',
                  install_options: {
                    path: '/tmp/radiator-carrier.tgz',
                  },
                },
                notsupported: {
                  version: '6.6.6',
                  install_options: {
                    path: '/tmp/notsupported-at-all.tgz',
                  },
                })
        end
      end

      context 'on Ubuntu 16.04' do
        let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

        it_behaves_like 'pack install with versions'
        it_behaves_like 'setup'
      end

      context 'on CentOS 7.4' do
        let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

        it_behaves_like 'pack install with versions'
        it_behaves_like 'setup'
      end
    end

    context 'and packs are provided with install options' do
      recipe do
        radiator_installation '1.2.3' do
          provider 'archive'

          install_options do
            path '/tmp/radiator.tgz'
          end

          packs('sim' => {
                  'install_options' => {
                    'version' => '3.2.1',
                    'source_properties' => {
                      'headers' => { 'Authorization' => 'Testing One Two Three' },
                    },
                    'path' => 'https://www.example.com/tmp/radiator-sim.tgz',
                  },
                },
                carrier: {
                  install_options: {
                    version: '5.4.3',
                    source_properties: {
                      headers: { 'Authorization' => 'Testing One Two Three' },
                    },
                    path: 'https://www.example.com/tmp/radiator-carrier.tgz',
                  },
                },
                notsupported: {
                  install_options: {
                    version: '6.6.6',
                    source_properties: {
                      headers: { 'Authorization' => 'Testing One Two Three' },
                    },
                    path: 'https://www.example.com/tmp/notsupported-at-all.tgz',
                  },
                })
        end
      end

      context 'on Ubuntu 16.04' do
        let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

        it_behaves_like 'pack install with options'
        it_behaves_like 'setup'
      end

      context 'on CentOS 7.4' do
        let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

        it_behaves_like 'pack install with options'
        it_behaves_like 'setup'
      end
    end
  end

  context 'When packs are uninstalled' do
    context 'and packs are provided as an array' do
      recipe do
        radiator_installation '1.2.3' do
          provider 'archive'

          # TODO: This is not supported for archives, needs better tests
          packs %w(sim carrier notsupported)

          action :remove
        end
      end

      context 'on Ubuntu 16.04' do
        let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

        it_behaves_like 'uninstall'
        it_behaves_like 'cleanup'
      end

      context 'on CentOS 7.4' do
        let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

        it_behaves_like 'uninstall'
        it_behaves_like 'cleanup'
      end
    end

    context 'and packs are provided as a simple hash' do
      recipe do
        radiator_installation '1.2.3' do
          provider 'archive'

          # TODO: This is not supported for archives, needs better tests
          packs('sim' => '3.2.1',
                carrier: '5.4.3',
                notsupported: '6.6.6')

          action :remove
        end
      end

      context 'on Ubuntu 16.04' do
        let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

        it_behaves_like 'uninstall'
        it_behaves_like 'cleanup'
      end

      context 'on CentOS 7.4' do
        let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

        it_behaves_like 'uninstall'
        it_behaves_like 'cleanup'
      end
    end

    context 'and packs are provided as a more complex hash' do
      recipe do
        radiator_installation '1.2.3' do
          provider 'archive'

          install_options do
            path '/tmp/radiator.tgz'
          end

          packs('sim' => {
                  'version' => '3.2.1',
                  'install_options' => {
                    'path' => '/tmp/radiator-sim.tgz',
                  },
                },
                carrier: {
                  version: '5.4.3',
                  install_options: {
                    path: '/tmp/radiator-carrier.tgz',
                  },
                },
                notsupported: {
                  version: '6.6.6',
                  install_options: {
                    path: '/tmp/notsupported-at-all.tgz',
                  },
                })

          action :remove
        end
      end

      context 'on Ubuntu 16.04' do
        let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

        it_behaves_like 'pack uninstall'
        it_behaves_like 'cleanup'
      end

      context 'on CentOS 7.4' do
        let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

        it_behaves_like 'pack uninstall'
        it_behaves_like 'cleanup'
      end
    end
  end
end
