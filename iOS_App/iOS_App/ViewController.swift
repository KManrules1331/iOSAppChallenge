//
//  ViewController.swift
//  iOS_App
//
//  Created by Apple on 1/28/16.
//  Copyright © 2016 PumpkinSpiceGirls. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    let motionCapture = CMMotionManager();
    let remoteSender = RemoteSender();

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        motionCapture.deviceMotionUpdateInterval = 1.0 / 30.0;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        motionCapture.stopDeviceMotionUpdates();
    }
    
    override func viewDidAppear(animated: Bool) {
        motionCapture.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: {(data: CMDeviceMotion?, error: NSError?) -> Void in
            let rotMat = data?.attitude.rotationMatrix;
            var dictionary = Dictionary<Int, Double>(minimumCapacity: 9);
            dictionary[0] = rotMat?.m11;
            dictionary[1] = rotMat?.m12;
            dictionary[2] = rotMat?.m13;
            dictionary[3] = rotMat?.m21;
            dictionary[4] = rotMat?.m22;
            dictionary[5] = rotMat?.m23;
            dictionary[6] = rotMat?.m31;
            dictionary[7] = rotMat?.m32;
            dictionary[8] = rotMat?.m33;
            
            self.remoteSender.sendInfo(dictionary);
        });
    }
}

