//
//  Thunder.swift
//  Hidden
//
//  Created by yo hanashima on 2017/07/05.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class Thunder: SKSpriteNode {
    
    init() {
        /* Initialize with 'bubble' asset */
        let texture = SKTexture(imageNamed: "thunder")
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 2
        
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0, y: 0.5)
        
        // Set physics properties
        let bodySize = CGSize(width: size.width, height: size.height)
        let centerPoint1 = CGPoint(x: size.width / 2 - (size.width * anchorPoint.x), y: size.height / 2 - (size.height * anchorPoint.y))
        physicsBody = SKPhysicsBody(rectangleOf: bodySize, center: centerPoint1)
        physicsBody?.categoryBitMask = 8
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = 7
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
