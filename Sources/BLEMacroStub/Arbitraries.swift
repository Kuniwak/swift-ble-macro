import Foundation
import SwiftCheck
import BLEMacro


extension UUID: @retroactive Arbitrary {
    public static var arbitrary: Gen<UUID> {
        return Gen<(UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)>
            .zip(
                UInt8.arbitrary,
                UInt8.arbitrary,
                UInt8.arbitrary,
                UInt8.arbitrary,
                UInt8.arbitrary,
                UInt8.arbitrary,
                UInt8.arbitrary,
                UInt8.arbitrary,
                UInt8.arbitrary,
                UInt8.arbitrary,
                UInt8.arbitrary,
                UInt8.arbitrary,
                UInt8.arbitrary,
                UInt8.arbitrary,
                UInt8.arbitrary,
                UInt8.arbitrary
            )
            .map(UUID.init(uuid:))
    }
}


public func shortArrayGen<T>() -> Gen<[T]> where T: Arbitrary {
    return Gen
        .zip(
            UInt8.arbitrary.map { $0 % 5 },
            T.arbitrary,
            T.arbitrary,
            T.arbitrary,
            T.arbitrary,
            T.arbitrary
        )
        .map { i, c1, c2, c3, c4, c5 in
            Array([c1, c2, c3, c4, c5].dropFirst(Int(i)))
        }
}


public let shortStringGen: Gen<String> = shortArrayGen()
    .map(String.init(_:))


public let descriptionGen: Gen<String?> = Gen<String?>
    .one(of: [
        shortStringGen.map(Optional.some),
        Gen.pure(nil)
    ])


public let dataGen: Gen<Data> = shortArrayGen()
    .map(Data.init(_:))


extension AssertCCCD: @retroactive Arbitrary {
    public static var arbitrary: Gen<AssertCCCD> {
        return descriptionGen.map(AssertCCCD.init(description:))
    }
}


extension AssertCharacteristic: @retroactive Arbitrary {
    public static var arbitrary: Gen<AssertCharacteristic> {
        Gen
            .zip(
                descriptionGen,
                UUID.arbitrary,
                shortArrayGen(),
                shortArrayGen(),
                AssertCCCD?.arbitrary
            )
            .map(AssertCharacteristic.init)
    }
}


extension AssertDescriptor: @retroactive Arbitrary {
    public static var arbitrary: Gen<AssertDescriptor> {
        return Gen
            .zip(descriptionGen, UUID.arbitrary)
            .map(AssertDescriptor.init(description:uuid:))
    }
}


extension AssertService: @retroactive Arbitrary {
    public static var arbitrary: Gen<AssertService> {
        return Gen
            .zip(
                descriptionGen,
                UUID.arbitrary,
                shortArrayGen()
            )
            .map(AssertService.init(description:uuid:characteristicAsserts:))
    }
}


extension AssertValue: @retroactive Arbitrary {
    public static var arbitrary: Gen<AssertValue> {
        return Gen
            .zip(
                descriptionGen,
                Value.arbitrary
            )
            .map(AssertValue.init(description:value:))
    }
}


extension Icon: @retroactive Arbitrary {
    public static var arbitrary: Gen<Icon> {
        Gen.fromElements(of: allCases)
    }
}


extension Macro: @retroactive Arbitrary {
    public static var arbitrary: Gen<Macro> {
        return Gen
            .zip(
                shortStringGen,
                Icon.arbitrary,
                shortArrayGen(),
                shortArrayGen()
            )
            .map(Macro.init)
    }
}


extension BLEMacro.Operation: @retroactive Arbitrary {
    public static var arbitrary: Gen<BLEMacro.Operation> {
        return Gen.one(of: [
            Write.arbitrary.map(Operation.write),
            WriteDescriptor.arbitrary.map(Operation.writeDescriptor),
            Read.arbitrary.map(Operation.read),
            Sleep.arbitrary.map(Operation.sleep),
            WaitForNotification.arbitrary.map(Operation.waitForNotification),
        ])
    }
}


extension BLEMacro.Property: @retroactive Arbitrary {
    public static var arbitrary: Gen<BLEMacro.Property> {
        return Gen
            .zip(PropertyName.arbitrary, PropertyRequirement?.arbitrary)
            .map(Property.init)
    }
}


extension PropertyName: @retroactive Arbitrary {
    public static var arbitrary: Gen<PropertyName> {
        Gen.fromElements(of: allCases)
    }
}


extension PropertyRequirement: @retroactive Arbitrary {
    public static var arbitrary: Gen<PropertyRequirement> {
        Gen.fromElements(of: allCases)
    }
}


extension Read: @retroactive Arbitrary {
    public static var arbitrary: Gen<Read> {
        return Gen
            .zip(
                descriptionGen,
                UUID.arbitrary,
                UUID.arbitrary,
                AssertValue?.arbitrary
            )
            .map(Read.init)
    }
}


extension Sleep: @retroactive Arbitrary {
    public static var arbitrary: Gen<Sleep> {
        return Gen
            .zip(descriptionGen, UInt.arbitrary)
            .map(Sleep.init)
    }
}


extension Value: @retroactive Arbitrary {
    public static var arbitrary: Gen<Value> {
        Gen.one(of: [
            dataGen.map(Value.data),
            String.arbitrary.map(Value.string)
        ])
    }
}


extension WaitForNotification: @retroactive Arbitrary {
    public static var arbitrary: Gen<WaitForNotification> {
        return Gen
            .zip(
                descriptionGen,
                UUID.arbitrary,
                UUID.arbitrary,
                AssertValue?.arbitrary
            )
            .map(WaitForNotification.init)
    }
}


extension Write: @retroactive Arbitrary {
    public static var arbitrary: Gen<Write> {
        return Gen
            .zip(
                descriptionGen,
                UUID.arbitrary,
                UUID.arbitrary,
                WritingType.arbitrary,
                Value.arbitrary
            )
            .map { Write(description: $0, serviceUUID: $1, characteristicUUID: $2, type: $3, value: $4) }
    }
}


extension WriteDescriptor: @retroactive Arbitrary {
    public static var arbitrary: Gen<WriteDescriptor> {
        return Gen
            .zip(
                descriptionGen,
                UUID.arbitrary,
                UUID.arbitrary,
                UUID.arbitrary,
                Value.arbitrary
            )
            .map { WriteDescriptor(description: $0, uuid: $1, serviceUUID: $2, characteristicUUID: $3, value: $4) }
    }
}


extension WritingType: @retroactive Arbitrary {
    public static var arbitrary: Gen<WritingType> {
        Gen.fromElements(of: allCases)
    }
}
