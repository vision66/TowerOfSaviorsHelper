//
//  SKCharacter.swift
//  SaintLisa
//
//  Created by weizhen on 2017/9/26.
//  Copyright © 2017年 weizhen. All rights reserved.
//

import SpriteKit

class SKCharacter: SKScene, SceneClickableType {
    
    private lazy var tap = UITapGestureRecognizer(target: self, action: #selector(onTapGesture(_:)))
    
    var character : SLCharacter! = nil
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        if let node = childNode(withName: "star") as? SKSpriteNode {
            node.texture = SKTexture(imageNamed: "card_star_\(character.star)")
        }
        
        if let node = self.childNode(withName: "image") as? SKSpriteNode {
            node.texture = SKTexture(imageNamed: "card_scene")
        }
        
        if let node = childNode(withName: "race_icon") as? SKSpriteNode {
            node.texture = SKTexture(imageNamed: "card_race_\(character.race.rawValue)")
        }
        
        if let node = childNode(withName: "attribute") as? SKSpriteNode {
            node.texture = SKTexture(imageNamed: "card_attribute_\(character.attribute.rawValue)")
        }
        
        if let node = childNode(withName: "name") as? SKLabelNode {
            node.text = character.name
        }
        
        if let node = childNode(withName: "size") as? SKLabelNode {
            node.text = "\(character.size)"
        }
        
        if let node = childNode(withName: "max_level") as? SKLabelNode {
            node.text = "\(character.maxLevel)"
        }
        
        if let node = childNode(withName: "life") as? SKLabelNode {
            node.text = "\(character.life)"
        }
        
        if let node = childNode(withName: "attack") as? SKLabelNode {
            node.text = "\(character.attack)"
        }
        
        if let node = childNode(withName: "recover") as? SKLabelNode {
            node.text = "\(character.recover)"
        }
        
        if let node = childNode(withName: "race") as? SKLabelNode {
            node.text = "\(character.race)"
        }
        
        if let node = childNode(withName: "leader_name") as? SKLabelNode {
            node.text = "\(character.leaderName)"
        }
        
        if let node = childNode(withName: "leader_desc") as? SKLabelNode {
            node.text = "\(character.leaderDesc)"
        }
        
        if let node = childNode(withName: "no") as? SKLabelNode {
            node.text = "No.\(character.no)"
        }
        
        view.addGestureRecognizer(tap)
        
        let loading = childNode(withName: "loading") as! SKLabelNode
        
        /// 从某处获取卡片信息, 并下载图片
        SDWebImageManager.shared().downloadImage(with: URL(string: character.image), options: SDWebImageOptions.allowInvalidSSLCertificates, progress: { (receivedSize: Int, expectedSize: Int) in
            
            KSLog("download launch image: receivedSize = %d, expectedSize = %d", receivedSize, expectedSize)
            
            loading.text = String.init(format: "%.2f%%", Double(receivedSize) / Double(expectedSize) * 100)
            
        }, completed: { (image: UIImage?, error: Error?, cacheType: SDImageCacheType, finished: Bool, imageURL: URL?) in
            
            KSLog("download launch image: image = %@, error = %@, cacheType = %d, finished = %@, imageURL = %@", NSStringFromCGSize(image?.size ?? CGSize.zero), (error?.localizedDescription ?? "nil"), (cacheType.rawValue), finished.description, (imageURL?.absoluteString ?? "unknown"))
            
            if error != nil {
                loading.text = "下载出错!"
                return
            }
            loading.isHidden = true
            
            let newImage = image!.scaleAspectFillSize(CGSizeMake(320, 225))
            
            self.character.image = imageURL!.absoluteString
            
            if let node = self.childNode(withName: "image") as? SKSpriteNode {
                node.texture = SKTexture(image: newImage)
            }
        })
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        view.removeGestureRecognizer(tap)
    }
    
    func scene(_ scene: SKScene, click button: SKButton) {
        KSLog("%@ %@", self, #function)
    }
    
    @objc func onTapGesture(_ recognizer: UITapGestureRecognizer) {
        
        let position = recognizer.location(in: self)!
        
        if nodes(at: position).contains(where: { $0.name == "image" }) == false {
            return
        }
                
        if let from = userData?["from scene"] as? String, from == "SKPackage" {
            let scene = SKScene(fileNamed: "SKPackage")!
            scene.scaleMode = .aspectFill
            scene.userData = userData
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
        }
    }
}
