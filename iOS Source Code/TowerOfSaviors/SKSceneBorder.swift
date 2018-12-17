//
//  SKSceneBorder.swift
//  TowerOfSaviors
//
//  Created by weizhen on 2018/10/30.
//  Copyright © 2018 aceasy. All rights reserved.
//

import UIKit

class SKSceneBorder: SKSpriteNode {

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if position.y > 0 {
            position = CGPointMake(0, scene_top_border)
        } else {
            position = CGPointMake(0, scene_bottom_border)
        }
    }
}
