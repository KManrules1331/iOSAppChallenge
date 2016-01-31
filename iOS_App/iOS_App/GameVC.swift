//
//  GameVC.swift
//  iOS_App
//
//  Created by Apple on 1/31/16.
//  Copyright © 2016 PumpkinSpiceGirls. All rights reserved.
//

import UIKit

class GameVC: UIViewController {

    // Ref to dial img
    @IBOutlet weak var dialObject: UIImageView!
    
    
    // Go back to menu
    @IBAction func BtnPress_BackToMenu(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func MoveDialByAmount(moveAmount : CGFloat){
        dialObject.transform = CGAffineTransformRotate(dialObject.transform, moveAmount)
    }
    
    func MoveDialToAngle(angle : CGFloat){
        dialObject.transform = CGAffineTransformMakeRotation(angle)
    }
    
    @IBAction func BtnPress_Swipe(sender: AnyObject) {
        // test moing the dial 
        MoveDialByAmount(50)
    }
}
