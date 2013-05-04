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

describe 'openbsd::pf' do
  include_context 'openbsd'

  before do
    chef_run.converge('openbsd::pf')
  end

  it 'should create /etc/pf.conf' do
    expect(chef_run).to create_file_with_content '/etc/pf.conf', '$OpenBSD: pf.conf,v 1.50 2011/04/28 00:19:42 mikeb Exp $'
  end
end
