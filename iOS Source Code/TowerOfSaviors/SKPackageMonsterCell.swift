//
//  SKPackageMonsterCell.swift
//  helper
//
//  Created by weizhen on 2018/1/25.
//  Copyright © 2018年 aceasy. All rights reserved.
//

import SpriteKit

/// `卡片包裹`中的卡片
class SKPackageMonsterCell: SKGridViewCell {
    
    /// 卡片头像
    var iconNode : SKButton!
    
    /// 描述文字
    let labelNode = SKLabelNode(fontNamed: "Helvetica")
    
    /// init
    required init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        iconNode = SKButton(texture: nil, color: .clear, size: package_cell_size)
        iconNode.name = "monster"
        addChild(iconNode)
        
        let shadow = SKSpriteNode(imageNamed: "icon_shadow")
        shadow.position = CGPoint(x: 0, y: -20)
        addChild(shadow)
        
        labelNode.fontSize = 10
        labelNode.position = shadow.position
        labelNode.verticalAlignmentMode = .center
        labelNode.color = UIColor(hexInteger: 0xE3E7E2)
        addChild(labelNode)
    }
    
    /// init
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
