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
# Spec:: dependencies
#

require 'spec_helper'

describe 'radiator::dependencies' do
  shared_examples_for 'dependencies recipe' do
    it 'includes build-essential::default' do
      expect_any_instance_of(Chef::Recipe).to receive(:include_recipe).with('build-essential::default')
      chef_run
    end
  end

  shared_examples_for 'radiator ubuntu dependencies' do
    it 'updates apt repo' do
      expect(chef_run).to update_apt_update('apt-get update')
    end

    it 'installs required packages' do
      expect(chef_run).to install_package(%w(perl cpanminus libdigest-md5-file-perl libdigest-sha-perl libdigest-md4-perl))
    end
  end

  shared_examples_for 'radiator-sim ubuntu dependencies' do
    it 'installs required packages' do
      expect(chef_run).to install_package(%w(libconvert-asn1-perl libcrypt-rijndael-perl libdigest-sha-perl libdigest-hmac-perl libdata-messagepack-perl))
    end

    it 'installs required cpan modules' do
      expect(chef_run).to install_cpan_module('Digest::SHA1')
    end
  end

  shared_examples_for 'radiator-gba-bsf ubuntu dependencies' do
    it 'installs required packages' do
      expect(chef_run).to install_package(%w(libxml-libxml-perl libdigest-sha-perl libcache-fastmmap-perl libcrypt-rijndael-perl libdigest-sha-perl libdigest-hmac-perl libdata-messagepack-perl))
    end
  end

  shared_examples_for 'radiator centos dependencies' do
    it 'installs required packages' do
      expect(chef_run).to install_package(%w(perl perl-App-cpanminus perl-Digest-MD5 perl-Digest-SHA perl-Time-HiRes))
    end

    it 'installs required cpan modules' do
      expect(chef_run).to install_cpan_module('Digest::MD4')
    end
  end

  shared_examples_for 'radiator-sim centos dependencies' do
    it 'installs required packages' do
      expect(chef_run).to install_package(%w(perl-Convert-ASN1 perl-Digest-SHA1))
    end
  end

  shared_examples_for 'radiator-gba-bsf centos dependencies' do
    it 'installs required packages' do
      expect(chef_run).to install_package(%w(perl-XML-LibXML perl-Digest-SHA))
    end

    it 'installs required cpan modules' do
      expect(chef_run).to install_cpan_module('Cache::FastMmap')
    end
  end

  context 'When all attributes are default' do
    before do
      allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).and_call_original
      allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).with('build-essential::default')
    end

    context 'on Ubuntu 16.04' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(
          platform: 'ubuntu',
          version: '16.04'
        ).converge(described_recipe)
      end

      include_examples 'standard chef run expectations'

      it_behaves_like 'radiator ubuntu dependencies'
      it_behaves_like 'dependencies recipe'
    end

    context 'on CentOS 7.4' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(
          platform: 'centos',
          version: '7.4.1708'
        ).converge(described_recipe)
      end

      include_examples 'standard chef run expectations'

      it_behaves_like 'radiator centos dependencies'
      it_behaves_like 'dependencies recipe'
    end
  end

  context 'When SIM pack is selected for installation' do
    context 'on Ubuntu 16.04' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04') do |node|
          node.override['radiator']['install_packs'] = [
            'sim',
          ]
        end.converge(described_recipe)
      end

      include_examples 'standard chef run expectations'

      it_behaves_like 'radiator ubuntu dependencies'
      it_behaves_like 'radiator-sim ubuntu dependencies'
    end

    context 'on CentOS 7.4' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'centos', version: '7.4.1708') do |node|
          node.override['radiator']['install_packs'] = [
            'sim',
          ]
        end.converge(described_recipe)
      end

      include_examples 'standard chef run expectations'

      it_behaves_like 'radiator centos dependencies'
      it_behaves_like 'radiator-sim centos dependencies'
    end
  end

  context 'When GBA-BSF pack is selected for installation' do
    context 'on Ubuntu 16.04' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04') do |node|
          node.override['radiator']['install_packs'] = [
            'gba-bsf',
          ]
        end.converge(described_recipe)
      end

      include_examples 'standard chef run expectations'

      it_behaves_like 'radiator ubuntu dependencies'
      it_behaves_like 'radiator-gba-bsf ubuntu dependencies'
    end

    context 'on CentOS 7.4' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'centos', version: '7.4.1708') do |node|
          node.override['radiator']['install_packs'] = [
            'gba-bsf',
          ]
        end.converge(described_recipe)
      end

      include_examples 'standard chef run expectations'

      it_behaves_like 'radiator centos dependencies'
      it_behaves_like 'radiator-gba-bsf centos dependencies'
    end
  end
end
