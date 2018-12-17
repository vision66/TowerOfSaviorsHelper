//
//  SKNavigationTitle.swift
//  TowerOfSaviors
//
//  Created by weizhen on 2018/10/12.
//  Copyright © 2018 aceasy. All rights reserved.
//

import UIKit

/// 标题栏
class SKNavigationTitle: SKSpriteNode {
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        position = CGPointMake(0, statusbar_position_y - 17)
    }
}
