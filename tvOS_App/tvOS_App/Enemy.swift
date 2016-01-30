//
//  Enemy.swift
//  tvOS_App
//
//  Created by Apple on 1/29/16.
//  Copyright © 2016 PumpkinSpiceGirls. All rights reserved.
//

import Foundation

class Enemy
{
    var shouldAttack : Bool
    {
        get
        {
            if (attackTimer > attackInterval)
            {
                attackTimer -= attackInterval;
                return true;
            }
            return false;
        }
    }
    
    private var health : Int;
    private var attack : Int;
    private var attackInterval : Double;
    private var weaknessAngle : Angle;
    private var marginOfError : Angle;
    
    private var attackTimer : CFTimeInterval;
    
    init(health: Int, attack: Int, attackInterval: Double, weaknessAngle: Angle, marginOfError: Angle)
    {
        self.health = health;
        self.attack = attack;
        self.attackInterval = attackInterval;
        self.weaknessAngle = weaknessAngle;
        self.marginOfError = marginOfError;
        
        self.attackTimer = 0.0;
    }
    
    func update(deltaTime: CFTimeInterval) -> Void
    {
        attackTimer += deltaTime;
    }
    
    func didHit(angle: Angle) -> Bool
    {
        let maxAngle = weaknessAngle + marginOfError;
        let minAngle = weaknessAngle - marginOfError;
        return angle < maxAngle && angle > minAngle
    }
}