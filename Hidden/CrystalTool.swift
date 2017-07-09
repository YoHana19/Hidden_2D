//
//  Crystal.swift
//  Hidden
//
//  Created by yo hanashima on 2017/07/05.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class CrystalTool: SKSpriteNode {
    
    init() {
        /* Initialize with 'bubble' asset */
        let texture = SKTexture(imageNamed: "lightningCrystal")
        let bodySize = CGSize(width: 30, height: 45)
        super.init(texture: texture, color: UIColor.clear, size: bodySize)
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 2
        
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        // Set physics properties
        physicsBody = SKPhysicsBody(circleOfRadius: size.height/2)
        physicsBody?.categoryBitMask = 4
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = 8

    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
