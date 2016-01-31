//
//  GameScene.swift
//  tvOS_App
//
//  Created by Apple on 1/28/16.
//  Copyright (c) 2016 PumpkinSpiceGirls. All rights reserved.
//

import SpriteKit
import GameController

class GameScene: SKScene {
    
    var enemy : Enemy!
    var player : Player!
    var debugPlayer : SKLabelNode!
    var debugEnemy : SKLabelNode!
    var debugText : SKLabelNode!
    var lastLocation : CGPoint = CGPointMake(0, 0)
    var controller : GCController!
    
    override func didMoveToView(view: SKView) {
        
        let playerData = PlayerData(health: 10, attackStrength: 1, attackAngle: Angle(value: 0.0));
        player = Player(data: playerData);
        let enemyData = EnemyData(health: 5, attack: 1, attackInterval: 2.0, weaknessAngle: Angle(value: 0.0), marginOfError: Angle(value: 0.0), imageName: "enemy");
        enemy = Enemy(data: enemyData, position: CGPointMake(size.width / 2, size.height / 2), scene: self);
        
        debugPlayer = SKLabelNode(fontNamed:"Chalkduster")
        debugPlayer.text = "Player Health: " + String(playerData.health)
                          + " Player Attack Strength: " + String(playerData.attackStrength)
                          + " Player Attack Angle: " + String(playerData.attackAngle.Value)
        debugPlayer.fontSize = 10
        debugPlayer.position = CGPoint(x:150, y:650)
        
        debugEnemy = SKLabelNode(fontNamed:"Chalkduster")
        debugEnemy.text = "Enemy Health: " + String(enemyData.health)
                         + " Enemy Attack: " + String(enemyData.attack)
                         + " Enemy Attack Interval: " + String(enemyData.attackInterval)
                         + " Enemy Weakness Angle: " + String(enemyData.weaknessAngle.Value)
                         + " Enemy Margin of Error: " + String(enemyData.marginOfError.Value)
        debugEnemy.fontSize = 10
        debugEnemy.position = CGPoint(x:370, y:640)
        
        debugText = SKLabelNode(fontNamed:"Chalkduster")
        debugText.text = "Debug"
        debugText.fontSize = 10
        debugText.position = CGPoint(x:100, y: 630)
        
        self.addChild(debugPlayer)
        self.addChild(debugEnemy)
        self.addChild(debugText)
        
        //Register select events
        let tapSelect = UITapGestureRecognizer()
        tapSelect.addTarget(self, action: "pressedSelect")
        tapSelect.allowedPressTypes = [NSNumber (integer: UIPressType.Select.rawValue)]
        self.view!.addGestureRecognizer(tapSelect)
        
        //Register swipe events
        let swipeUp = UISwipeGestureRecognizer()
        swipeUp.addTarget(self, action: "swipedUp")
        swipeUp.direction = .Up
        self.view!.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer()
        swipeDown.addTarget(self, action: "swipedDown")
        swipeDown.direction = .Down
        self.view!.addGestureRecognizer(swipeDown)
        
        GCController.startWirelessControllerDiscoveryWithCompletionHandler({()->Void in })
        
        NSNotificationCenter.defaultCenter().addObserverForName(GCControllerDidConnectNotification, object: nil, queue: nil)
        { note in
            self.controller = GCController.controllers().first!
            
            self.controller.microGamepad?.valueChangedHandler = { (gamepad, element) -> Void in
                if element == self.controller.microGamepad?.dpad {
                    //TODO: now that we have access to dpad movement, use that to adjust the attack angle!
                    self.debugText.text = String(self.controller.microGamepad?.dpad.left.value)
                }
            }
        }
        self.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.waitForDuration(enemyData.attackInterval),SKAction.runBlock(){self.player.damage(enemyData.attack)}])))
        self.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.waitForDuration(enemyData.attackInterval),SKAction.runBlock(){self.enemy.weaknessAngle = self.enemy.weaknessAngle + Angle(value: M_PI/6)}])))
    }
    
    func pressedSelect()
    {
        debugText.text = "Select button pressed"
        //TODO: Fix the condition that detects sucessful hits
        if ( player.attackAngle == enemy.weaknessAngle || player.attackAngle + Angle(value:M_PI) == enemy.weaknessAngle)
        {
            //debugText.text = "successful attack"
            enemy.damage(player.attackStrength)
        }
        else
        {
            //debugText.text = "Missed attack"
        }
        //player.damage(enemy.attack)
    }
    
    func swipedUp()
    {
        //debugText.text = "Swiped Up"
        player.attackAngle = player.attackAngle + Angle(value: M_PI/6);
    }
    
    func swipedDown()
    {
        //debugText.text = "Swiped down"
        player.attackAngle = player.attackAngle - Angle(value: M_PI/6);
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        debugEnemy.text = "Enemy Health: " + String(enemy.health)
            + " Enemy Attack: " + String(enemy.attack)
            + " Enemy Attack Interval: " + String(enemy.attackInterval)
            + " Enemy Weakness Angle: " + String(enemy.weaknessAngle.Value)
            + " Enemy Margin of Error: " + String(enemy.marginOfError.Value)
        debugPlayer.text = "Player Health: " + String(player.health)
            + " Player Attack Strength: " + String(player.attackStrength)
            + " Player Attack Angle: " + String(player.attackAngle.Value)
        
        if !player.isAlive
        {
            //Go to game over screen
        }
        
        
    }
}
