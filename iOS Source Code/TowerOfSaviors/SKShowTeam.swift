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
    private lazy var memberNodes = self["队伍成员/成员"] as! [SKButton]
    
    /// 识别长按
    private lazy var longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture(_:)))
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // 播放背景音乐
        SKBackgroundMusicPlayer.Key.夜幕下的旅途.play()
        
        // 调整节点位置
        self["队伍成员"].first?.position = CGPointMake(   0, statusbar_position_y - 270 + 180)
        self["综合属性"].first?.position = CGPointMake(   0, statusbar_position_y - 270 + 100)
        self["团队技能"].first?.position = CGPointMake(-150, statusbar_position_y - 270 + 40)
        self["进入战斗"].first?.position = CGPointMake( 110, bottombar_position_y + 30)
        
        // 加载小队数据
        team.loadConfiguration()
        
        // 如果场景是从`编辑队伍`转回的
        if let index = userData?["team index"] as? Int {
            if let monster = userData?["monster"] as? SLMonster {
                team[index] = monster
            } else {
                team[index] = nil
            }
        }
        
        // 根据队伍调整成员图片
        for index in 0 ..< SLTeam.MaxMemebersCount {
            let texture : SKTexture?
            if let monster = team[index] {
                texture = SLTextures.monsterIcons[monster.怪兽名称]
            } else {
                texture = SKTexture(imageNamed: "item_unknown")
            }
            memberNodes[index].setTexture(texture, for: .normal)
        }
        
        // 根据队伍调整综合战力
        let capabilities0 = team.basicCapabilities()
        let capabilities1 = team.finalCapabilities()
                
        let labels = ["空间", "生命", "水攻", "火攻", "木攻", "光攻", "暗攻", "回复"]
        
        for label in labels {
            
            let nodes = self["综合属性/" + label] as! [SKLabelNode]
            
            if nodes.count > 0 {
                nodes[0].text = capabilities0[label]?.asString
            }
            
            if nodes.count > 1 {
                nodes[1].text = capabilities1[label]?.asString
            }
        }
        
        // 团队技能描述
        self["团队技能"].first?.label?.text = team.strings.joined(separator: "\n\n")
        
        // 监视[长按手势]
        view.addGestureRecognizer(longPressRecognizer)
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        view.removeGestureRecognizer(longPressRecognizer)
    }
    
    func scene(_ scene: SKScene, click button: SKButton) {
     
        if button.name == "背包" {
            
            team.saveConfiguration()
            
            let scene = SKScene(fileNamed: "SKPackage")!
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
            return
        }
        
        if button.name == "能量" {
            
            team.saveConfiguration()
            
            let scene = SKScene(fileNamed: "SKWorld")!
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
            return
        }
        
        if button.name == "进入战斗" {
            
            team.saveConfiguration()
            
            let scene = SKScene(fileNamed: "SKPlayStone")!
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
            return
        }
        
        if button.name == "成员" {
            
            team.saveConfiguration()
            
            let index = memberNodes.index(of: button)!
            
            let scene = SKScene(fileNamed: "SKSelectMemeber")!
            scene.scaleMode = .aspectFill
            scene.userData = ["team index" : index]
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
            return
        }
    }
    
    @objc func longPressGesture(_ recognizer: UILongPressGestureRecognizer) {
        
        if recognizer.state != .began { return }
        
        guard let location = recognizer.location(in: self) else { return }
        
        let tapped = atPoint(location)
        
        guard let memberIndex = memberNodes.index(where: { $0 === tapped }) else { return }
        
        guard let monster = team[memberIndex] else { return }

        let scene = SKScene(fileNamed: "SKMonster") as! SKMonster
        scene.monster = monster
        scene.scaleMode = .aspectFill
        scene.fromScene = self
        view?.presentScene(scene, transition: SKTransition.fade(withDuration: 2.0))
        
        view?.removeGestureRecognizer(longPressRecognizer)
    }
}
