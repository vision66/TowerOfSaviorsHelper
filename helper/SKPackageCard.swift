//
//  SKPackageCard.swift
//  helper
//
//  Created by weizhen on 2018/1/25.
//  Copyright © 2018年 aceasy. All rights reserved.
//

import SpriteKit

/// `卡片包裹`中的卡片
class SKPackageCard: SKButton {
    
    /// 卡片素质
    let character : SLCharacter
    
    /// 卡片头像
    let avatar : SKSpriteNode
    
    /// 描述文字
    let titleLabel = SKLabelNode(fontNamed: "Helvetica")
    
    init(character : SLCharacter, size: CGSize) {
        
        self.character = character
        
        let texture = SLGloabls.avatarTextures["icon_\(character.no)@2x.png"] ?? SKTexture(imageNamed: "item_unknown")
        
        self.avatar = SKSpriteNode(texture: texture, color: UIColor.clear, size: size)
        
        super.init(texture: nil, color: UIColor.clear, size: size)
        
        addChild(avatar)
        
        let shadow = SKSpriteNode(imageNamed: "icon_shadow")
        shadow.position = CGPoint(x: 0, y: -20)
        addChild(shadow)
        
        titleLabel.text = "No.\(character.no)"
        titleLabel.fontSize = 10
        titleLabel.position = shadow.position
        titleLabel.verticalAlignmentMode = .center
        titleLabel.color = UIColor(hexInteger: 0xE3E7E2)
        addChild(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
