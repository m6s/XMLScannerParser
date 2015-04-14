# XMLScannerParser XML parser for Cocoa

*MATXMLScannerParser* is a drop-in replacement for *NSXMLParser*. The implementation is based on *NSScanner*. It doesn't support namespaces, perform validation nor check for wellformedness of XML documents.

## Motivation

I created XMLScannerParser when I encountered bugs in the original NSXMLParser. I hope that Apple will eventually fix these bugs, and that I can then switch to their parser implementation again. It can also help you finding out why a particular XML file won't parse, since it's light-weight and easy to understand and debug.

## Design

XMLScannerParser doesn't depend on any external framework. It has the same event based interface as NSXMLParser, is implemented in pure Objective C, and fits into two source files (plus headers). This is a naive implementation in that it doesn't employ any established parsing or tokenizing algorithms. For someone to tweak it to his/her specific needs, only some Foundation Kit experience should be necessary.
Beware, I haven't read the XML, let alone the SGML specs, and XMLScannerParser will only work with the most basic XML input.

## Alternatives

The original NSXMLParser is a thin object oriented wrapper around *libxml2*, and I suspect libxml2 shares some of its bugs. Nevertheless, using libxml2 directly is an option.
Next, there is [TBXML](https://github.com/71squared/TBXML), which is supposedly very fast, [TinyXML-2](http://www.grinninglizard.com/tinyxml2/), a parser implemented in C++, TouchXML, KissXML, GDataXML. All of these parsers provide a DOM interface for working with the XML data. I haven't found out if anybody successfully compiled and integrated *Xerces* into their app.

## Installation

The parser consists of four files only. Simply drop these files into you project.

It is also available through CocoaPods. To install it add the following line to your Podfile:

```
pod 'XMLScannerParser', :git => 'https://github.com/m6s/XMLScannerParser.git'
```

## License

Copyright (C) 2015 Matthias Schmitt. XMLScannerParser is released under the MIT license.
