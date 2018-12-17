//
//  SKRunestone.swift
//  SaintLisa
//
//  Created by weizhen on 2017/9/29.
//  Copyright © 2017年 weizhen. All rights reserved.
//

import SpriteKit

/// Battle中代表符石的实体对象
class SKRunestone: SKSpriteNode {
    
    /// 符石的爆炸标记
    /// - 大于0时, 表示会在第combo轮发生爆炸;
    /// - 小于0时, 表示会爆炸, 但是不知道在第几轮, 在分析版面时使用
    /// - 等于0时, 表示不会爆炸
    var 爆炸标记 : Int = 0
    
    /// 版面标记(天降标记)
    /// - 大于0时, 表示天降fallId轮后的版面
    /// - 小于0时, 未知
    /// - 等于0时, 表示初始版面
    var 天降标记 : Int = 0
    
    /// 符石的类型. 例如水、火、木、光、暗、心
    var 元素属性 : SLElementType = .水
    
    /// 符石的状态. 例如强化等
    var 元素状态 : SLElementStatus = .普通
    
    /// 符石状态. 例如种族标记、锁定、冰冻、隐藏等
    var 符石状态 : SLRunestoneStatus = .正常
    
    /// 构造器
    init(element: SLElementType = .水, status: SLElementStatus = .普通, stone: SLRunestoneStatus = .正常) {

        self.元素属性 = element
        self.元素状态 = status
        self.符石状态 = stone
        
        let texture = status.texture(element)
        
        super.init(texture: texture, color: .clear, size: texture.size())
    }
    
    /// 改变符石
    func change(element: SLElementType = .水, status: SLElementStatus = .普通, stone: SLRunestoneStatus = .正常, animation: Bool = true) {
        
        self.元素属性 = element
        self.元素状态 = status
        self.符石状态 = stone
        
        let newTexture = status.texture(element)
        
        if animation {
            let image = SKAction.setTexture(newTexture)
            let scale = SKAction.sequence([SKAction.scale(to: 0.9, duration: 0.2), SKAction.scale(to: 1.0, duration: 0.1)])
            let alpha = SKAction.sequence([SKAction.fadeAlpha(to: 0.8, duration: 0.2), SKAction.fadeAlpha(to: 1.0, duration: 0.1)])
            self.run(SKAction.group([image, scale, alpha]))
        } else {
            self.texture = newTexture
        }
    }
    
    /// 构造器
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 执行爆炸效果, 动画结束后, 会将自己从父节点中移除
    func boom(completion completionBlock: @escaping () -> Void) {
        
        KSLog("stone boom: %@", description)
        
        let boom = SLAnimations.stoneBoom!
        let remove = SKAction.removeFromParent()
        
        run(SKAction.sequence([boom, remove]), completion: completionBlock)
    }
    
    /// 打印符石信息
    override var description: String {
        return String(format: "%@[c%02d,f%02d](%@%03d,%@%03d)", 元素属性.description, 爆炸标记, 天降标记, (position.x >= 0 ? "+" : "-"), abs(Int(position.x)), (position.y >= 0 ? "+" : "-"), abs(Int(position.y)))
    }
}

func ==(left: SKRunestone, right: SKRunestone) -> Bool {
    return left.元素属性 == right.元素属性 && left.元素状态 == right.元素状态 && left.符石状态 == right.符石状态
}
