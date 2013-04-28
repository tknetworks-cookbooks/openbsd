require 'chefspec'

describe 'openbsd::pf' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'openbsd::pf' }
  it 'should do something' do
    pending 'Your recipe examples go here.'
  end
end
