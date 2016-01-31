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
    var attackGesture : UIGestureRecognizer!
    
    var GameState : GameStateEnum! {
        didSet
        {
            self.removeAllChildren();
            self.removeAllActions();
            switch(GameState)
            {
            case .Some(.Menu):
                let background = SKSpriteNode(imageNamed: "enemy");
                background.size = size;
                background.position = CGPointMake(size.width / 2, size.height / 2);
                background.zPosition = -5;
                self.addChild(background);
                break;
            case .Some(.Running):
                let background = SKSpriteNode(imageNamed: "background_TV", normalMapped: true)
                background.size = size
                background.position = CGPointMake(size.width/2, size.height/2)
                background.zPosition = -5;
                self.addChild(background);
                
                let playerData = PlayerData(health: 10, attackStrength: 1, attackAngle: Angle(value: 0.0));
                player = Player(data: playerData);
                let enemyData = EnemyData(health: 5, attack: 1, attackInterval: 2.0, weaknessAngle: Angle(value: 0.0), marginOfError: Angle(value: 0.75), imageName: "enemy");
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
                
                self.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.waitForDuration(enemyData.attackInterval),SKAction.runBlock(){self.player.damage(enemyData.attack)}])))
                self.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.waitForDuration(enemyData.attackInterval),SKAction.runBlock(){self.enemy.weaknessAngle = self.enemy.weaknessAngle + Angle(value: M_PI/6)}])))
                
                break;
            case .Some(.GameOver):
                let background = SKSpriteNode(imageNamed: "enemy");
                background.size = size;
                background.position = CGPointMake(size.width / 2, size.height / 2);
                background.zPosition = -5;
                self.addChild(background);
                break;
            case .Some(.Paused):
                break;
            default:
                break;
            }
        }
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        //Set up VGC
        self.GameState = .Menu;
        
        VgcManager.startAs(.Central, appIdentifier: "PSGiOSRITChallenge", includesPeerToPeer: true);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "controllerDidConnect:", name: VgcControllerDidConnectNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "controllerDidDisconnect:", name: VgcControllerDidDisconnectNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedPeripheralSetup:", name: VgcPeripheralSetupNotification, object: nil);
        
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
                    self.movedDPad(xPosition);
                }
            }
        }
        
    }
    
    func movedDPad(xPosition: Float)
    {
        switch(self.GameState)
        {
        case .Some(.Menu):
            //Do nothing
            break;
        case .Some(.Running):
            self.player.attackAngle = Angle(value: M_PI * Double(xPosition));
            break;
        case .Some(.GameOver):
            //Do nothing
            break;
        case .Some(.Paused):
            //Do nothing
            break;
        default:
            break;
        }
        
    }
    
    func pressedSelect()
    {
        switch(self.GameState)
        {
        case .Some(.Menu):
            self.GameState = .Running;
            break;
        case .Some(.Running):
            if ( player.attackAngle > enemy.weaknessAngle - enemy.marginOfError && player.attackAngle < enemy.weaknessAngle + enemy.marginOfError)
            {
                debugText.text = "successful attack"
                enemy.damage(player.attackStrength)
            }
            else
            {
                debugText.text = "Missed attack"
            }
            break;
        case .Some(.GameOver):
            self.GameState = .Menu;
            break;
        default:
            //Do nothing?
            break;
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        switch(self.GameState)
        {
        case .Some(.Menu):
            //Do nothing
            break;
        case .Some(.Running):
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
                self.GameState = .GameOver;
            }
        case .Some(.GameOver):
            break;
        case .Some(.Paused):
            break;
        default:
            break;
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
            self.movedDPad(xValue);
            print("dpad changed! x: \(xValue), y: \(yValue)");
        }
        
        controller.extendedGamepad?.leftThumbstick.valueChangedHandler = { (dpad, xValue, yValue) in
            self.movedDPad(xValue);
            print("left thumbstick changed! x: \(xValue), y: \(yValue)");
        }
        
        controller.extendedGamepad?.rightThumbstick.valueChangedHandler = { (dpad, xValue, yValue) in
            self.movedDPad(xValue);
            print("right thumbstick changed! x: \(xValue), y: \(yValue)");
        }
        
        controller.extendedGamepad?.buttonA.valueChangedHandler = { (input, value, pressed) in
            if (pressed)
            {
                self.pressedSelect();
            }
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
