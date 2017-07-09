//
//  GameScene.swift
//  Hidden
//
//  Created by yo hanashima on 2017/06/30.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import SpriteKit
import GameplayKit

/* For setting initial angle */
extension Int {
    var degreesToRadians: Double { return Double(self) * M_PI / 180 }
    var radiansToDegrees: Double { return Double(self) * 180 / M_PI }
}

enum GameSceneState {
    case GameStart, SetTarget, SetCrystal, Firing, GameOver
}

enum TutorialState {
    case state1, state2, state3, state4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    /* Game objects */
    var gridNode: Grid!
    var gameOverNode: SKNode!
    
    /* Objects Arrays */
    var targetArray: [Target] = []
    var target2Array: [Target2] = []
    var crystalArray: [Crystal] = []
    var crystalToolArray: [CrystalTool] = []
    var thunderArray: [Thunder] = []
    
    /* Set connection with buttons */
    var buttonFire: MSButtonNode!
    var buttonReset: MSButtonNode!
    var buttonRetry: MSButtonNode!
    
    /* For tutorial */
    var tutorialState: TutorialState = .state1
    var tutorial11: SKLabelNode!
    var tutorial12: SKLabelNode!
    var tutorial21: SKLabelNode!
    var tutorial22: SKLabelNode!
    var tutorial41: SKLabelNode!
    var tutorial42: SKLabelNode!
    var tutorial5: SKLabelNode!
    var tutorial6: SKLabelNode!
    
    /* Number of crystals to use */
    var numCrystalLabel: SKLabelNode!
    var numberOfCrystal: Int = 2 {
        didSet {
            numCrystalLabel.text = String(numberOfCrystal)
        }
    }
    
    /* Game Speed */
    let thunderSpeed: CGFloat = 0.05
    var thunderTime: CGFloat = 1.0
    let hideTimer: TimeInterval = 4.0
    
    /* Number of targets to add */
    var numOfTargetLayer1:Int = 3
    var numOfTargetLayer2:Int = 1
    var numOfTargetLayer3:Int = 2
    
    /* Game Flags */
    var firstSetFlag = true
    var setDoneFlag = false
    var fireAble = true
    var resetAble = true
    var firingDoneFlag = false
    var setDoneLayer1 = false
    var setDoneLayer2 = false
    var firstMove = false
    var tutorialFlag = true
    static var FirstGame: Bool?
    
    /* Game management */
    var gameState: GameSceneState = .GameStart
    var gameTurn = 0
    
    /* Score */
    var scoreLabel: SKLabelNode!
    var score: Int = 0 {
        didSet {
            scoreLabel.text = String(score)
        }
    }
    var bestLabel: SKLabelNode!
    var bestScoreLabel: SKLabelNode!
    static var bestScore: Int = 0
        
    /* grid spots */
    var spotLayer1: [[Int]] = []
    var spotLayer2: [[Int]] = []
    var spotLayer3: [[Int]] = []
    
