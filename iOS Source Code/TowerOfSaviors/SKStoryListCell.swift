//
//  SLStoryListCell.swift
//  helper
//
//  Created by weizhen on 2018/2/7.
//  Copyright © 2018年 aceasy. All rights reserved.
//

import SpriteKit

/// SLSScriptList列表中的一行
class SKStoryListCell: SKGridViewCell {
    
    /// 背景
    var backgroundImage : SKButton!
    
    /// 标题
    var titleLabel : SKLabelNode!
    
    /// 详情
    private var detailsLabel : SKLabelNode!
    
    /// 期限
    private var expiredLabel : SKLabelNode!
    
    /// 状态
    private var statusLabel : SKLabelNode!
    
    /// 详情
    var details : String? {
        
        get {
            return detailsLabel.text
        }
        
        set {
            detailsLabel.text = newValue
            detailsLabel.parent?.isHidden = (newValue == nil || newValue!.length == 0)
        }
    }
    
    /// 期限
    var expired : String? {
        
        get {
            return expiredLabel.text
        }
        
        set {
            expiredLabel.text = newValue
            expiredLabel.parent?.isHidden = (newValue == nil || newValue!.length == 0)
        }
    }
    
    /// 状态
    var status : String? {
        
        get {
            return statusLabel.text
        }
        
        set {
            statusLabel.text = newValue
            statusLabel.parent?.isHidden = (newValue == nil || newValue!.length == 0)
        }
    }
    
    required init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        backgroundImage = SKButton(imageNamed: "list_cell0")
        backgroundImage.position = .zero
        backgroundImage.name = "item"
        addChild(backgroundImage)
        
        titleLabel = SKLabelNode(fontNamed: "Helvetica")
        titleLabel.fontSize = 12
        titleLabel.verticalAlignmentMode = .center
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.position = CGPointMake(-130, 10)
        addChild(titleLabel)
        
        let detailsBG = SKSpriteNode(texture: nil, color: SKColor.black, size: CGSizeMake(120, 16))
        detailsBG.anchorPoint = CGPointMake(0.0, 0.5)
        detailsBG.position = CGPointMake(-130, -10)
        addChild(detailsBG)
        
        detailsLabel = SKLabelNode(fontNamed: "Helvetica")
        detailsLabel.fontSize = 10
        detailsLabel.verticalAlignmentMode = .center
        detailsLabel.horizontalAlignmentMode = .left
        detailsLabel.position = CGPointMake(4, 0)
        detailsBG.addChild(detailsLabel)
        
        let expiredBG = SKSpriteNode(texture: nil, color: SKColor.black, size: CGSizeMake(80, 16))
        expiredBG.anchorPoint = CGPointMake(0.0, 0.5)
        expiredBG.position = CGPointMake(-5, -10)
        addChild(expiredBG)
        
        expiredLabel = SKLabelNode(fontNamed: "Helvetica")
        expiredLabel.fontSize = 10
        expiredLabel.verticalAlignmentMode = .center
        expiredLabel.horizontalAlignmentMode = .left
        expiredLabel.position = CGPointMake(4, 0)
        expiredBG.addChild(expiredLabel)
        
        let statusBG = SKSpriteNode(texture: nil, color: SKColor.black, size: CGSizeMake(40, 16))
        statusBG.position = CGPointMake(100, -10)
        addChild(statusBG)
        
        statusLabel = SKLabelNode(fontNamed: "Helvetica")
        statusLabel.fontSize = 10
        statusLabel.verticalAlignmentMode = .center
        statusLabel.horizontalAlignmentMode = .center
        statusLabel.position = CGPointMake(0, 0)
        statusBG.addChild(statusLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
