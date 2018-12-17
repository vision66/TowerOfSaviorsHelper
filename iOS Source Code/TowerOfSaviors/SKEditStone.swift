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
    
    /// [元素类型]选项的数组
    private lazy var elementTypeNodes = self["元素类型/option"]
    
    /// 当前选中的[元素类型]
    var selectedElement : SLElementType = .水 {
        didSet {
            let newNode = elementTypeNodes[selectedElement.rawValue]
            let moveAct = SKAction.moveTo(x: newNode.position.x, duration: 0.2)
            self["元素类型/focus"].first?.run(moveAct)
        }
    }
    
    /// [元素状态]选项的数组
    private lazy var statusTypeNodes = self["元素状态/option"]
    
    /// 当前选中的[元素状态]
    var selectedStatus : SLElementStatus = .普通 {
        didSet {
            let newNode = statusTypeNodes[selectedStatus.rawValue]
            let moveAct = SKAction.moveTo(x: newNode.position.x, duration: 0.2)
            self["元素状态/focus"].first?.run(moveAct)
        }
    }
    
    /// [符石状态]选项的数组
    private lazy var stoneTypeNodes = self["符石状态/option"]
    
    /// 当前选中的[符石状态]
    var selectedStone : SLRunestoneStatus = .正常 {
        didSet {
            let newNode = stoneTypeNodes[selectedStone.rawValue]
            let moveAct = SKAction.moveTo(x: newNode.position.x, duration: 0.2)
            self["符石状态/focus"].first?.run(moveAct)
        }
    }
    
    /// 位于矩阵上的30颗符石
    private var stones = [SKRunestone]()
    
    /// 上一次变换的符石, 防止重复转换, 以减少触发的次数
    private var lastStone : SKRunestone? = nil
    
    /// 菜单
    private lazy var menuLayer = self["菜单"].first as! SKSpriteNode
    
    /// 手指在符石矩阵上滑动
    private lazy var pan = UIPanGestureRecognizer(target: self, action: #selector(matrixTouch(_:)))
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        /// 显示符石矩阵
        let matrixNode = self["stones/matrix"].first! as! SKTileMapNode
        matrixNode.isUserInteractionEnabled = true
        
        /// 构造并填充符石
        let cols = matrixNode.numberOfColumns
        for index in 0 ..< 30 {
            let node = SKRunestone(element: .水, status: .普通, stone: .正常)
            node.position = matrixNode.centerOfTile(atColumn: index % cols, row: index / cols)
            matrixNode.addChild(node)
            stones.append(node)
        }
        
        if let matrixData = UserDefaults.standard.array(forKey: "stones matrix") as? [[String: Int]] {
            for (index, dict) in matrixData.enumerated() {
                let element = SLElementType(rawValue: dict["元素属性"]!)!
                let status = SLElementStatus(rawValue: dict["元素状态"]!)!
                let stone = SLRunestoneStatus(rawValue: dict["符石状态"]!)!
                stones[index].change(element: element, status: status, stone: stone, animation: false)
            }
        }
        
        view.addGestureRecognizer(pan)
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        view.removeGestureRecognizer(pan)
    }
    
    @objc func matrixTouch(_ recognizer: UIPanGestureRecognizer) {
        
        if recognizer.state == .began {
            lastStone = nil
            return
        }
        
        if recognizer.state == .ended {
            lastStone = nil
            return
        }
        
        if recognizer.state == .changed {

            let location = recognizer.location(in: self)!
            
            guard let node = atPoint(location) as? SKRunestone else {
                //KSLog("not touch any stone")
                return
            }
            
            if lastStone === node {
                //KSLog("did handle this stone")
                return
            }
            
            lastStone = node
            node.change(element: selectedElement, status: selectedStatus, stone: selectedStone)
            run(SKAction.playSoundEffect(.stoneMove))

            return
        }
    }
    
    func scene(_ scene: SKScene, click button: SKButton) {
        
        if let index = elementTypeNodes.index(of: button) {
            selectedElement = SLElementType(rawValue: index)!
            return
        }
        
        if let index = statusTypeNodes.index(of: button) {
            selectedStatus = SLElementStatus(rawValue: index)!
            return
        }
        
        if let index = stoneTypeNodes.index(of: button) {
            selectedStone = SLRunestoneStatus(rawValue: index)!
            return
        }
        
        if button.name == "设置" {
            menuLayer.isHidden = false
            return
        }
        
        if button.name == "导入" {
            let show = ImagePickerController()
            show.sourceType = .photoLibrary
            show.delegate = self
            view?.viewController?.present(show, animated: true, completion: nil)
            return
        }
        
        if button.name == "item" {
            
            menuLayer.isHidden = true
            
            let title = button.firstLabel!.text!
            
            if title == "编辑完成" {
                
                save()
                
                let scene = SKScene(fileNamed: "SKPlayStone")!
                scene.scaleMode = .aspectFill
                view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
                
                return
            }
            
            if title == "编辑队伍" {

                save()
                
                let scene = SKScene(fileNamed: "SKSelectMemeber")!
                scene.scaleMode = .aspectFill
                view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
                
                return
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let ih = image.size.height * image.scale
        let iw = image.size.width * image.scale
        let rect = CGRectMake(0, 0.5-480*iw/ih/320/2, 1.0, 268*iw/ih/320)
        
        let texture = SKTexture(image: image)

        let snapNode = self["快照"].first as? SKSpriteNode
        snapNode?.texture = SKTexture(rect: rect, in: texture)
        snapNode?.size = CGSizeMake(80, 67)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func save() {
        let matrixData = stones.map { ["元素属性" : $0.元素属性.rawValue, "元素状态" : $0.元素状态.rawValue, "符石状态" : $0.符石状态.rawValue] }
        UserDefaults.standard.set(matrixData, forKey: "stones matrix")
    }
}
