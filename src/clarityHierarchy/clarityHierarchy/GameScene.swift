//
//  GameScene.swift
//  UFO
//
//  Created by Xiaoyong Xu on 2017-03-15
//  Copyright © 2017 Xiaoyong Xu. All rights reserved.
//

import AudioToolbox // for the function of vibrate when the
import SpriteKit // It is a spriteKit game
import GameplayKit // basic game library
import AVFoundation // for game sound effect

var HighScore = Int() // the public valuable to store the Highest Score the user have achieve

struct PhysicsCatagory{//uses a shift operator to set a unique value for each of the categoryBitMasks in our physics bodies.
    static let UFO : UInt32 = 0x1 << 1
    static let rock : UInt32 = 0x1 << 2
    static let Ground : UInt32 = 0x1 << 3
    static let Score : UInt32 = 0x1 << 4
}



class GameScene: SKScene, SKPhysicsContactDelegate{// class GameScene which will present the game
    
    var rocks = SKNode()
    var Ground = SKSpriteNode()
    var UFO = SKSpriteNode()
    var Score = Int()
    var moveAndRemove = SKAction()
    var gameStarted = Bool()
    let scoreLabel = SKLabelNode()
    let scoreLabel2 = SKLabelNode()
    let scoreLabel3 = SKLabelNode()
    var died = Bool()
    var restartButton = SKSpriteNode()
    var newHsButton = SKSpriteNode()
    var LsButton = SKSpriteNode()
    
    func restartScene(){//Once the UFO died, the gameScene will Restart
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStarted = false
        Score = 0
        createScene()
    }
    
    func createScene(){ // Create the Game Scene
        self.physicsWorld.contactDelegate = self
        
        for i in 0..<2{ // create the background
            let background = SKSpriteNode(imageNamed: "Background")
            background.anchorPoint = CGPoint(x: 0.5, y:0.5)
            background.position = CGPoint(x: (CGFloat(i) * self.frame.width) , y: 0)
            background.name = "background"
            background.size = self.frame.size
            //background.size = (self.view?.bounds.size)!
            self.addChild(background)
            
        }
        //Create a score board
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - 150)
        scoreLabel.text = "Score \(Score)"
        scoreLabel.zPosition = 6
        scoreLabel.fontName = "04b_19"
        scoreLabel.fontSize = 40
        self.addChild(scoreLabel)
        
        //Create the Ground with a physical body for a condition of UFO's status
        Ground = SKSpriteNode(imageNamed: "Ground")
        Ground.setScale(0.7)
        Ground.position = CGPoint(x: self.frame.midX, y: self.frame.minY + Ground.frame.height/2)
        
        Ground.physicsBody = SKPhysicsBody(rectangleOf: Ground.size)
        Ground.physicsBody?.categoryBitMask = PhysicsCatagory.Ground
        Ground.physicsBody?.collisionBitMask = PhysicsCatagory.UFO
        Ground.physicsBody?.contactTestBitMask = PhysicsCatagory.UFO
        Ground.physicsBody?.affectedByGravity = false
        Ground.physicsBody?.isDynamic = false
        Ground.zPosition = 3
        self.addChild(Ground)
        
        
        //Create the UFO with a physical body
        UFO = SKSpriteNode(imageNamed: "UFO")
        UFO.size = CGSize(width: 64, height: 64)
        UFO.position = CGPoint(x: self.frame.midX - 200, y: self.frame.midY)
        
