//
//  SKPlayStone.swift
//  SpriteKitDemo
//
//  Created by weizhen on 2017/10/31.
//  Copyright © 2017年 weizhen. All rights reserved.
//

import SpriteKit

class SKPlayStone: SKScene, SLNMatrixDelegate, SceneClickableType {
    
    /// 当前队伍
    private var team = SLTeam()
    
    /// `cropNode`的子节点, 用于显示符石矩阵, 超出`maskNode`的部分将会隐藏
    private var matrixNode : SKPlayStoneMatrix!
    
    /// 首消符石
    private var stonesAtFirst = [SLElement : Int]()
    
    /// 累积符石
    private var stonesAtWhole = [SLElement : Int]()
    
    /// 连击数目
    private var combo = 0 {
        didSet {
            let label = self.labelNode(withName: "summary/combos/label")!
            label.text = String(combo)
            label.run(SKAction.sequence([SKAction.scale(to: 1.2, duration: 0.15), SKAction.scale(to: 1.0, duration: 0.10)]))
        }
    }
    
    /// 移动符石时, 交换的次数. 如果值为0, 不认为当前进行的移动符石的操作
    private var steps = 0 {
        didSet {
            let label = labelNode(withName: "summary/steps/label")!
            label.text = String(steps)
            label.run(SKAction.sequence([SKAction.scale(to: 1.2, duration: 0.15), SKAction.scale(to: 1.0, duration: 0.10)]))
        }
    }
    
    /// 天降符石的次数
    private var falls = 0 {
        didSet {
            let label = labelNode(withName: "summary/falls/label")!
            label.text = String(falls)
            label.run(SKAction.sequence([SKAction.scale(to: 1.2, duration: 0.15), SKAction.scale(to: 1.0, duration: 0.10)]))
        }
    }
    
    /// 菜单
    private let menuLayer = SKMenuLayer(identifies: [.replay, .stones, .cards, .cancel])
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // 构造队伍
        let memberNodes = self["team/member"] as! [SKSpriteNode]
        
        team.loadConfiguration()
        
        for index in 0 ..< 6 {
            if let character = team[index] {
                memberNodes[index].texture = SLGloabls.avatarTextures["icon_\(character.no)@2x.png"]
            } else {
                memberNodes[index].texture = SKTexture(imageNamed: "item_null")
            }
        }
        
        // 构造面板
        
        matrixNode = SKPlayStoneMatrix(team: team)
        matrixNode.delegate = self
        
        let maskNode = SKShapeNode(rectOf: matrixNode.mapSize)
        maskNode.fillColor = SKColor.black
        maskNode.strokeColor = SKColor.black
        
        let cropNode = SKCropNode()
        cropNode.maskNode = maskNode
        cropNode.position = CGPoint(x: 0, y: -105)
        cropNode.addChild(matrixNode)
        
        let stonesBoard = childNode(withName: "stones")!
        stonesBoard.addChild(cropNode)
        
        // 布局符石
        matrixNode.reset(animated: false)
    }
    
    func scene(_ scene: SKScene, click button: SKButton) {
        
        if button.name == "settings" {
            menuLayer.addTarget(self, action: #selector(selectMenu(_:)))
            camera?.addChild(menuLayer)
            return
        }
    }
    
    @objc func selectMenu(_ menu: SKMenu) {
        
        menuLayer.removeFromParent()
        
        if menu.identify == .replay {
           
            matrixNode.reset()
            
            return
        }
        
        if menu.identify == .cards {
            
            let scene = SKScene(fileNamed: "SKShowTeam")!
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
            
            return
        }
        
        if menu.identify == .stones {
            
            let scene = SKScene(fileNamed: "SKEditStone")!
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
            
            return
        }
        
        if menu.identify == .about {
           
            return
        }
        
        if menu.identify == .cancel {

            return
        }
        
        return
    }
    
    func matrix(_ sender: SKPlayStoneMatrix, swapAtIndex index: Int) {
        
        if index == 1 {
            
            falls = 0
            combo = 0
            
            let labels = self["removed/element/label"] as! [SKLabelNode]
            for index in 0 ... 5 {
                labels[index].text = "首消 | 累积"
            }
            stonesAtFirst.removeAll()
            stonesAtWhole.removeAll()
        }
        
        steps = index
    }
    
    func matrix(_ sender: SKPlayStoneMatrix, boomAtIndex index: Int) {
        
        let combo = sender.allCombos[index]
        
        /* combo at first and whole */
        self.combo = index + 1
        
        /* stone at first and whole */
        let stoneType = combo.first!.object.type
        var countAtFirst = self.stonesAtFirst[stoneType] ?? 0
        
        if falls == 0 {
            countAtFirst += combo.count
            self.stonesAtFirst[stoneType] = countAtFirst
        }
        
        var countAtWhole = self.stonesAtWhole[stoneType] ?? 0
        countAtWhole += combo.count
        self.stonesAtWhole[combo.first!.object.type] = countAtWhole
        
        let label = self["removed/element/label"][stoneType.rawValue] as! SKLabelNode
        label.text = "\(countAtFirst) | \(countAtWhole)"
    }
    
    func matrix(_ sender: SKPlayStoneMatrix, fallAtIndex index: Int) {
        falls += 1
    }
    
    func matrix(_ sender: SKPlayStoneMatrix, boomAndFall finished: Bool) {
        
    }
}
