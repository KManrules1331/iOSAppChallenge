//
//  Enemy.swift
//  tvOS_App
//
//  Created by Apple on 1/29/16.
//  Copyright © 2016 PumpkinSpiceGirls. All rights reserved.
//

import Foundation
import SpriteKit

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
    
    var health : Int;
    var attack : Int;
    var attackInterval : Double;
    var weaknessAngle : Angle;
    var marginOfError : Angle;
    var sprite : SKSpriteNode;
    
    private var width = CGFloat(100);
    private var height = CGFloat(100);
    
    private var attackTimer : CFTimeInterval;
    
    init(data: EnemyData, position: CGPoint, scene: SKScene)
    {
        self.sprite = SKSpriteNode(imageNamed: data.imageName)
        
        self.sprite.position = position;
        self.sprite.xScale = width / self.sprite.frame.width;
        self.sprite.yScale = height / self.sprite.frame.height;
        self.health = data.health;
        self.attack = data.attack;
        self.attackInterval = data.attackInterval;
        self.weaknessAngle = data.weaknessAngle;
        self.marginOfError = data.marginOfError;
        
        self.attackTimer = 0.0;
        
        scene.addChild(self.sprite);
    }
    
    func update(deltaTime: CFTimeInterval) -> Void
    {
        attackTimer += deltaTime;
    }
    
    func damage (dmg: Int)
    {
        health -= dmg;
    }
    
    func didHit(angle: Angle) -> Bool
    {
        let maxAngle = weaknessAngle + marginOfError;
        let minAngle = weaknessAngle - marginOfError;
        return angle < maxAngle && angle > minAngle
    }
}