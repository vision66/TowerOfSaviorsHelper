//
//  SKLaunch.swift
//  SaintLisa
//
//  Created by weizhen on 2017/9/19.
//  Copyright © 2017年 weizhen. All rights reserved.
//

import SpriteKit

/// 先显示"载入中...", 此时将资源加载到内存中. 待加载完毕后, 显示为`点击屏幕进入`, 跳转到主界面
class SKLaunch: SKScene, SceneClickableType {
    
    private lazy var touchArea = childNode(withName: "touch_area") as! SKSpriteNode
    
    private lazy var blinkText = childNode(withName: "blink_text") as! SKLabelNode
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        touchArea.isHidden = true
        blinkText.text = "载入中..."
        
        let music = SKAudioNode(fileNamed: "日照间的旅程.m4a")
        music.autoplayLooped = true
        addChild(music)

        SLGloabls.setupResources(withCompletionHandler: loadingResourcesCompletion)
    }
    
    func scene(_ scene: SKScene, click button: SKButton) {
        
        if button.name == "touch_area" {
            let scene = SKScene(fileNamed: "SKWorld")!
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
            return
        }
    }
    
    func loadingResourcesCompletion() {
        touchArea.isHidden = false
        blinkText.text = "点击屏幕进入"
    }
}
