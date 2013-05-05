#
# Author:: Ken-ichi TANABE (<nabeken@tknetworks.org>)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
require 'spec_helper'

describe 'openbsd::ipsec_initiator_test' do
  include_context 'openbsd'

  shared_examples_for 'ipsec{,_chef}.conf' do
    it 'should create /etc/ipsec{,_chef}.conf' do
      expect(chef_run).to create_file_with_content '/etc/ipsec.conf', 'include "/etc/ipsec_chef.conf"'
      expect(chef_run).to create_file_with_content '/etc/ipsec_chef.conf', "# chefspec.local -> ipsec-gw1.example.org
ike dynamic esp proto gre from 10.7.43.10/32 to 10.7.43.2/32 peer #{chef_run.node['openbsd']['ipsec']['gw_addr']} psk #{chef_run.node['openbsd']['ipsec']['psk']}"
    end
  end

  context 'without rdomain' do
    before do
      Chef::Recipe.any_instance.stub(:data_bag_item).with('ipsec', 'ipsec-gw1').and_return(
        "vpn1" => {
          "ipsec-gw1.example.org" => {
            "lo1" => "10.7.43.2",
            "gre1" => "10.7.50.2"
          },
          "chefspec.local" => {
            "lo1" => "10.7.43.10",
            "gre1" => "10.7.50.10"
          }
        }
      )
      chef_run.converge('openbsd::ipsec_initiator_test')
    end

    it_behaves_like 'ipsec{,_chef}.conf'

    it 'should create /etc/hostname.lo1' do
      expect(chef_run).to create_file_with_content '/etc/hostname.lo1', "inet 10.7.43.10"
    end

    it 'should create /etc/hostname.gre1' do
      expect(chef_run).to create_file_with_content '/etc/hostname.gre1', "tunnel 10.7.43.10 10.7.43.2
10.7.50.10 10.7.50.2"
    end

    it 'should enable/start isakmpd' do
      expect(chef_run).to start_service 'isakmpd'
      expect(chef_run).to enable_service 'isakmpd'
    end

    it 'should enable ipsec' do
      expect(chef_run).to enable_service 'ipsec'
    end
  end

  context 'with rdomain 1' do
    before do
      Chef::Recipe.any_instance.stub(:data_bag_item).with('ipsec', 'ipsec-gw1').and_return(
        "vpn1" => {
          "ipsec-gw1.example.org" => {
            "lo1" => "10.7.43.2",
            "gre1" => "10.7.50.2"
          },
          "chefspec.local" => {
            "lo1" => "10.7.43.10",
            "gre1" => "10.7.50.10",
            "enc1" => "up",
            "rdomain" => 1
          }
        }
      )
      chef_run.converge('openbsd::ipsec_initiator_test')
    end

    it_behaves_like 'ipsec{,_chef}.conf'

    it 'should create /etc/hostname.lo1' do
      expect(chef_run).to create_file_with_content '/etc/hostname.lo1', "rdomain 1
inet 10.7.43.10"
    end

    it 'should create /etc/hostname.gre1' do
      expect(chef_run).to create_file_with_content '/etc/hostname.gre1', "tunneldomain 1
tunnel 10.7.43.10 10.7.43.2
10.7.50.10 10.7.50.2"
    end

    it 'should create /etc/hostname.enc1' do
      expect(chef_run).to create_file_with_content '/etc/hostname.enc1', "rdomain 1
up"
    end
  end
end
