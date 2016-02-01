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
    var enemy1Idl : SKSpriteNode!
    var enemy1Atk : SKSpriteNode!
    var enemy2Idl : SKSpriteNode!
    var enemy2Atk : SKSpriteNode!
    var sword : SKSpriteNode!
    var currentEnemy : Int = 0
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        //Set up VGC
        VgcManager.startAs(.Central, appIdentifier: "PSGiOSRITChallenge", includesPeerToPeer: true);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "controllerDidConnect:", name: VgcControllerDidConnectNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "controllerDidDisconnect:", name: VgcControllerDidDisconnectNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedPeripheralSetup:", name: VgcPeripheralSetupNotification, object: nil);
        
        let background = SKSpriteNode(imageNamed: "background_TV", normalMapped: true)
        background.size = size
        background.position = CGPointMake(size.width/2, size.height/2)
        background.zPosition = -5
        
        enemy1Idl = SKSpriteNode(imageNamed: "enemy_idle", normalMapped: true)
        enemy1Idl.size = CGSize(width: 300, height: 300)
        enemy1Idl.position = CGPointMake(size.width/2, size.height/2)
        enemy1Idl.zPosition = 2
        
        enemy1Atk = SKSpriteNode(imageNamed: "enemy_attack", normalMapped: true)
        enemy1Atk.size = CGSize(width: 300, height: 300)
        enemy1Atk.position = CGPointMake(size.width/2, size.height/2)
        enemy1Atk.zPosition = 2
        
        enemy2Idl = SKSpriteNode(imageNamed: "enemy_2_idle", normalMapped: true)
        enemy2Idl.size = CGSize(width: 300, height: 300)
        enemy2Idl.position = CGPointMake(size.width/2 + 800, size.height/2 + 800)
        enemy2Idl.zPosition = 2
        
        enemy2Atk = SKSpriteNode(imageNamed: "enemy_2_attack", normalMapped: true)
        enemy2Atk.size = CGSize(width: 300, height: 300)
        enemy2Atk.position = CGPointMake(size.width/2 + 800, size.height/2 + 800)
        enemy2Atk.zPosition = 2
        
        sword = SKSpriteNode(imageNamed: "swordFixed", normalMapped: true)
        sword.size = CGSize(width: 253/4, height: 3200/4)
        //sword.anchorPoint = CGPoint(x:size.width/2, y:size.height/2)
        sword.position = CGPointMake(size.width/2, size.height/2)
        sword.zPosition = 3
        
        let playerData = PlayerData(health: 10, attackStrength: 1, attackAngle: Angle(value: 0.0));
        player = Player(data: playerData);
        let enemyData = EnemyData(health: 5, attack: 1, attackInterval: 2.0, weaknessAngle: Angle(value: 0.0), marginOfError: Angle(value: M_PI/2), imageName: "enemy");
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
        self.addChild(background)
        self.addChild(enemy1Idl)
        enemy1Idl.hidden = true
        self.addChild(enemy1Atk)
        enemy1Atk.hidden = true
        self.addChild(enemy2Idl)
        enemy2Idl.hidden = false
        self.addChild(enemy2Atk)
        enemy2Atk.hidden = true
        self.addChild(sword)
        
        //Register select events
        let tapSelect = UITapGestureRecognizer()
        tapSelect.addTarget(self, action: "pressedSelect")
        tapSelect.allowedPressTypes = [NSNumber (integer: UIPressType.Select.rawValue)]
        self.view!.addGestureRecognizer(tapSelect)
        
        GCController.startWirelessControllerDiscoveryWithCompletionHandler({()->Void in })
        
        NSNotificationCenter.defaultCenter().addObserverForName(GCControllerDidConnectNotification, object: nil, queue: nil)
        { note in
            self.controller = GCController.controllers().first!
            
            self.controller.microGamepad?.valueChangedHandler = { (gamepad, element) -> Void in
                if element == self.controller.microGamepad?.dpad {
                    let xPosition = (self.controller.microGamepad?.dpad.left.value)! - (self.controller.microGamepad?.dpad.right.value)!
                    self.player.attackAngle = Angle(value: M_PI * Double(xPosition))
                }
            }
        }
        //Enemy attacks
        self.runAction(SKAction.repeatActionForever(SKAction.sequence(
            [SKAction.waitForDuration(enemyData.attackInterval),
                SKAction.runBlock(){self.player.damage(enemyData.attack)}])))
        
            self.runAction(SKAction.repeatActionForever(SKAction.sequence([
                    SKAction.runBlock(){self.enemy1Idl.hidden = false},
                    SKAction.waitForDuration(enemyData.attackInterval - 0.45),
                    SKAction.runBlock(){self.enemy1Idl.hidden = true},
                    SKAction.runBlock(){self.enemy1Atk.hidden = false},
                    SKAction.waitForDuration(0.45),
                    SKAction.runBlock(){self.enemy1Atk.hidden = true},
                    SKAction.runBlock(){self.enemy1Idl.hidden = false}])))
        
            self.runAction(SKAction.repeatActionForever(SKAction.sequence([
                    SKAction.runBlock(){self.enemy2Idl.hidden = false},
                    SKAction.waitForDuration(enemyData.attackInterval - 0.45),
                    SKAction.runBlock(){self.enemy2Idl.hidden = true},
                    SKAction.runBlock(){self.enemy2Atk.hidden = false},
                    SKAction.waitForDuration(0.45),
                    SKAction.runBlock(){self.enemy2Atk.hidden = true},
                    SKAction.runBlock(){self.enemy2Idl.hidden = false}])))
        
        //Enemy rotates
        self.runAction(SKAction.repeatActionForever(SKAction.sequence([
            SKAction.waitForDuration(0.01),
            SKAction.runBlock(){self.enemy.weaknessAngle = self.enemy.weaknessAngle + Angle(value: M_PI/500)}])))
    }
    
    func pressedSelect()
    {
        if ( player.attackAngle > enemy.weaknessAngle - enemy.marginOfError && player.attackAngle < enemy.weaknessAngle + enemy.marginOfError)
        {
            debugText.text = "successful attack"
            enemy.damage(player.attackStrength)
        }
        else
        {
            debugText.text = "Missed attack"
        }
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
        
        debugText.text = "\(currentEnemy)"
        
        let rotation = CGFloat(self.enemy.weaknessAngle.Value);
        self.enemy1Idl.zRotation = rotation + CGFloat(M_PI/2);
        self.enemy1Atk.zRotation = rotation + CGFloat(5 * M_PI/12);
        self.enemy2Idl.zRotation = rotation - CGFloat(M_PI/12);
        self.enemy2Atk.zRotation = rotation;
        self.sword.zRotation = CGFloat(self.player.attackAngle.Value) - CGFloat(M_PI/2);
        
        if ( enemy.health == 0)
        {
            enemy.health = 5
            enemy.marginOfError = (enemy.marginOfError == Angle(value: M_PI/2)) ? Angle(value: M_PI/5) : Angle(value: M_PI/2)
            currentEnemy += 1;
            let enemy1Pos = enemy1Atk.position;
            let enemy2Pos = enemy2Atk.position;
            
            enemy1Idl.position = enemy2Pos;
            enemy1Atk.position = enemy2Pos;
            
            enemy2Idl.position = enemy1Pos;
            enemy2Atk.position = enemy1Pos;
        }
        
        if !player.isAlive
        {
            //Go to game over screen
        }
        
        
    }
    
    @objc func controllerDidConnect(notification: NSNotification)
    {
        if VgcManager.appRole == .EnhancementBridge { return }
        
        guard let controller : VgcController = notification.object as? VgcController else {
            print("Got nil controller in controllerDidConnect");
            return;
        }
        
        //if controller.deviceInfo.controllerType == .MFiHardware { return }
        
        VgcManager.peripheralSetup = VgcPeripheralSetup();
        VgcManager.peripheralSetup.motionActive = false;
        VgcManager.peripheralSetup.enableMotionAttitude = true;
        VgcManager.peripheralSetup.enableMotionGravity = true;
        VgcManager.peripheralSetup.enableMotionRotationRate = true;
        VgcManager.peripheralSetup.enableMotionUserAcceleration = true;
        VgcManager.peripheralSetup.sendToController(controller);
        
        controller.extendedGamepad?.dpad.valueChangedHandler = { (dpad, xValue, yValue) in
            self.player.attackAngle = Angle(value: M_PI * Double(xValue))
            print("dpad changed! x: \(xValue), y: \(yValue)");
        }
        
        controller.extendedGamepad?.leftThumbstick.valueChangedHandler = { (dpad, xValue, yValue) in
            self.player.attackAngle = Angle(value: M_PI * Double(xValue))
            print("left thumbstick changed! x: \(xValue), y: \(yValue)");
        }
        
        controller.extendedGamepad?.rightThumbstick.valueChangedHandler = { (dpad, xValue, yValue) in
            self.player.attackAngle = Angle(value: M_PI * Double(xValue))
            print("right thumbstick changed! x: \(xValue), y: \(yValue)");
        }
        
        controller.extendedGamepad?.buttonA.valueChangedHandler = { (input, value, pressed) in
            self.pressedSelect()
            print("A button changed: value: \(value), pressed: \(pressed)");
        }
        
    }
    
    @objc func controllerDidDisconnect(notification: NSNotification)
    {
        //Set up actions for controller disconnects
    }
    
    @objc func receivedPeripheralSetup(notification: NSNotification)
    {
        print("Peripheral setup!");
    }
}
