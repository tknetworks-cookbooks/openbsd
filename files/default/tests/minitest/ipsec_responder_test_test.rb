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

describe_recipe 'openbsd::ipsec_responder_test' do
  it 'sets net.inet.gre.allow=1' do
    value = 'net.inet.gre.allow=1'
    file("/etc/sysctl.conf").must_include value
    assert_sh "[ \"x`sysctl net.inet.gre.allow`\" = 'x#{value}' ]"
  end

  it 'creates hostname.lo1' do
    hostnameif = file("/etc/hostname.lo1")
    hostnameif.must_exist.with(:mode, "640").with(:owner, "root").with(:group, "wheel")
    hostnameif.must_include "inet 10.7.43.2"
  end

  it 'creates hostname.gre1' do
    hostnameif = file("/etc/hostname.gre1")
    hostnameif.must_exist.with(:mode, "640").with(:owner, "root").with(:group, "wheel")
    hostnameif.must_include "tunnel 10.7.43.2 10.7.43.10
10.7.50.2 10.7.50.10 netmask 255.255.255.255"
  end

  it 'creates ipsec.conf' do
    ipsecconf = file("/etc/ipsec.conf")
    ipsecconf.must_exist.with(:mode, "600").with(:owner, "root").with(:group, "wheel")
    ipsecconf.must_include %Q[include "/etc/ipsec_chef.conf"]
  end

  it 'creates ipsec_chef.conf' do
    ipsecchefconf = file("/etc/ipsec_chef.conf")
    ipsecchefconf.must_exist.with(:mode, "600").with(:owner, "root").with(:group, "wheel")

    ipsecchefconf.must_include "# ipsec-gw.example.org -> vagrant-openbsd1
ike passive esp proto gre from 10.7.43.2/32 to 10.7.43.10/32 peer any psk #{node['openbsd']['ipsec']['psk']}"

    ipsecchefconf.must_include "# ipsec-gw.example.org -> vagrant-openbsd2
ike passive esp proto gre from 10.7.43.3/32 to 10.7.43.11/32 peer any psk #{node['openbsd']['ipsec']['psk']}"
  end

  it 'enables/starts isakmpd' do
    service("isakmpd").must_be_running
    service("isakmpd").must_be_enabled
  end

  it 'enable ipsecctl' do
    service("ipsec").must_be_enabled
  end
end
