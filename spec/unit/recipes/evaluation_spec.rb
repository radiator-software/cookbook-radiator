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
# Spec:: evaluation
#

require 'spec_helper'

describe 'radiator::evaluation' do
  shared_examples_for 'evaluation recipe' do
    it 'includes radiator::dependencies' do
      expect_any_instance_of(Chef::Recipe).to receive(:include_recipe).with('radiator::dependencies')
      chef_run
    end
  end

  shared_examples_for 'evaluation install' do
    let(:eval_file) { "#{Chef::Config[:file_cache_path]}/Radiator-Locked-#{chef_run.node['radiator']['evaluation']['install_version']}.tgz" }
    let(:eval_auth) { Base64.encode64('chef:spec').gsub('\n', '') }

    it 'shows radiator license' do
      expect(chef_run).to run_ruby_block('show-radiator-license')
    end

    it 'gets download url' do
      expect(chef_run).to run_ruby_block('get-radiator-download-url')
    end

    it 'installs and configures radiator' do
      expect(chef_run).to create_radiator_installation('radiator-evaluation').with(
                                                                                    # TODO: I couldn't get these matches to work, as path is lazily evaluated
                                                                                    # provider: Radiator::Provider::InstallationArchive,
                                                                                    # install_options: {
                                                                                    #   'destination' => '/opt/radiator-locked',
                                                                                    #   'source_properties' => {
                                                                                    #     'headers' => { 'Authorization' => "Basic #{eval_auth}" },
                                                                                    #   },
                                                                                    # }
                                                                                  )
      expect(chef_run).to create_radiator_configuration('radius')
      expect(chef_run).to enable_radiator_service('radiator').with(
        config_path: '/etc/radiator/radius.cfg'
      )
    end
  end

  context 'When evaluation install is wanted' do
    before do
      allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).and_call_original
      allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).with('radiator::dependencies')
    end

    context 'on Ubuntu 16.04' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04') do |node|
          node.override['radiator']['evaluation']['show_license'] = true
          node.override['radiator']['evaluation']['accept_license'] = true
          node.override['radiator']['evaluation']['download_username'] = 'chef'
          node.override['radiator']['evaluation']['download_password'] = 'spec'
        end.converge(described_recipe)
      end

      include_examples 'standard chef run expectations'

      it_behaves_like 'evaluation recipe'
      it_behaves_like 'evaluation install'
    end

    context 'on CentOS 7.4' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'centos', version: '7.4.1708') do |node|
          node.override['radiator']['evaluation']['show_license'] = true
          node.override['radiator']['evaluation']['accept_license'] = true
          node.override['radiator']['evaluation']['download_username'] = 'chef'
          node.override['radiator']['evaluation']['download_password'] = 'spec'
        end.converge(described_recipe)
      end

      include_examples 'standard chef run expectations'

      it_behaves_like 'evaluation recipe'
      it_behaves_like 'evaluation install'
    end
  end
end
