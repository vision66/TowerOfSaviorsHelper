//
//  SKWorld.swift
//  SaintLisa
//
//  Created by weizhen on 2017/9/19.
//  Copyright © 2017年 weizhen. All rights reserved.
//

import SpriteKit

/// 主界面, 各个项目的主要入口都在这里.
class SKWorld: SKScene, SceneClickableType {
    
    /// 拖拽地图. 位移大于特定值时, 移动到下个场景; 反之, 回到原处
    private lazy var pan = UIPanGestureRecognizer(target: self, action: #selector(onPanGesture(_:)))
    
    /// -1067 九封; -346 八封; 373 塔; 1066 飞艇
    enum WorldKeyPoint : CGFloat {
        case the9thSeal = -1067
        case the8thSeal = -346
        case theTower = 373
        case theAirship = 1066
    }
    private let listPoint : [WorldKeyPoint] = [.theTower]
    //private let listPoint : [CGFloat] = [-1067, -346, 373, 1066]
    
    /// 地图
    private lazy var world = childNode(withName: "世界")!
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        let music = SKAudioNode(fileNamed: "夜幕下的旅途.m4a")
        music.autoplayLooped = true
        addChild(music)
        
        if let position = SLGloabls.offsetOfWorldMap {
            world.position = position
        }
        
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
            world.run(SKAction.moveTo(y: WorldKeyPoint.theTower.rawValue, duration: 0.3))
            return
        }
        
        if button.name == "寒霜冰川" ||
            button.name == "炽热荒土" ||
            button.name == "神木森林" ||
            button.name == "圣光之城" ||
            button.name == "暗夜深渊" ||
            button.name == "以诺塔" ||
            button.name == "天门长廊" ||
            button.name == "净水幻泉" ||
            button.name == "星云神坛" ||
            button.name == "嗜血渊狱" ||
            button.name == "迷锁门廊" ||
            button.name == "圣城尼比鲁" ||
            button.name == "空幻大堂" ||
            button.name == "圣殿传送阵" ||
            button.name == "神域大殿" ||
            button.name == "古神遗迹" ||
            button.name == "旅人的记忆" ||
            button.name == "遗迹特许" {
            let scene = SKScene(fileNamed: "SKStoryList")!
            scene.scaleMode = .aspectFill
            scene.userData = ["地点": button.name!]
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
            return
        }
    }
    
    private var beganPoint : CGPoint = .zero
    
    @objc private func onPanGesture(_ recognizer: UIPanGestureRecognizer) {
        
        if recognizer.state == .began {
            beganPoint = world.position
        }
        
        let offsetY = recognizer.translation(in: view).y * scene_width / view_width
        
        var targetY = world.position.y - offsetY
        
        if targetY < listPoint.first!.rawValue {
            targetY = listPoint.first!.rawValue
        }
        
        if targetY > listPoint.last!.rawValue {
            targetY = listPoint.last!.rawValue
        }
        
        world.position = CGPointMake(world.position.x, targetY)
        
        if recognizer.state == .ended {
            
            if abs(world.position.y - beganPoint.y) > 100 {
                
                var nextPoint : CGFloat
                
                if world.position.y - beganPoint.y > 0 {
                    nextPoint = listPoint.first(where: { $0.rawValue > beganPoint.y })!.rawValue
                } else {
                    nextPoint = listPoint.reversed().first(where: { $0.rawValue < beganPoint.y })!.rawValue
                }
                
                world.run(SKAction.moveTo(y: nextPoint, duration: 0.3))
                SLGloabls.offsetOfWorldMap = CGPointMake(0, nextPoint)
            }
            else {
                world.run(SKAction.moveTo(y: beganPoint.y, duration: 0.3))
                SLGloabls.offsetOfWorldMap = beganPoint
            }
        }
        
        recognizer.setTranslation(CGPoint.zero, in: view)
    }
}
