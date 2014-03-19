require 'spec_helper'
require 'db_events/queueing'

describe 'DbEvents::Queueing' do
	let(:test_class) {Class.new { include DbEvents::Queueing }}
	let(:performer_class) do
		Class.new do
		 	def perform(*args); end
		 	def initialize(*args); end
		end
	end

	subject { test_class.new }

	it '#enqueue' do
		subject.enqueue(performer_class)
		p = subject.instance_variable_get(:@dbe_performers)
		p.should be_a_kind_of(Array)
		p.first.should be_a_kind_of(performer_class)
		#pending "bla: #{test_class.included_modules}"
	end

	# it '#'
end


