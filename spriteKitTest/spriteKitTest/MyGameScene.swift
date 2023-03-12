//
//  MyGameScene.swift
//  spriteKitTest
//
//  Created by Roman Yarmoliuk on 01.01.2023.
//

import Foundation
import SpriteKit

class MyGameScene: SKScene {
    
    
    var score = 0 {
        didSet {
            label.text = "Score: \(score)"
        }
    }
    var startIsAllowed = Bool()
    var timerIsEnd = true
    
    
    let label = SKLabelNode()
    let bestScoreLabel = SKLabelNode()
    let gameOverLabel = SKLabelNode(text: "Game Over")
    let startLabel = SKLabelNode(text: "Tap to restart")
    let heartsLabel = SKLabelNode()
    
    let pause: SKSpriteNode = {
        let texture = SKTexture(imageNamed: "pause")
        let pause = SKSpriteNode(texture: texture)
        pause.size = CGSize(width: 50, height: 50)
        return pause
    }()
    
    var heartsCount = 3 {
        didSet {
            //            heartsLabel.text = "\(heartsCount) ♥️"
            heartsLabel.text = ""
            for _ in 0..<heartsCount {
                heartsLabel.text! += "♥️"
            }
        }
    }
    
    let player: SKShapeNode = {
        
        let size = CGSize(width: 80, height: 40)
        let rect = CGRect(origin: .zero, size: size)
        let player = SKShapeNode(rectOf: size, cornerRadius: 10)
        
        player.position.y = 200
        
        player.physicsBody = .init(rectangleOf: player.frame.size)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.isDynamic = false
        player.physicsBody?.categoryBitMask = BitMasks.player
        
        player.fillColor = UIColor.purple
        
        return player
    }()
    
    lazy var protection: SKShapeNode = {
        
        let r = player.frame.size.width
        let protection = SKShapeNode(circleOfRadius: r)
        protection.position.y = player.position.y
        
        protection.physicsBody = .init(circleOfRadius: r)
        protection.physicsBody?.isDynamic = false
        protection.physicsBody?.categoryBitMask = BitMasks.protection
        protection.physicsBody?.collisionBitMask = BitMasks.enemy
        
        protection.fillColor = UIColor(cgColor: CGColor(red: 0, green: 0, blue: 0.8, alpha: 0.2))
        return protection
    }()
    
    
    var generationSpeed = 0.8
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.backgroundColor = .systemIndigo
        
        heartsLabel.position.y = frame.maxY - 60
        heartsLabel.position.x = frame.midX
        
        label.position.y = frame.midY + 50
        label.position.x = frame.midX
        
        bestScoreLabel.position.y = frame.midY - 50
        bestScoreLabel.position.x = frame.midX
        
        gameOverLabel.position.y = frame.maxY - 100
        gameOverLabel.position.x = frame.midX
        gameOverLabel.fontSize = 50
        
        startLabel.text = "Tap to start"
        startLabel.position.y = frame.minY + 100
        startLabel.position.x = frame.midX
        
        player.position.x = frame.midX
        
        pause.position = CGPoint(x: frame.maxX - 40,
                                 y: frame.maxY - 40)
        
        addChild(label)
        addChild(startLabel)
        addChild(heartsLabel)
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity.dy = -6
        
