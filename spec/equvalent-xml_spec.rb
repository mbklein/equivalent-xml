$:.push(File.join(File.dirname(__FILE__),'..','lib'))
require 'nokogiri'
require 'equivalent-xml'

describe EquivalentXml do

  it "should consider a document equivalent to itself" do
    doc1 = Nokogiri::XML("<doc xmlns='foo:bar'><first>foo  bar baz</first><second>things</second></doc>")
    EquivalentXml.equivalent?(doc1,doc1).should == true
  end
  
  it "should ensure that attributes match" do
    doc1 = Nokogiri::XML("<doc xmlns='foo:bar'><first order='1'>foo  bar baz</first><second>things</second></doc>")
    doc2 = Nokogiri::XML("<doc xmlns='foo:bar'><first order='2'>foo  bar baz</first><second>things</second></doc>")
    EquivalentXml.equivalent?(doc1,doc2).should == false

    doc1 = Nokogiri::XML("<doc xmlns='foo:bar'><first order='1'>foo  bar baz</first><second>things</second></doc>")
    doc2 = Nokogiri::XML("<doc xmlns='foo:bar'><first order='1'>foo  bar baz</first><second>things</second></doc>")
    EquivalentXml.equivalent?(doc1,doc2).should == true
  end
  
  it "shouldn't care about attribute order" do
    doc1 = Nokogiri::XML("<doc xmlns='foo:bar'><first order='1' value='quux'>foo  bar baz</first><second>things</second></doc>")
    doc2 = Nokogiri::XML("<doc xmlns='foo:bar'><first value='quux' order='1'>foo  bar baz</first><second>things</second></doc>")
    EquivalentXml.equivalent?(doc1,doc2).should == true
  end
  
  it "shouldn't care about element order by default" do
    doc1 = Nokogiri::XML("<doc xmlns='foo:bar'><first>foo  bar baz</first><second>things</second></doc>")
    doc2 = Nokogiri::XML("<doc xmlns='foo:bar'><second>things</second><first>foo  bar baz</first></doc>")
    EquivalentXml.equivalent?(doc1,doc2).should == true
  end
  
  it "should care about element order if :element_order => true is specified" do
    doc1 = Nokogiri::XML("<doc xmlns='foo:bar'><first>foo  bar baz</first><second>things</second></doc>")
    doc2 = Nokogiri::XML("<doc xmlns='foo:bar'><second>things</second><first>foo  bar baz</first></doc>")
    EquivalentXml.equivalent?(doc1,doc2,:element_order => true).should == false
  end
  
  it "should ensure nodesets have the same number of elements" do
    doc1 = Nokogiri::XML("<doc xmlns='foo:bar'><first>foo  bar baz</first><second>things</second></doc>")
    doc2 = Nokogiri::XML("<doc xmlns='foo:bar'><second>things</second><first>foo  bar baz</first><third/></doc>")
    EquivalentXml.equivalent?(doc1,doc2).should == false
  end

  it "should ensure namespaces match" do
    doc1 = Nokogiri::XML("<doc xmlns='foo:bar'><first>foo  bar baz</first><second>things</second></doc>")
    doc2 = Nokogiri::XML("<doc xmlns='foo:baz'><first>foo  bar baz</first><second>things</second></doc>")
    EquivalentXml.equivalent?(doc1,doc2).should == false
  end

  it "should normalize simple whitespace by default" do
    doc1 = Nokogiri::XML("<doc xmlns='foo:bar'><first>foo  bar baz</first><second>things</second></doc>")
    doc2 = Nokogiri::XML("<doc xmlns='foo:bar'><first>foo bar  baz</first><second>things</second></doc>")
    EquivalentXml.equivalent?(doc1,doc2).should == true
  end

  it "shouldn't normalize simple whitespace if :normalize_whitespace => false is specified" do
    doc1 = Nokogiri::XML("<doc xmlns='foo:bar'><first>foo  bar baz</first><second>things</second></doc>")
    doc2 = Nokogiri::XML("<doc xmlns='foo:bar'><first>foo bar  baz</first><second>things</second></doc>")
    EquivalentXml.equivalent?(doc1,doc2, :normalize_whitespace => false).should == false
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
    EquivalentXml.equivalent?(doc1,doc2).should == true
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
    EquivalentXml.equivalent?(doc1,doc2, :normalize_whitespace => false).should == false
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
    EquivalentXml.equivalent?(doc1,doc2).should == true
  end
  
  it "should properly handle a mixture of text and element nodes" do
    doc1 = Nokogiri::XML("<doc xmlns='foo:bar'><phrase>This phrase <b>has bold text</b> in it.</phrase></doc>")
    doc2 = Nokogiri::XML("<doc xmlns='foo:bar'><phrase>This phrase in <b>has bold text</b> it.</phrase></doc>")
    EquivalentXml.equivalent?(doc1,doc2).should == false
  end

end
