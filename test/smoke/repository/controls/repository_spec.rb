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

case os[:family]
when 'redhat'
  include_controls 'rpm'
when 'debian'
  include_controls 'deb'
end

control 'radiator-repository-01' do
  title 'Radiator installed from repository'
  desc 'Ensure Radiator installation from repository has succeeded'

  describe package('radiator-sim') do
    it { should be_installed }
  end

  describe package('radiator-carrier') do
    it { should be_installed }
  end

  describe package('radiator-telco') do
    it { should be_installed }
  end
end
