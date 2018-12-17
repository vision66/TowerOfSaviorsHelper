//
//  SKMonster.swift
//  SaintLisa
//
//  Created by weizhen on 2017/9/26.
//  Copyright © 2017年 weizhen. All rights reserved.
//

import SpriteKit

class SKMonster: SKScene {
    
    /// 拖拽, 查看额外的内容
    private lazy var pan = UIPanGestureRecognizer(target: self, action: #selector(onPanGesture(_:)))
    
    /// 点击, 退出此场景
    private lazy var tap = UITapGestureRecognizer(target: self, action: #selector(onTapGesture(_:)))
    
    private lazy var cardHead = self["卡片头部"].first!
    
    private lazy var cardBody = self["卡片中部"].first!
    
    private lazy var cardFoot = self["卡片底部"].first!
    
    private lazy var background = self["背景"].first!
    
    private lazy var carema = self["摄像机"].first!
    
    /// 从这个场景进入
    var fromScene : SKScene?
    
    var monster : SLMonster! = nil
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        monster.getSkills()
        
        self["卡片头部/星级"].first?.sprite?.texture = SKTexture(imageNamed: "card_star_\(monster.怪兽星级)")
        
        self["卡片头部/形象"].first?.sprite?.texture = SKTexture(imageNamed: "卡片边框_背景")
        
        self["卡片头部/属性"].first?.sprite?.texture = SKTexture(imageNamed: "card_attribute_\(monster.元素属性.rawValue)")
        
        self["卡片头部/名字"].first?.label?.text = monster.怪兽名称
        
        self["卡片头部/空间"].first?.label?.text = "\(monster.占据空间)"
        
        self["卡片头部/等级"].first?.label?.text = "\(monster.最大等级)"
        
        self["卡片头部/种族"].first?.sprite?.texture = SKTexture(imageNamed: "card_race_\(monster.怪兽种族.rawValue)")
        
        self["卡片头部/种族/title"].first?.label?.text = "\(monster.怪兽种族)"
        
        self["卡片头部/生命/title"].first?.label?.text = "\(monster.满级生命)"
        
        self["卡片头部/攻击/title"].first?.label?.text = "\(monster.满级攻击)"
        
        self["卡片头部/回复/title"].first?.label?.text = "\(monster.满级回复)"
        
        self["摄像机/上边框"].first?.position = CGPointMake(0, scene_top_border)
        self["摄像机/下边框"].first?.position = CGPointMake(0, scene_bottom_border)
        
        cardHead.position = CGPointMake(0, scene_top_border)
        cardBody.position = CGPointMake(0, cardHead.calculateAccumulatedFrame().origin.y)
        
        var node_postion_y : CGFloat = 0
        
        for skill in monster.主动技能 {
            
            let node = SKReferenceNode(fileNamed: "SKSkillNode")!.firstChild!.firstChild as! SKSkillNode
            node.removeFromParent()
            
            node.setSkill(skill)
            node.position = CGPointMake(0, node_postion_y)
            cardBody.addChild(node)
            
            node_postion_y = node.calculateAccumulatedFrame().origin.y
        }
        
        if let skill = monster.队长技能 {
            
            let node = SKReferenceNode(fileNamed: "SKSkillNode")!.firstChild!.firstChild as! SKSkillNode
            node.removeFromParent()
            
            node.setSkill(skill)
            node.position = CGPointMake(0, node_postion_y)
            cardBody.addChild(node)
            
            node_postion_y = node.calculateAccumulatedFrame().origin.y
        }
        
        for skill in monster.团队技能 {
            
            let node = SKReferenceNode(fileNamed: "SKSkillNode")!.firstChild!.firstChild as! SKSkillNode
            node.removeFromParent()
            
            node.setSkill(skill)
            node.position = CGPointMake(0, node_postion_y)
            cardBody.addChild(node)
            
            node_postion_y = node.calculateAccumulatedFrame().origin.y
        }
        
        for skill in monster.升华技能 {
            
            let node = SKReferenceNode(fileNamed: "SKSkillNode")!.firstChild!.firstChild as! SKSkillNode
            node.removeFromParent()
            
            node.setSkill(skill)
            node.position = CGPointMake(0, node_postion_y)
            cardBody.addChild(node)
            
            node_postion_y = node.calculateAccumulatedFrame().origin.y
        }
        
        for skill in monster.组合技能 {
            
            let node = SKReferenceNode(fileNamed: "SKSkillNode")!.firstChild!.firstChild as! SKSkillNode
            node.removeFromParent()
            
            node.setSkill(skill)
            node.position = CGPointMake(0, node_postion_y)
            cardBody.addChild(node)
            
            node_postion_y = node.calculateAccumulatedFrame().origin.y
        }
        
        cardFoot.position = CGPointMake(0, cardBody.calculateAccumulatedFrame().origin.y)
        self["卡片底部/编号"].first?.label?.text = "No.\(monster.怪兽标识)"
        
        view.addGestureRecognizer(pan)
        view.addGestureRecognizer(tap)
        
        let loading = self["卡片头部/加载进度"].first as! SKLabelNode
        
        /// 从某处获取卡片信息, 并下载图片        
        SDWebImageManager.shared().loadImage(with: monster.怪兽立绘, options: SDWebImageOptions.allowInvalidSSLCertificates, progress: { receivedSize, expectedSize, targetURL in
            
            KSLog("download launch image: receivedSize = %d, expectedSize = %d", receivedSize, expectedSize)
            
            loading.text = String(format: "%.2f%%", Double(receivedSize) / Double(expectedSize) * 100)
            
        }, completed: { (image: UIImage?, data: Data?, error: Error?, cacheType: SDImageCacheType, finished: Bool, imageURL: URL?) in
            
            KSLog("download launch image: image = %@, error = %@, cacheType = %d, finished = %@, imageURL = %@", NSStringFromCGSize(image?.size ?? CGSize.zero), (error?.localizedDescription ?? "nil"), (cacheType.rawValue), finished.description, (imageURL?.absoluteString ?? "unknown"))
            
            if error != nil {
                loading.text = "下载出错!"
                return
            }
            loading.isHidden = true
            
            let newImage = UIImage(cgImage: image!.cgImage!, scale: 0.2, orientation: .up)
            self["卡片头部/形象"].first?.sprite?.texture = SKTexture(image: newImage)
        })
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        view.removeGestureRecognizer(pan)
        view.removeGestureRecognizer(tap)
    }
    
    @objc func onTapGesture(_ recognizer: UITapGestureRecognizer) {
        
        let position = recognizer.location(in: self)!
        
        if nodes(at: position).contains(where: { $0.name == "形象" }) == false {
            return
        }
        
        if let scene = fromScene {
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
            return
        }
                
        if let from = userData?["from scene"] as? String {
            
            if from == "SKPackage" {
                let scene = SKScene(fileNamed: "SKPackage")!
                scene.scaleMode = .aspectFill
                scene.userData = userData
                view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
            } else if from == "SKSealCard" {
                let scene = SKScene(fileNamed: "SKWorld")!
                scene.scaleMode = .aspectFill
                scene.userData = userData
                view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
            }
        }
    }
    
    @objc private func onPanGesture(_ recognizer: UIPanGestureRecognizer) {
        
        let offsetY = recognizer.translation(in: view).y * scene_per_screen
        
        var targetY = carema.position.y + offsetY
        
        let min : CGFloat = scene_top_border - scene_bottom_border - cardHead.calculateAccumulatedFrame().size.height - cardBody.calculateAccumulatedFrame().size.height - cardFoot.calculateAccumulatedFrame().size.height
        if targetY < min {
            targetY = min
        }
        
        let max : CGFloat = 0
        if targetY > max {
            targetY = max
        }
        
        carema.position = CGPointMake(0, targetY)
        background.position = carema.position
        
        recognizer.setTranslation(CGPoint.zero, in: view)
    }
}
