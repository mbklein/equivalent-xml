require File.expand_path('../spec_helper.rb',__FILE__)
require 'nokogiri'
require 'oga'

describe EquivalentXml do
  before(:all) { 
    require 'nokogiri' 
    require 'oga'
  }

  it "should not compare Nodes of different classes" do
    doc1 = Nokogiri::XML("<doc xmlns='foo:bar'><first order='1'>foo  bar baz</first><second>things</second></doc>")
    doc2 = Oga.parse_xml("<doc xmlns='foo:bar'><first order='1'>foo  bar baz</first><second>things</second></doc>")
    expect { EquivalentXml.equivalent?(doc1,doc2) }.to raise_error(ArgumentError)
  end
end
