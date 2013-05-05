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

describe 'openbsd::hostnameif' do
  include_context 'openbsd'

  before do
    item = JSON.parse(open(File.expand_path('../../data_bags/openbsd_hostnameif/ipsec-gw1.json', __FILE__)).read)
    item['id'] = chef_run.node['hostname']
    data_bag_item = Chef::DataBagItem.new
    data_bag_item.raw_data = item
    Chef::Recipe.any_instance.stub(:data_bag_item).with('openbsd_hostnameif', 'chefspec').and_return(data_bag_item)
    chef_run.converge('openbsd::hostnameif')
  end

  it 'should create /etc/hostname.carp0' do
    expect(chef_run).to create_file_with_content '/etc/hostname.carp0', 'advbase 1 advskew 100 vhid 1 pass secret carpdev em1
inet 192.168.67.100 255.255.255.0
inet6 2001:db8:6dc:7aa::100 64'
  end

  it 'should create /etc/hostname.carp1' do
    expect(chef_run).to create_file_with_content '/etc/hostname.carp1', 'advbase 1 advskew 100 vhid 20 pass secret carpdev em2
inet 10.0.67.100 255.255.255.0
inet6 2001:db8:6dc:7ff::100 96
!route add 10.0.30.0/24 10.0.67.30'
  end

  it 'should create /etc/hostname.gre100' do
    expect(chef_run).to create_file_with_content '/etc/hostname.gre100', 'tunnel 10.0.40.10 10.0.40.11
mtu 1430
!/sbin/route add -inet6 default ::1 -ifp gre0'
  end

  it 'should create /etc/hostname.enc3' do
    expect(chef_run).to create_file_with_content '/etc/hostname.enc3', 'rdomain 1
up'
  end
end
