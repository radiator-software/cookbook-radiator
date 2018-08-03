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

control 'radiator-01' do
  title 'Radiator'
  desc 'Ensure Radiator is installed and running'

  describe package('perl') do
    it { should be_installed }
  end

  describe user('radiator') do
    it { should exist }
  end

  describe file('/var/run/radiator') do
    it { should be_directory }
    it { should be_owned_by 'radiator' }
  end

  describe file('/var/log/radiator') do
    it { should be_directory }
    it { should be_owned_by 'radiator' }
  end

  describe file('/etc/radiator') do
    it { should be_directory }
    it { should be_owned_by 'radiator' }
  end

  describe file('/etc/radiator/radius.cfg') do
    it { should be_owned_by 'radiator' }
  end

  if os[:family] == 'redhat'
    describe package('perl-Digest-MD5') do
      it { should be_installed }
    end

    describe package('perl-Digest-SHA') do
      it { should be_installed }
    end
  elsif %w(debian ubuntu).include?(os[:family])
    describe package('libdigest-md5-file-perl') do
      it { should be_installed }
    end

    describe package('libdigest-sha-perl') do
      it { should be_installed }
    end
  end

  describe service('radiator') do
    it { should be_enabled }
    it { should be_running }
  end

  describe service('radiator-instance@1') do
    it { should be_enabled }
    it { should be_running }
  end

  describe service('radiator-instance@2') do
    it { should be_enabled }
    it { should be_running }
  end

  describe file('/etc/radiator/instances.cfg') do
    it { should be_owned_by 'radiator' }
  end

  describe port(1812) do
    its('protocols') { should include 'udp' }
  end

  describe port(1813) do
    its('protocols') { should include 'udp' }
  end

  describe port(11812) do
    its('protocols') { should include 'udp' }
  end

  describe port(11813) do
    its('protocols') { should include 'udp' }
  end

  describe port(21812) do
    its('protocols') { should include 'udp' }
  end

  describe port(21813) do
    its('protocols') { should include 'udp' }
  end
end
