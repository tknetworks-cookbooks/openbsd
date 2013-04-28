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

describe_recipe 'openbsd::ipsec_initiator' do
  it 'sets net.inet.gre.allow=1' do
    value = 'net.inet.gre.allow=1'
    file("/etc/sysctl.conf").must_include value
    assert_sh "[ \"x`sysctl net.inet.gre.allow`\" = 'x#{value}' ]"
  end

  it 'creates hostname.lo1' do
    hostnameif = file("/etc/hostname.lo1")
    hostnameif.must_exist.with(:mode, "640").with(:owner, "root").with(:group, "wheel")
    hostnameif.must_include "rdomain 1
inet 10.7.43.10"
  end

  it 'creates hostname.gre1' do
    hostnameif = file("/etc/hostname.gre1")
    hostnameif.must_exist.with(:mode, "640").with(:owner, "root").with(:group, "wheel")
    hostnameif.must_include "tunneldomain 1
tunnel 10.7.43.10 10.7.43.2
10.7.50.10 10.7.50.2 netmask 255.255.255.255"
  end

  it 'creates hostname.enc1' do
    hostnameif = file("/etc/hostname.enc1")
    hostnameif.must_include "rdomain 1
up"
  end

  it 'creates ipsec.conf' do
    ipsecconf = file("/etc/ipsec.conf")
    ipsecconf.must_exist.with(:mode, "600").with(:owner, "root").with(:group, "wheel")
    ipsecconf.must_include %Q[include "/etc/ipsec_chef.conf"]
  end

  it 'creates ipsec_chef.conf' do
    ipsecchefconf = file("/etc/ipsec_chef.conf")
    ipsecchefconf.must_exist.with(:mode, "600").with(:owner, "root").with(:group, "wheel")
    ipsecchefconf.must_include "# vagrant-openbsd1 -> ipsec-gw.example.org
ike dynamic esp proto gre from 10.7.43.10/32 to 10.7.43.2/32 peer #{node['openbsd']['ipsec']['gw_addr']} psk #{node['openbsd']['ipsec']['psk']}"
  end

  it 'appends isakmpd with rdomain in rc.local' do
    rclocal = file("/etc/rc.local")
    rclocal.must_include %Q[route -T 1 exec isakmpd -K -v]
  end

  it 'appends ipsecctl with rdomain in rc.local' do
    rclocal = file("/etc/rc.local")
    rclocal.must_include %Q[route -T 1 exec ipsecctl -f /etc/ipsec.conf]
  end
end
