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
        /* Setup your scene here */
        //Set up VGC
        VgcManager.startAs(.Central, appIdentifier: "PSGiOSRITChallenge", includesPeerToPeer: true);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "controllerDidConnect:", name: VgcControllerDidConnectNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "controllerDidDisconnect:", name: VgcControllerDidDisconnectNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedPeripheralSetup:", name: VgcPeripheralSetupNotification, object: nil);
        
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
                    let zPosition = (self.controller.microGamepad?.dpad.left.value)! - (self.controller.microGamepad?.dpad.right.value)!
                    self.player.attackAngle = Angle(value: M_PI * Double(zPosition))
                }
            }
        }
        self.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.waitForDuration(enemyData.attackInterval),SKAction.runBlock(){self.player.damage(enemyData.attack)}])))
        self.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.waitForDuration(enemyData.attackInterval),SKAction.runBlock(){self.enemy.weaknessAngle = self.enemy.weaknessAngle + Angle(value: M_PI/6)}])))
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
            //Set up action for dPad here
            print("dpad changed! x: \(xValue), y: \(yValue)");
        }
        
        controller.extendedGamepad?.leftThumbstick.valueChangedHandler = { (dpad, xValue, yValue) in
            //Set up action for left thumbstick here
            print("left thumbstick changed! x: \(xValue), y: \(yValue)");
        }
        
        controller.extendedGamepad?.rightThumbstick.valueChangedHandler = { (dpad, xValue, yValue) in
            //Set up action for right thumbstick here
            print("right thumbstick changed! x: \(xValue), y: \(yValue)");
        }
        
        controller.extendedGamepad?.rightShoulder.valueChangedHandler = { (input, value, pressed) in
            //Set up action for right shoulder here
            print("right shoulder changed: value: \(value), pressed: \(pressed)");
        }
        
        controller.extendedGamepad?.leftShoulder.valueChangedHandler = { (input, value, pressed) in
            //Set up action for left shoulder here
            print("left shoulder changed: value: \(value), pressed: \(pressed)");
        }
        
        controller.extendedGamepad?.rightTrigger.valueChangedHandler = { (input, value, pressed) in
            //Set up action for right trigger here
            print("right trigger changed: value: \(value), pressed: \(pressed)");
        }
        
        controller.extendedGamepad?.leftTrigger.valueChangedHandler = { (input, value, pressed) in
            //Set up action for left trigger here
            print("left trigger changed: value: \(value), pressed: \(pressed)");
        }
        
        controller.extendedGamepad?.buttonA.valueChangedHandler = { (input, value, pressed) in
            //Set up action for buttonA here
            print("A button changed: value: \(value), pressed: \(pressed)");
        }
        
        controller.extendedGamepad?.buttonX.valueChangedHandler = { (input, value, pressed) in
            //Set up action for button X here
            print("X button changed: value: \(value), pressed: \(pressed)");
        }
        
        controller.extendedGamepad?.buttonB.valueChangedHandler = { (input, value, pressed) in
            //Set up action for button B here
            print("B button changed: value: \(value), pressed: \(pressed)");
        }
        
        controller.extendedGamepad?.buttonY.valueChangedHandler = { (input, value, pressed) in
            //Set up action for button Y here
            print("Y button changed: value: \(value), pressed: \(pressed)");
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
