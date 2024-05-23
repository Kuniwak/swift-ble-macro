public struct AssignedNumberWithID: Equatable, AssignedNumberProtocol {
    public let name: String
    public let id: String
    public let uuidByte3: UInt8
    public let uuidByte4: UInt8

    public var optionalId: String? {
        return id
    }

    public init(name: String, id: String, uuidByte3: UInt8, uuidByte4: UInt8) {
        self.name = name
        self.id = id
        self.uuidByte3 = uuidByte3
        self.uuidByte4 = uuidByte4
    }
}
