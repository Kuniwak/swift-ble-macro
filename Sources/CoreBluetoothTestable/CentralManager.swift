import CoreBluetooth
import Combine
import BLEInternal


public protocol CentralManagerProtocol {
    // MARK: - Properties from CBManager
    var state: CBManagerState { get }
    var authorization: CBManagerAuthorization { get }
    
    // MARK: - Properties from CBCentralManager
    var isScanning: Bool { get }
    
    // MARK: - Methods from CBCentralManager
    func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> [any PeripheralProtocol]
    func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> [any PeripheralProtocol]
    func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?)
    func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String: Any]?)
    func stopScan()
    func connect(_ peripheral: any PeripheralProtocol)
    func connect(_ peripheral: any PeripheralProtocol, options: [String: Any]?)
    func cancelPeripheralConnection(_ peripheral: any PeripheralProtocol)
    
    // MARK: - Publishers for CBCentralManagerDelegate
    var didUpdateState: AnyPublisher<CBManagerState, Never> { get }
    var willRestoreState: AnyPublisher<[String: Any], Never> { get }
    var didDiscoverPeripheral: AnyPublisher<(peripheral: any PeripheralProtocol, advertisementData: [String : Any], rssi: NSNumber), Never> { get }
    var didConnectPeripheral: AnyPublisher<any PeripheralProtocol, Never> { get }
    var didFailToConnectPeripheral: AnyPublisher<(peripheral: any PeripheralProtocol, error: (any Error)?), Never> { get }
    var didDisconnectPeripheral: AnyPublisher<(peripheral: any PeripheralProtocol, error: (any Error)?), Never> { get }
    var didDisconnectPeripheralReconnecting: AnyPublisher<(peripheral: any PeripheralProtocol, timestamp: CFAbsoluteTime, isReconnecting: Bool, error: (any Error)?), Never> { get }
    
    // MARK: - Properties for Internal Use
    var _wrapped: CBCentralManager? { get }
}


public class CentralManager: NSObject, CentralManagerProtocol {
    // MARK: - Properties from CBManager
    public var state: CBManagerState { centralManager.state }
    public var authorization: CBManagerAuthorization { centralManager.authorization }
    
    // MARK: - Properties from CBCentralManager
    public var isScanning: Bool { centralManager.isScanning }
    
    // MARK: - Publishers for CBCentralManagerDelegate
    private let didUpdateStateSubject: CurrentValueSubject<CBManagerState, Never>
    public let didUpdateState: AnyPublisher<CBManagerState, Never>
    
    private let willRestoreStateSubject: PassthroughSubject<[String: Any], Never>
    public let willRestoreState: AnyPublisher<[String: Any], Never>
    
    private let didDiscoverPeripheralSubject: PassthroughSubject<(peripheral: any PeripheralProtocol, advertisementData: [String : Any], rssi: NSNumber), Never>
    public let didDiscoverPeripheral: AnyPublisher<(peripheral: any PeripheralProtocol, advertisementData: [String : Any], rssi: NSNumber), Never>
    
    private let didConnectPeripheralSubject: PassthroughSubject<any PeripheralProtocol, Never>
    public let didConnectPeripheral: AnyPublisher<any PeripheralProtocol, Never>

    private let didFailToConnectPeripheralSubject: PassthroughSubject<(peripheral: any PeripheralProtocol, error: (any Error)?), Never>
    public let didFailToConnectPeripheral: AnyPublisher<(peripheral: any PeripheralProtocol, error: (any Error)?), Never>
    
    private let didDisconnectPeripheralSubject: PassthroughSubject<(peripheral: any PeripheralProtocol, error: (any Error)?), Never>
    public let didDisconnectPeripheral: AnyPublisher<(peripheral: any PeripheralProtocol, error: (any Error)?), Never>
    
    private let didDisconnectPeripheralReconnectingSubject: PassthroughSubject<(peripheral: any PeripheralProtocol, timestamp: CFAbsoluteTime, isReconnecting: Bool, error: (any Error)?), Never>
    public let didDisconnectPeripheralReconnecting: AnyPublisher<(peripheral: any PeripheralProtocol, timestamp: CFAbsoluteTime, isReconnecting: Bool, error: (any Error)?), Never>
    
    // MARK: - Properties for Internal Use
    private let centralManager: CBCentralManager
    public var _wrapped: CBCentralManager? { centralManager }
    