        UFO.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        
        UFO.physicsBody?.categoryBitMask = PhysicsCatagory.UFO
        UFO.physicsBody?.collisionBitMask = PhysicsCatagory.Ground | PhysicsCatagory.rock
        UFO.physicsBody?.contactTestBitMask =  PhysicsCatagory.Ground | PhysicsCatagory.rock | PhysicsCatagory.Score
        UFO.physicsBody?.affectedByGravity = false
        UFO.physicsBody?.isDynamic = true
        UFO.zPosition = 2
        self.addChild(UFO)
        checkPhysics()
    }
    
    override func didMove(to view: SKView) {
        createScene()//Game starts
 
        do{
            let sounds:[String] = ["fail","getStar"]//Create a collection of string for preload the sound
            for sound in sounds{
                let path : String = Bundle.main.path(forResource:sound,ofType:"mp3")!
                let url: URL = URL (fileURLWithPath: path)
                let player: AVAudioPlayer = try AVAudioPlayer (contentsOf: url)
                player.prepareToPlay()
            }
        }catch{
        }
    }
    
    
    
    func createButton(){//Create the restart button
        restartButton = SKSpriteNode(imageNamed: "RestartBtn")
        restartButton.size = CGSize(width: 300, height: 150)
        restartButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 170)
        restartButton.zPosition = 6
        restartButton.setScale(0)
        self.addChild(restartButton)
        restartButton.run(SKAction.scale(to: 1.0, duration: 0.5))
    }
    
    func createButton2(){//Create the message board whether shows the highscore or shows lose
        scoreLabel3.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 150)
        scoreLabel3.text = "Score \(HighScore)"
        scoreLabel3.zPosition = 7
        scoreLabel3.fontName = "04b_19"
        scoreLabel3.fontSize = 60
        self.addChild(scoreLabel3)
