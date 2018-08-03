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
# Spec:: utils
#

require_relative '../../spec_helper'
require_relative '../../../libraries/utils'

describe Radiator::Utils do
  let(:helper_class) { Class.new { include Radiator::Utils } }

  describe '#find_radiusd_bin' do
    context 'When run_state is set' do
      let(:node) { Chef::Node.new() }
      let(:desired_value) { '/usr/foo/bar/bin/radiusd' }

      before do
        node.run_state['radiator'] ||= {}
        node.run_state['radiator']['installation'] ||= {}
        node.run_state['radiator']['installation']['radiusd_bin_path'] = '/usr/foo/bar/bin/radiusd'
      end

      it 'should return correct radiusd bin path' do
        expect(helper_class.new.find_radiusd_bin(node)).to eq(desired_value)
      end
    end

    context 'When run_state is not set' do
      let(:node) { Chef::Node.new() }
      let(:desired_value) { '/usr/bin/radiusd' }

      it 'should return correct radiusd bin path' do
        expect(helper_class.new.find_radiusd_bin(node)).to eq(desired_value)
      end
    end
  end

  describe '#find_radiator_includes' do
    context 'When run_state is set' do
      let(:node) { Chef::Node.new() }
      let(:desired_value) { ['/opt/radiator', '/tmp/foo', '/tmp/bar'] }

      before do
        node.run_state['radiator'] ||= {}
        node.run_state['radiator']['installation'] ||= {}
        node.run_state['radiator']['installation']['perl_includes'] = ['/opt/radiator', '/tmp/foo', '/tmp/bar']
      end

      it 'should return correct includes array' do
        expect(helper_class.new.find_radiator_includes(node)).to eq(desired_value)
      end
    end

    context 'When run_state is not set' do
      let(:node) { Chef::Node.new() }
      let(:desired_value) { [] }

      it 'should return correct includes array' do
        expect(helper_class.new.find_radiator_includes(node)).to eq(desired_value)
      end
    end
  end

  describe '#grep_log' do
    context 'When no real warnings or errors are found' do
      let(:param_log) do
        <<-EOS
          Wed May  2 13:15:44 2018 065509: DEBUG: Finished reading configuration file '/etc/radiator/.chef-example20180502-11696-xgtybn.cfg'
          This Radiator license will expire on 2018-09-01
          Wed May  2 13:15:44 2018 065632: WARNING: This Radiator license will expire on 2018-09-01
          This Radiator license will stop operating after 1000 requests
          Wed May  2 13:15:44 2018 065761: WARNING: This Radiator license will stop operating after 1000 requests
          To license an unlimited full source version of Radiator, see
          https://www.open.com.au/ordering.html
          To extend your license period, contact info@open.com.au

          Wed May  2 13:15:44 2018 065833: WARNING: To license an unlimited full source version of Radiator, see
          https://www.open.com.au/ordering.html
          To extend your license period, contact info@open.com.au
        EOS
      end

      it 'should return true' do
        expect(helper_class.new.grep_log(param_log)).to be_truthy
      end
    end

    context 'When warnings are found' do
      let(:param_log) do
        <<-EOS
          Wed May  2 16:02:53 2018 702817: WARNING: Clause Handler still open. Opened in /etc/radiator/example.cfg line 37
          Wed May  2 16:02:53 2018 704392: DEBUG: Finished reading configuration file '/etc/radiator/example.cfg'
          This Radiator license will expire on 2018-09-01
          Wed May  2 16:02:53 2018 707679: WARNING: This Radiator license will expire on 2018-09-01
          This Radiator license will stop operating after 1000 requests
        EOS
      end

      it 'should return false' do
        expect(helper_class.new.grep_log(param_log)).to be_falsey
      end
    end

    context 'When errors are found' do
      let(:param_log) do
        <<-EOS
          Wed May  2 16:02:53 2018 702817: ERR: Clause Handler still open. Opened in /etc/radiator/example.cfg line 37
          Wed May  2 16:02:53 2018 704392: DEBUG: Finished reading configuration file '/etc/radiator/example.cfg'
          This Radiator license will expire on 2018-09-01
          Wed May  2 16:02:53 2018 707679: WARNING: This Radiator license will expire on 2018-09-01
          This Radiator license will stop operating after 1000 requests
        EOS
      end

      it 'should return false' do
        expect(helper_class.new.grep_log(param_log)).to be_falsey
      end
    end
  end
end
