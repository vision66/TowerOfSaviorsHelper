//
//  SKEnemyNode.swift
//  TowerOfSaviors
//
//  Created by weizhen on 2018/11/9.
//  Copyright © 2018 aceasy. All rights reserved.
//

import SpriteKit

/// 敌人的血条
class SKEnemyNode: SKSpriteNode {

    private lazy var lcap = self["左"].first!.sprite!
    
    private lazy var rcap = self["右"].first!.sprite!
    
    private lazy var pipe = self["槽"].first!.sprite!
    
    private lazy var life = self["值"].first!.sprite!
    
    var maximumLife : Int = 100
    
    private(set) var currentLife : Int = 20 
    
    var style : SLElementType = .水 {
        didSet {
            life.texture = SKTexture(imageNamed: "血条_" + style.description)
        }
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let width = size.width
        let height = size.height
        life.position = CGPointMake(0 - width / 2, 0 - height / 2)
        life.size = CGSizeMake(width, life.size.height)
        pipe.size = CGSizeMake(width, pipe.size.height)
        lcap.position = CGPointMake(5 - width / 2, 0 - height / 2)
        rcap.position = CGPointMake(width / 2 - 5, 0 - height / 2)
    }
    
    func setCurrentLife(_ value: Int, animation: Bool) {
        
        currentLife = value
        
        let xScale = currentLife.asCGFloat / maximumLife.asCGFloat
        
        if animation {
            life.removeAllActions()
            life.run(SKAction.scaleX(to: xScale, duration: 0.2))
        } else {
            life.xScale = xScale
        }
    }
}
