//
//  DexcomG7HeartbeatBluetoothTransmitter.swift
//

import Foundation
import os
import CoreBluetooth
import AVFoundation

/**
 DexcomG7HeartbeatBluetoothTransmitter is not a real CGMTransmitter but used as workaround to make clear in bluetoothperipheral manager that libreview is used as CGM
 */
class DexcomG7HeartbeatBluetoothTransmitter: BluetoothTransmitter {
    
    // MARK: - properties
    
    /// service CBUUID
    private let CBUUID_Service_G7: String = "F8083532-849E-531C-C594-30F1F86A4EA5"
    
    /// advertisement CBUUID
    private let CBUUID_Advertisement_G7: String = "FEBC"

    /// receive characteristic - this is the characteristic for the one minute reading
    private let CBUUID_ReceiveCharacteristic_G7: String = "F8083535-849E-531C-C594-30F1F86A4EA5" // authentication characteristic
    
    /// not really useful
    private let CBUUID_WriteCharacteristic_G7: String = "F8083535-849E-531C-C594-30F1F86A4EA5"
    
    /// for trace
    private let log = OSLog(subsystem: ConstantsLog.subSystem, category: ConstantsLog.categoryHeartBeatG7)
    
    /// when was the last heartbeat
    private var lastHeartBeatTimeStamp: Date

    // MARK: - Initialization
    /// - parameters:
    ///     - address: if already connected before, then give here the address that was received during previous connect, if not give nil
    ///     - name : if already connected before, then give here the name that was received during previous connect, if not give nil
    ///     - transmitterID: should be the name of the libre 3 transmitter as seen in the iOS settings, doesn't need to be the full name, 3-5 characters should be ok
    ///     - bluetoothTransmitterDelegate : a bluetoothTransmitterDelegate
    init(address:String?, name: String?, transmitterID:String, bluetoothTransmitterDelegate: BluetoothTransmitterDelegate) {

        var newAddressAndName:BluetoothTransmitter.DeviceAddressAndName = BluetoothTransmitter.DeviceAddressAndName.notYetConnected(expectedName: transmitterID)
        
        // if address not nil, then it's about connecting to a device that was already connected to before. We don't know the exact device name, so better to set it to nil. It will be assigned the real value during connection process
        if let address = address {
            newAddressAndName = BluetoothTransmitter.DeviceAddressAndName.alreadyConnectedBefore(address: address, name: nil)
        }
        
        // initially last heartbeat was never (ie 1 1 1970)
        self.lastHeartBeatTimeStamp = Date(timeIntervalSince1970: 0)

        super.init(addressAndName: newAddressAndName, CBUUID_Advertisement: CBUUID_Advertisement_G7, servicesCBUUIDs: [CBUUID(string: CBUUID_Service_G7)], CBUUID_ReceiveCharacteristic: CBUUID_ReceiveCharacteristic_G7, CBUUID_WriteCharacteristic: CBUUID_WriteCharacteristic_G7, bluetoothTransmitterDelegate: bluetoothTransmitterDelegate)
        
    }
    
    // MARK: CBCentralManager overriden functions
    
    override func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

        //super.peripheral(peripheral, didUpdateValueFor: characteristic, error: error)

        // trace the received value and uuid
        if let value = characteristic.value {
            trace("in peripheralDidUpdateValueFor, characteristic = %{public}@, data = %{public}@", log: log, category: ConstantsLog.categoryHeartBeatG7, type: .info, String(describing: characteristic.uuid), value.hexEncodedString())
        }

        // this is the trigger for calling the heartbeat
        if (Date()).timeIntervalSince(lastHeartBeatTimeStamp) > ConstantsHeartBeat.minimumTimeBetweenTwoHeartBeats {
            
            // sleep for a second to allow Loop to read the readings and upload them to NS
            Thread.sleep(forTimeInterval: 1)

            self.bluetoothTransmitterDelegate?.heartBeat()

            lastHeartBeatTimeStamp = Date()

        }
        
    }
            
}
