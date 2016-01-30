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
    
    var isAlive : Bool
    {
        get
        {
            return health > 0;
        }
    }
    
    init(health: Int, attackStrength: Int)
    {
        self.health = health;
        self.attackStrength = attackStrength;
    }
}