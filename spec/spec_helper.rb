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
require 'chefspec'

shared_context 'openbsd' do
  let (:chef_run) {
    ChefSpec::ChefRunner.new(
      :step_into => %w{openbsd_ipsec openbsd_interface openbsd_ike openbsd_reload_ipsec_conf}
    ) do |node|
      node.automatic_attrs['platform'] = 'openbsd'
      node.set['etc']['passwd']['root']['gid'] = 0
    end
  }

  before do
    Chef::Config[:role_path] = ::File.expand_path('../../roles', __FILE__)
  end
end
