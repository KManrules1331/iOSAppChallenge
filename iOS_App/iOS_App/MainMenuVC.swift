//
//  MainMenuVC.swift
//  iOS_App
//
//  Created by Apple on 1/31/16.
//  Copyright © 2016 PumpkinSpiceGirls. All rights reserved.
//

import UIKit 

class MainMenuVC: UIViewController {

    override func viewDidLoad() {
        // Hide the nav bar
        self.navigationController?.navigationBarHidden = true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
