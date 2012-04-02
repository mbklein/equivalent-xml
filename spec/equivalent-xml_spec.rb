$:.push(File.join(File.dirname(__FILE__),'..','lib'))
require 'nokogiri'
require 'equivalent-xml'
require 'simplecov'
SimpleCov.start

describe EquivalentXml do

  it "should consider a document equivalent to itself" do
    doc1 = Nokogiri::XML("<doc xmlns='foo:bar'><first>foo  bar baz</first><second>things</second></doc>")
    doc1.should be_equivalent_to(doc1)
  end
  
  it "should compare non-XML content based on its string representation" do
    nil.should be_equivalent_to(nil)
    ''.should be_equivalent_to('')
    ''.should be_equivalent_to(nil)
    'foo'.should be_equivalent_to('foo')
    'foo'.should_not be_equivalent_to('bar')
    doc1 = Nokogiri::XML("<doc xmlns='foo:bar'><first order='1'>foo  bar baz</first><second>things</second></doc>")
    doc1.should_not be_equivalent_to(nil)
  end

  it "should ensure that attributes match" do
    doc1 = Nokogiri::XML("<doc xmlns='foo:bar'><first order='1'>foo  bar baz</first><second>things</second></doc>")
    doc2 = Nokogiri::XML("<doc xmlns='foo:bar'><first order='2'>foo  bar baz</first><second>things</second></doc>")
    doc1.should_not be_equivalent_to(doc2)

    doc1 = Nokogiri::XML("<doc xmlns='foo:bar'><first order='1'>foo  bar baz</first><second>things</second></doc>")
    doc2 = Nokogiri::XML("<doc xmlns='foo:bar'><first order='1'>foo  bar baz</first><second>things</second></doc>")
    doc1.should be_equivalent_to(doc2)
  end
  
  it "shouldn't care about attribute order" do
    doc1 = Nokogiri::XML("<doc xmlns='foo:bar'><first order='1' value='quux'>foo  bar baz</first><second>things</second></doc>")
    doc2 = Nokogiri::XML("<doc xmlns='foo:bar'><first value='quux' order='1'>foo  bar baz</first><second>things</second></doc>")
    doc1.should be_equivalent_to(doc2)
  end
  
  it "shouldn't care about element order by default" do
    doc1 = Nokogiri::XML("<doc xmlns='foo:bar'><first>foo  bar baz</first><second>things</second></doc>")
    doc2 = Nokogiri::XML("<doc xmlns='foo:bar'><second>things</second><first>foo  bar baz</first></doc>")
    doc1.should be_equivalent_to(doc2)
  end
  
  it "should care about element order if :element_order => true is specified" do
    doc1 = Nokogiri::XML("<doc xmlns='foo:bar'><first>foo  bar baz</first><second>things</second></doc>")
    doc2 = Nokogiri::XML("<doc xmlns='foo:bar'><second>things</second><first>foo  bar baz</first></doc>")
    doc1.should_not be_equivalent_to(doc2).respecting_element_order
  end
  
  it "should ensure nodesets have the same number of elements" do
    doc1 = Nokogiri::XML("<doc xmlns='foo:bar'><first>foo  bar baz</first><second>things</second></doc>")
    doc2 = Nokogiri::XML("<doc xmlns='foo:bar'><second>things</second><first>foo  bar baz</first><third/></doc>")
    doc1.should_not be_equivalent_to(doc2)
  end

  it "should ensure namespaces match" do
    doc1 = Nokogiri::XML("<doc xmlns='foo:bar'><first>foo  bar baz</first><second>things</second></doc>")
    doc2 = Nokogiri::XML("<doc xmlns='foo:baz'><first>foo  bar baz</first><second>things</second></doc>")
    doc1.should_not be_equivalent_to(doc2)
  end

  it "should compare namespaces based on URI, not on prefix" do
    doc1 = Nokogiri::XML("<doc xmlns:foo='foo:bar'><foo:first>foo  bar baz</foo:first><foo:second>things</foo:second></doc>")
    doc2 = Nokogiri::XML("<doc xmlns:baz='foo:bar'><baz:first>foo  bar baz</baz:first><baz:second>things</baz:second></doc>")
    doc1.should be_equivalent_to(doc2)
  end

  it "should ignore declared but unused namespaces" do
    doc1 = Nokogiri::XML("<doc xmlns:foo='foo:bar'><first>foo  bar baz</first><second>things</second></doc>")
    doc2 = Nokogiri::XML("<doc><first>foo  bar baz</first><second>things</second></doc>")
    doc1.should be_equivalent_to(doc2)
  end

  it "should normalize simple whitespace by default" do
    doc1 = Nokogiri::XML("<doc xmlns='foo:bar'><first>foo  bar baz</first><second>things</second></doc>")
    doc2 = Nokogiri::XML("<doc xmlns='foo:bar'><first>foo bar  baz</first><second>things</second></doc>")
    doc1.should be_equivalent_to(doc2)
  end

  it "shouldn't normalize simple whitespace if :normalize_whitespace => false is specified" do
    doc1 = Nokogiri::XML("<doc xmlns='foo:bar'><first>foo  bar baz</first><second>things</second></doc>")
    doc2 = Nokogiri::XML("<doc xmlns='foo:bar'><first>foo bar  baz</first><second>things</second></doc>")
    doc1.should_not be_equivalent_to(doc2).with_whitespace_intact
  end

  it "should normalize complex whitespace by default" do
    doc1 = Nokogiri::XML("<doc xmlns='foo:bar'><first>foo  bar baz</first><second>things</second></doc>")
    doc2 = Nokogiri::XML(%{<doc xmlns='foo:bar'>
      <second>things</second>
      <first>
        foo
        bar baz
      </first>
    </doc>})
    doc1.should be_equivalent_to(doc2)
  end
  
  it "shouldn't normalize complex whitespace if :normalize_whitespace => false is specified" do
    doc1 = Nokogiri::XML("<doc xmlns='foo:bar'><first>foo  bar baz</first><second>things</second></doc>")
    doc2 = Nokogiri::XML(%{<doc xmlns='foo:bar'>
      <second>things</second>
      <first>
        foo
        bar baz
      </first>
    </doc>})
    doc1.should_not be_equivalent_to(doc2).with_whitespace_intact
  end

  it "should ignore comment nodes" do
    doc1 = Nokogiri::XML("<doc xmlns='foo:bar'><first>foo  bar baz</first><second>things</second></doc>")
    doc2 = Nokogiri::XML(%{<doc xmlns='foo:bar'>
      <second>things</second>
      <!-- Comment Node -->
      <first>
        foo
        bar baz
      </first>
    </doc>})
    doc1.should be_equivalent_to(doc2)
  end
  
  it "should properly handle a mixture of text and element nodes" do
    doc1 = Nokogiri::XML("<doc xmlns='foo:bar'><phrase>This phrase <b>has bold text</b> in it.</phrase></doc>")
    doc2 = Nokogiri::XML("<doc xmlns='foo:bar'><phrase>This phrase in <b>has bold text</b> it.</phrase></doc>")
    doc1.should_not be_equivalent_to(doc2)
  end

  it "should properly handle documents passed in as strings" do
    doc1 = "<doc xmlns='foo:bar'><first order='1'>foo  bar baz</first><second>things</second></doc>"
    doc2 = "<doc xmlns='foo:bar'><first order='1'>foo  bar baz</first><second>things</second></doc>"
    doc1.should be_equivalent_to(doc2)

    doc1 = "<doc xmlns='foo:bar'><first order='1'>foo  bar baz</first><second>things</second></doc>"
    doc2 = "<doc xmlns='foo:bar'><first order='1'>foo  bar baz quux</first><second>things</second></doc>"
    doc1.should_not be_equivalent_to(doc2)
  end

  it "should compare nodesets" do
    doc1 = Nokogiri::XML("<doc xmlns='foo:bar'><first>foo  bar baz</first><second>things</second></doc>")
    doc1.root.children.should be_equivalent_to(doc1.root.children)
  end
  
  it "should compare nodeset with string" do
    doc1 = Nokogiri::XML("<doc xmlns='foo:bar'><first>foo  bar baz</first><second>things</second></doc>")
    doc1.root.children.should be_equivalent_to("<first xmlns='foo:bar'>foo  bar baz</first><second xmlns='foo:bar'>things</second>")
  end
end
