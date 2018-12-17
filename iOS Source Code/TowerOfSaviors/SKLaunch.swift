//
//  SKLaunch.swift
//  SaintLisa
//
//  Created by weizhen on 2017/9/19.
//  Copyright © 2017年 weizhen. All rights reserved.
//

import SpriteKit

/// 先显示[载入中...], 此时将资源加载到内存中. 等待加载完毕后, 显示为[点击屏幕进入], 跳转到主界面
class SKLaunch: SKScene {
    
    /// 提示文字
    private lazy var blinkText = self["提示"].first as! SKLabelNode
    
    /// 下一个场景
    private var nextScene : SKScene!
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // 播放背景音乐
        SKBackgroundMusicPlayer.Key.日照间的旅程.play()
                
        let group = DispatchGroup()
        let queue = DispatchQueue.global()        
        KSLog("load ...")
        
        // 加载纹理素材
        group.enter()
        SLTextures.loadTextures { error in
            KSLog("load textures, ok")
            group.leave()
        }
        
        // 加载动画资源
        group.enter()
        SLAnimations.loadTextures { error in
            KSLog("load animations, ok")
            group.leave()
        }
        
        // 加载音效文件
        queue.async(group: group) {
            SKSoundEffect.shared.loadMetadata()
            KSLog("load sounds, ok")
        }
        
        // 加载怪兽资料
        queue.async(group: group) {
            SLGloabls.shared.loadMonsters()
            KSLog("load monsters, ok")
        }
        
        // 加载世界场景
        queue.async(group: group) {
            let scene = SKScene(fileNamed: "SKWorld")!
            scene.scaleMode = .aspectFill
            self.nextScene = scene
            KSLog("load world, ok")
        }
                
        // 全部加载完成
        group.notify(queue: DispatchQueue.main) {
            self.blinkText.text = "点击屏幕进入"
            KSLog("load all completion")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if blinkText.text == "点击屏幕进入" {
            SKSoundEffect.Key.buttonDown.play()
            view?.presentScene(nextScene, transition: SKTransition.fade(withDuration: 0.6))
        }
    }
}
