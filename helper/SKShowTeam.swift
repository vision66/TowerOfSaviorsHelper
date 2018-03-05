//
//  SKShowTeam.swift
//  SaintLisa
//
//  Created by weizhen on 2017/9/26.
//  Copyright © 2017年 weizhen. All rights reserved.
//

import SpriteKit

/// 展示当前队伍
class SKShowTeam: SKScene, SceneClickableType {
    
    /// 当前队伍
    private var team = SLTeam()
    
    /// 代表队伍成员的节点
    private lazy var memberNodes = self["members/item"] as! [SKSpriteNode]
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        team.loadConfiguration()
        
        // 如果场景是从`编辑队伍`转回的
        if let index = userData?["team index"] as? Int {
            
            if let character = userData?["character"] as? SLCharacter {
                team[index] = character
            } else {
                team[index] = nil
            }
        }
        
        // 根据队伍调整成员图片
        for index in 0 ..< 6 {
            if let character = team[index] {
                memberNodes[index].texture = SLGloabls.avatarTextures["icon_\(character.no)@2x.png"]
            } else {
                memberNodes[index].texture = SKTexture(imageNamed: "item_null")
            }
        }
        
        // 根据队伍调整综合战力
        let capabilities0 = team.basicCapabilities()
        let capabilities1 = team.finalCapabilities()
        
        if let node = childNode(withName: "values/size") as? SKLabelNode {
            node.text = capabilities0["size"]?.asString
        }
        
        let labels = ["life", "water", "fire", "wood", "light", "dark", "recover"]
        for label in labels {
            if let node = self["values/" + label] as? [SKLabelNode] {
                node[0].text = capabilities0[label]?.asString
                node[1].text = capabilities1[label]?.asString
            }
        }
        
        // 根据队伍调整队伍技能
        if let node = childNode(withName: "tips/label") as? SKLabelNode {
            let descs = team.skills.map { $0.队伍技能 }
            node.text = descs.joined(separator: "\n\n")
            childNode(withName: "title/btn_right")?.isUserInteractionEnabled = (descs.count > 0)
        }
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
    }
    
    func scene(_ scene: SKScene, click button: SKButton) {
     
        if button.name == "package" {
            
            team.saveConfiguration()
            
            let scene = SKScene(fileNamed: "SKPackage")!
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
            return
        }
        
        if button.name == "energy" {
            
            team.saveConfiguration()
            
            let scene = SKScene(fileNamed: "SKWorld")!
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
            return
        }
        
        if button.name == "confirm" {
            
            team.saveConfiguration()
            
            let scene = SKScene(fileNamed: "SKPlayStone")!
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
            return
        }
        
        if button.name == "btn_right" {
            childNode(withName: "tips")?.isHidden = false
            return
        }
        
        if button.name == "item" {
            
            team.saveConfiguration()
            
            let index = memberNodes.index(of: button)!
            
            let scene = SKScene(fileNamed: "SKEditTeam")!
            scene.scaleMode = .aspectFill
            scene.userData = ["team index" : index]
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
            return
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let position = touches.first!.location(in: self)
        
        if atPoint(position) == childNode(withName: "tips/mask") {
            childNode(withName: "tips")?.isHidden = true
        }
    }
}
