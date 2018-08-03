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
# Spec:: spec_helper
#

gem 'chef', '= 13.8.5'

require 'chefspec'
require 'chefspec/berkshelf'
require 'halite/spec_helper'
require 'poise_archive/cheftie'
require 'simplecov'

if ENV['TRAVIS'] == 'true'
  begin
    require 'coveralls'

    SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  rescue NameError
    raise 'Could not load coveralls. Please install it first.'
  end
else
  require 'fileutils'

  coverage_dir = 'test-coverage'
  FileUtils.mkdir_p(coverage_dir)

  SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
end

SimpleCov.coverage_dir(coverage_dir)
SimpleCov.minimum_coverage(90)
SimpleCov.start do
  add_filter '/spec/'
end

RSpec.configure do |config|
  config.include Halite::SpecHelper
  config.backtrace_exclusion_patterns << %r{/halite/spec_helper}

  config.color = true
  config.tty = true

  config.formatter = :documentation

  config.file_cache_path = Chef::Config[:file_cache_path]
end

RSpec.shared_examples 'standard chef run expectations' do
  it 'converges successfully' do
    expect { chef_run }.to_not raise_error
  end
end

# Mock SystemD service resource provider
def set_systemd!
  allow(Chef::Platform::ServiceHelpers).to receive(:service_resource_providers).and_return([:systemd])
end