    override func didMove(to view: SKView) {
        /* Game management */
        if GameScene.FirstGame ?? true {
        
            /* Connect scene objects */
            gridNode = childNode(withName: "gridNode") as! Grid
            gameOverNode = childNode(withName: "gameOverNode")
            gameOverNode.isHidden = true
            
            /* For tutorial */
            tutorial11 = childNode(withName: "tutorial1") as! SKLabelNode
            tutorial12 = childNode(withName: "tutorial2") as! SKLabelNode
            
            /* Touch points for tutorial */
            let circle1 = SKShapeNode(circleOfRadius: 25.0)
            circle1.position = CGPoint(x: 236, y: 135)
            circle1.name = "posTutorial1"
            circle1.strokeColor = SKColor.black
            circle1.fillColor = SKColor.blue
            circle1.alpha = CGFloat(0.5)
            let circle2 = SKShapeNode(circleOfRadius: 25.0)
            circle2.position = CGPoint(x: 513, y: 835)
            circle2.name = "posTutorial2"
            circle2.strokeColor = SKColor.black
            circle2.fillColor = SKColor.blue
            circle2.alpha = CGFloat(0.5)
            self.addChild(circle1)
            self.addChild(circle2)
            
            tutorial21 = childNode(withName: "tutorial3") as! SKLabelNode
            tutorial22 = childNode(withName: "tutorial4") as! SKLabelNode
            tutorial21.isHidden = true
            tutorial22.isHidden = true
            
            tutorial41 = childNode(withName: "tutorial41") as! SKLabelNode
            tutorial42 = childNode(withName: "tutorial42") as! SKLabelNode
            tutorial41.isHidden = true
            tutorial42.isHidden = true
            
            tutorial5 = childNode(withName: "tutorial5") as! SKLabelNode
            tutorial6 = childNode(withName: "tutorial6") as! SKLabelNode
            tutorial5.isHidden = true
            tutorial6.isHidden = true
            
            /* set connection with buttons */
            buttonFire = childNode(withName: "buttonFire") as! MSButtonNode
            buttonReset = childNode(withName: "buttonReset") as! MSButtonNode
            buttonRetry = childNode(withName: "buttonRetry") as! MSButtonNode
            buttonRetry.state = .msButtonNodeStateHidden
            
            /* fire thunder when buttonFire tapped */
            buttonFire.selectedHandler = {
                /* Make sure you can fire only when setting crystal proid */
                guard self.gameState == .SetCrystal || self.gameState == .GameStart else { return }
                
                /* make sure there are more than 2 crystals */
                guard self.crystalArray.count > 1 else { return }
                
                /* Make sure buttonFire is able to press only once */
                guard self.resetAble else { return }
                self.fireAble = false
                
                /* Make sure disable buttonReset after pressing buttonFire */
                self.resetAble = false
                
                /* show up targets */
                self.showUpTargets(self.targetArray)
                self.showUpTargets(self.target2Array)
                
                /* show up crystal at grid if any */
                if self.crystalToolArray.count > 0 {
                    self.showUpTargets(self.crystalToolArray)
                }
                
                /* Extend thunder in the way to link with crystals */
                let numberOfCrystals = self.crystalArray.count
                var waitTime: CGFloat = 0
                for i in 0...numberOfCrystals-2 {
                    let durationOfExtend = self.fireThunder(waitTime, FromPointIndex: i)
                    waitTime += durationOfExtend
                    if i == numberOfCrystals-2 {
                        let wait = SKAction.wait(forDuration: TimeInterval(durationOfExtend+CGFloat(1.0)))
                        let doneFire = SKAction.run({ self.firingDoneFlag = true })
                        let seq = SKAction.sequence([wait, doneFire])
                        self.run(seq)
                    }
                }
            }
            
            /* reset crystals when buttonReset tapped */
            buttonReset.selectedHandler = {
                guard self.gameState == .SetCrystal else { return }
                guard self.resetAble else { return }
                
                for crystal in self.crystalArray {
                    crystal.removeFromParent()
                    self.numberOfCrystal += 1
                }
                self.crystalArray.removeAll()
                
            }
            
            /* Setup retry button selection handler */
            buttonRetry.selectedHandler = {
                
                /* Grab reference to our SpriteKit view */
                let skView = self.view as SKView!
                
                /* Load Game scene */
                let scene = GameScene(fileNamed:"GameScene") as GameScene!
                
                /* Ensure correct aspect mode */
                scene!.scaleMode = .aspectFill
                
                /* Restart game scene */
                skView!.presentScene(scene)
            }
            
            /* no gravity */
            self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
            
            /* Set physics contact delegate */
            physicsWorld.contactDelegate = self
            
            /* display crystals to use */
            numCrystalLabel = childNode(withName: "numCrystalLabel") as! SKLabelNode
            
            /* score */
            scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode
            bestLabel = childNode(withName: "bestLabel") as! SKLabelNode
            bestLabel.isHidden = true
            bestScoreLabel = childNode(withName: "bestScoreLabel") as! SKLabelNode
            bestScoreLabel.isHidden = true
            
            /* Set spots */
            makeSpotLayer1()
            makeSpotLayer2()
            makeSpotLayer3()
            
            /* Set first target */
            self.addTargetAtGrid(x: 4, y: 4, type: 1)
            
            GameScene.FirstGame = false
        } else {
            /* Connect scene objects */
            gridNode = childNode(withName: "gridNode") as! Grid
            gameOverNode = childNode(withName: "gameOverNode")
            gameOverNode.isHidden = true
            
            /* For tutorial */
            tutorial11 = childNode(withName: "tutorial1") as! SKLabelNode
            tutorial12 = childNode(withName: "tutorial2") as! SKLabelNode
            tutorial11.isHidden = true
            tutorial12.isHidden = true
            tutorial21 = childNode(withName: "tutorial3") as! SKLabelNode
            tutorial22 = childNode(withName: "tutorial4") as! SKLabelNode
            tutorial21.isHidden = true
            tutorial22.isHidden = true
            tutorial41 = childNode(withName: "tutorial41") as! SKLabelNode
            tutorial42 = childNode(withName: "tutorial42") as! SKLabelNode
            tutorial41.isHidden = true
            tutorial42.isHidden = true
            
            tutorial5 = childNode(withName: "tutorial5") as! SKLabelNode
            tutorial6 = childNode(withName: "tutorial6") as! SKLabelNode
            tutorial5.isHidden = true
            tutorial6.isHidden = true
            
            /* set connection with buttons */
            buttonFire = childNode(withName: "buttonFire") as! MSButtonNode
            buttonReset = childNode(withName: "buttonReset") as! MSButtonNode
            buttonRetry = childNode(withName: "buttonRetry") as! MSButtonNode
            buttonRetry.state = .msButtonNodeStateHidden
            
            /* fire thunder when buttonFire tapped */
            buttonFire.selectedHandler = {
                /* Make sure you can fire only when setting crystal proid */
                guard self.gameState == .SetCrystal || self.gameState == .GameStart else { return }
                
                /* make sure there are more than 2 crystals */
                guard self.crystalArray.count > 1 else { return }
                
                /* Make sure buttonFire is able to press only once */
                guard self.resetAble else { return }
                self.fireAble = false
                
                /* Make sure disable buttonReset after pressing buttonFire */
                self.resetAble = false
                
                /* show up targets */
                self.showUpTargets(self.targetArray)
                self.showUpTargets(self.target2Array)
                
                /* show up crystal at grid if any */
                if self.crystalToolArray.count > 0 {
                    self.showUpTargets(self.crystalToolArray)
                }
                
                /* Extend thunder in the way to link with crystals */
                let numberOfCrystals = self.crystalArray.count
                var waitTime: CGFloat = 0
                for i in 0...numberOfCrystals-2 {
                    let durationOfExtend = self.fireThunder(waitTime, FromPointIndex: i)
                    waitTime += durationOfExtend
                    if i == numberOfCrystals-2 {
                        let wait = SKAction.wait(forDuration: TimeInterval(durationOfExtend+self.thunderTime))
                        let doneFire = SKAction.run({ self.firingDoneFlag = true })
                        let seq = SKAction.sequence([wait, doneFire])
                        self.run(seq)
                    }
                }
            }
            
            /* reset crystals when buttonReset tapped */
            buttonReset.selectedHandler = {
                guard self.gameState == .SetCrystal else { return }
                guard self.resetAble else { return }
                
                for crystal in self.crystalArray {
                    crystal.removeFromParent()
                    self.numberOfCrystal += 1
                }
                self.crystalArray.removeAll()
                
            }
            
            /* Setup retry button selection handler */
            buttonRetry.selectedHandler = {
                
                /* Grab reference to our SpriteKit view */
                let skView = self.view as SKView!
                
                /* Load Game scene */
                let scene = GameScene(fileNamed:"GameScene") as GameScene!
                
                /* Ensure correct aspect mode */
                scene!.scaleMode = .aspectFill
                
                /* Restart game scene */
                skView!.presentScene(scene)
            }
            
            /* no gravity */
            self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
            
            /* Set physics contact delegate */
            physicsWorld.contactDelegate = self
            
            /* display crystals to use */
            numCrystalLabel = childNode(withName: "numCrystalLabel") as! SKLabelNode
            
            /* score */
            scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode
            bestLabel = childNode(withName: "bestLabel") as! SKLabelNode
            bestLabel.isHidden = true
            bestScoreLabel = childNode(withName: "bestScoreLabel") as! SKLabelNode
            bestScoreLabel.isHidden = true
            
            /* Set spots */
            makeSpotLayer1()
            makeSpotLayer2()
            makeSpotLayer3()
            
            self.firstMove = true
            self.gameState = .SetTarget
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        switch gameState {
        case .GameStart:
            switch tutorialState {
            case .state1:
                if self.numberOfCrystal < 1 {
                    tutorialState = .state2
                }
                break;
            case .state2:
                self.tutorial11.isHidden = true
                self.tutorial12.isHidden = true
                self.tutorial21.isHidden = false
                self.tutorial22.isHidden = false
                if self.targetArray.count == 0 {
                    tutorialState = .state3
                }
                break;
            case .state3:
                self.tutorial21.isHidden = true
                self.tutorial22.isHidden = true
                let wait = SKAction.wait(forDuration: 2.0)
                let moveState = SKAction.run({ self.tutorialState = .state4 })
                let seq = SKAction.sequence([wait, moveState])
                self.run(seq)
                break;
            case .state4:
                self.tutorial41.isHidden = false
                self.tutorial42.isHidden = false
                
                /* remove all crystals */
                for crystal in self.crystalArray {
                    crystal.removeFromParent()
                    self.numberOfCrystal += 1
                    self.crystalArray.removeFirst()
                }
                
                /* remove all thunders */
                for thunder in thunderArray {
                    thunder.removeFromParent()
                }
                self.thunderArray.removeAll()
                let wait = SKAction.wait(forDuration: 2.0)
                let offMsg = SKAction.run({
                    self.tutorial41.isHidden = true
                    self.tutorial42.isHidden = true
                })
                let moveState = SKAction.run({ self.gameState = .SetTarget })
                let seq = SKAction.sequence([wait, offMsg, moveState])
                self.run(seq)
                break;
            }
            break;
        case .SetTarget:
            if self.numberOfCrystal >= 4 {
                self.thunderTime = 2.5
            }
            
            if self.gameTurn > 3 && self.gameTurn < 7 {
                numOfTargetLayer2 = 3
            } else if self.gameTurn >= 7 && self.gameTurn < 15 {
                numOfTargetLayer2 = 5
            } else if self.gameTurn >= 15 && self.gameTurn < 30 {
                numOfTargetLayer2 = 7
            } else if self.gameTurn >= 30 {
                numOfTargetLayer3 = 4
            }
            if tutorialFlag {
                self.tutorial5.isHidden = false
                let wait = SKAction.wait(forDuration: 4.0)
                let moveState = SKAction.run({
                    self.tutorial5.isHidden = true
                    self.tutorial6.isHidden = false
                })
                let seq = SKAction.sequence([wait, moveState])
                self.run(seq)
                self.tutorialFlag = false
            }
            if firstSetFlag {
                if self.gameTurn == 9 {
                    self.setCrystal()
                } else if self.gameTurn == 18 {
                    self.setCrystal()
//                } else if self.gameTurn == 27 {
//                    self.setCrystal()
                }
                setTargets()
            }
            if setDoneFlag {
                /* Reset spots array */
                spotLayer1.removeAll()
                spotLayer2.removeAll()
                firstSetFlag = true
                setDoneFlag = false
                self.resetAble = true
                self.fireAble = true
                gameState = .SetCrystal
            }
            break;
        case .SetCrystal:
            if firingDoneFlag {
                /* remove all crystals */
                for crystal in self.crystalArray {
                    crystal.removeFromParent()
                    self.numberOfCrystal += 1
                    self.crystalArray.removeFirst()
                }
                
                /* remove all thunders */
                for thunder in thunderArray {
                    thunder.removeFromParent()
                }
                self.thunderArray.removeAll()
                
                firingDoneFlag = false
//                print("left target num is \(targetArray.count)")
                
                /* set spots */
                makeSpotLayer1()
                makeSpotLayer2()
                makeSpotLayer3()
                gameTurn += 1
                gameState = .SetTarget
                print("game turn is \(self.gameTurn)")
                print("num tharget 1 is \(self.numOfTargetLayer1)")
                print("num tharget 2 is \(self.numOfTargetLayer2)")
            }
            break;
        case .Firing:
            break;
        case .GameOver:
            gameOverNode.isHidden = false
            bestLabel.isHidden = false
            if self.score > GameScene.bestScore {
                GameScene.bestScore = self.score
            }
            bestScoreLabel.text = String(GameScene.bestScore)
            bestScoreLabel.isHidden = false
            buttonRetry.state = .msButtonNodeStateActive
            break;
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Make sure you can set crystals only during SetCrystal period */
        guard self.gameState == .SetCrystal || self.gameState == .GameStart else { return }
        
        if self.gameState == .GameStart {
            let touch = touches.first!              // Get the first touch
            let location = touch.location(in: self) // Find the location of that touch in this view
            let nodeAtPoint = atPoint(location)     // Find the node at that location
            if nodeAtPoint.name == "posTutorial1" || nodeAtPoint.name == "posTutorial2" {
                nodeAtPoint.removeFromParent()
            } else {
                return
            }
        }
        
        if self.tutorial6.isHidden == false {
           self.tutorial6.isHidden = true
        }
        
        /* You can use the number of crystals you have */
        if numberOfCrystal > 0 {
            /* There will only be one touch as multi touch is not enabled by default */
            let touch = touches.first!              // Get the first touch
            
            /* Grab position of touch relative to the grid */
            let location = touch.location(in: self)
            
            /* New creature object */
            let crystal = Crystal()
            crystal.position = location
            
            /* Add sushi to scene */
            addChild(crystal)
            
            /* Add sushi piece to the sushi tower */
            crystalArray.append(crystal)
            
            numberOfCrystal -= 1
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        /* Physics contact delegate implementation */
        
        /* Get references to the bodies involved in the collision */
        let contactA:SKPhysicsBody = contact.bodyA
        let contactB:SKPhysicsBody = contact.bodyB
        
        /* Get references to the physics body parent SKSpriteNode */
        
        /* Check if either physics bodies was a target */
        if contactA.categoryBitMask == 1 || contactB.categoryBitMask == 1 {
            if contactA.categoryBitMask == 1 {
                let nodeA = contactA.node as! Target
                nodeA.deathFlag = true
                nodeA.removeFromParent()
            }
            if contactB.categoryBitMask == 1 {
                let nodeB = contactB.node as! Target
                nodeB.deathFlag = true
                nodeB.removeFromParent()
            }
            
            /* Remove target from targetArray */
            targetArray = targetArray.filter({ $0.deathFlag == false })
            target2Array = target2Array.filter({ $0.deathFlag == false })
            
            /* scoring */
            self.score += 1
        }
        
        /* Check if either physics bodies was a target2 */
        if contactA.categoryBitMask == 2 || contactB.categoryBitMask == 2 {
            if contactA.categoryBitMask == 2 {
                let nodeA = contactA.node as! Target2
                nodeA.deathFlag = true
                nodeA.removeFromParent()
            }
            if contactB.categoryBitMask == 2 {
                let nodeB = contactB.node as! Target2
                nodeB.deathFlag = true
                nodeB.removeFromParent()
            }
            
            /* Remove target from targetArray */
            target2Array = target2Array.filter({ $0.deathFlag == false })
            
            /* scoring */
            self.score += 1
        }
        
        /* Check if either physics bodies was a crystal */
        if contactA.categoryBitMask == 4 || contactB.categoryBitMask == 4 {
            if contactA.categoryBitMask == 4 {
                let nodeA = contactA.node as! CrystalTool
                nodeA.removeFromParent()
            }
            if contactB.categoryBitMask == 4 {
                let nodeB = contactB.node as! CrystalTool
                nodeB.removeFromParent()
            }
            
            /* increse crystal to use */
            self.numberOfCrystal += 1
        }
    }
    
    
    /*== functions to add target on grid ==*/
 
    func setTargets() {
        firstSetFlag = false
        if targetArray.count > 0 || target2Array.count > 0 {
            if self.firstMove {
                let moveTarget = SKAction.run({
                    for target in self.targetArray {
                        target.moveOutward()
                        if target.outOfGridFlag {
                            self.gameState = .GameOver
                            return
                        }
                    }
                    for target in self.target2Array {
                        target.moveOutward()
                        if target.outOfGridFlag {
                            self.gameState = .GameOver
                            return
                        }
                    }
                })
                if self.gameTurn < 20 {
                    let addTarget = SKAction.run({
                        self.setTargetPositionLayer1(self.numOfTargetLayer1, type: 1)
                        self.setTargetPositionLayer2(self.numOfTargetLayer2, type: 1)
                    })
                    let wait = SKAction.wait(forDuration: hideTimer)
                    let hideTarget = SKAction.run({
                        self.hideTargets(self.targetArray)
                        self.hideTargets(self.target2Array)
                        self.hideTargets(self.crystalToolArray)
                    })
                    let setDone = SKAction.run({ self.setDoneFlag = true })
                    let seq = SKAction.sequence([moveTarget, addTarget, wait, hideTarget, setDone])
                    self.run(seq)

                } else if self.gameTurn >= 20 && self.gameTurn < 25 {
                    let addTarget = SKAction.run({
                        self.setTargetPositionLayer1(self.numOfTargetLayer1, type: 1)
                        self.setTargetPositionLayer2(self.numOfTargetLayer2, type: 1)
                        self.setTargetPositionLayer3(self.numOfTargetLayer3, type: 1)
                    })
                    let wait = SKAction.wait(forDuration: hideTimer)
                    let hideTarget = SKAction.run({
                        self.hideTargets(self.targetArray)
                        self.hideTargets(self.target2Array)
                        self.hideTargets(self.crystalToolArray)
                    })
                    let setDone = SKAction.run({ self.setDoneFlag = true })
                    let seq = SKAction.sequence([moveTarget, addTarget, wait, hideTarget, setDone])
                    self.run(seq)
                } else if self.gameTurn >= 25 && self.gameTurn < 30 {
                    let addTarget = SKAction.run({
                        self.setTargetPositionLayer1(self.numOfTargetLayer1, type: 2)
                        self.setTargetPositionLayer2(self.numOfTargetLayer2, type: 1)
                        self.setTargetPositionLayer3(self.numOfTargetLayer2, type: 1)
                    })
                    let wait = SKAction.wait(forDuration: hideTimer)
                    let hideTarget = SKAction.run({
                        self.hideTargets(self.targetArray)
                        self.hideTargets(self.target2Array)
                        self.hideTargets(self.crystalToolArray)
                    })
                    let setDone = SKAction.run({ self.setDoneFlag = true })
                    let seq = SKAction.sequence([moveTarget, addTarget, wait, hideTarget, setDone])
                    self.run(seq)
                } else if self.gameTurn >= 30 {
                    let addTarget = SKAction.run({
                        self.setTargetPositionLayer1(self.numOfTargetLayer1, type: 2)
                        self.setTargetPositionLayer2(self.numOfTargetLayer2, type: 1)
                        self.setTargetPositionLayer3(self.numOfTargetLayer2, type: 1)
                    })
                    let wait = SKAction.wait(forDuration: hideTimer)
                    let hideTarget = SKAction.run({
                        self.hideTargets(self.targetArray)
                        self.hideTargets(self.target2Array)
                        self.hideTargets(self.crystalToolArray)
                    })
                    let setDone = SKAction.run({ self.setDoneFlag = true })
                    let seq = SKAction.sequence([moveTarget, addTarget, wait, hideTarget, setDone])
                    self.run(seq)
                }
            } else {
                self.firstMove = true
                self.setDoneFlag = true
            }
        } else {
            let addTarget = SKAction.run({
                self.setTargetPositionLayer1(self.numOfTargetLayer1, type: 1)
                self.setTargetPositionLayer2(self.numOfTargetLayer2, type: 1)
            })
            let wait = SKAction.wait(forDuration: hideTimer)
            let hideTarget = SKAction.run({
                self.hideTargets(self.targetArray)
                self.hideTargets(self.target2Array)
                self.hideTargets(self.crystalToolArray)
            })
            let setDone = SKAction.run({ self.setDoneFlag = true })
            let seq = SKAction.sequence([addTarget, wait, hideTarget, setDone])
            self.run(seq)
        }
    }
    
    func makeSpotLayer1() {
        for i in 3...5 {
            for v in 3...5 {
                self.spotLayer1.append([i, v])
            }
        }
        self.spotLayer1 = self.spotLayer1.filter({ $0 != [4, 4] })
        
    }
    
    func makeSpotLayer2() {
        let array1 = [2, 6]
        let array2 = [2, 3, 4, 5, 6]
        let array3 = [3, 4, 5]
        for i in array1 {
            for v in array2 {
                self.spotLayer2.append([i, v])
            }
        }
        for i in array1 {
            for v in array3 {
                self.spotLayer2.append([v, i])
            }
        }
        
    }
    
    func makeSpotLayer3() {
        let array1 = [1, 7]
        let array2 = [1, 2, 3, 4, 5, 6, 7]
        let array3 = [2, 3, 4, 5, 6]
        for i in array1 {
            for v in array2 {
                self.spotLayer3.append([i, v])
            }
        }
        for i in array1 {
            for v in array3 {
                self.spotLayer3.append([v, i])
            }
        }
    }
    
    func setTargetPositionLayer1(_ total: Int, type: Int) {
        var numOfSpot = self.spotLayer1.count
        
        for _ in 0...total-1 {
            let rand = arc4random_uniform(UInt32(numOfSpot))
            addTargetAtGrid(x: self.spotLayer1[Int(rand)][0], y: self.spotLayer1[Int(rand)][1], type: type)
            self.spotLayer1.remove(at: Int(rand))
            numOfSpot -= 1
        }
        
    }

    func setTargetPositionLayer2(_ total: Int, type: Int) {
        var numOfSpot = self.spotLayer2.count
        
        for _ in 0...total-1 {
            let rand = arc4random_uniform(UInt32(numOfSpot))
            addTargetAtGrid(x: self.spotLayer2[Int(rand)][0], y: self.spotLayer2[Int(rand)][1], type: type)
            self.spotLayer2.remove(at: Int(rand))
            numOfSpot -= 1
        }
    }
    
    func setTargetPositionLayer3(_ total: Int, type: Int) {
        var numOfSpot = self.spotLayer3.count
        
        for _ in 0...total-1 {
            let rand = arc4random_uniform(UInt32(numOfSpot))
            addTargetAtGrid(x: self.spotLayer3[Int(rand)][0], y: self.spotLayer3[Int(rand)][1], type: type)
            self.spotLayer3.remove(at: Int(rand))
            numOfSpot -= 1
        }
    }

    func addTargetAtGrid(x: Int, y: Int, type: Int) {
        /* Add a new creature at grid position*/
        
        /* get the position of grid */
        let positionOfGrid = gridNode.position
        
        /* New creature object */
        switch type {
        case 1:
            let target = Target()
            /* Calculate position on screen */
            let gridPosition = CGPoint(x: Int(positionOfGrid.x)+x*gridNode.cellWidth+gridNode.cellWidth/2, y: Int(positionOfGrid.y)+y*gridNode.cellHeight+gridNode.cellHeight/2)
            target.position = gridPosition
            
            /* Add creature to grid node */
            addChild(target)
            
            /* Add target to Array */
            targetArray.append(target)
            
            /* keep track the position of targets */
            target.positionX = x
            target.positionY = y
            
            target.setLayer()
            
        case 2:
            let target = Target2()
            /* Calculate position on screen */
            let gridPosition = CGPoint(x: Int(positionOfGrid.x)+x*gridNode.cellWidth+gridNode.cellWidth/2, y: Int(positionOfGrid.y)+y*gridNode.cellHeight+gridNode.cellHeight/2)
            target.position = gridPosition
            
            /* Add creature to grid node */
            addChild(target)
            
            /* Add target to Array */
            target2Array.append(target)
            
            /* keep track the position of targets */
            target.positionX = x
            target.positionY = y
            
            target.setLayer()
            
        default:
            break;
        }
    }
    
    func hideTargets(_ targetArray: [SKSpriteNode]) {
        for target in targetArray {
            target.isHidden = true
        }
    }
    
    func showUpTargets(_ targetArray: [SKSpriteNode]) {
        for target in targetArray {
            target.isHidden = false
        }
    }
    
    /*== function to set crystal ==*/
    
    func setCrystal() {
        let randX = arc4random_uniform(9)
        let randY = arc4random_uniform(9)
        let addCrystal = SKAction.run({
            self.addCrystalAtGrid(x: Int(randX), y: Int(randY))
        })
        let wait = SKAction.wait(forDuration: hideTimer)
        let hideCrystal = SKAction.run({
            for crystal in self.crystalToolArray {
                crystal.isHidden = true
            }
        })
        let seq = SKAction.sequence([addCrystal, wait, hideCrystal])
        self.run(seq)
    }
    
    func addCrystalAtGrid(x: Int, y: Int) {
        /* Add a new creature at grid position*/
        
        /* New creature object */
        let crystalTool = CrystalTool()
        
        /* get the position of grid */
        let positionOfGrid = gridNode.position
        
        /* Calculate position on screen */
        let gridPosition = CGPoint(x: Int(positionOfGrid.x)+x*gridNode.cellWidth+gridNode.cellWidth/2, y: Int(positionOfGrid.y)+y*gridNode.cellHeight+gridNode.cellHeight/2)
        crystalTool.position = gridPosition
        
        /* Add creature to grid node */
        addChild(crystalTool)
        
        /* Add target to Array */
        crystalToolArray.append(crystalTool)
        
    }
    
    /*== function to generate thunder ==*/
    
    func fireThunder(_ waitTime: CGFloat, FromPointIndex: Int) -> CGFloat {
        
        /* get crystals thunder kinks */
        let firingCrystalFrom = crystalArray[FromPointIndex]
        let firingCrystalTo = crystalArray[FromPointIndex+1]
        
        /* create thunder */
        let crystalLocation = firingCrystalFrom.position
        let thunder = Thunder()
        thunder.position = crystalLocation
        
        /* set thunder's angle toward crystalsTo */
        let angleOfTwoCrystals = atan2(firingCrystalTo.position.y-firingCrystalFrom.position.y, firingCrystalTo.position.x-firingCrystalFrom.position.x)
        thunder.zRotation = angleOfTwoCrystals
        
        /* add thunder onto screen */
        self.addChild(thunder)
        self.thunderArray.append(thunder)
        thunder.isHidden = true
        
        /* caluculate how long thunder should extend */
        let distanceOfTwoCrystals = sqrt(pow(firingCrystalTo.position.x-firingCrystalFrom.position.x, 2) + pow(firingCrystalTo.position.y-firingCrystalFrom.position.y, 2))
        let magnification = distanceOfTwoCrystals/thunder.size.width
        
        /* extend thunder to crystalTo */
        let duration = thunderSpeed * magnification
        let extendThunder = SKAction.scaleX(to: magnification, duration: TimeInterval(duration))
        
        /* make sure fire next thunder after finishing current thunder firing */
        let waitTime = SKAction.wait(forDuration: TimeInterval(waitTime))
        let createThunder = SKAction.run({
            thunder.isHidden = false
        })
        
        let seq = SKAction.sequence([waitTime, createThunder, extendThunder])
        thunder.run(seq)
        
        // print(String(describing: type(of: test)))
        
        return duration
    }

}
