//
//  ViewController.swift
//  TestApp
//
//  Created by Alsey Coleman Miller on 4/20/16.
//  Copyright © 2016 PureSwift. All rights reserved.
//

import UIKit
import Foundation
import Bluetooth
import GATT

final class ViewController: UIViewController {
    
    let central = CentralManager()
    
    let duration: TimeInterval = 5

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        central.log = { print("CentralManager:", $0) }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scan()
    }
    
    @IBAction func scan(_ sender: AnyObject? = nil) {
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            
            guard let controller = self else { return }
            
            let central = controller.central
            
            let duration = controller.duration
            
            central.waitForPoweredOn()
            
            print("Scanning for \(duration) seconds")
            
            let scanResults = central.scan(duration: duration)
            
            print("Found \(scanResults.count) peripherals")
            
            do {
                
                defer { print("Finished scan") }
                
                for result in scanResults {
                    
                    let peripheral = result.peripheral
                    
                    print("Peripheral: \(peripheral.identifier) \(result.advertisementData.localName ?? "")")
                    
                    do { try central.connect(to: peripheral) }
                    catch { print("Could not connect:", error); continue }
                    
                    let services = try central.discoverServices(for: peripheral)
                    
                    for service in services {
                        
                        print("Service: \(service.uuid)")
                        
                        let characteristics = try central.discoverCharacteristics(for: service.uuid, peripheral: peripheral)
                        
                        for characteristic in characteristics {
                            
                            print("Characteristic: \(characteristic.uuid)")
                        }
                    }
                }
            }
                
            catch { print("Error: \(error)") }
        }
    }
}
