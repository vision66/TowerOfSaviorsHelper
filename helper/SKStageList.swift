//
//  SLSStoryList.swift
//  helper
//
//  Created by weizhen on 2018/2/7.
//  Copyright © 2018年 aceasy. All rights reserved.
//

import SpriteKit

/// 展示可选择的关卡
class SKStageList: SKScene, SceneClickableType {

    /// 剧本列表
    private lazy var list = childNode(withName: "list")!
    
    /// 剧本数据
    private var stages : JSON!
    
    /// 拖拽列表
    private lazy var pan = UIPanGestureRecognizer(target: self, action: #selector(onPanGesture(_:)))
    
    /// list往上拖拽到极限时的位置
    private var maxPositionY : CGFloat {
        return list.calculateAccumulatedFrame().height - 12 + storylist_bottom - scene_height / 2
    }
    
    /// list往下拖拽到极限时的位置
    private var minPositionY : CGFloat {
        return scene_height / 2 - 24 - storylist_top
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        let story = userData?["故事"] as! String

        // 从json文件中取的地点数据
        stages = SLGloabls.database.search("select ss.*, cc.'no' from stage ss left join character cc on cc.name = ss.'头像' where ss.'故事'=?", story).asJSON

        // 更新列表
        for (index, script) in stages.arrayValue.enumerated() {
            
            let texture = SLGloabls.avatarTextures["icon_\(script["no"].stringValue)@2x.png"] ?? SKTexture(imageNamed: "item_unknown")

            let cell = SKStageListCell(texture: texture)
            cell.titleLabel.text = script["关卡"].string
            cell.energyLabel.text = "体力: " + script["体力"].intValue.asString
            cell.roundLabel.text = "战斗: " + script["回合"].intValue.asString
            cell.expLabel.text = "经验: " + script["经验"].intValue.asString
            cell.position = CGPointMake(0, 0 - CGFloat(index) * 60)
            cell.name = "item"
            list.addChild(cell)
        }

        list.position = CGPoint(x: 0, y: minPositionY)
        
        // 添加手势
        view.addGestureRecognizer(pan)
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        view.removeGestureRecognizer(pan)
    }
    
    func scene(_ scene: SKScene, click button: SKButton) {
        
        if button.name == "team" {
            let scene = SKScene(fileNamed: "SKShowTeam")!
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
            return
        }
        
        if button.name == "package" {
            let scene = SKScene(fileNamed: "SKPackage")!
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
            return
        }
        
        if button.name == "energy" {
            let scene = SKScene(fileNamed: "SKWorld")!
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
            return
        }
        
        if button.name == "btn_left" {
            let scene = SKScene(fileNamed: "SKStoryList")!
            scene.scaleMode = .aspectFill
            scene.userData = userData
            view?.presentScene(scene)
            return
        }
        
        if button.name == "item" {
        
            return
        }
    }
    
    @objc private func onPanGesture(_ recognizer: UIPanGestureRecognizer) {
        
        let offsetY = recognizer.translation(in: view).y * scene_width / view_width
        
        var targetY = list.position.y - offsetY
            
        let max = maxPositionY
        if targetY > max {
            targetY = max
        }
        
        let min = minPositionY
        if targetY < min {
            targetY = min
        }

        list.position = CGPoint(x: 0, y: targetY)
        
        recognizer.setTranslation(.zero, in: view)
    }
}
