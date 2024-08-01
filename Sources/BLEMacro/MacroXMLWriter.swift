public enum MacroXMLWriter {
    public static func write(_ xmlElement: MacroXMLElement, to stream: inout any TextOutputStream, withIndent indent: Int) {
        for _ in 0..<indent {
            stream.write("\t")
        }
        stream.write("<")
        if let namespace = xmlElement.namespace {
            stream.write(namespace)
            stream.write(":")
        }
        stream.write(xmlElement.tag)
        
        for attribute in xmlElement.attributes {
            stream.write(" ")
            if let namespace = attribute.namespace {
                stream.write(namespace)
                stream.write(":")
            }
            stream.write(attribute.name)
            stream.write("=\"")
            stream.write(escapeXML(attribute.value))
            stream.write("\"")
        }
        
        if xmlElement.children.isEmpty {
            stream.write(" />")
        } else {
            stream.write(">")
            stream.write("\n")
            
            for child in xmlElement.children {
                write(child, to: &stream, withIndent: indent + 1)
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


private func escapeXML(_ string: String) -> String {
    string
        .replacingOccurrences(of: "&", with: "&amp;")
        .replacingOccurrences(of: "<", with: "&lt;")
        .replacingOccurrences(of: ">", with: "&gt;")
        .replacingOccurrences(of: "\"", with: "&quot;");
}
