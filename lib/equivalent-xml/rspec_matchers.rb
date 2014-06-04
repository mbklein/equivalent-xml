require 'equivalent-xml'

begin
  require 'rspec/expectations'
rescue LoadError
end

module EquivalentXml::RSpecMatchers

  if defined?(::RSpec::Matchers)
    rspec_namespace = ::RSpec::Matchers
  elsif defined?(::Spec::Matchers)
    rspec_namespace = ::Spec::Matchers
  else
    raise NameError, "Cannot find Spec (rspec 1.x) or RSpec (rspec 2.x)"
  end

  # Determine if the receiver is equivalent to the argument as defined
  # in {file:README.rdoc README.rdoc} and {EquivalentXml.equivalent? EquivalentXml.equivalent?}.
  #   node.should be_equivalent_to(other_node)
  #   node.should_not be_equivalent_to(other_node)
  #   node.should be_equivalent_to(other_node).respecting_element_order
  #   node.should be_equivalent_to(other_node).with_whitespace_intact
  #   node.should be_equivalent_to(other_node).respecting_element_order.with_whitespace_intact
  #   node.should be_equivalent_to(other_node).ignoring_content_of("Device > SerialNumber")
  def be_equivalent_to(expected)
    # Placeholder method for documentation purposes; the actual
    # method is defined using RSpec's matcher DSL.
  end

  rspec_namespace.define :be_equivalent_to do |expected|
    opts = {}
    match do |actual|
      EquivalentXml.equivalent?(actual,expected,opts)
    end

    chain :respecting_element_order do
      opts[:element_order] = true
    end

    chain :with_whitespace_intact do
      opts[:normalize_whitespace] = false
    end

    chain :ignoring_content_of do |paths|
      opts[:ignore_content] = paths
    end

    chain :ignoring_attr_values do
      opts[:ignore_attr_values] = true
    end

    failure_message_for_should do |actual|
      [ 'expected:', expected.to_s, 'got:', actual.to_s ].join("\n")
    end

    failure_message_for_should_not do |actual|
      [ 'expected:', actual.to_s, 'not to be equivalent to:', expected.to_s ].join("\n")
    end
  end

end
