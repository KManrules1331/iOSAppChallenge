//
//  GameVC.swift
//  iOS_App
//
//  Created by Apple on 1/31/16.
//  Copyright © 2016 PumpkinSpiceGirls. All rights reserved.
//

import UIKit

class GameVC: UIViewController {
    
    var dialController : DialControllerView!;
    var aButtonElement : Element!
    
    override func viewDidLoad() {
        // Initialize Peripheral
        VgcManager.startAs(.Peripheral, appIdentifier: "PSGiOSRITChallenge", customElements: CustomElements(), customMappings: CustomMappings(), includesPeerToPeer: true)
        
        // Set peripheral device info
        // Send an empty string for deviceUID and UID will be auto-generated and stored to user defaults
        VgcManager.peripheral.deviceInfo = DeviceInfo(deviceUID: "", vendorName: "", attachedToDevice: false, profileType: .ExtendedGamepad, controllerType: .Software, supportsMotion: true)
        
        // This property needs to be set to a specific iCade controller to enable the functionality.  This
        // cannot be done by automatically discovering the identity of the controller; rather, it requires
        // presenting a list of controllers to the user and let them choose.
        VgcManager.iCadeControllerMode = .Disabled
        
        // Kick off the search for Centrals and Bridges that we can connect to.  When
        // services are found, the VgcPeripheralFoundService will fire.
        VgcManager.peripheral.browseForServices()
        
        VgcManager.includesPeerToPeer = true
        
        VgcManager.peripheral.motion.updateInterval = 1/60
        
        VgcManager.peripheral.motion.enableAttitude = true
        VgcManager.peripheral.motion.enableGravity = false
        VgcManager.peripheral.motion.enableRotationRate = false
        VgcManager.peripheral.motion.enableUserAcceleration = false
        
        VgcManager.peripheral.motion.enableAdaptiveFilter = true
        VgcManager.peripheral.motion.enableLowPassFilter = true
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "foundService:", name: VgcPeripheralFoundService, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peripheralDidConnect:", name: VgcPeripheralDidConnectNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peripheralDidDisconnect:", name: VgcPeripheralDidDisconnectNotification, object: nil)
        
        dialController = DialControllerView(frame: CGRect(x: self.view.frame.width / 2 - 100, y: self.view.frame.height / 2 - 100, width: 200, height: 200));
        self.view.addSubview(dialController);
        
        aButtonElement = VgcManager.elements.elementFromType(ElementType.ButtonA);
    }
    
    // Go back to menu
    @IBAction func BtnPress_BackToMenu(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func BtnPress_Swipe(sender: AnyObject) {
        // test moing the dial 
        aButtonElement.value = Float(1.0);
        VgcManager.peripheral.sendElementState(aButtonElement);
    }
    
    @IBAction func BtnRelease_Swipe(sender: AnyObject) {
        aButtonElement.value = Float(0.0);
        VgcManager.peripheral.sendElementState(aButtonElement);
    }
    
    @objc func foundService(notification: NSNotification) {
        let vgcService = notification.object as! VgcService
        vgcLogDebug("Found service: \(vgcService.fullName) isMainThread: \(NSThread.isMainThread())")
        VgcManager.peripheral.connectToService(vgcService);
    }
    
    @objc func peripheralDidConnect(notification: NSNotification) {
        VgcManager.peripheral.stopBrowsingForServices()
    }
    
    @objc func peripheralDidDisconnect(notification: NSNotification) {
        
        vgcLogDebug("Got VgcPeripheralDidDisconnectNotification notification")
        VgcManager.peripheral.browseForServices()
        
    }
}
