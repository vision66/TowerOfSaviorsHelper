//
//  SLSStoryList.swift
//  helper
//
//  Created by weizhen on 2018/2/7.
//  Copyright © 2018年 aceasy. All rights reserved.
//

import SpriteKit

/// 展示可选择的关卡
class SKStageList: SKScene, SceneClickableType, SKGridViewDelegate {
    
    /// 剧本列表
    private let collection = SKGridView()
    
    /// 剧本数据
    private var place : JSON?
    private var story : JSON?
    private var stages : JSON?
    
    /// 拖拽列表
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // 当前地点
        guard let placeId = userData?["地点标识"] as? Int else { return }
        place = SLGloabls.shared.database.search("SELECT * FROM 副本地点 WHERE 地点标识 = ?", placeId).first?.asJSON
        
        // 当前故事
        guard let storyId = userData?["剧本标识"] as? Int else { return }
        story = SLGloabls.shared.database.search("SELECT * FROM 副本剧本 WHERE 剧本标识 = ?", storyId).first?.asJSON
        
        // 包含关卡
        stages = SLGloabls.shared.database.search("SELECT * FROM 副本关卡 WHERE 剧本标识 = ?", storyId).asJSON
        
        // 更新标题
        if let node = self["标题栏/label"].first as? SKLabelNode {
            node.text = story?["剧本名称"].string
        }
        
        // 添加列表
        let height : CGFloat = scene_height - 220
        
        collection.bounds = CGRectMake(-scene_width / 2, -height / 2, scene_width, height)
        collection.position = CGPointMake(0, -24)
        collection.itemSize = CGSizeMake(scene_width, 56)
        collection.minimumLineSpacing = 0
        collection.minimumInteritemSpacing = 0
        collection.contentInset = UIEdgeInsetsMake(0, 0, 40, 0)
        collection.delegate = self
        collection.register(SKStageListCell.self, forCellReuseIdentifier: SKStageListCell.defaultIdentifier)
        insertChild(collection, at: 1)
        collection.didMove(to: self)
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        collection.willRemove(from: self)
    }
    
    func scene(_ scene: SKScene, click button: SKButton) {
                
        if button.name == "能量" {
            let scene = SKScene(fileNamed: "SKWorld")!
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
            return
        }
        
        if button.name == "左按钮" {
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
    
    func gridView(_ gridView: SKGridView, numberOfItems unuse: Int) -> Int {
        return stages?.array?.count ?? 0
    }
    
    func gridView(_ gridView: SKGridView, cellForItemAt indexPath: Int) -> SKGridViewCell {
        
        let stage = stages![indexPath]
        let icon = stage["关卡头像"].stringValue
        
        let cell = collection.dequeueReusableCell(withIdentifier: SKStageListCell.defaultIdentifier, for: indexPath) as! SKStageListCell
        cell.avatarNode.texture = SLTextures.monsterIcons[icon] ?? SKTexture(imageNamed: "item_unknown")
        cell.titleLabel.text = stage["关卡名称"].string
        cell.energyLabel.text = "体力: " + stage["扣除体力"].intValue.asString
        cell.roundLabel.text = "战斗: " + stage["战斗次数"].intValue.asString
        cell.expLabel.text = "经验: " + stage["获得经验"].intValue.asString
        return cell
    }
}
