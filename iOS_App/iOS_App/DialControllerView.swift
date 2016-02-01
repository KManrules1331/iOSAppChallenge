//
//  DialController.swift
//  iOS_App
//
//  Created by Apple on 1/31/16.
//  Copyright © 2016 PumpkinSpiceGirls. All rights reserved.
//

import Foundation
import UIKit

class DialControllerView : UIView {
    let rotationElement : Element!;
    let dialView : UIImageView!;
    var rotationOffset : Angle = Angle(value: 0.0);
    var currentRotation : Angle = Angle(value: 0.0);
    var beginRotation : Angle = Angle(value: 0.0);
    
    var value : Float {
        get {
            return self.value;
        }
        set {
            self.value = newValue;
        }
    }
    
    override init(frame: CGRect)
    {
        self.rotationElement = VgcManager.elements.elementFromType(ElementType.RightThumbstickXAxis);
        let dialImage = UIImage(named: "dial");
        dialView = UIImageView(image: dialImage);
        
        super.init(frame: frame);
        
        dialView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height);
        self.addSubview(dialView);
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Cannot initialize dialControllerView from Storyboard!  Use frame initializer");
    }
    
    func percentageForce(touch: UITouch) -> Float {
        let force = Float(touch.force)
        let maxForce = Float(touch.maximumPossibleForce)
        let percentageForce: Float
        if (force == 0) { percentageForce = 0 } else { percentageForce = force / maxForce }
        return percentageForce
    }
    
    var lastRefresh = NSDate();
    
    func processTouch(touch: UITouch!) {
        
        if touch!.view == self {
            
            // Avoid updating too often
            if lastRefresh.timeIntervalSinceNow > -(1 / 60) { return } else { lastRefresh = NSDate() }
            
            // Prevent the stick from leaving the view center area
            var newX = touch!.locationInView(self).x
            var newY = touch!.locationInView(self).y
            let movementMarginSize = self.bounds.size.width * 0.25
            if newX < movementMarginSize { newX = movementMarginSize}
            if newX > self.bounds.size.width - movementMarginSize { newX = self.bounds.size.width - movementMarginSize }
            if newY < movementMarginSize { newY = movementMarginSize }
            if newY > self.bounds.size.height - movementMarginSize { newY = self.bounds.size.height - movementMarginSize }
            
            // Regularize the value between -1 and 1
            let rangeSize = self.bounds.size.height - (movementMarginSize * 2.0)
            let xValue = (((newX / rangeSize) - 0.5) * 2.0) - 1.0
            var yValue = (((newY / rangeSize) - 0.5) * 2.0) - 1.0
            yValue = -(yValue)
            
            let rotationVal = Angle(value: Double(atan2(xValue, yValue))) - beginRotation;
            currentRotation = rotationVal + rotationOffset;
            
            rotationElement.value = Float(currentRotation.Value)
            dialView.transform = CGAffineTransformMakeRotation(CGFloat(currentRotation.Value));
            VgcManager.peripheral.sendElementState(rotationElement)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first;
        
            if touch!.view == self {
                // Prevent the stick from leaving the view center area
                var newX = touch!.locationInView(self).x
                var newY = touch!.locationInView(self).y
                let movementMarginSize = self.bounds.size.width * 0.25
                if newX < movementMarginSize { newX = movementMarginSize}
                if newX > self.bounds.size.width - movementMarginSize { newX = self.bounds.size.width - movementMarginSize }
                if newY < movementMarginSize { newY = movementMarginSize }
                if newY > self.bounds.size.height - movementMarginSize { newY = self.bounds.size.height - movementMarginSize }
        
                // Regularize the value between -1 and 1
                let rangeSize = self.bounds.size.height - (movementMarginSize * 2.0)
                let xValue = (((newX / rangeSize) - 0.5) * 2.0) - 1.0
                var yValue = (((newY / rangeSize) - 0.5) * 2.0) - 1.0
                yValue = -(yValue)
        
                let rotationVal = Angle(value: Double(atan2(xValue, yValue)));
                beginRotation = rotationVal;
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        self.processTouch(touch)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        rotationOffset = currentRotation;
    }
}
