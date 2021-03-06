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
# must be set via role
default["openbsd"]["ipsec"]["psk"] = "SECRET"
default["openbsd"]["ipsec"]["gw_hostname"] = "ipsec-gw1"
default["openbsd"]["ipsec"]["gw_fqdn"] = "ipsec-gw1.example.org"
default["openbsd"]["ipsec"]["gw_addr"] = "192.168.67.2"
default["openbsd"]["ipsec"]["is_gateway"] = false
