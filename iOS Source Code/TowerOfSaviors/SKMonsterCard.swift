//
//  SKMonsterCard.swift
//  TowerOfSaviors
//
//  Created by weizhen on 2018/10/30.
//  Copyright © 2018 aceasy. All rights reserved.
//

import UIKit

class SKMonsterCard: SKSpriteNode {

    private var isShining = false
    
    private var source : SKSpriteNode!
    
    private var target : SKSpriteNode!
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: nil, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        source = self["初始"].first?.sprite
        target = self["目标"].first?.sprite
    }
    
    func setStar(_ star: Int) {
        
        source.texture = SKTexture(imageNamed: "卡片背面_青铜")
        
        if        star == 4 {
            target.texture = SKTexture(imageNamed: "卡片背面_白银")
        } else if star == 5 {
            target.texture = SKTexture(imageNamed: "卡片背面_黄金")
        } else if star == 6 {
            target.texture = SKTexture(imageNamed: "卡片背面_白金")
        } else if star >= 7 {
            target.texture = SKTexture(imageNamed: "卡片背面_黑金")
        } else {
            target.texture = SKTexture(imageNamed: "卡片背面_青铜")
        }
    }
    
    func setProgress(_ rate: CGFloat) {
        target.alpha = rate
        source.alpha = 1 - rate
    }
    
    private func shine() {
        
        if isShining == false {
            return
        }
        
        let effect = SKSpriteNode(imageNamed: "卡片发光")
        effect.setScale(0.1)
        addChild(effect)
        
        let newa = SKAction.run(shine)
        let wait = SKAction.wait(forDuration: 0.4)
        let queu = SKAction.sequence([wait, newa])
        
        let zoom = SKAction.scale(to: 3.0, duration: 1.0)
        let fade = SKAction.fadeOut(withDuration: 1.0)
        let group = SKAction.group([zoom, fade, queu])
        
        let remv = SKAction.removeFromParent()
        effect.run(SKAction.sequence([group, remv]))
    }
    
    func play() {
        isShining = true
        shine()
    }
    
    func stop() {
        isShining = false
    }
}
