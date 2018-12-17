//
//  SKStatusBar.swift
//  helper
//
//  Created by weizhen on 2018/2/6.
//  Copyright © 2018年 aceasy. All rights reserved.
//

import SpriteKit

/// 顶部的状态栏
class SKStatusBar: SKSpriteNode {

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
                
        position = CGPointMake(0, statusbar_position_y)
        
        if let node = self["版本号"].first as? SKLabelNode {
            node.text = "版本 " + Bundle.shortVersion
        }
        
        if let node = self["构建号"].first as? SKLabelNode {
            node.text = "编译 " + Bundle.buildVersion
        }
        
        if let node = self["现在时间"].first as? SKLabelNode {
            node.text = Date().string(using: "yyyy年MM月dd日")
        }
    }
}
