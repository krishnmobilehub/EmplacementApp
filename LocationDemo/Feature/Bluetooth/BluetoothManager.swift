
import UIKit
import CoreBluetooth

class BluetoothManager: NSObject {
    private var centralManager: CBCentralManager?
    private var discoveredPeripheral: CBPeripheral?
    private var writeCharacteristic: CBCharacteristic?
    private var readCharacteristic: CBCharacteristic?
    
    override init() {
        super.init()
    }

    static let sharedInstance: BluetoothManager = {
        let instance = BluetoothManager()
        return instance
    }()
}

extension BluetoothManager {
    func start() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func cleanup() {
        guard discoveredPeripheral?.state == .connected else {
            return
        }
        
        guard let services = discoveredPeripheral?.services else {
            centralManager?.cancelPeripheralConnection(discoveredPeripheral!)
            return
        }
        
        for service in services {
            guard let characteristics = service.characteristics else {
                continue
            }
            
            for characteristic in characteristics {
                if characteristic.uuid.isEqual("xxx") && characteristic.isNotifying {
                    discoveredPeripheral?.setNotifyValue(false, for: characteristic)
                    return
                }
            }
        }
    }
    
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            centralManager?.scanForPeripherals(withServices: nil, options: nil)
            print("Searching Device...")
            break
        default:
            print("Please Switch ON the bluetooth of your phone")
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discovered \(String(describing: peripheral.name)) || \(peripheral.identifier.uuidString) at \(RSSI)\n")
        print("\nConnecting to peripheral \(peripheral)\n")
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral). (\(error!.localizedDescription))")
        cleanup()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Peripheral Connected \(peripheral)\n")
        centralManager?.stopScan()
        print("Scanning stopped\n")
        
        print("Device Connected...")
        discoveredPeripheral?.delegate = self
        discoveredPeripheral?.discoverServices(nil)
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            print("Error discovering services: \(error!.localizedDescription)\n")
            cleanup()
            return
        }
        
        guard let services = peripheral.services else {
            return
        }
        
        for service in services {
            print("Service uuid: \(service.uuid)") // put condition for particular uuid
            peripheral.discoverCharacteristics(nil, for: service)
        }
        
        print("Pairing Device...")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            print("Error discovering characteristics: \(error!.localizedDescription)\n")
            cleanup()
            return
        }
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        print("characteristic: \(characteristics)")
        
        for characteristic in characteristics {
            print("characteristic: \(characteristic)")
            
            if characteristic.uuid.isEqual("xyz") { // connect to perticular characteristics suppose write
                print("writeCharacteristicUUID found\n")
                writeCharacteristic = characteristic
            }
            
            if characteristic.uuid.isEqual("abc") { // connect to perticular characteristics suppose read
                print("readCharacteristicUUID found\n")
                readCharacteristic = characteristic
                discoveredPeripheral?.setNotifyValue(true, for: readCharacteristic!)
                discoveredPeripheral?.discoverDescriptors(for: readCharacteristic!)
            }
        }
        
        print("Device Paired...")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("Error discovering descriptors: \(error!.localizedDescription)\n")
            cleanup()
            return
        }
        
        guard let descriptors = characteristic.descriptors else {
            return
        }
        
        for descriptor in descriptors {
            print("descriptor: \(descriptor)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("error: \(String(describing: error))")
        }
        else {
            print("isNotifying: \(characteristic.isNotifying)")
            print("characteristic: \(characteristic)")
        }
        
        peripheral.readValue(for: characteristic)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("error: \(error)")
            return
        }
        print("Write Succeeded!")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        guard error == nil else {
            print("Error discovering descriptor: \(error!.localizedDescription)")
            return
        }
        
        if let data = descriptor.value {
            print("Received Descriptor Data length: \(data)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("Error discovering service: \(error!.localizedDescription)")
            return
        }
    }
}

