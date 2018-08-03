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

control 'radiator-deb-01' do
  title 'Radiator installed from deb'
  desc 'Ensure Radiator installation from deb has succeeded'

  perl_version = command('perl --version | grep version').stdout.match(/\(v[0-9\.]*\)/).to_s.tr('(v)', '')

  describe file("/usr/local/share/perl/#{perl_version}/Radius") do
    it { should be_directory }
    it { should be_owned_by 'root' }
  end

  describe file('/usr/bin/radiusd') do
    it { should be_owned_by 'root' }
  end

  describe package('radiator') do
    it { should be_installed }
  end
end
