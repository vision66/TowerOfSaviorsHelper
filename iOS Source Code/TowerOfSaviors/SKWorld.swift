//
//  SKWorld.swift
//  SaintLisa
//
//  Created by weizhen on 2017/9/19.
//  Copyright © 2017年 weizhen. All rights reserved.
//

import SpriteKit

/// 地图偏移
enum AnchorPoint : CGFloat {
    case 第九封印 = -1600
    case 第八封印 = -880
    case 元素领域 = -160
    case 玩家国度 = 560
    case 第十封印 = 1555
}

/// 上次离开本界面时地图的偏移. 作为全局变量来持久化数据
fileprivate var lastAnchorPoint = AnchorPoint.元素领域.rawValue

/// 主界面, 各个项目的主要入口都在这里
class SKWorld: SKScene, SceneClickableType {
    
    /// 拖拽地图. 位移大于特定值时, 移动到下个场景; 反之, 回到原处
    private lazy var dragRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onDragGesture(_:)))
    
    /// 地图
    private lazy var world = self["世界地图"].first!

    /// 地图偏移
    private let allAnchorPoints = [AnchorPoint.第九封印, .第八封印, .元素领域, .玩家国度, .第十封印]
    
    /// 拖拽地图时, 手指按下时, 地图的位置
    private var beganPoint = CGPoint.zero
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
                
        // 偏移地图
        world.position = CGPointMake(0, lastAnchorPoint)
        
        // 播放背景音乐
        SKBackgroundMusicPlayer.Key.夜幕下的旅途.play()
        
        // 启用拖拽手势
        view.addGestureRecognizer(dragRecognizer)
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        view.removeGestureRecognizer(dragRecognizer)
    }
    
    func scene(_ scene: SKScene, click button: SKButton) {
        
        if button.name == "能量" {
            lastAnchorPoint = AnchorPoint.元素领域.rawValue
            world.run(SKAction.moveTo(y: lastAnchorPoint, duration: 0.3))
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
            scene.userData = ["地点名称": button.name!]
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
            return
        }
    }
    
    @objc private func onDragGesture(_ recognizer: UIPanGestureRecognizer) {
        
        // 手指按下时, 记录当前地图位置. 假定此时地图静止
        if recognizer.state == .began {
            beganPoint = world.position
        }
        
        // 手指拖动时, 根据手指偏移量, 移动地图
        if recognizer.state == .changed {
            
            let offsetY = recognizer.translation(in: view).y * scene_per_screen
            
            var targetY = world.position.y - offsetY
            
            if targetY < allAnchorPoints.first!.rawValue {
                targetY = allAnchorPoints.first!.rawValue
            }
            
            if targetY > allAnchorPoints.last!.rawValue {
                targetY = allAnchorPoints.last!.rawValue
            }
            
            world.position = CGPointMake(world.position.x, targetY)
        }
        
        // 手指松开时, 地图应该自动移动, 以调整到适当位置
        if recognizer.state == .ended {
            
            var nextPosition : CGFloat
            if abs(world.position.y - beganPoint.y) < 100 {
                nextPosition = beganPoint.y
            } else if world.position.y > beganPoint.y {
                nextPosition = allAnchorPoints.first(where: { $0.rawValue > beganPoint.y })!.rawValue
            } else {
                nextPosition = allAnchorPoints.reversed().first(where: { $0.rawValue < beganPoint.y })!.rawValue
            }
            
            world.run(SKAction.moveTo(y: nextPosition, duration: 0.3))
            lastAnchorPoint = nextPosition
        }
        
        recognizer.setTranslation(CGPoint.zero, in: view)
    }
}
