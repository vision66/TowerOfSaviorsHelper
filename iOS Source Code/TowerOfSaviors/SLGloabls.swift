//
//  SLGloabls.swift
//  helper
//
//  Created by weizhen on 2018/1/22.
//  Copyright © 2018年 aceasy. All rights reserved.
//

import UIKit
import SpriteKit

/// 屏幕的宽度
let screen_width : CGFloat = UIScreen.main.bounds.size.width

/// 屏幕的高度
let screen_height : CGFloat = UIScreen.main.bounds.size.height

/// 场景宽度
let scene_width : CGFloat = 320

/// 场景高度
let scene_height : CGFloat = scene_width * screen_height / screen_width

/// 场景与屏幕的比率
let scene_per_screen = scene_width / screen_width

/// 上边框锚点的位置
let scene_top_border = scene_height / 2 - 24

/// 下边框锚点的位置
let scene_bottom_border = 24 - scene_height / 2

/// 状态栏锚点的位置
let statusbar_position_y = scene_height / 2 - 80

/// 标签栏锚点的位置
let bottombar_position_y = 80 - scene_height / 2

/// 包裹中, 卡片矩阵的每一个单元格的宽、高
let package_tile_size : CGFloat = 60

/// 包裹中, 卡片之间的距离. value = 10
let package_cell_space : CGFloat = (scene_width - package_tile_size * 5) / 2

/// 包裹中, 卡片的宽、高. 50x50
let package_cell_size : CGSize = CGSizeMake(package_tile_size - package_cell_space, package_tile_size - package_cell_space)

/// 锁定敌人血量, 无论如何被攻击都不会损失生命. UserDefault的Key, value是Bool类型
let enemy_life_locked : String = "锁定敌人血量"

/// 锁定转珠时间, UserDefault的Key, value是Bool类型
let steps_time_locked : String = "锁定转珠时间"

/// 没有影响的条件下, 转珠时间为5s
let steps_base_time : TimeInterval = 5.0

/// 软件中所有需要的资源, 包括纹理、帧动画、声音等等. 与Assets.xcassets的差异在于, 这些资源没有用在sks文件中, 一般用于动态生成的SKSpriteNode
class SLGloabls {
    
    /// 单例
    static let shared = SLGloabls()
    
    /// 怪兽资料
    var monsters = [SLMonster]()
    
    /// 数据库
    var database = SQLite()
        
    /// 加载怪兽资料
    func loadMonsters() {
        
        // 打开数据库
        let path = Bundle.main.url(forResource: "towerofsaviors", withExtension: "db")!
        database.open(in: path.absoluteString)
        
        // 怪兽资料
        let jsonArray = database.search("SELECT * FROM 怪兽数据 WHERE 怪兽标识").asJSON
        monsters = jsonArray.arrayValue.map { SLMonster(json: $0) }
    }
}

/// 背景音乐播放器
extension SKBackgroundMusicPlayer {
    
    /// 播放背景音乐
    enum Key : String {
        case 日照间的旅程 = "日照间的旅程"
        case 夜幕下的旅途 = "夜幕下的旅途"
        case 龙脉爆发 = "龙脉爆发"
        case 踏上战途 = "踏上战途"
        case 以诺圣区 = "以诺圣区"
        case 战斗的终结 = "战斗的终结"
        
        /// 播放音乐
        func play() {
            if let url = Bundle.main.url(forResource: "background music/" + self.rawValue, withExtension: "m4a") {
                SKBackgroundMusicPlayer.shared.play(url)
            } else {
                KSLog("play background music [\(self)], not find")
            }
        }
    }
}

/// 音效播放器
extension SKSoundEffect {
    
    /// 播放音效
    enum Key : String {
        case buttonDown = "button_down" // 按下按钮时
        case buttonUp = "button_up" // 松开按钮时
        case stoneMove = "stone_move" // 转珠时移动符石的音效
        case stoneChanged = "stone_changed" // 符石类型变换时的音效
        case stoneBoom0 = "stone_boom0" // 消除时符石爆炸的音效
        case stoneBoom1 = "stone_boom1"
        case stoneBoom2 = "stone_boom2"
        case stoneBoom3 = "stone_boom3"
        case stoneBoom4 = "stone_boom4"
        case stoneBoom5 = "stone_boom5"
        case stoneBoom6 = "stone_boom6"
        case stoneBoom7 = "stone_boom7"
        case stoneBoom8 = "stone_boom8"
        case sealMoving = "抽卡移动"
        case sealMoveOut = "抽卡出卡"
        case attackReady = "战斗发起攻击"
        case attackUpgrade = "战斗获得增益"
        case hitByWater = "战斗水属击中"
        case hitByFlame = "战斗火属击中"
        case hitByEarth = "战斗木属击中"
        case hitByLight = "战斗光属击中"
        case hitByMurky = "战斗暗属击中"
        
        static var all : [Key] {
            return [
                .buttonDown,
                .buttonUp,
                .stoneMove,
                .stoneChanged,
                .stoneBoom0,
                .stoneBoom1,
                .stoneBoom2,
                .stoneBoom3,
                .stoneBoom4,
                .stoneBoom5,
                .stoneBoom6,
                .stoneBoom7,
                .stoneBoom8,
                .sealMoving,
                .sealMoveOut,
                .attackReady,
                .attackUpgrade,
                .hitByWater,
                .hitByFlame,
                .hitByEarth,
                .hitByLight,
                .hitByMurky,
            ]
        }
        
        func play() {
            SKSoundEffect.shared.play(self.rawValue)
        }
    }
    
    func loadMetadata() {
        
        var sounds = [String : URL]()
        for key in Key.all {
            if let url = Bundle.main.url(forResource: key.rawValue, withExtension: "m4a", subdirectory: "sound effect") {
                sounds[key.rawValue] = url
            } else {
                KSLog("not find \(key)")
            }
        }
        
        loadMetadata(sounds)
    }
}

/// 播放音效
extension SKAction {
    
    class func playSoundEffect(_ key: SKSoundEffect.Key) -> SKAction {
        return SKAction.run { SKSoundEffect.shared.play(key.rawValue) }
    }
}
