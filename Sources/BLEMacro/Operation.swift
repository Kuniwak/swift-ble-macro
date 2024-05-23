import Foundation


public enum Operation: Equatable {
    case write(Write)
    case writeDescriptor(WriteDescriptor)
    case read(Read)
    case sleep(Sleep)
    case waitForNotification(WaitForNotification)
    case notSupported(element: String)
    
    
    public static func parse(xml: XMLElement) -> Result<Operation, MacroXMLError> {
        switch xml.name {
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
            return .failure(.notSupportedOperation(element: xml.name))
        }
    }
}
