import Foundation


public protocol AssignedNumberProtocol {
    var name: String { get }
    var optionalId: String? { get }
    var uuidByte3: UInt8 { get }
    var uuidByte4: UInt8 { get }
}


public func uuid16Bits(_ uuidByte3: UInt8, _ uuidByte4: UInt8) -> UUID {
    return uuid32Bits(0x00, 0x00, uuidByte3, uuidByte4)
}


public func uuid32Bits(_ uuidByte1: UInt8, _ uuidByte2: UInt8, _ uuidByte3: UInt8, _ uuidByte4: UInt8) -> UUID {
    return UUID(uuid: (
        uuidByte1,
        uuidByte1,
        uuidByte3,
        uuidByte4,
        UInt8(0x00),
        UInt8(0x00),
        UInt8(0x10),
        UInt8(0x00),
        UInt8(0x80),
        UInt8(0x00),
        UInt8(0x00),
        UInt8(0x80),
        UInt8(0x5f),
        UInt8(0x9b),
        UInt8(0x34),
        UInt8(0xfb)
    ))
}


extension AssignedNumberProtocol {
    public func uuid() -> UUID { uuid16Bits(uuidByte3, uuidByte4) }
}
