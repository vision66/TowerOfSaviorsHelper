//
//  SKStageListCell.swift
//  helper
//
//  Created by weizhen on 2018/2/7.
//  Copyright © 2018年 aceasy. All rights reserved.
//

import SpriteKit

/// SLSStageList列表中的一行
class SKStageListCell: SKGridViewCell {

    /// 背景
    var backgroundImage : SKButton!
    
    /// 头像
    var avatarNode : SKSpriteNode!
    
    /// 标题
    var titleLabel : SKLabelNode!
    
    /// 体力
    var energyLabel : SKLabelNode!
    
    /// 回合
    var roundLabel : SKLabelNode!
    
    /// 经验值
    var expLabel : SKLabelNode!
    
    required init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        backgroundImage = SKButton(imageNamed: "list_cell0")
        backgroundImage.position = .zero
        backgroundImage.name = "item"
        addChild(backgroundImage)
        
        avatarNode = SKSpriteNode(texture: nil, color: .clear, size: CGSize(width: 50, height: 50))
        avatarNode.position = CGPointMake(-128, 0)
        addChild(avatarNode)
        
        titleLabel = SKLabelNode(fontNamed: "Helvetica")
        titleLabel.fontSize = 12
        titleLabel.verticalAlignmentMode = .center
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.position = CGPointMake(-84, 10)
        addChild(titleLabel)

        let detailsBG = SKSpriteNode(texture: nil, color: SKColor.black, size: CGSizeMake(60, 16))
        detailsBG.position = CGPointMake(-55, -10)
        addChild(detailsBG)

        energyLabel = SKLabelNode(fontNamed: "Helvetica")
        energyLabel.fontSize = 10
        energyLabel.verticalAlignmentMode = .center
        energyLabel.horizontalAlignmentMode = .left
        energyLabel.position = CGPointMake(-26, 0)
        energyLabel.fontColor = SKColor(hexInteger: 0x25eff8)
        detailsBG.addChild(energyLabel)

        let expiredBG = SKSpriteNode(texture: nil, color: SKColor.black, size: CGSizeMake(60, 16))
        expiredBG.position = CGPointMake(15, -10)
        addChild(expiredBG)

        roundLabel = SKLabelNode(fontNamed: "Helvetica")
        roundLabel.fontSize = 10
        roundLabel.verticalAlignmentMode = .center
        roundLabel.horizontalAlignmentMode = .left
        roundLabel.position = CGPointMake(-26, 0)
        roundLabel.fontColor = SKColor(hexInteger: 0x81fe67)
        expiredBG.addChild(roundLabel)

        let expBG = SKSpriteNode(texture: nil, color: SKColor.black, size: CGSizeMake(60, 16))
        expBG.position = CGPointMake(85, -10)
        addChild(expBG)

        expLabel = SKLabelNode(fontNamed: "Helvetica")
        expLabel.fontSize = 10
        expLabel.verticalAlignmentMode = .center
        expLabel.horizontalAlignmentMode = .left
        expLabel.position = CGPointMake(-26, 0)
        expLabel.fontColor = SKColor(hexInteger: 0x25eff8)
        expBG.addChild(expLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