        removeNodes()
        
    }
    
    func removeNodes() {
        
        let action = SKAction.run {
            self.children.forEach { node in
                if node.position.y < self.frame.minY - 100 {
                    node.removeFromParent()
                }
            }
        }
        
        let sqns = SKAction.sequence([.wait(forDuration: 30), action])
        
        self.run(.repeatForever(sqns))
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = event?.allTouches?.first
        let touchPoint = (touch?.location(in: self))!
        
        if pause.contains(touchPoint) {
            
            self.isPaused.toggle()
            
            let playOrPause = isPaused == true ? "play" : "pause"
            
            pause.run(.sequence([.scale(to: 1.5, duration: 0.15),
                                 .scale(to: 1, duration: 0.15)]))
            
            self.pause.texture = SKTexture(imageNamed: playOrPause)
            
        }
        
        if startIsAllowed == false && timerIsEnd {
            resetGame()
        }
        
        if touchPoint.y < 200 {
            player.position.x = touchPoint.x
            protection.position.x = touchPoint.x
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = event?.allTouches?.first
        let touchPoint = (touch?.location(in: self))!
        
        if touchPoint.y < 200 {
            player.position.x = touchPoint.x
            protection.position.x = touchPoint.x
        }
        
    }
    
    let arrayOfItems: [Int] = {
       
        var amountOfItems = [40, 20, 4, 1, 1]
        var arrayOfItems = [Int]()
        var count = 0
        
        for i in amountOfItems {
            for _ in 1...i {
                arrayOfItems.append(count)
            }
            count += 1
        }
        return arrayOfItems
    }()
    
    func createFallingItem() {
        let randomItem = arrayOfItems.randomElement()!
        let itemNames = ["star", "dynamite", "bonus", "shield", "heart"]
        
        let sqns = SKAction.sequence([
            SKAction.wait(forDuration: generationSpeed),
            SKAction.run {
                let fallingItem: SKSpriteNode = {
                    
                    let high: CGFloat = randomItem == 0 ? 25 : 50
                    let size = CGSize(width: high, height: high)
                    
                    let itemTexture = SKTexture(imageNamed: itemNames[randomItem])
                    let fallingItem = SKSpriteNode(texture: itemTexture, size: size)
                    
                    let bitMask = {
                        switch randomItem {
                        case 0: return BitMasks.star
                        case 1: return BitMasks.enemy
                        case 2: return BitMasks.bonus
                        case 3: return BitMasks.shield
                        default: return BitMasks.heart
                        }
                    }()
                    
                    fallingItem.physicsBody = .init(circleOfRadius: high / 4)
                    fallingItem.physicsBody?.categoryBitMask = bitMask
                    fallingItem.physicsBody?.collisionBitMask = BitMasks.player
                    
                    if bitMask == BitMasks.enemy || bitMask == BitMasks.shield {
                        
                        fallingItem.physicsBody?.collisionBitMask = BitMasks.protection
                        
                    }
                    
                    fallingItem.physicsBody?.contactTestBitMask = BitMasks.player
                    
                    fallingItem.position = CGPoint(
                        x: .random(in: self.frame.minX + 25...self.frame.maxX - 25),
                        y: self.frame.maxY)
                    
                    return fallingItem
                }()
                
                self.addChild(fallingItem)
                
                fallingItem.run(.rotate(byAngle: 3, duration: 2))
                                
                if self.generationSpeed > 0.15 {
                    self.generationSpeed *= 0.985
                }
                
                if self.startIsAllowed {
                    self.createFallingItem()
                }
                
            }
        ])
        self.run(sqns)
        
        
    }
    
    
}

extension MyGameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var body: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask == BitMasks.player {
            body = contact.bodyB
        } else {
            body = contact.bodyA
        }
        
        switch body.categoryBitMask {
        case BitMasks.star:
            score += 1
        case BitMasks.bonus:
            score += 10
        case BitMasks.shield:
            
            addChild(protection)
            
            var count = 0.0
            
            let sqns = SKAction.sequence([
                .wait(forDuration: 0.25),
                .run {
                    self.protection.alpha -= 1.0 / 12.0
                    count += 0.25
                    if count == 3 {
                        self.protection.removeFromParent()
                        self.protection.alpha = 1
                    }
                }])
            
            self.run(.repeat(sqns, count: 12))
            
        case BitMasks.heart:
            if heartsCount < 3 {
                heartsCount += 1
            } else {
                score += 10
            }
            
        default:
            if heartsCount > 1 {
                heartsCount -= 1
            } else {
                heartsCount -= 1
                self.run(.wait(forDuration: 2)) {
                    self.timerIsEnd = true
                    self.addChild(self.startLabel)
                }
                
                startIsAllowed = false
                
                let bestScore = UserDefaultsManager.shared.getScore()
                
                label.text = "Your score is: \(score)"
                bestScoreLabel.text = "Best score: \(bestScore)"
                
                if  bestScore < score {
                    UserDefaultsManager.shared.setScore(value: score)
                }
                
                removeAllChildren()
                
                addChild(gameOverLabel)
                addChild(label)
                addChild(bestScoreLabel)
                addChild(heartsLabel)
                
            }
            
        }
        body.node?.removeFromParent()
    }
    
    func resetGame() {
        
        timerIsEnd = false
        
        gameOverLabel.removeFromParent()
        bestScoreLabel.removeFromParent()
        startLabel.removeFromParent()
        
        score = 0
        heartsCount = 3
        
        startIsAllowed = true
        generationSpeed = 0.8
        label.text = "Score: \(score)"
        
        createFallingItem()
        
        addChild(player)
        addChild(pause)
    }
}