    private let logger: LoggerProtocol

    
    // MARK: - Initializers
    public init(queue: DispatchQueue? = nil, options: [String: Any]? = nil, loggingBy logger: LoggerProtocol) {
        let central = CBCentralManager(delegate: nil, queue: queue, options: options)
        self.centralManager = central
        
        self.logger = logger

        let didUpdateStateSubject = CurrentValueSubject<CBManagerState, Never>(central.state)
        self.didUpdateStateSubject = didUpdateStateSubject
        self.didUpdateState = didUpdateStateSubject.eraseToAnyPublisher()
        
        let willRestoreStateSubject = PassthroughSubject<[String: Any], Never>()
        self.willRestoreStateSubject = willRestoreStateSubject
        self.willRestoreState = willRestoreStateSubject.eraseToAnyPublisher()
        
        let didDiscoverPeripheralSubject = PassthroughSubject<(peripheral: any PeripheralProtocol, advertisementData: [String : Any], rssi: NSNumber), Never>()
        self.didDiscoverPeripheralSubject = didDiscoverPeripheralSubject
        self.didDiscoverPeripheral = didDiscoverPeripheralSubject.eraseToAnyPublisher()
        
        let didConnectPeripheralSubject = PassthroughSubject<any PeripheralProtocol, Never>()
        self.didConnectPeripheralSubject = didConnectPeripheralSubject
        self.didConnectPeripheral = didConnectPeripheralSubject.eraseToAnyPublisher()
        
        let didFailToConnectPeripheralSubject = PassthroughSubject<(peripheral: any PeripheralProtocol, error: (any Error)?), Never>()
        self.didFailToConnectPeripheralSubject = didFailToConnectPeripheralSubject
        self.didFailToConnectPeripheral = didFailToConnectPeripheralSubject.eraseToAnyPublisher()
        
        let didDisconnectPeripheralSubject = PassthroughSubject<(peripheral: any PeripheralProtocol, error: (any Error)?), Never>()
        self.didDisconnectPeripheralSubject = didDisconnectPeripheralSubject
        self.didDisconnectPeripheral = didDisconnectPeripheralSubject.eraseToAnyPublisher()
        
        let didDisconnectPeripheralReconnectingSubject = PassthroughSubject<(peripheral: any PeripheralProtocol, timestamp: CFAbsoluteTime, isReconnecting: Bool, error: (any Error)?), Never>()
        self.didDisconnectPeripheralReconnectingSubject = didDisconnectPeripheralReconnectingSubject
        self.didDisconnectPeripheralReconnecting = didDisconnectPeripheralReconnectingSubject.eraseToAnyPublisher()
        
        super.init()
        
        central.delegate = self
    }
    
    
    deinit {
        self.logger.debug("deinit CentralManager")
    }
    
    
    // MARK: - Methods from CBCentralManager
    public func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> [any PeripheralProtocol] {
        logger.trace()
        return centralManager.retrievePeripherals(withIdentifiers: identifiers)
            .map{ Peripheral.from(peripheral: $0, logger: logger) }
    }
    
    
    public func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> [any PeripheralProtocol] {
        logger.trace()
        return centralManager.retrieveConnectedPeripherals(withServices: serviceUUIDs)
            .map{ Peripheral.from(peripheral: $0, logger: logger) }
    }
    
    
    public func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?) {
        scanForPeripherals(withServices: serviceUUIDs, options: nil)
    }
    
    
    public func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String: Any]?) {
        logger.trace()
        centralManager.scanForPeripherals(withServices: serviceUUIDs, options: options)
    }
    
    
    public func stopScan() {
        logger.trace()
        centralManager.stopScan()
    }
    
    
    public func connect(_ peripheral: any PeripheralProtocol) {
        connect(peripheral, options: nil)
    }
    
    
    public func connect(_ peripheral: any PeripheralProtocol, options: [String: Any]?) {
        logger.trace()
        
        guard let wrapped = peripheral._wrapped else {
            fatalError("Peripheral must hold a CBPeripheral instance")
        }
        
        centralManager.connect(wrapped, options: options)
    }
    
    
    public func cancelPeripheralConnection(_ peripheral: any PeripheralProtocol) {
        logger.trace()
        
        guard let wrapped = peripheral._wrapped else {
            fatalError("Peripheral must hold a CBPeripheral instance")
        }
        
        centralManager.cancelPeripheralConnection(wrapped)
    }
}


extension CentralManager: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        logger.trace()
        didUpdateStateSubject.send(central.state)
    }
    
    
    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        logger.trace()
        willRestoreStateSubject.send(dict)
    }
    
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        logger.trace()
        didDiscoverPeripheralSubject.send((
            peripheral: Peripheral.from(peripheral: peripheral, logger: logger),
            advertisementData: advertisementData,
            rssi: RSSI
        ))
    }
    
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        logger.trace()
        didConnectPeripheralSubject.send(Peripheral.from(peripheral: peripheral, logger: logger))
    }
    
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        logger.trace()
        didFailToConnectPeripheralSubject.send((Peripheral.from(peripheral: peripheral, logger: logger), error))
    }
    
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        logger.trace()
        didDisconnectPeripheralSubject.send((Peripheral.from(peripheral: peripheral, logger: logger), error))
    }
    
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, timestamp: CFAbsoluteTime, isReconnecting: Bool, error: (any Error)?) {
        logger.trace()
        didDisconnectPeripheralReconnectingSubject.send((Peripheral.from(peripheral: peripheral, logger: logger), timestamp, isReconnecting, error))
    }
}
