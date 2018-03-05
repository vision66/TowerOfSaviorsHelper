//
//  SKElementStone.swift
//  SaintLisa
//
//  Created by weizhen on 2017/9/29.
//  Copyright © 2017年 weizhen. All rights reserved.
//

import SpriteKit

/// Battle中代表符石的实体对象
class SKElementStone: SKSpriteNode {
    
    /// 符石
    var object : SLStone
    
    /// 符石的爆炸标记
    /// - 大于0时, 表示会在第combo轮发生爆炸;
    /// - 小于0时, 表示会爆炸, 但是不知道在第几轮
    /// - 等于0时, 表示不会爆炸
    var comboId : Int = 0
    
    /// 版面标记(天降标记)
    /// - 大于0时, 表示天降fallId轮后的版面
    /// - 小于0时, 未知
    /// - 等于0时, 表示初始版面
    var fallId : Int = 0
    
    /// 构造器
    init(stone : SLStone) {
        
        self.object = stone
        
        let texture : SKTexture
        if stone.status == .normal {
            texture = SLGloabls.normalStoneTextures[stone.type.rawValue]
        } else {
            texture = SLGloabls.strongStoneTextures[stone.type.rawValue]
        }
        
        super.init(texture: texture, color: .red, size: texture.size())
    }
    
    /// 构造器
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 执行爆炸效果
    func boom(whenHappen happenBlock: @escaping () -> Void,  completion completionBlock: @escaping () -> Void) {
        
        if comboId <= 0 { return }
        
        KSLog("stone boom: %@", description)
        
        let wait = SKAction.wait(forDuration: 0.1)
        
        let sound = (comboId < 8) ? SLGloabls.stoneBoomSounds[comboId] : SLGloabls.stoneBoomSounds[8]
        let fade = SKAction.fadeOut(withDuration: 0.4)
        let happen = SKAction.run(happenBlock)
        let group = SKAction.group([fade, sound, SLGloabls.stoneBoomAnimation!, happen])
        
        let remove = SKAction.removeFromParent()
        
        run(SKAction.sequence([wait, group, remove]), completion: completionBlock)
    }
    
    /// 符石的类型. 例如水、火、木、光、暗、心
    func setStone(stone: SLStone, animation: Bool = true) {
        
        self.object = stone
        
        let newTexture : SKTexture
        if stone.status == .normal {
            newTexture = SLGloabls.normalStoneTextures[stone.type.rawValue]
        } else {
            newTexture = SLGloabls.strongStoneTextures[stone.type.rawValue]
        }
        
        if animation {
            let image = SKAction.setTexture(newTexture)
            let sound = SLGloabls.stoneChangedSound
            let scale = SKAction.sequence([SKAction.scale(to: 0.9, duration: 0.2), SKAction.scale(to: 1.0, duration: 0.1)])
            let alpha = SKAction.sequence([SKAction.fadeAlpha(to: 0.8, duration: 0.2), SKAction.fadeAlpha(to: 1.0, duration: 0.1)])
            self.run(SKAction.group([image, sound, scale, alpha]))
        } else {
            self.texture = newTexture
        }
    }
    
    /// 打印符石信息
    override var description: String {
        return String(format: "%@[c%02d,f%02d](%@%03d,%@%03d)", object.type.description, comboId, fallId,
                      (position.x >= 0 ? "+" : "-"), abs(Int(position.x)),
                      (position.y >= 0 ? "+" : "-"), abs(Int(position.y)))
    }
}
