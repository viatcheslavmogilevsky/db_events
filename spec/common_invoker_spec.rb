require 'spec_helper'
require 'db_events/invokers/common'


describe DbEvents::Invokers::Common, '#distributors' do
	it 'have empty array after creation' do
		d = subject.instance_variable_get(:@distributors)
		d.should be_a_kind_of(Array)
		d.should be_empty
	end
end