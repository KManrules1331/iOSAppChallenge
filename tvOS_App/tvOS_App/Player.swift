//
//  Player.swift
//  tvOS_App
//
//  Created by Apple on 1/29/16.
//  Copyright © 2016 PumpkinSpiceGirls. All rights reserved.
//

import Foundation

class Player {
    var health : Int;
    var attackStrength : Int;
    var attackAngle : Angle;
    
    var isAlive : Bool
    {
        get
        {
            return health > 0;
        }
    }
    
    init(data: PlayerData)
    {
        self.health = data.health;
        self.attackStrength = data.attackStrength;
        self.attackAngle = data.attackAngle;
    }
    
    func damage(dmg: Int)
    {
        health -= dmg;
    }
}