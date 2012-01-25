# equivalent-xml

## Description

### Problem

Testing XML output is difficult:
* Comparing text output is brittle due to the vagaries of serialization.
* Attribute order doesn't matter.
* Element order matters sometimes, but not always. 
* Text sometimes needs to be normalized, but CDATA doesn't.
* Nodes in the same namespace don't always use the same prefix
* Etc.

### Solution

EquivalentXml for Nokogiri

[![Build Status](https://secure.travis-ci.org/mbklein/equivalent-xml.png)](http://travis-ci.org/mbklein/equivalent-xml)
[![Dependency Status](https://gemnasium.com/mbklein/equivalent-xml.png)](https://gemnasium.com/mbklein/equivalent-xml)

### Use
    EquivalentXml.equivalent?(node_1, node_2, opts = { :element_order => false, :normalize_whitespace => true }) { |n1, n2, result| ... }

node_1 and node_2 can be any Nokogiri::XML::Node descendants (or any string 
containing an XML document or document fragment). The most common use case is 
to compare two Nokogiri::XML::Document instances.

node_1 is equivalent to node_2 if and only if:
* node_1 and node_2 are of the same class
* node_1 and node_2 are in the same namespace
* node_1 and node_2 have the same number of child nodes
  (excluding ProcessingInstructions, Comments and empty Text nodes)
* For each child of node_1, there is exactly one equal child of node_2
* If called with :element_order => true, equivalent child elements must be
  in the same relative position in order to be considered equal

If a block is given, the block will be called every time two nodes are compared. The parameters will be 
the two nodes being compared as well as the result of the comparison. If the block explicitly returns 
`true` or `false` (a real `TrueClass` or `FalseClass`, not just an expression that can be coerced to
true or false), the return value will override the result of the comparison.

`Element` nodes are equivalent if they have the same name, and their 
child nodesets are equal (as defined above)

`Attribute` nodes are equivalent if their names and values match exactly

`CDATA` nodes are equivalent if their text strings match exactly,
including leading, trailing, and internal whitespace

Non-CDATA `CharacterData` nodes are equivalent if their text strings 
match after stripping leading and trailing whitespace and collapsing 
internal whitespace to a single space

`Document` nodes are equivalent if their root nodes are equal

`ProcessingInstruction` and `Comment` nodes are ignored

#### Options

    :element_order => true

Require elements to be in the same relative position in order to be
considered equivalent.

    :normalize_whitespace => false

Don't normalize whitespace within text nodes; require text nodes to 
match exactly.

### Using with RSpec

EquivalentXml includes a custom matcher for RSpec (version >=1.2.4) that makes including XML
equivalencies in your spec tests a cinch!

Equivalency:

    node_1.should be_equivalent_to(node_2)
    node_1.should_not be_equivalent_to(node_2)

Chained modifiers:

    node_1.should be_equivalent_to(node_2).respecting_element_order
    node_1.should be_equivalent_to(node_2).with_whitespace_intact
    node_1.should be_equivalent_to(node_2).respecting_element_order.with_whitespace_intact

## Contributing to equivalent-xml
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## History

- <b>0.2.9</b> - Fix for rspec-rails >= 2.7 (contrib. by jcoyne)
- <b>0.2.8</b> - Allow comparison against nodesets (contrib. by gkellogg)
- <b>0.2.7</b> - Auto-require RSpec matchers if RSpec is loaded
- <b>0.2.6</b> - Added documentation for RSpec matchers
- <b>0.2.5</b> - Added YARD documentation
- <b>0.2.4</b> - Fixed comparison of non-XML input
- <b>0.2.3</b> - Improved handling of non-XML input
- <b>0.2.2</b> - Dependency update
- <b>0.2.1</b> - Hotfix: Missing files in gemspec
- <b>0.2.0</b> - Custom rspec matchers
- <b>0.1.6</b> - Allow caller to override comparison result in block
- <b>0.1.5</b> - Allow XML documents to be passed as strings, re-instituting dependency on nokogiri
- <b>0.1.4</b> - Hotfix: Missing block parameter on compare_nodesets()
- <b>0.1.3</b> - Hotfix: Missing block parameter on compare_nodesets()
- <b>0.1.2</b> - Yield evaluated nodes and provisional result if block given
- <b>0.1.1</b> - Removed explicit runtime dependency on nokogiri
- <b>0.1.0</b> - Initial release

## Copyright

Copyright (c) 2011 Michael B. Klein. See LICENSE.txt for further details.

