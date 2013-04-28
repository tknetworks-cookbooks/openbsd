require 'chefspec'

describe 'openbsd::ipsec_responder' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'openbsd::ipsec_responder' }
  it 'should do something' do
    pending 'Your recipe examples go here.'
  end
end
