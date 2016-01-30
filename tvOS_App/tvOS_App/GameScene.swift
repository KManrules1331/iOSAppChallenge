//
//  GameScene.swift
//  tvOS_App
//
//  Created by Apple on 1/28/16.
//  Copyright (c) 2016 PumpkinSpiceGirls. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var enemy : Enemy!
    var player : Player!
    var debugPlayer : SKLabelNode!
    var debugEnemy : SKLabelNode!
    var debugText : SKLabelNode!
    var lastLocation : CGPoint = CGPointMake(0, 0)
    
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
        
        /*
        let dragRecognizer = UIPanGestureRecognizer()
        dragRecognizer.addTarget(self, action: "detectDrag")
        self.view!.addGestureRecognizer(dragRecognizer)
        */
        self.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.waitForDuration(enemyData.attackInterval),SKAction.runBlock(){self.player.damage(enemyData.attack)}])))
        self.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.waitForDuration(enemyData.attackInterval),SKAction.runBlock(){self.enemy.weaknessAngle = self.enemy.weaknessAngle + Angle(value: M_PI/6)}])))
    }
    
    /*
    func detectDrag(recognizer:UIPanGestureRecognizer)
    {
        //Xcode complains if I make this "Var" instead of "Let" cause I never mutate it :/
        let velocity = recognizer.translationInView(self.view)
        if let view = recognizer.view {
            view.center = CGPoint(x:view.center.x + velocity.x,
                y:view.center.y + velocity.y)
        }
        recognizer.setTranslation(CGPointZero, inView: self.view)
        //debugText.text = String(velocity)
        //player.attackAngle = player.attackAngle + Angle(value: Double(velocity.x))
    }
    */
    
    func pressedSelect()
    {
        debugText.text = "Select button pressed"
        if ( player.attackAngle == enemy.weaknessAngle)
        {
            debugText.text = "successful attack"
            enemy.damage(player.attackStrength)
        }
        else
        {
            debugText.text = "Missed attack"
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
