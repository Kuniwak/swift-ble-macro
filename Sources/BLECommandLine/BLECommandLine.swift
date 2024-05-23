import ArgumentParser


@main
struct BLECommandLine: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "ble",
        abstract: "Utility for Bluetooth Low Energy",
        version: "0.0.0",
        subcommands: [
            PeripheralDiscovery.self,
            MacroValidation.self,
            MacroCompilation.self,
            MacroExecution.self,
            StartREPL.self
        ]
    )
}
