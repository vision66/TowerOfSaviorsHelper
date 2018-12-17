//
//  SKParameters.swift
//  TowerOfSaviors
//
//  Created by weizhen on 2018/10/25.
//  Copyright © 2018 aceasy. All rights reserved.
//

import UIKit

class SKParameters: SKScene, SceneClickableType {
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        if let button = self["背景音乐/图标"].first as? SKButton {
            button.setTexture(SKTexture(imageNamed: "背景音乐_启用"), for: .selected)
            button.isSelected = (SKBackgroundMusicPlayer.shared.volume != 0.0)
        }
        
        if let button = self["游戏音效/图标"].first as? SKButton {
            button.setTexture(SKTexture(imageNamed: "游戏音效_启用"), for: .selected)
            button.isSelected = (SKSoundEffect.shared.volume != 0.0)
        }
        
        if let button = self["锁定转珠时间/使能开关"].first as? SKButton {
            button.setTexture(SKTexture(imageNamed: "使能开关_开启"), for: .selected)
            button.isSelected = UserDefaults.standard.bool(forKey: steps_time_locked)
        }
        
        if let button = self["锁定敌人血条/使能开关"].first as? SKButton {
            button.setTexture(SKTexture(imageNamed: "使能开关_开启"), for: .selected)
            button.isSelected = UserDefaults.standard.bool(forKey: enemy_life_locked)
        }
        
        if let button = self["强化动画/使能开关"].first as? SKButton {
            button.setTexture(SKTexture(imageNamed: "使能开关_开启"), for: .selected)
        }
        
        if let button = self["进化动画/使能开关"].first as? SKButton {
            button.setTexture(SKTexture(imageNamed: "使能开关_开启"), for: .selected)
        }
        
        if let slider = self["背景音乐/滑动器"].first as? SKSlider {
            slider.minimumValue = 0.0
            slider.maximumValue = 1.0
            slider.currentValue = SKBackgroundMusicPlayer.shared.volume.asCGFloat
            slider.addTarget(self, action: #selector(musicVolumeChanged(_:)), for: .valueChanged)
        }
        
        if let slider = self["游戏音效/滑动器"].first as? SKSlider {
            slider.minimumValue = 0.0
            slider.maximumValue = 1.0
            slider.currentValue = SKSoundEffect.shared.volume.asCGFloat
            slider.addTarget(self, action: #selector(soundVolumeChanged(_:)), for: .valueChanged)
        }
    }
    
    func scene(_ scene: SKScene, click button: SKButton) {
        
        guard let title = button.parent?.name else { return }
        
        if title == "背景音乐" {
            
            let slider = self["背景音乐/滑动器"].first as? SKSlider
            
            if button.isSelected {
                button.isSelected = false
                slider?.currentValue = 0.0
                SKBackgroundMusicPlayer.shared.volume = 0.0
            } else {
                button.isSelected = true
                slider?.currentValue = 1.0
                SKBackgroundMusicPlayer.shared.volume = 1.0
            }
            
            return
        }
        
        if title == "游戏音效" {
            
            let slider = self["游戏音效/滑动器"].first as? SKSlider
            
            if button.isSelected {
                button.isSelected = false
                slider?.currentValue = 0.0
                SKSoundEffect.shared.volume = 0.0
            } else {
                button.isSelected = true
                slider?.currentValue = 1.0
                SKSoundEffect.shared.volume = 1.0
            }
            
            return
        }
        
        if title == "锁定转珠时间" {
            let isSelected = button.isSelected
            button.isSelected = !isSelected
            UserDefaults.standard.set(!isSelected, forKey: steps_time_locked)
            return
        }
        
        if title == "锁定敌人血条" {
            let isSelected = button.isSelected
            button.isSelected = !isSelected
            UserDefaults.standard.set(!isSelected, forKey: enemy_life_locked)
            return
        }
        
        if title == "强化动画" {
            let isSelected = button.isSelected
            button.isSelected = !isSelected
            // TODO: something
            return
        }
        
        if title == "进化动画" {
            let isSelected = button.isSelected
            button.isSelected = !isSelected
            // TODO: something
            return
        }
        
        if button.name == "能量" {
            let scene = SKScene(fileNamed: "SKWorld")!
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
            return
        }
    }
    
    @objc func musicVolumeChanged(_ sender: SKSlider) {
        
        let button = self["背景音乐/图标"].first! as! SKButton
        
        if sender.currentValue == 0.0 && button.isSelected == true {
            button.isSelected = false
        } else if sender.currentValue != 0.0 && button.isSelected == false {
            button.isSelected = true
        }

        SKBackgroundMusicPlayer.shared.volume = sender.currentValue.asFloat
    }
    
    @objc func soundVolumeChanged(_ sender: SKSlider) {
        
        let button = self["游戏音效/图标"].first! as! SKButton 
        
        if sender.currentValue == 0.0 && button.isSelected == true {
            button.isSelected = false
        } else if sender.currentValue != 0.0 && button.isSelected == false {
            button.isSelected = true
        }
        
        SKSoundEffect.shared.volume = sender.currentValue.asFloat
    }
}
