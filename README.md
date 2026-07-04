# :computer: XML-Parser

</br>

![Compiler](https://github.com/user-attachments/assets/a916143d-3f1b-4e1f-b1e0-1067ef9e0401) <img src="https://github.com/user-attachments/assets/2cfb871d-890b-45a7-997d-98c8380150cb" />  
![Components](https://github.com/user-attachments/assets/d6a7a7a4-f10e-4df1-9c4f-b4a1a8db7f0e) ![None](https://github.com/user-attachments/assets/30ebe930-c928-4aaf-a8e1-5f68ec1ff349)  
![Description](https://github.com/user-attachments/assets/dbf330e0-633c-4b31-a0ef-b1edb9ed5aa7) <img src="https://github.com/user-attachments/assets/fb355511-24c9-4dba-8bea-1fbdac8b7c7a" />  
![Last Update](https://github.com/user-attachments/assets/e1d05f21-2a01-4ecf-94f3-b7bdff4d44dd) <img src="https://github.com/user-attachments/assets/e327c2d9-b52b-4d79-b01e-603c56acabfc" />  
![License](https://github.com/user-attachments/assets/ff71a38b-8813-4a79-8774-09a2f3893b48) ![Freeware](https://github.com/user-attachments/assets/1fea2bbf-b296-4152-badd-e1cdae115c43)  

</br>

Extensible Markup Language (XML) is a [markup language](https://en.wikipedia.org/wiki/Markup_language) and file format for storing, transmitting, and reconstructing data. It defines a set of rules for encoding documents in a format that is both human-readable and machine-readable. The World Wide Web Consortium's XML 1.0 Specification of 1998 and several other related specifications—all of them free open standards—define XML.

The design goals of XML emphasize simplicity, generality, and usability across the Internet. It is a textual data format with strong support via [Unicode](https://en.wikipedia.org/wiki/Unicode) for different human languages. Although the design of XML focuses on documents, the language is widely used for the representation of arbitrary data structures, such as those used in web services.

</br>

<img src="https://github.com/user-attachments/assets/fb247ae1-9f7e-4824-bfa8-2c4809ee0325" />

</br>
</br>

An XML parser is a software component that reads in XML (eXtensible Markup Language) documents, checks them for syntax errors, and translates them into a format readable by programs (often an object model). Since XML is inherently just a raw text stream, the parser converts this text into a hierarchical structure that your application can work with.

### There are two fundamental types of XML parsers:

* ### Tree-based parsers (DOM)  
  The parser reads the entire XML document into memory and creates a tree-like structure (Document Object Model/DOM).
    * ### Advantages  
      You can jump back and forth within the tree as you please, and edit, add, or delete elements.
    * ### Disadvantages
      High memory usage. With extremely large files, this can lead to memory overflows.
    * ### Typical libraries
      XmlDoc (Delphi) XmlDocument (C#/.NET), DOMDocument (JavaScript), xml.dom.minidom (Python).

* ### Event-based parsers (SAX)
  These parsers read the XML document sequentially from top to bottom (stream-based). They generate events (e.g., "start element found," "text found").
    * ### Advantages
      Extremely fast and memory-efficient, as the tree is not kept in memory. Ideal for very large files.
    * ### Disadvantages
      Access is unidirectional (no jumping back). Complex searches are more cumbersome to program.
    * ### Typical libraries  
      XmlDocReader (Delphi) XmlReader (C#/.NET), xml.sax (Python), SAXParser (Java).

# Parse Example
```xml
<?xml version="1.0" encoding="UTF-8"?>
<bookstore>
    <book id="1">
        <title>Harry Potter and the Sorcerer's Stone</title>
        <author>J.K. Rowling</author>
        <year>1997</year>
        <price>24.99</price>
    </book>
    <book id="2">
        <title>The Hobbit</title>
        <author>J.R.R. Tolkien</author>
        <year>1937</year>
        <price>15.00</price>
    </book>
</bookstore>
```

# Keywords:
The strings entered in the "KeyWords.ini" file are displayed in a default color. Generally, XML tags are green, but other colors can be selected.

If values are changed, added, or removed, the same change must be applied in the
```"Keywords.pas"``` unit.
Otherwise, color errors will occur.
