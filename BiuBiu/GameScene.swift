//
//  GameScene.swift
//  BiuBiu
//
//  Created by Wenzhe on 15/5/16.
//  Copyright (c) 2016 Wenzhe. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let Enemy : UInt32 = 0x1 << 0
    static let SmallBall : UInt32 = 0x1 << 1
    static let MainBall : UInt32 = 0x1 << 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var MainBall = SKSpriteNode(imageNamed: "hero")
    
    var enemyTimer = NSTimer()
    
    var hit = 0
    
    var gameStarted = false
    var restart = true
    
    var TTBlabel = SKLabelNode(fontNamed: "STHeitiJ-Medium")
    var ScoreLabel = SKLabelNode(fontNamed: "STHeitiJ-Medium")
    var HighScoreLabel = SKLabelNode(fontNamed: "STHeitiJ-Medium")
    
    var score = 0
    var highScore = 0

    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        self.physicsWorld.contactDelegate = self
        
        let HSD = NSUserDefaults.standardUserDefaults()
        if HSD.valueForKey("HS") != nil{
            highScore = HSD.valueForKey("HS") as! Int
        }
        
        TTBlabel.text = "Tap To Begin"
        TTBlabel.fontSize = 34
        TTBlabel.position = CGPoint(x: frame.width / 2, y: frame.height / 3.5)
        TTBlabel.fontColor = UIColor.blueColor()
        TTBlabel.zPosition = 2.0
        self.addChild(TTBlabel)
        
        TTBlabel.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.fadeInWithDuration(1.0), SKAction.fadeOutWithDuration(1.0)])))
        
        HighScoreLabel.text = "HighScore : \(highScore)"
        HighScoreLabel.position = CGPoint(x: scene!.frame.width / 2, y: scene!.frame.height / 1.3)
        HighScoreLabel.fontColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        self.addChild(HighScoreLabel)
        
        ScoreLabel.alpha = 0
        ScoreLabel.text = "\(score)"
        ScoreLabel.position = CGPoint(x: scene!.frame.width / 2, y: scene!.frame.height / 1.3)
        ScoreLabel.fontColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        self.addChild(ScoreLabel)
        
        backgroundColor = UIColor.whiteColor()

        MainBall.size = CGSize(width: 225, height: 225)
        MainBall.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        MainBall.color = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        MainBall.colorBlendFactor = 1.0
        MainBall.zPosition = 1.0
        MainBall.name = "MainBall"
        
        MainBall.physicsBody = SKPhysicsBody(circleOfRadius: MainBall.size.width / 2)
        MainBall.physicsBody?.categoryBitMask = PhysicsCategory.MainBall
        MainBall.physicsBody?.collisionBitMask = PhysicsCategory.Enemy
        MainBall.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
        MainBall.physicsBody?.affectedByGravity = false
        MainBall.physicsBody?.dynamic = false
        
        self.addChild(MainBall)
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA.node != nil && contact.bodyB.node != nil {
            
            let firstBody = contact.bodyA.node as! SKSpriteNode
            let secondBody = contact.bodyB.node as! SKSpriteNode
            
            if firstBody.name == "SmallBall" && secondBody.name == "Enemy" {
                collide(secondBody, bullet: firstBody)
            }else if firstBody.name == "Enemy" && secondBody.name == "SmallBall" {
                collide(firstBody, bullet: secondBody)
            }else if firstBody.name == "MainBall" && secondBody.name == "Enemy" {
                collideMain(secondBody)
            }else if firstBody.name == "Enemy" && secondBody.name == "MainBall" {
                collideMain(firstBody)
            }
        }
    }
    
    func collide(enemy: SKSpriteNode, bullet: SKSpriteNode){
        enemy.physicsBody?.dynamic = true
        enemy.physicsBody?.affectedByGravity = true
        enemy.physicsBody?.mass = 5.0
        bullet.physicsBody?.mass = 5.0
        
        enemy.removeAllActions()
        bullet.removeAllActions()
        
        enemy.physicsBody?.contactTestBitMask = 0
        enemy.physicsBody?.collisionBitMask = 0
        enemy.name = ""
        bullet.physicsBody?.contactTestBitMask = 0
        bullet.physicsBody?.collisionBitMask = 0
        bullet.name = ""
        
        score += 1
        ScoreLabel.text = "\(score)"
    }
    
    func collideMain(enemy: SKSpriteNode){
        if hit < 2 {
            MainBall.runAction(SKAction.scaleBy(1.5, duration: 0.4))
            
            MainBall.runAction(SKAction.sequence([SKAction.colorizeWithColor(UIColor.redColor(), colorBlendFactor: 1.0, duration: 0.1), SKAction.colorizeWithColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1), colorBlendFactor: 1.0, duration: 0.1) ]))
            
            hit += 1
            
        }else{
            
            if score > highScore{
                let highScoreDefault = NSUserDefaults.standardUserDefaults()
                highScore = score
                highScoreDefault.setInteger(highScore, forKey: "HS")
                HighScoreLabel.text = "HighScore : \(highScore)"
            }
            
            enemyTimer.invalidate()
            restart = false
            
            let triggerTime = (Int64(NSEC_PER_SEC) * 2)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                self.restart = true
            })
            gameStarted = false
            
            ScoreLabel.runAction(SKAction.fadeOutWithDuration(1.0))
            TTBlabel.runAction(SKAction.fadeInWithDuration(0.2))
            TTBlabel.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.fadeInWithDuration(1.0), SKAction.fadeOutWithDuration(1.0)])))
            HighScoreLabel.runAction(SKAction.sequence([SKAction.waitForDuration(0.5),SKAction.fadeInWithDuration(1.0)]))
        }
        enemy.removeFromParent()
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        if gameStarted == false{
            if restart == false {
                return
            }
            enemyTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(self.Enemies), userInfo: nil, repeats: true)
            gameStarted = true
            MainBall.runAction(SKAction.scaleBy(0.44, duration: 0.2))
            hit = 0
            score = 0
            
            ScoreLabel.text = "\(score)"
            TTBlabel.removeAllActions()
            TTBlabel.runAction(SKAction.fadeOutWithDuration(0.2))
            HighScoreLabel.runAction(SKAction.fadeOutWithDuration(0.2))
            ScoreLabel.runAction(SKAction.sequence([SKAction.waitForDuration(1.0),SKAction.fadeInWithDuration(0.2)]))
            
            
            return
        }
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let SmallBall = SKSpriteNode(imageNamed: "hero")
            SmallBall.position = MainBall.position
            SmallBall.size = CGSize(width: 20, height: 20)
            SmallBall.physicsBody = SKPhysicsBody(circleOfRadius: SmallBall.size.width / 2)
            SmallBall.color = UIColor(red: 0.1, green: 0.85, blue: 0.95, alpha: 1)
            SmallBall.colorBlendFactor = 1.0
            
            SmallBall.physicsBody?.categoryBitMask = PhysicsCategory.SmallBall
            SmallBall.physicsBody?.collisionBitMask = PhysicsCategory.Enemy
            SmallBall.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
            SmallBall.name = "SmallBall"
            SmallBall.physicsBody?.dynamic = true
            SmallBall.physicsBody?.affectedByGravity = true
            
            self.addChild(SmallBall)
            
            var dx = CGFloat(location.x - MainBall.position.x)
            var dy = CGFloat(location.y - MainBall.position.y)
            let magnitude = sqrt(dx*dx + dy*dy)
            dx /= magnitude
            dy /= magnitude
            let vector = CGVector(dx: 15 * dx, dy: 15 * dy)
            
            SmallBall.physicsBody?.applyImpulse(vector)
            
        }
    }
    
    func Enemies(){
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.size = CGSize(width: 20, height: 20)
        enemy.color = UIColor.redColor()
        enemy.colorBlendFactor = 1.0
        enemy.name = "Enemy"
        
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemy.size.width / 2)
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        enemy.physicsBody?.collisionBitMask = PhysicsCategory.SmallBall | PhysicsCategory.MainBall
        enemy.physicsBody?.contactTestBitMask = PhysicsCategory.SmallBall | PhysicsCategory.MainBall
        enemy.physicsBody?.dynamic = true
        enemy.physicsBody?.affectedByGravity = false
        
        let randomPosNum = arc4random() % 4
        
        switch(randomPosNum){
        case 0:
            enemy.position.x = 0
            enemy.position.y = CGFloat(arc4random_uniform(UInt32(frame.size.height)))
            break
        case 1:
            enemy.position.x = frame.size.width
            enemy.position.y = CGFloat(arc4random_uniform(UInt32(frame.size.height)))
            break
        case 2:
            enemy.position.y = 0
            enemy.position.x = CGFloat(arc4random_uniform(UInt32(frame.size.width)))
            break
        case 3:
            enemy.position.y = frame.size.height
            enemy.position.x = CGFloat(arc4random_uniform(UInt32(frame.size.width)))
            break
        default:
            break
        }
        self.addChild(enemy)
        enemy.runAction(SKAction.moveTo(MainBall.position, duration: 3))
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
