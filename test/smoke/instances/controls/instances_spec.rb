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

control 'radiator-instances-01' do
  title 'Radiator Instances'
  desc 'Ensure multiple Radiator instaces are configured and running'

  describe file('/etc/radiator/instances.cfg') do
    it { should be_owned_by 'radiator' }
  end

  describe service('radiator-instance@1') do
    it { should be_enabled }
    it { should be_running }
  end

  describe service('radiator-instance@2') do
    it { should be_enabled }
    it { should be_running }
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
