public struct AssignedNumberWithoutID: Equatable, AssignedNumberProtocol {
    public let name: String
    public let optionalId: String? = nil
    public let uuidByte3: UInt8
    public let uuidByte4: UInt8

    public init(name: String, uuidByte3: UInt8, uuidByte4: UInt8) {
        self.name = name
        self.uuidByte3 = uuidByte3
        self.uuidByte4 = uuidByte4
    }
}
