import Fuzi


public enum Operation: Equatable, Codable, Sendable {
    case write(Write)
    case writeDescriptor(WriteDescriptor)
    case read(Read)
    case sleep(Sleep)
    case waitForNotification(WaitForNotification)
    case notSupported(element: String)
    
    
    public static func parse(xml: Fuzi.XMLElement) -> Result<Operation, MacroXMLError> {
        switch xml.tag {
        case Write.name:
            return Write.parse(xml: xml).map { .write($0) }
        case WriteDescriptor.name:
            return WriteDescriptor.parse(xml: xml).map { .writeDescriptor($0) }
        case Read.name:
            return Read.parse(xml: xml).map { .read($0) }
        case Sleep.name:
            return Sleep.parse(xml: xml).map { .sleep($0) }
        case WaitForNotification.name:
            return WaitForNotification.parse(xml: xml).map { .waitForNotification($0) }
        default:
            return .failure(.notSupportedOperation(element: xml.tag))
        }
    }
    
    
    public func xml() -> MacroXMLElement {
        switch self {
        case .write(let write):
            return write.xml()
        case .writeDescriptor(let writeDescriptor):
            return writeDescriptor.xml()
        case .read(let read):
            return read.xml()
        case .sleep(let sleep):
            return sleep.xml()
        case .waitForNotification(let waitForNotification):
            return waitForNotification.xml()
        case .notSupported(let element):
            return MacroXMLElement(tag: element, attributes: [], children: [])
        }
    }
}


extension Operation: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .write(let write):
            return write.debugDescription
        case .writeDescriptor(let writeDescriptor):
            return writeDescriptor.debugDescription
        case .read(let read):
            return read.debugDescription
        case .sleep(let sleep):
            return sleep.debugDescription
        case .waitForNotification(let waitForNotification):
            return waitForNotification.debugDescription
        case .notSupported(let element):
            return ".notSupported(element: \(element))"
        }
    }
}