//        if Score == HighScore{
//            //when a user got a new highScore, it will present the image of HighScore
//            newHsButton = SKSpriteNode(imageNamed: "Highscore")
//            newHsButton.size = CGSize(width: 300, height: 150)
//            newHsButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
//            newHsButton.zPosition = 6
//            newHsButton.setScale(0)
//            self.addChild(newHsButton)
//            newHsButton.run(SKAction.scale(to: 1.0, duration: 0.5))
//        }
      
        if Score < HighScore{
            //When a user did not get a highSocre, it will present the image of Lose
            LsButton = SKSpriteNode(imageNamed: "Lose")
            LsButton.size = CGSize(width: 300, height: 150)
            LsButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            LsButton.zPosition = 6
            LsButton.setScale(0)
            self.addChild(LsButton)
            LsButton.run(SKAction.scale(to: 1.0, duration: 0.5))
        }
    }
    
    
    
    
    
    func didBegin(_ contact: SKPhysicsContact) {//after the game begin
        //create bodies for conditions to decided whether the UFO die and whether
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        //Once the UFO collect the yellow stars, the score plus one
        if firstBody.categoryBitMask == PhysicsCatagory.Score && secondBody.categoryBitMask == PhysicsCatagory.UFO{
            Score += 1
            if Score > HighScore{
                HighScore += 1
                
            }
            scoreLabel.text = "Score \(Score)"//the score text will be shown in the top of the screen
            scoreLabel2.text = "Highest \(HighScore)"
            //The high score text will be shown if the score did not reach the highest
            firstBody.node?.removeFromParent()
            self.run(SKAction.playSoundFileNamed("getStar", waitForCompletion: false))
        }else
            if firstBody.categoryBitMask == PhysicsCatagory.UFO && secondBody.categoryBitMask == PhysicsCatagory.Score{
                Score += 1
                if Score > HighScore{
                    HighScore += 1
                }
                scoreLabel.text = "\(Score)"
                scoreLabel2.text = "Highest \(HighScore)"
                
                secondBody.node?.removeFromParent()
                
        }
        //The condition function for deciding whether the UFO hit the barrier rocks
        if firstBody.categoryBitMask == PhysicsCatagory.UFO && secondBody.categoryBitMask == PhysicsCatagory.rock || firstBody.categoryBitMask == PhysicsCatagory.rock && secondBody.categoryBitMask == PhysicsCatagory.UFO{
            enumerateChildNodes(withName: "rocks", using: ({
                (node, error) in
                
                node.speed = 0
                
                self.removeAllActions()
            }))
            
            if died == false{// Once UFO hit the rocks, set the status to die and present two button
                died = true
                self.run(SKAction.playSoundFileNamed("fail", waitForCompletion: false))
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                createButton()
                createButton2()
            }
            
        }
        //The condition function for deciding whether the UFO hit the ground
        if firstBody.categoryBitMask == PhysicsCatagory.UFO && secondBody.categoryBitMask == PhysicsCatagory.Ground || firstBody.categoryBitMask == PhysicsCatagory.Ground && secondBody.categoryBitMask == PhysicsCatagory.UFO{
            enumerateChildNodes(withName: "rocks", using: ({
                (node, error) in
                node.speed = 0
                self.removeAllActions()
            }))
            
            if died == false{// Once UFO hit the ground, set the status to die and present two button

                died = true
                self.run(SKAction.playSoundFileNamed("fail", waitForCompletion: false))
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                createButton()
                createButton2()
            }
            
        }
        
        
    }
    
    //not obligatory - just for checking if physicsBody works right
    func checkPhysics() {
        // Create an array of all the nodes with physicsBodies
        var physicsNodes = [SKNode]()
        
        //Get all physics bodies
        enumerateChildNodes(withName: "//.") { node, _ in
            if let _ = node.physicsBody {
                physicsNodes.append(node)
            } else {
                
            }
        }
        
        //For each node, check it's category against every other node's collion and contctTest bit mask
        for node in physicsNodes {
            let category = node.physicsBody!.categoryBitMask
            // Identify the node by its category if the name is blank
            let name = node.name != nil ? node.name! : "Category \(category)"
            
            let collisionMask = node.physicsBody!.collisionBitMask
            let contactMask = node.physicsBody!.contactTestBitMask
            
            // If all bits of the collisonmask set, just say it collides with everything.
            if collisionMask == UInt32.max {
                print("\(name) collides with everything")
            }
            
            for otherNode in physicsNodes {
                if (node != otherNode) && (node.physicsBody?.isDynamic == true) {
                    let otherCategory = otherNode.physicsBody!.categoryBitMask
                    // Identify the node by its category if the name is blank
                    let otherName = otherNode.name != nil ? otherNode.name! : "Category \(otherCategory)"
                    
                    // If the collisonmask and category match, they will collide
                    if ((collisionMask & otherCategory) != 0) && (collisionMask != UInt32.max) {
                        print("\(name) collides with \(otherName)")
                    }
                    // If the contactMAsk and category match, they will contact
                    if (contactMask & otherCategory) != 0 {print("\(name) notifies when contacting \(otherName)")}
                }
            }
        }
    }
    
    
    
    func createrocks(){//Create the barrier for the game
       //random Number for the barriers' position
        let randomNum = CGFloat.random(min:0, max: 300)
        
        //Create the soreNode for the starCoin ,which will increase the score once the UFO collect it, 
        //and make it present randomly
        let scoreNode = SKSpriteNode(imageNamed: "Coin")
        scoreNode.size =  CGSize(width: 50, height: 50)
        scoreNode.position = CGPoint(x: self.frame.width+230, y: self.frame.midY+randomNum)
        scoreNode.zPosition = 2
        
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCatagory.Score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCatagory.UFO
        scoreNode.color = SKColor.cyan
        
        //Similar with the starCoin, it will create the barrier of rocks and set the rokcs position 
        //randomly
        rocks = SKNode()
        rocks.name = "rocks"
        let rock1 = SKSpriteNode(imageNamed: "Wall")
        let rock2 = SKSpriteNode(imageNamed: "comet")
        let rock3 = SKSpriteNode(imageNamed: "Wall")
        
        let randomPosition = CGFloat.random(min: -400, max: 400)
        rocks.position.y = rocks.position.y + randomPosition
        rocks.addChild(scoreNode)
        rocks.run(moveAndRemove)
        self.addChild(rocks)
        
        let randomPos = CGFloat.random(min:350, max: 500)
        let randomPos2 = CGFloat.random(min:350, max: 800)
        
        rock1.position = CGPoint(x: self.frame.width, y: self.frame.midY + 0)
        rock2.position = CGPoint(x: self.frame.width, y: self.frame.midY + randomPos)
        rock3.position = CGPoint(x: self.frame.width, y: self.frame.midY - randomPos2)
        
        rock1.setScale(0.7)
        rock2.setScale(0.7)
        rock3.setScale(0.7)
        
        rock1.physicsBody = SKPhysicsBody(rectangleOf: rock1.size)
        rock1.physicsBody?.categoryBitMask = PhysicsCatagory.rock
        rock1.physicsBody?.collisionBitMask = PhysicsCatagory.UFO
        rock1.physicsBody?.contactTestBitMask = PhysicsCatagory.UFO
        rock1.physicsBody?.isDynamic = false
        rock1.physicsBody?.affectedByGravity = false
        
        
        rock2.physicsBody = SKPhysicsBody(rectangleOf: rock2.size)
        rock2.physicsBody?.categoryBitMask = PhysicsCatagory.rock
        rock2.physicsBody?.collisionBitMask = PhysicsCatagory.UFO
        rock2.physicsBody?.contactTestBitMask = PhysicsCatagory.UFO
        rock2.physicsBody?.isDynamic = false
        rock2.physicsBody?.affectedByGravity = false
        
        rock3.physicsBody = SKPhysicsBody(rectangleOf: rock1.size)
        rock3.physicsBody?.categoryBitMask = PhysicsCatagory.rock
        rock3.physicsBody?.collisionBitMask = PhysicsCatagory.UFO
        rock3.physicsBody?.contactTestBitMask = PhysicsCatagory.UFO
        rock3.physicsBody?.isDynamic = false
        rock3.physicsBody?.affectedByGravity = false
        
        rocks.addChild(rock1)
        rocks.addChild(rock2)
        rocks.addChild(rock3)
        rocks.zPosition = 1
        
        
    }
    
    //Condition for notion of whether the game start by touching the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameStarted == false{
            gameStarted = true
            UFO.physicsBody?.affectedByGravity = true
            
            let spawn = SKAction.run({
                () in
                self.createrocks()
            })
            
            //Set the delay
            let delay = SKAction.wait(forDuration: 3.0)
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
            self.run(spawnDelayForever)
            
            let distance = CGFloat(self.frame.width*2)
            
            //Move the rocks from the right to the left
            let moveRocks = SKAction.moveBy(x: -distance - 100, y: 0, duration: TimeInterval(0.006 * distance))
            let removeRocks = SKAction.removeFromParent() //remove the pipes after they moved off the screen
            
            moveAndRemove = SKAction.sequence([moveRocks, removeRocks])
            
            //Set the UFO postion
            UFO.physicsBody?.velocity = CGVector(dx: 0.0 , dy: 0.0)
            UFO.physicsBody?.applyImpulse(CGVector(dx: 0.0 , dy: 30.0), at: UFO.position)
            
        }else{
            if died == true{
                
                
            }else{ //Set the Moving speed of UFO
                UFO.physicsBody?.velocity = CGVector(dx: 0.0 , dy: 0.0)
                UFO.physicsBody?.applyImpulse(CGVector(dx: 0.0 , dy: 30.0), at: UFO.position)
            }
            
        }
        
        
        for touch in touches{
            let location = touch.location(in: self)
            
            if died == true{//show the restart button the game if UFO dies
                if restartButton.contains(location){
                    restartScene()
                    
                }
            }
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if gameStarted == true{//game starts
            if died == false{//as long as the UFO is not died, move the background from right to left
                enumerateChildNodes(withName: "background", using: ({
                    (node, error) in
                    
                    let bg = node as! SKSpriteNode
                    bg.position = CGPoint(x: bg.position.x - 3, y: bg.position.y)
                    //point and float
                    if bg.position.x <= -bg.size.width{
                        bg.position = CGPoint(x: bg.position.x + bg.size.width*2, y: bg.position.y)
                    }
                }))
            }
        }
    }
}






