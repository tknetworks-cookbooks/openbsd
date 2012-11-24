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
require 'chef/mixin/shell_out'

execute "reload-ipsec-conf" do
  extend Chef::Mixin::ShellOut
  command "/sbin/ipsecctl -f /etc/ipsec.conf"
  action :nothing
  only_if do
    shell_out("/usr/bin/pgrep isakmpd", :env => nil).status.success?
  end
end

template "/etc/ipsec.conf" do
  source "ipsec.conf"
  mode 0600
  owner "root"
  group node[:etc][:passwd][:root][:gid]
  notifies :run, "execute[reload-ipsec-conf]"
end