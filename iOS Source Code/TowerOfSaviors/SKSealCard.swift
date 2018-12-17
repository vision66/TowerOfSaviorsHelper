//
//  SKSealCard.swift
//  TowerOfSaviors
//
//  Created by weizhen on 2018/10/26.
//  Copyright © 2018 aceasy. All rights reserved.
//

import UIKit

class SKSealCard: SKScene {
    
    /// 被抽出的卡片
    private lazy var monsterCard = self["抽卡盒子/卡片"].first! as! SKMonsterCard
    
    /// 抽卡机
    private lazy var sealBox = self["抽卡盒子"].first! as! SKSpriteNode

    /// 识别拖拽
    private lazy var dragRecognizer = UIPanGestureRecognizer(target: self, action: #selector(dragGesture(_:)))
    
    /// 拖拽触发时, 按住了卡片
    private var cardIsDragging : Bool = false
    
    /// 拖拽卡片时, 最多移动到这个位置
    private let endedline : CGFloat = -360
    
    /// 卡片的初始位置
    private let beganline : CGFloat = 0
    
    /// 记录上一次播放音效的位置, 每隔20px会播放一次[抽卡移动]的音效
    private var lastSoundPosition : CGFloat = 0
    
    /// 缓存资源
    private var queue = DispatchQueue(label: "com.aceasy.towerofsaviors.SKSealCard")
    
    /// 即将被抽出的卡片, 很明显, 在程序逻辑内, 这个卡片在进入此场景时就已经确定了
    private var monster : SLMonster = {
        let random = Int(arc4random()) % SLGloabls.shared.monsters.count
        let monster = SLGloabls.shared.monsters[random]
        return monster
    }()
    
    /// 下一个场景
    private var nextScene : SKScene!
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        self["摄像机/上边框"].first?.position = CGPointMake(0, scene_top_border)
        self["摄像机/下边框"].first?.position = CGPointMake(0, scene_bottom_border)        
        self["抽卡盒子"].first?.position = CGPointMake(0, scene_top_border)
        
        SKBackgroundMusicPlayer.shared.stop()
        
        monsterCard.setStar(monster.怪兽星级)
        
        view.addGestureRecognizer(dragRecognizer)
        
        queue.async {
            let scene = SKScene(fileNamed: "SKMonster") as! SKMonster
            scene.monster = self.monster
            scene.scaleMode = .aspectFill
            scene.userData = ["from scene": "SKSealCard"]
            self.nextScene = scene
        }
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
    }
    
    /// 抽卡时, 抽动的音效
    private let sealMoving = SKAction.playSoundEffect(SKSoundEffect.Key.sealMoving)
    
    override func update(_ currentTime: TimeInterval) {
        
        // 如果成功抽出卡片, 这个值为false
        if dragRecognizer.isEnabled {
            
            let monsterCard_position_y = monsterCard.position.y
            
            if abs(monsterCard_position_y - lastSoundPosition) > 30 {
                run(sealMoving)
                lastSoundPosition = monsterCard_position_y
            }
            
            monsterCard.setProgress((beganline - monsterCard_position_y) / (beganline - endedline))
        }
    }
    
    @objc func dragGesture(_ recognizer: UIPanGestureRecognizer) {
        
        if recognizer.state == .began && cardIsDragging == false {
            
            guard let location = recognizer.location(in: self) else { return }
            
            guard nodes(at: location).contains(monsterCard) else { return }
            
            cardIsDragging = true
            
            return
        }
        
        if recognizer.state == .changed && cardIsDragging == true {
            
            let offset_0 = CGPoint.zero
            let offset_d = recognizer.translation(in: view!)
            let convert_0 = convertPoint(fromView: offset_0)
            let convert_d = convertPoint(fromView: offset_d)
            let moveby_y = convert_d.y - convert_0.y
            
            let old_y = monsterCard.position.y
            var new_y = old_y + moveby_y
            if  new_y < endedline {
                new_y = endedline
            }
            
            monsterCard.position = CGPointMake(0, new_y)
            
            recognizer.setTranslation(.zero, in: view!)
            
            return
        }
        
        if recognizer.state == .ended && cardIsDragging == true {
            
            cardIsDragging = false
            
            let last_y = monsterCard.position.y

            if last_y > endedline + 50 {
                let back = SKAction.moveTo(y: beganline, duration: 0.5)
                monsterCard.run(back)
            } else {
                
                dragRecognizer.isEnabled = false
                view?.removeGestureRecognizer(dragRecognizer)
                
                let sound = SKAction.playSoundEffect(SKSoundEffect.Key.sealMoveOut)
                run(sound)
                
                let down = SKAction.moveTo(y: scene_bottom_border - scene_top_border - monsterCard.size.height / 2, duration: 0.2)
                let wait = SKAction.wait(forDuration: 0.1)
                let remo = SKAction.removeFromParent()
                monsterCard.run(SKAction.sequence([down, wait, remo])) {
                    
                    self.insertChild(self.monsterCard, at: 1)
                    
                    let move = SKAction.moveTo(y: 0, duration: 0.5)
                    move.timingMode = .easeIn
                    let zoom = SKAction.scale(to: 1.2, duration: 0.5)
                    zoom.timingMode = .easeIn
                    
                    let moveAndZoom = SKAction.group([move, zoom])
                   
                    let wait = SKAction.wait(forDuration: 2)
                    let glow = SKAction.run { self.monsterCard.play() }
                    
                    let waitAndGlow = SKAction.group([wait, glow])
                    
                    self.monsterCard.run(SKAction.sequence([moveAndZoom, waitAndGlow])) {
                        
                        self.view?.presentScene(self.nextScene, transition: SKTransition.fade(withDuration: 2.0))
                    }
                }
            }
            
            return
        }
    }
}
