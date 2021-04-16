//
//  ViewController.swift
//  BeurerTestPulse
//
//  Created by Daniel Karoumi on 2021-04-14.
//

import UIKit
import CoreBluetooth

let ServiceCBUUID = CBUUID(string: "1822")
let characteristicCBUUID = CBUUID(string: "2A23")



class ViewController: UIViewController {
    var centralManager: CBCentralManager!
    var heartRatePeripheral: CBPeripheral!


    override func viewDidLoad() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
          case .unknown:
            print("central.state is .unknown")
          case .resetting:
            print("central.state is .resetting")
          case .unsupported:
            print("central.state is .unsupported")
          case .unauthorized:
            print("central.state is .unauthorized")
          case .poweredOff:
            print("central.state is .poweredOff")
          case .poweredOn:
            print("central.state is .poweredOn")
//            centralManager.scanForPeripherals(withServices: [ServiceCBUUID])
            centralManager.scanForPeripherals(withServices: nil)
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        if peripheral.name=="PO60"{
            heartRatePeripheral = peripheral
            heartRatePeripheral.delegate = self
            centralManager.stopScan()
            centralManager.connect(heartRatePeripheral)
        }

    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
      print("Connected!")
      heartRatePeripheral.discoverServices(nil)

    }

}

extension ViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }

        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)

        }

    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
      guard let characteristics = service.characteristics else { return }

      for characteristic in characteristics {
        print(characteristic)
        
        if characteristic.properties.contains(.read) {
          print("\(characteristic.uuid): properties contains .read")
          peripheral.readValue(for: characteristic)

        }
        if characteristic.properties.contains(.notify) {
          print("\(characteristic.uuid): properties contains .notify")
        }

      }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
      switch characteristic.uuid {
        case characteristicCBUUID:
          print(characteristic.value ?? "no value")
            print(type(of: characteristic.properties))
            print(String(data: characteristic.value!, encoding: .utf8))
      default:
          print("Unhandled Characteristic UUID: \(characteristic.uuid)")
      }
    }


}

