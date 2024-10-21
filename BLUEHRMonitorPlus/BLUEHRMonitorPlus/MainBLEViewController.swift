//
//  MainBLEViewController.swift
//  BLEHRMonitor
//
//  Created by Mario Andres Heberthardt Marchant on 24/9/24.
//

import UIKit
import CoreBluetooth

class MainBLEViewController: UIViewController {

    //lazy vars UI to be used
    lazy var topHeaderView:UIView = {
        var topView = UIView()
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.backgroundColor = UIColor.green
        
        return topView
    }()
    
    lazy var titleView:UILabel = {
        var title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Heart Rate Monitor"
        title.font = UIFont.boldSystemFont(ofSize: 25)
        title.textColor = .white
        title.textAlignment = .center
        
        return title
    }()
    
    lazy var mainStackView:UIStackView = {
        var stack = UIStackView(arrangedSubviews: [spaceView, titleLable, hrStackView, titleSensor, titleLocationSensor])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .equalCentering
        
        return stack
    }()
    
    lazy var hrStackView:UIStackView = {
        var stack = UIStackView(arrangedSubviews: [titleHR, imageHR])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        
        return stack
    }()
    
    lazy var spaceView:UIView = {
        let space = UIView(frame: .zero)
        space.heightAnchor.constraint(equalToConstant: 25).isActive = true
        return space
    }()
    
    lazy var titleLable:UILabel = {
        var title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Current Heart Rate"
        title.font = UIFont.boldSystemFont(ofSize: 35)
        title.textAlignment = .center
        title.textColor = .black
        
        return title
    }()
    
    lazy var titleHR:UILabel = {
        var title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = heartRateText ?? "00"
        title.font = UIFont.systemFont(ofSize: 130)
        title.textAlignment = .center
        title.textColor = .black
        
        return title
    }()
    
    lazy var imageHR:UIImageView = {
        let hrImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        hrImage.image = UIImage(systemName: "heart.fill")
        //hrImage.translatesAutoresizingMaskIntoConstraints = false
        hrImage.tintColor = .black
        hrImage.addSymbolEffect(.pulse, options: .repeating, animated: true)
        
        
        return hrImage
    }()
    
    lazy var titleSensor:UILabel = {
        var title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Body Sensor Location"
        title.font = UIFont.boldSystemFont(ofSize: 35)
        title.textAlignment = .center
        title.textColor = .black
        
        return title
    }()
    
    lazy var titleLocationSensor:UILabel = {
        var title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = locationText ?? "----"
        title.font = UIFont.boldSystemFont(ofSize: 40)
        title.textAlignment = .center
        title.textColor = .black
        
        return title
    }()
    
    let heartRateServiceCBUUID = CBUUID(string: Constants.serviceTypeCBUUID)
    let heartRateMeasurementCharacteristicCBUUID = CBUUID(string: Constants.heartRateMeasurementCBUUID)
    let bodySensorLocationCharacteristicCBUUID = CBUUID(string: Constants.bodySensorLocationCBUUID)

    var centralManager: CBCentralManager!
    var heartRatePeripheral: CBPeripheral!
    var locationText:String!
    var heartRateText:String!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self, queue: nil)
        setView()

    }

    
    func setView() {
        view.backgroundColor = .white
        setTopView()
        setStackView()
    }
    
    func setTopView() {
        let topView = topHeaderView
        view.addSubview(topView)
        topView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        topView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        topView.addSubview(titleView)
        titleView.leadingAnchor.constraint(equalTo: topView.leadingAnchor).isActive = true
        titleView.trailingAnchor.constraint(equalTo: topView.trailingAnchor).isActive = true
        titleView.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -10).isActive = true
    
    }
    
    func setStackView() {
        let stack = mainStackView
        view.addSubview(stack)
        
        stack.topAnchor.constraint(equalTo: topHeaderView.bottomAnchor).isActive = true
        stack.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stack.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
    }

}

extension MainBLEViewController: CBCentralManagerDelegate {
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
              centralManager.scanForPeripherals(withServices: nil)
            @unknown default:
              print("Default case, should never get here")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        if peripheral.name == "SmartHR Monitor" {
            centralManager.stopScan()
            heartRatePeripheral = peripheral
            heartRatePeripheral.delegate = self
            centralManager.connect(heartRatePeripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        heartRatePeripheral.discoverServices(nil)
    }
}

extension MainBLEViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            print(service)
            print(service.characteristics ?? "Characteristic are nil")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print(characteristic)
            
            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid): properties contains .read")
            }
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify")
            }
            
            peripheral.readValue(for: characteristic)
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        guard let characteristicData = characteristic.value,
        let byte = characteristicData.first else { return }
        switch characteristic.uuid {
            case bodySensorLocationCharacteristicCBUUID:
                print(characteristic.value ?? "no value")
                print(Constants.bodySensorLocation.locationValues[byte.hashValue])
                locationText = Constants.bodySensorLocation.locationValues[byte.hashValue]
            case heartRateMeasurementCharacteristicCBUUID:
                let bpm = heartRate(from: characteristic)
                
            default:
                print("Characteristic not handle UUID: \(characteristic.uuid)")
        }
    }
    
    private func heartRate(from characteristic: CBCharacteristic) -> Int {
      guard let characteristicData = characteristic.value else { return -1 }
      let byteArray = [UInt8](characteristicData)

      let firstBitValue = byteArray[0] & 0x01
      if firstBitValue == 0 {
        // Heart Rate Value Format is in the 2nd byte
        return Int(byteArray[1])
      } else {
        // Heart Rate Value Format is in the 2nd and 3rd bytes
        return (Int(byteArray[1]) << 8) + Int(byteArray[2])
      }
    }

}
