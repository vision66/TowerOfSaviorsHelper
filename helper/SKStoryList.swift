//
//  SKStoryList.swift
//  helper
//
//  Created by weizhen on 2018/2/7.
//  Copyright © 2018年 aceasy. All rights reserved.
//

import SpriteKit

/// 展示可选择的剧本
class SKStoryList: SKScene, SceneClickableType {

    /// 剧本列表
    private lazy var list = childNode(withName: "list")!
    
    /// 剧本数据
    private var stories : JSON!
    
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
        
        let address = userData?["地点"] as! String
        
        // 从json文件中取的地点数据
        stories = SLGloabls.database.search("select * from story where 地点=?", address).asJSON
        
        // 更新标题
        if let node = childNode(withName: "title/label") as? SKLabelNode {
            node.text = address
        }
        
        // 更新列表
        for (index, story) in stories.arrayValue.enumerated() {
            
            let cell = SKStoryListCell(size: CGSize.zero)
            cell.titleLabel.text = story["故事"].string
            cell.details = story["限制"].string
            cell.expired = nil
            cell.status = nil
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
        
        if button.name == "energy" || button.name == "btn_left" {
            let scene = SKScene(fileNamed: "SKWorld")!
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
            return
        }
        
        if button.name == "item" {
            
            let cell = button as! SKStoryListCell
            
            let story = stories.arrayValue.first(where: { $0["故事"].string == cell.titleLabel.text })!
            
            let scene = SKScene(fileNamed: "SKStageList")!
            scene.scaleMode = .aspectFill
            scene.userData = ["地点" : story["地点"].stringValue,
                              "故事" : story["故事"].stringValue]
            view?.presentScene(scene)
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
