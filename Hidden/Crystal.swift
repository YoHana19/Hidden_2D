//
//  Crystal.swift
//  Hidden
//
//  Created by yo hanashima on 2017/07/05.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class Crystal: SKSpriteNode {
    
    init() {
        /* Initialize with 'bubble' asset */
        let texture = SKTexture(imageNamed: "lightningCrystal")
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 3
        
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
