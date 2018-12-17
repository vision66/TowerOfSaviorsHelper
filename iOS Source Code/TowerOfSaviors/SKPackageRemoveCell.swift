//
//  SKPackageRemoveCell.swift
//  helper
//
//  Created by weizhen on 2018/1/25.
//  Copyright © 2018年 aceasy. All rights reserved.
//

import SpriteKit

/// `卡片包裹`中的卡片
class SKPackageRemoveCell: SKGridViewCell {
    
    /// 卡片头像
    var iconNode : SKButton!
    
    /// init
    required init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        let texture = SKTexture(imageNamed: "item_delete")
        
        iconNode = SKButton(texture: texture, color: .clear, size: package_cell_size)
        iconNode.name = "delete"
        addChild(iconNode)
    }
    
    /// init
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
