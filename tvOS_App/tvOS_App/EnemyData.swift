//
//  EnemyData.swift
//  tvOS_App
//
//  Created by Apple on 1/30/16.
//  Copyright © 2016 PumpkinSpiceGirls. All rights reserved.
//

import Foundation

struct EnemyData {
    var health : Int;
    var attack : Int;
    var attackInterval : Double;
    var weaknessAngle : Angle;
    var marginOfError : Angle;
    var imageName : String;
}