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
# Spec:: radiator_installation_package
#

require_relative '../../spec_helper'
require_relative '../../../libraries/radiator_installation'
require_relative '../../../libraries/radiator_installation_package'

describe Radiator::Resource::Installation do
  let(:default_attributes) do
    {
      'radiator' => {
        'user' => 'radiator',
        'group' => 'radiator',
        'user_home' => '/home/radiator',
        'user_shell' => '/bin/false',
        'supported_packs' => %w(sim telco carrier gba-bsf),
      },
    }
  end

  step_into(:radiator_installation)

  shared_examples_for 'install' do
    it 'installs package' do
      is_expected.to create_radiator_installation('1.2.3')
      is_expected.to install_package('radiator').with(
        version: '1.2.3'
      )
    end
  end

  shared_examples_for 'install with nil' do
    it 'installs package with any version' do
      is_expected.to create_radiator_installation('version-defined-as-nil')
      is_expected.to install_package('radiator').with(
        version: nil
      )
    end
  end

  shared_examples_for 'install with version' do
    it 'installs package with version' do
      is_expected.to create_radiator_installation('version-defined-as-1.2.3')
      is_expected.to install_package('radiator').with(
        version: '1.2.3'
      )
    end
  end

  shared_examples_for 'install with options' do
    it 'upgrades package with options' do
      is_expected.to create_radiator_installation('1.2.3')
      is_expected.to upgrade_package('radiator').with(
        options: ['--no-install-recommends', '--assume-yes']
      )
    end
  end

  shared_examples_for 'install with version in options' do
    it 'installs package with version' do
      is_expected.to create_radiator_installation('version-defined-in-options')
      is_expected.to install_package('radiator').with(
        version: '3.2.1'
      )
    end
  end

  shared_examples_for 'install with remote source' do
    it 'installs package with source' do
      is_expected.to create_radiator_installation('1.2.3')
      is_expected.to create_remote_file("#{Chef::Config[:file_cache_path]}/MS4yLjM_radiator.pkg").with(
        source: 'https://example.com/download/radiator.pkg'
      )
      is_expected.to install_package('radiator').with(
        source: "#{Chef::Config[:file_cache_path]}/MS4yLjM_radiator.pkg"
      )
    end
  end

  shared_examples_for 'install with local source' do
    it 'installs package with source' do
      is_expected.to create_radiator_installation('1.2.3')
      is_expected.to install_package('radiator').with(
        source: '/tmp/downloaded/radiator.pkg'
      )
    end
  end

  shared_examples_for 'pack install' do
    it 'installs packages' do
      is_expected.to create_radiator_installation('1.2.3')
      is_expected.to install_package('radiator').with(
        version: '1.2.3'
      )
      is_expected.to install_package('radiator-sim')
      is_expected.to install_package('radiator-carrier')
      is_expected.to_not install_package('radiator-notsupported')
    end
  end

  shared_examples_for 'pack install with versions' do
    it 'installs packages' do
      is_expected.to create_radiator_installation('1.2.3')
      is_expected.to install_package('radiator').with(
        version: '1.2.3'
      )
      is_expected.to install_package('radiator-sim').with(
        version: '3.2.1'
      )
      is_expected.to install_package('radiator-carrier').with(
        version: '5.4.3'
      )
      is_expected.to_not install_package('radiator-notsupported')
    end
  end

  shared_examples_for 'pack install with options' do
    it 'installs packages' do
      is_expected.to create_radiator_installation('1.2.3')
      is_expected.to install_package('radiator').with(
        version: '1.2.3'
      )
      is_expected.to upgrade_package('radiator-sim').with(
        version: '3.2.1',
        options: ['--no-install-recommends', '--assume-yes']
      )
      is_expected.to upgrade_package('radiator-carrier').with(
        version: '5.4.3',
        options: ['--no-install-recommends', '--assume-yes']
      )
      is_expected.to_not install_package('radiator-notsupported')
    end
  end

  shared_examples_for 'pack install with remote source' do
    it 'installs packages' do
      is_expected.to create_radiator_installation('1.2.3')
      is_expected.to install_package('radiator').with(
        version: '1.2.3'
      )
      is_expected.to create_remote_file("#{Chef::Config[:file_cache_path]}/MS4yLjM_radiator-sim.pkg").with(
        source: 'https://example.com/download/radiator-sim.pkg'
      )
      is_expected.to install_package('radiator-sim').with(
        source: "#{Chef::Config[:file_cache_path]}/MS4yLjM_radiator-sim.pkg"
      )
      is_expected.to create_remote_file("#{Chef::Config[:file_cache_path]}/MS4yLjM_radiator-carrier.pkg").with(
        source: 'https://example.com/download/radiator-carrier.pkg'
      )
      is_expected.to install_package('radiator-carrier').with(
        source: "#{Chef::Config[:file_cache_path]}/MS4yLjM_radiator-carrier.pkg"
      )
      is_expected.to_not install_package('radiator-notsupported')
    end
  end

  shared_examples_for 'pack install with local source' do
    it 'installs packages' do
      is_expected.to create_radiator_installation('1.2.3')
      is_expected.to install_package('radiator').with(
        version: '1.2.3'
      )
      is_expected.to install_package('radiator-sim').with(
        source: '/tmp/downloaded/radiator-sim.pkg'
      )
      is_expected.to install_package('radiator-carrier').with(
        source: '/tmp/downloaded/radiator-carrier.pkg'
      )
      is_expected.to_not install_package('radiator-notsupported')
    end
  end

  shared_examples_for 'uninstall' do
    it 'removes package' do
      is_expected.to remove_radiator_installation('1.2.3')
      is_expected.to remove_package('radiator')
    end
  end

  shared_examples_for 'pack uninstall' do
    it 'uninstalls packages' do
      is_expected.to remove_radiator_installation('1.2.3')
      is_expected.to remove_package('radiator')
      is_expected.to remove_package('radiator-sim')
      is_expected.to remove_package('radiator-carrier')
      is_expected.to_not remove_package('radiator-notsupported')
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
        provider 'package'
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
        provider 'package'
        version '1.2.3'
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
        provider 'package'
        version nil
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
        provider 'package'

        install_options do
          options '--no-install-recommends --assume-yes'
          action 'upgrade'
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
        provider 'package'

        install_options do
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

  context 'When URI source is provided in install options' do
    recipe do
      radiator_installation '1.2.3' do
        provider 'package'

        install_options do
          source 'https://example.com/download/radiator.pkg'
        end
      end
    end

    context 'on Ubuntu 16.04' do
      let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

      it_behaves_like 'install with remote source'
      it_behaves_like 'setup'
    end

    context 'on CentOS 7.4' do
      let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

      it_behaves_like 'install with remote source'
      it_behaves_like 'setup'
    end
  end

  context 'When path source is provided in install options' do
    recipe do
      radiator_installation '1.2.3' do
        provider 'package'

        install_options do
          source '/tmp/downloaded/radiator.pkg'
        end
      end
    end

    context 'on Ubuntu 16.04' do
      let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

      it_behaves_like 'install with local source'
      it_behaves_like 'setup'
    end

    context 'on CentOS 7.4' do
      let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

      it_behaves_like 'install with local source'
      it_behaves_like 'setup'
    end
  end

  context 'When user creation is disabled' do
    recipe do
      radiator_installation '1.2.3' do
        provider 'package'
        user false
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
        provider 'package'
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
        provider 'package'
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
          provider 'package'

          packs %w(sim carrier notsupported)
        end
      end

      context 'on Ubuntu 16.04' do
        let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

        it_behaves_like 'pack install'
        it_behaves_like 'setup'
      end

      context 'on CentOS 7.4' do
        let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

        it_behaves_like 'pack install'
        it_behaves_like 'setup'
      end
    end

    context 'and packs are provided as a simple hash' do
      recipe do
        radiator_installation '1.2.3' do
          provider 'package'

          packs('sim' => '3.2.1',
                carrier: '5.4.3',
                notsupported: '6.6.6')
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

    context 'and packs are provided as a more complex hash' do
      recipe do
        radiator_installation '1.2.3' do
          provider 'package'

          packs('sim' => {
                  'version' => '3.2.1',
                },
                carrier: {
                  version: '5.4.3',
                },
                notsupported: {
                  version: '6.6.6',
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
          provider 'package'

          packs('sim' => {
                  'install_options' => {
                    'version' => '3.2.1',
                    'action' => 'upgrade',
                    'options' => '--no-install-recommends --assume-yes',
                  },
                },
                carrier: {
                  install_options: {
                    version: '5.4.3',
                    action: 'upgrade',
                    options: '--no-install-recommends --assume-yes',
                  },
                },
                notsupported: {
                  install_options: {
                    version: '6.6.6',
                    action: 'upgrade',
                    options: '--no-install-recommends --assume-yes',
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

    context 'and packs are provided with remote source in install options' do
      recipe do
        radiator_installation '1.2.3' do
          provider 'package'

          packs('sim' => {
                  'install_options' => {
                    'version' => '3.2.1',
                    'source' => 'https://example.com/download/radiator-sim.pkg',
                  },
                },
                carrier: {
                  install_options: {
                    version: '5.4.3',
                    source: 'https://example.com/download/radiator-carrier.pkg',
                  },
                },
                notsupported: {
                  install_options: {
                    version: '6.6.6',
                    source: 'https://example.com/download/im-not-going-to-be-installed.pkg',
                  },
                })
        end
      end

      context 'on Ubuntu 16.04' do
        let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

        it_behaves_like 'pack install with remote source'
        it_behaves_like 'setup'
      end

      context 'on CentOS 7.4' do
        let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

        it_behaves_like 'pack install with remote source'
        it_behaves_like 'setup'
      end
    end

    context 'and packs are provided with local source in install options' do
      recipe do
        radiator_installation '1.2.3' do
          provider 'package'

          packs('sim' => {
                  'install_options' => {
                    'version' => '3.2.1',
                    'source' => '/tmp/downloaded/radiator-sim.pkg',
                  },
                },
                carrier: {
                  install_options: {
                    version: '5.4.3',
                    source: '/tmp/downloaded/radiator-carrier.pkg',
                  },
                },
                notsupported: {
                  install_options: {
                    version: '6.6.6',
                    source: '/tmp/im-not-going-to-be-installed.pkg',
                  },
                })
        end
      end

      context 'on Ubuntu 16.04' do
        let(:chefspec_options) { { platform: 'ubuntu', version: '16.04' } }

        it_behaves_like 'pack install with local source'
        it_behaves_like 'setup'
      end

      context 'on CentOS 7.4' do
        let(:chefspec_options) { { platform: 'centos', version: '7.4.1708' } }

        it_behaves_like 'pack install with local source'
        it_behaves_like 'setup'
      end
    end

    context 'When packs are uninstalled' do
      context 'and packs are provided as an array' do
        recipe do
          radiator_installation '1.2.3' do
            provider 'package'

            packs %w(sim carrier notsupported)

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

      context 'and packs are provided as a simple hash' do
        recipe do
          radiator_installation '1.2.3' do
            provider 'package'

            packs('sim' => '3.2.1',
                  carrier: '5.4.3',
                  notsupported: '6.6.6')

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
end
