//
//  Target.swift
//  Hidden
//
//  Created by yo hanashima on 2017/07/03.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class Target2: SKSpriteNode {
    
    var positionX: Int = 4
    var positionY: Int = 4
    var positionLayer: PositionLayer = .layer1
    var outOfGridFlag = false
    var deathFlag = false
    
    init() {
        /* Initialize with 'bubble' asset */
        let texture = SKTexture(imageNamed: "target2")
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 2
        
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        // Set physics properties
        physicsBody = SKPhysicsBody(circleOfRadius: size.width/2)
        physicsBody?.categoryBitMask = 2
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = 8
        
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setLayer() {
        if self.positionX == 2 || self.positionX == 6 || self.positionY == 2 || self.positionY == 6 {
            self.positionLayer = .layer2
        } else if self.positionX == 1 || self.positionX == 7 || self.positionY == 1 || self.positionY == 7 {
            self.positionLayer = .layer3
        }
    }
    
    func moveOutward() {
        switch positionLayer {
            
            /* (4, 4) center */
        case .layer0:
            self.positionLayer = .layer2
            break;
            
            /* (3, 3) ~ (5, 5) */
        case .layer1:
            if self.positionX == 3 {
                /* (3, 3) left bottom */
                if self.positionY == 3 {
                    /* ←↓: to (2, 2) */
                    self.positionX = self.positionX-2
                    self.positionY = self.positionY-2
                    let move = SKAction.moveBy(x: -140, y: -140, duration: 1.0)
                    self.run(move)
                    /* (3, 5) left top */
                } else if self.positionY == 5 {
                    /* ↑←: to (2, 6) */
                    self.positionX = self.positionX-2
                    self.positionY = self.positionY+2
                    let move = SKAction.moveBy(x: -140, y: 140, duration: 1.0)
                    self.run(move)
                    /* (3, 4) left side*/
                } else {
                    /* ←: to (2, 4) */
                    self.positionX = self.positionX-2
                    let move = SKAction.moveBy(x: -140, y: 0, duration: 1.0)
                    self.run(move)
                }
            }
            if self.positionX == 4 {
                /* (4, 3) middle bottom */
                if self.positionY == 3 {
                    /* ↓: to (4, 2) */
                    self.positionY = self.positionY-2
                    let move = SKAction.moveBy(x: 0, y: -140, duration: 1.0)
                    self.run(move)
                    /* (4, 5) middle top */
                } else if self.positionY == 5 {
                    /* ↑: to (4, 6) */
                    self.positionY = self.positionY+2
                    let move = SKAction.moveBy(x: 0, y: 140, duration: 1.0)
                    self.run(move)
                }
            }
            if self.positionX == 5 {
                /* (5, 3) right bottom */
                if self.positionY == 3 {
                    /* ↓→: to (6, 2) */
                    self.positionX = self.positionX+2
                    self.positionY = self.positionY-2
                    let move = SKAction.moveBy(x: 140, y: -140, duration: 1.0)
                    self.run(move)
                    /* (5, 5) right top */
                } else if self.positionY == 5 {
                    /* ↑→: to (6, 6) */
                    self.positionX = self.positionX+2
                    self.positionY = self.positionY+2
                    let move = SKAction.moveBy(x: 140, y: 140, duration: 1.0)
                    self.run(move)
                    /* (5, 4) right side */
                } else {
                    /* →: to (6, 4) */
                    self.positionX = self.positionX+2
                    let move = SKAction.moveBy(x: 140, y: 0, duration: 1.0)
                    self.run(move)
                }
            }
            self.positionLayer = .layer3
            break;
            
            /* (2, 2) ~ (6, 6) */
        case .layer2:
            if self.positionX == 2 {
                /* (2, 2) left bottom */
                if self.positionY == 2 {
                    /* ↓←: to (1, 1) */
                    self.positionX = self.positionX-2
                    self.positionY = self.positionY-2
                    let move = SKAction.moveBy(x: -140, y: -140, duration: 1.0)
                    self.run(move)
                    /* (2, 6) left top */
                } else if self.positionY == 6 {
                    /* ↑←: to (1, 7) */
                    self.positionX = self.positionX-2
                    self.positionY = self.positionY+2
                    let move = SKAction.moveBy(x: -140, y: 140, duration: 1.0)
                    self.run(move)
                    /* (2, 3) ~ (2, 5) left side */
                } else {
                    /* ←: to (1, 3) ~ (1, 5) */
                    self.positionX = self.positionX-2
                    let move = SKAction.moveBy(x: -140, y: 0, duration: 1.0)
                    self.run(move)
                }
            }
            if self.positionY == 2 {
                /* (3, 2) ~ (5, 2) bottom side */
                if self.positionX != 2 && self.positionX != 6  {
                    /* ↓: (3, 1) ~ (5, 1) */
                    self.positionY = self.positionY-2
                    let move = SKAction.moveBy(x: 0, y: -140, duration: 1.0)
                    self.run(move)
                }
            }
            if self.positionY == 6 {
                /* (3, 6) ~ (5, 6) top side */
                if self.positionX != 2 && self.positionX != 6  {
                    /* ↑: (3, 7) ~ (5, 7) */
                    self.positionY = self.positionY+2
                    let move = SKAction.moveBy(x: 0, y: 140, duration: 1.0)
                    self.run(move)
                }
            }
            if self.positionX == 6 {
                /* (6, 2) right bottom  */
                if self.positionY == 2 {
                    /* ↓→: to (7, 1) */
                    self.positionX = self.positionX+2
                    self.positionY = self.positionY-2
                    let move = SKAction.moveBy(x: 140, y: -140, duration: 1.0)
                    self.run(move)
                    /* (6, 6) right top  */
                } else if self.positionY == 6 {
                    /* ↑→: to (7, 7) */
                    self.positionX = self.positionX+2
                    self.positionY = self.positionY+2
                    let move = SKAction.moveBy(x: 140, y: 140, duration: 1.0)
                    self.run(move)
                    /* (6, 3) ~ (6, 5) right side */
                } else {
                    /* →: to (7, 3) ~ (7, 5) */
                    self.positionX = self.positionX+2
                    let move = SKAction.moveBy(x: 140, y: 0, duration: 1.0)
                    self.run(move)
                }
            }
            self.positionLayer = .layer4
            break;
            
            /* (1, 1) ~ (7, 7) */
        case .layer3:
            if self.positionX == 1 {
                /* (1, 1) left bottom */
                if self.positionY == 1 {
                    /* ↓←: to (0, 0) */
                    self.positionX = self.positionX-2
                    self.positionY = self.positionY-2
                    let move = SKAction.moveBy(x: -140, y: -140, duration: 1.0)
                    self.run(move)
                    /* (1, 7) left top */
                } else if self.positionY == 7 {
                    /* ↑←: to (0, 7) */
                    self.positionX = self.positionX-2
                    self.positionY = self.positionY+2
                    let move = SKAction.moveBy(x: -140, y: 140, duration: 1.0)
                    self.run(move)
                    /* (1, 2) ~ (1, 6) left side */
                } else {
                    /* ←: to (0, 2) ~ (0, 6) */
                    self.positionX = self.positionX-2
                    let move = SKAction.moveBy(x: -140, y: 0, duration: 1.0)
                    self.run(move)
                }
            }
            if self.positionY == 1 {
                /* (2, 1) ~ (6, 1) bottom side */
                if self.positionX != 2 && self.positionX != 6  {
                    /* ↓: (2, 0) ~ (6, 0) */
                    self.positionY = self.positionY-2
                    let move = SKAction.moveBy(x: 0, y: -140, duration: 1.0)
                    self.run(move)
                }
            }
            if self.positionY == 7 {
                /* (2, 7) ~ (6, 7) top side */
                if self.positionX != 2 && self.positionX != 6  {
                    /* ↑: (2, 8) ~ (6, 8) */
                    self.positionY = self.positionY+2
                    let move = SKAction.moveBy(x: 0, y: 140, duration: 1.0)
                    self.run(move)
                }
            }
            if self.positionX == 7 {
                /* (7, 1) right bottom  */
                if self.positionY == 1 {
                    /* ↓→: to (8, 0) */
                    self.positionX = self.positionX+2
                    self.positionY = self.positionY-2
                    let move = SKAction.moveBy(x: 140, y: -140, duration: 1.0)
                    self.run(move)
                    /* (7, 7) right top  */
                } else if self.positionY == 7 {
                    /* ↑→: to (8, 8) */
                    self.positionX = self.positionX+2
                    self.positionY = self.positionY+2
                    let move = SKAction.moveBy(x: 140, y: 140, duration: 1.0)
                    self.run(move)
                    /* (7, 2) ~ (7, 6) right side */
                } else {
                    /* →: to (7, 2) ~ (8, 6) */
                    self.positionX = self.positionX+2
                    let move = SKAction.moveBy(x: 140, y: 0, duration: 1.0)
                    self.run(move)
                }
            }
            /* Game Over */
            self.outOfGridFlag = true
            break;
            
            /* (0, 0) ~ (8, 8) */
        case .layer4:
            if self.positionX == 0 {
                /* left side ← */
                let move = SKAction.moveBy(x: -70, y: 0, duration: 1.0)
                self.run(move)
            }
            
            if self.positionY == 0 {
                /* bottom side ↓ */
                if self.positionX != 0 && self.positionX != 8  {
                    let move = SKAction.moveBy(x: 0, y: -70, duration: 1.0)
                    self.run(move)
                }
            }
            
            if self.positionY == 8 {
                /* top side ↑ */
                if self.positionX != 0 && self.positionX != 8  {
                    let move = SKAction.moveBy(x: 0, y: 70, duration: 1.0)
                    self.run(move)
                }
            }
            
            if self.positionX == 8 {
                /* right side → */
                let move = SKAction.moveBy(x: 70, y: 0, duration: 1.0)
                self.run(move)
            }
            
            /* Game Over */
            let wait = SKAction.wait(forDuration: 1.0)
            let flag = SKAction.run({ self.outOfGridFlag = true })
            let seq = SKAction.sequence([wait, flag])
            self.run(seq)
            break;
        }
    }
    
}
