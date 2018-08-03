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
# Spec:: helpers
#

require_relative '../../spec_helper'
require_relative '../../../libraries/helpers'

describe Radiator::Helpers::Configuration do
  let(:helper_class) { Class.new { include Radiator::Helpers::Configuration } }

  describe '#print_value' do
    let(:param_config) do
      {
        'a_single_string_value' => 'testing',
        'a_single_integer_value' => 3,
        'AN_Array_of_Values' => ['testing', '0.5', 12],
        'a_hash_of_values' => {
          'yet_another_string' => 'TestingToo',
        },
        'a_nil_value' => nil,
      }
    end

    context 'When default parameters are used' do
      context 'and the config contains a single string value' do
        let(:param_key) { 'a_single_string_value' }

        let(:desired_value) { "a_single_string_value testing\n" }

        it 'should return properly formatted value' do
          expect(helper_class.new.print_value(param_config, param_key)).to eq(desired_value)
        end
      end

      context 'and the config contains a single integer value' do
        let(:param_key) { 'a_single_integer_value' }

        let(:desired_value) { "a_single_integer_value 3\n" }

        it 'should return properly formatted value' do
          expect(helper_class.new.print_value(param_config, param_key)).to eq(desired_value)
        end
      end

      context 'and the config contains an array of values' do
        let(:param_key) { 'AN_Array_of_Values' }

        let(:desired_value) { "AN_Array_of_Values testing\nAN_Array_of_Values 0.5\nAN_Array_of_Values 12\n" }

        it 'should return properly formatted value' do
          expect(helper_class.new.print_value(param_config, param_key)).to eq(desired_value)
        end
      end

      context 'and the config contains a hash of values' do
        let(:param_key) { 'a_hash_of_values' }

        it 'should print a warning and return nil' do
          expect(Chef::Log).to receive(:warn)
          expect(helper_class.new.print_value(param_config, param_key)).to be_nil
        end
      end

      context 'and the config contains a nil value' do
        let(:param_key) { 'a_nil_value' }

        it 'should print a warning and return nil' do
          expect(Chef::Log).to receive(:warn)
          expect(helper_class.new.print_value(param_config, param_key)).to be_nil
        end
      end

      context 'and a missing key is given' do
        let(:param_key) { 'a_missing_key' }

        it 'should return nil' do
          expect(helper_class.new.print_value(param_config, param_key)).to be_nil
        end
      end
    end

    context 'When an indent is provided' do
      let(:param_indent) { 4 }

      context 'and the config contains a single string value' do
        let(:param_key) { 'a_single_string_value' }

        let(:desired_value) { "    a_single_string_value testing\n" }

        it 'should return properly formatted value' do
          expect(helper_class.new.print_value(param_config, param_key, indent: param_indent)).to eq(desired_value)
        end
      end

      context 'and the config contains a single integer value' do
        let(:param_key) { 'a_single_integer_value' }

        let(:desired_value) { "    a_single_integer_value 3\n" }

        it 'should return properly formatted value' do
          expect(helper_class.new.print_value(param_config, param_key, indent: param_indent)).to eq(desired_value)
        end
      end

      context 'and the config contains an array of values' do
        let(:param_key) { 'AN_Array_of_Values' }

        let(:desired_value) { "    AN_Array_of_Values testing\n    AN_Array_of_Values 0.5\n    AN_Array_of_Values 12\n" }

        it 'should return properly formatted value' do
          expect(helper_class.new.print_value(param_config, param_key, indent: param_indent)).to eq(desired_value)
        end
      end
    end

    context 'When a default value is provided' do
      let(:param_default) { 'default' }

      context 'and the config contains a value' do
        let(:param_key) { 'a_single_string_value' }

        let(:desired_value) { "a_single_string_value testing\n" }

        it 'should return properly formatted value' do
          expect(helper_class.new.print_value(param_config, param_key, default: param_default)).to eq(desired_value)
        end
      end

      context 'and the config contains a nil value' do
        let(:param_key) { 'a_nil_value' }

        let(:desired_value) { "a_nil_value default\n" }

        it 'should return properly formatted default value' do
          expect(helper_class.new.print_value(param_config, param_key, default: param_default)).to eq(desired_value)
        end
      end

      context 'and the config does not contain the key' do
        let(:param_key) { 'a_missing_key' }

        let(:desired_value) { "a_missing_key default\n" }

        it 'should return properly formatted default value' do
          expect(helper_class.new.print_value(param_config, param_key, default: param_default)).to eq(desired_value)
        end
      end
    end
  end
end
