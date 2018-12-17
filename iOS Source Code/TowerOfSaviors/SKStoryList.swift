//
//  SKStoryList.swift
//  helper
//
//  Created by weizhen on 2018/2/7.
//  Copyright © 2018年 aceasy. All rights reserved.
//

import SpriteKit

/// 展示可选择的剧本
class SKStoryList: SKScene, SceneClickableType, SKGridViewDelegate {
    
    /// 剧本列表   
    private let collection = SKGridView()
    
    /// 剧本数据
    private var place : JSON?
    private var stories : JSON?
    
    /// 拖拽列表
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        let placeName = userData?["地点名称"] as! String
        
        // 更新标题
        if let node = self["标题栏/label"].first as? SKLabelNode {
            node.text = placeName
        }
        
        // 当前地点
        place = SLGloabls.shared.database.search("SELECT * FROM 副本地点 WHERE 地点名称 = ?", placeName).first?.asJSON
        
        // 此处故事
        guard let placeId = place?["地点标识"].int else { return }
        stories = SLGloabls.shared.database.search("SELECT * FROM 副本剧本 WHERE 地点标识 = ?", placeId).asJSON
        
        // 添加列表
        let height : CGFloat = scene_height - 220
        
        collection.bounds = CGRectMake(-scene_width / 2, -height / 2, scene_width, height)
        collection.position = CGPointMake(0, -24)
        collection.itemSize = CGSizeMake(scene_width, 56)
        collection.minimumLineSpacing = 0
        collection.minimumInteritemSpacing = 0
        collection.contentInset = UIEdgeInsetsMake(0, 0, 40, 0)
        collection.delegate = self
        collection.register(SKStoryListCell.self, forCellReuseIdentifier: SKStoryListCell.defaultIdentifier)
        insertChild(collection, at: 1)
        collection.didMove(to: self)
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        collection.willRemove(from: self)
    }
    
    func scene(_ scene: SKScene, click button: SKButton) {
                
        if button.name == "能量" || button.name == "左按钮" {
            let scene = SKScene(fileNamed: "SKWorld")!
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
            return
        }
        
        if button.name == "item" {
            
            let cell = button.parent as! SKStoryListCell
            let story = stories![cell.indexPath!]
            
            let scene = SKScene(fileNamed: "SKStageList")!
            scene.scaleMode = .aspectFill
            scene.userData = ["地点标识" : place!["地点标识"].intValue,
                              "地点名称" : place!["地点名称"].stringValue,
                              "剧本标识" : story["剧本标识"].intValue,
                              "剧本名称" : story["剧本名称"].stringValue]
            view?.presentScene(scene)
            return
        }
    }
    
    func gridView(_ gridView: SKGridView, numberOfItems unuse: Int) -> Int {
        return stories?.array?.count ?? 0
    }
    
    func gridView(_ gridView: SKGridView, cellForItemAt indexPath: Int) -> SKGridViewCell {
        
        let story = stories![indexPath]
        
        let cell = collection.dequeueReusableCell(withIdentifier: SKStoryListCell.defaultIdentifier, for: indexPath) as! SKStoryListCell
        cell.titleLabel.text = story["剧本名称"].string
        cell.details = story["限制条件"].string
        cell.expired = "180日"
        cell.status = "进行中"
        return cell
    }
}
