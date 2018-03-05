//
//  SKEditStone.swift
//  SpriteKitDemo
//
//  Created by weizhen on 2017/10/31.
//  Copyright © 2017年 weizhen. All rights reserved.
//

import SpriteKit

/// 编辑符石版面
class SKEditStone: SKScene, SceneClickableType, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private lazy var typeNodes = self["type/option"]
    
    var selectedType : SLElement = .水 {
        didSet {
            let newNode = typeNodes[selectedType.rawValue]
            let moveAct = SKAction.moveTo(x: newNode.position.x, duration: 0.2)
            childNode(withName: "type/focus")?.run(moveAct)
        }
    }
    
    private lazy var statusNodes = self["status/option"]
    
    var selectedStatus : SLElementStatus = .normal {
        didSet {
            let newNode = statusNodes[selectedStatus.rawValue]
            let moveAct = SKAction.moveTo(x: newNode.position.x, duration: 0.2)
            childNode(withName: "status/focus")?.run(moveAct)
        }
    }
    
    private lazy var overlayNodes = self["overlay/option"]
    
    var selectedOverlay : SLStoneOverlay = .normal {
        didSet {
            let newNode = overlayNodes[selectedOverlay.rawValue]
            let moveAct = SKAction.moveTo(x: newNode.position.x, duration: 0.2)
            childNode(withName: "overlay/focus")?.run(moveAct)
        }
    }
    
    /// 显示符石矩阵
    private var matrixNode : SKTileMapNode!
    
    /// 位于矩阵上的30颗符石
    private var stones = [SKElementStone]()
    
    /// 菜单
    private let menuLayer = SKMenuLayer(identifies: [.commit, .cancel])
    
    /// 手指在符石矩阵上滑动
    private lazy var pan = UIPanGestureRecognizer(target: self, action: #selector(self.scenePan(on:)))
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        matrixNode = childNode(withName: "stones/matrix") as? SKTileMapNode
        matrixNode.isUserInteractionEnabled = true
        
        /// 构造并填充符石
        let cols = matrixNode.numberOfColumns
        for index in 0 ..< 30 {
            let object = SLStone(type: .水)
            let stone = SKElementStone(stone: object)
            stone.position = matrixNode.centerOfTile(atColumn: index % cols, row: index / cols)
            matrixNode.addChild(stone)
            stones.append(stone)
        }
        
        if let matrixData = UserDefaults.standard.array(forKey: "stones matrix") as? [[String: Int]] {
            for (index, dict) in matrixData.enumerated() {
                let type = SLElement(rawValue: dict["type"]!)!
                let status = SLElementStatus(rawValue: dict["status"]!)!
                let overlay = SLStoneOverlay(rawValue: dict["overlay"]!)!
                let object = SLStone(type: type, status: status, overlay: overlay)
                stones[index].setStone(stone: object, animation: false)
            }
        }
        
        view.addGestureRecognizer(pan)
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        view.removeGestureRecognizer(pan)
    }
    
    @objc func scenePan(on recognizer: UIPanGestureRecognizer) {
        
        let location = recognizer.location(in: self)!
        let nodes = self.nodes(at: location)
        
        for node in nodes {
            
            guard let index = stones.index(where: { node === $0 }) else { continue }
            
            let stone = stones[index]
            
            if stone.object.type == selectedType && stone.object.status == selectedStatus && stone.object.overlay == selectedOverlay { continue }
            
            let object = SLStone(type: selectedType, status: selectedStatus, overlay: selectedOverlay)
            stones[index].setStone(stone: object)

            return
        }
    }
    
    func scene(_ scene: SKScene, click button: SKButton) {
        
        if let index = typeNodes.index(of: button) {
            selectedType = SLElement(rawValue: index)!
            return
        }
        
        if let index = statusNodes.index(of: button) {
            selectedStatus = SLElementStatus(rawValue: index)!
            return
        }
        
        if let index = overlayNodes.index(of: button) {
            selectedOverlay = SLStoneOverlay(rawValue: index)!
            return
        }
        
        if button.name == "settings" {
            menuLayer.addTarget(self, action: #selector(self.selectMenu(_:)))
            camera?.addChild(menuLayer)
            return
        }
        
        if button.name == "import" {
            let show = UIImagePickerController()
            show.sourceType = UIImagePickerControllerSourceType.photoLibrary
            show.delegate = self
            view?.viewController?.present(show, animated: true, completion: nil)
            UIApplication.shared.isStatusBarHidden = false
            return
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let ih = image.size.height * image.scale
        let iw = image.size.width * image.scale
        let rect = CGRectMake(0, 0.5-480*iw/ih/320/2, 1.0, 268*iw/ih/320)
        
        let texture = SKTexture(image: image)

        let snapNode = childNode(withName: "import_result") as? SKSpriteNode
        snapNode?.texture = SKTexture(rect: rect, in: texture)
        snapNode?.size = CGSizeMake(80, 67)
        
        picker.dismiss(animated: true, completion: {
            UIApplication.shared.isStatusBarHidden = true
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: {
            UIApplication.shared.isStatusBarHidden = true
        })
    }
    
    private func save() {
        let matrixData = stones.map { ["type" : $0.object.type.rawValue, "status" : $0.object.status.rawValue, "overlay" : $0.object.overlay.rawValue] }
        UserDefaults.standard.set(matrixData, forKey: "stones matrix")
    }
    
    @objc func selectMenu(_ menu: SKMenu) {
       
        menuLayer.removeFromParent()
        
        if menu.identify == .commit {
            
            save()
            
            let scene = SKScene(fileNamed: "SKPlayStone")!
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
            
            return
        }
        
        if menu.identify == .cards {
            
            save()
            
            let scene = SKScene(fileNamed: "SKEditTeam")!
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
            
            return
        }
        
        if menu.identify == .cancel {

            return
        }
    }
}
