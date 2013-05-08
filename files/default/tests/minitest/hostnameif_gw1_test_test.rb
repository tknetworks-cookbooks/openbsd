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
require 'minitest/spec'

describe_recipe 'openbsd::hostnameif' do
  it 'creates /etc/hostname.carp0' do
    hostnameif = file("/etc/hostname.carp0")
    hostnameif.must_exist.with(:mode, "640").with(:owner, "root").with(:group, "wheel")
    hostnameif.must_include 'advbase 1 advskew 100 vhid 1 pass secret carpdev em1
inet 192.168.67.100 255.255.255.0
inet6 2001:db8:6dc:7aa::100 64'
  end

  it 'creates /etc/hostname.carp1' do
    hostnameif = file("/etc/hostname.carp1")
    hostnameif.must_exist.with(:mode, "640").with(:owner, "root").with(:group, "wheel")
    hostnameif.must_include 'advbase 1 advskew 100 vhid 20 pass secret carpdev em2
inet 10.0.67.100 255.255.255.0
inet6 2001:db8:6dc:7ff::100 96
!route add 10.0.30.0/24 10.0.67.30'
  end

  it 'creates /etc/hostname.gre100' do
    hostnameif = file("/etc/hostname.gre100")
    hostnameif.must_exist.with(:mode, "640").with(:owner, "root").with(:group, "wheel")
    hostnameif.must_include 'tunnel 10.0.40.10 10.0.40.11
mtu 1430
!/sbin/route add -inet6 default ::1 -ifp gre0'
  end

  it 'creates /etc/hostname.enc3' do
    hostnameif = file("/etc/hostname.enc3")
    hostnameif.must_exist.with(:mode, "640").with(:owner, "root").with(:group, "wheel")
    hostnameif.must_include 'rdomain 1
up'
  end
end
