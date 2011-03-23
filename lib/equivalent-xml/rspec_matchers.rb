require 'equivalent-xml'

class RSpecNotFound < Exception ; end
  
if defined?(RSpec)
  rspec_namespace = RSpec::Matchers
elsif defined?(Spec)
  rspec_namespace = Spec::Matchers
else
  raise RSpecNotFound, "Cannot find Spec (rspec 1.x) or RSpec (rspec 2.x)"
end

rspec_namespace.define :be_equivalent_to do |expected, opts|
  @opts = opts || {}
  
  match do |actual|
    @expected = expected
    @actual = actual
    EquivalentXml.equivalent?(@actual,@expected,@opts) { |n1,n2,result|
      if result == false and @failure_nodes.nil?
        @failure_nodes = { :expected => n2, :actual => n1 }
      end
    }
  end
  
  chain :respecting_element_order do 
    @opts[:element_order] = true
  end
  
  chain :with_whitespace_intact do
    @opts[:normalize_whitespace] = false
  end
  
  failure_message_for_should do
    <<-MESSAGE
expected:
#{@failure_nodes[:expected].to_xml}
got:
#{@failure_nodes[:actual].to_xml}
MESSAGE
  end
      
  failure_message_for_should_not do
    <<-MESSAGE
expected:
#{@actual.to_xml}
not to be equivalent to:
#{@expected.to_xml}
MESSAGE
  end

end
