//
//  Grid.swift
//  Hidden
//
//  Created by yo hanashima on 2017/07/03.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class Grid: SKSpriteNode, SKPhysicsContactDelegate {
    
    /* Grid array dimensions */
    let rows = 9
    let columns = 9
    
    /* Individual cell dimension, auto-calculated */
    var cellWidth = 0
    var cellHeight = 0
    
    
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        /* Calculate individual cell dimensions */
        cellWidth = Int(size.width) / columns
        cellHeight = Int(size.height) / rows
    }
    
}
