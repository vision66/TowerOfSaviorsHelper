//
//  SKBottomBar.swift
//  TowerOfSaviors
//
//  Created by weizhen on 2018/10/12.
//  Copyright © 2018 aceasy. All rights reserved.
//

import UIKit

/// 底部的标签栏
class SKBottomBar: SKSpriteNode {
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        position = CGPointMake(0, bottombar_position_y)
        
        if let button = self["队伍"].first as? SKButton {
            button.addTarget(self, action: #selector(clickTeam), for: .touchUpInside)
        }
        
        if let button = self["背包"].first as? SKButton {
            button.addTarget(self, action: #selector(clickPackage), for: .touchUpInside)
        }

        if let button = self["抽卡"].first as? SKButton {
            button.addTarget(self, action: #selector(clickAltar), for: .touchUpInside)
        }
        
        if let button = self["设置"].first as? SKButton {
            button.addTarget(self, action: #selector(clickParameters), for: .touchUpInside)
        }
    }
    
    @objc func clickTeam() {
        
        guard let scene = scene, type(of: scene) != SKShowTeam.self else { return }
        
        guard let view = scene.view else { return }
        
        let next = SKScene(fileNamed: "SKShowTeam")!
        next.scaleMode = .aspectFill
        view.presentScene(next, transition: SKTransition.fade(withDuration: 0.6))
    }
    
    @objc func clickPackage() {
        
        guard let scene = scene, type(of: scene) != SKPackage.self else { return }
        
        guard let view = scene.view else { return }
        
        let next = SKScene(fileNamed: "SKPackage")!
        next.scaleMode = .aspectFill
        view.presentScene(next, transition: SKTransition.fade(withDuration: 0.6))
    }
    
    @objc func clickAltar() {
        
        guard let scene = scene, type(of: scene) != SKSealCard.self else { return }
        
        guard let view = scene.view else { return }
        
        let next = SKScene(fileNamed: "SKSealCard")!
        next.scaleMode = .aspectFill
        view.presentScene(next, transition: SKTransition.fade(withDuration: 0.6))
    }
    
    @objc func clickParameters() {
        
        guard let scene = scene, type(of: scene) != SKParameters.self else { return }
        
        guard let view = scene.view else { return }
        
        let next = SKScene(fileNamed: "SKParameters")!
        next.scaleMode = .aspectFill
        view.presentScene(next, transition: SKTransition.fade(withDuration: 0.6))
    }
}
