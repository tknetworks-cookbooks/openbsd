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

describe 'openbsd::ipsec_responder_test' do
  include_context 'openbsd'

  context 'without rdomain' do
    before do
      chef_run.node.automatic_attrs['fqdn'] = 'ipsec-gw1.example.org'
      chef_run.node.automatic_attrs['hostname'] = 'ipsec-gw1'
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
      chef_run.converge('openbsd::ipsec_responder_test')
    end

    it 'should create /etc/ipsec{,_chef}.conf' do
      expect(chef_run).to create_file_with_content '/etc/ipsec.conf', 'include "/etc/ipsec_chef.conf"'
      expect(chef_run).to create_file_with_content '/etc/ipsec_chef.conf', "# ipsec-gw1.example.org -> chefspec.local
ike passive esp proto gre from 10.7.43.2/32 to 10.7.43.10/32 peer any psk #{chef_run.node['openbsd']['ipsec']['psk']}"
    end


    it 'should create /etc/hostname.lo1' do
      expect(chef_run).to create_file_with_content '/etc/hostname.lo1', "inet 10.7.43.2"
    end

    it 'should create /etc/hostname.gre1' do
      expect(chef_run).to create_file_with_content '/etc/hostname.gre1', "tunnel 10.7.43.2 10.7.43.10
10.7.50.2 10.7.50.10"
    end

    it 'should enable/start isakmpd' do
      expect(chef_run).to start_service 'isakmpd'
      expect(chef_run).to enable_service 'isakmpd'
    end

    it 'should enable ipsec' do
      expect(chef_run).to enable_service 'ipsec'
    end
  end
end
