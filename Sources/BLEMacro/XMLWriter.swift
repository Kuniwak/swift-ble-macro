public struct XMLElement {
    public var tag: String
    public var attributes: [String: String]
    public var children: [XMLElement]
    
    public init(tag: String, attributes: [String: String], children: [XMLElement]) {
        self.tag = tag
        self.attributes = attributes
        self.children = children
    }
}


public class XMLWriter {
    private var stream: TextOutputStream
    
    
    public init(writeTo stream: inout TextOutputStream) {
        self.stream = stream
    }
    
    
    public func write(_ xmlElement: XMLElement, withIndent indent: Int) {
        for _ in 0..<indent {
            stream.write("\t")
        }
        stream.write("<")
        stream.write(xmlElement.tag)
        
        for (key, value) in xmlElement.attributes {
            stream.write(" ")
            stream.write(key)
            stream.write("=\"")
            stream.write(value)
            stream.write("\"")
        }
        
        if xmlElement.children.isEmpty {
            stream.write(" />")
        } else {
            stream.write(">")
            stream.write("\n")
            
            for child in xmlElement.children {
                write(child, withIndent: indent + 1)
            }
            
            for _ in 0..<indent {
                stream.write("\t")
            }
            stream.write("</")
            stream.write(xmlElement.tag)
            stream.write(">")
        }
    }
}
