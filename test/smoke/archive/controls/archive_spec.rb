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

control 'radiator-archive-01' do
  title 'Radiator installed from archive'
  desc 'Ensure Radiator installation from archive has succeeded'

  # Radiator can be installed in a versioned directory or not, find it
  radiator_versioned_dirs = command('find /opt/ -type d -name radiator*').stdout.split

  radiator_versioned_dirs.each do |install_dir|
    describe file(install_dir) do
      it { should be_directory }
      it { should be_owned_by 'radiator' }
    end
  end

  describe file('/usr/local/bin/radiusd') do
    it { should be_symlink }
  end
end
