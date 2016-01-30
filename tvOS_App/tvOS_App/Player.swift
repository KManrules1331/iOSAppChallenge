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
    var Health : Int
    {
        get
        {
            return health;
        }
    }
    var AttackStrength : Int
    {
        get
        {
            return attackStrength;
        }
        set(value)
        {
            attackStrength = value;
        }
    }
    
    init(data: PlayerData)
    {
        self.health = data.health;
        self.attackStrength = data.attackStrength;
    }
    
    func damage(dmg: Int)
    {
        health -= dmg;
    }
}