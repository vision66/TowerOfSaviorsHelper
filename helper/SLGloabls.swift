//
//  SLGloabls.swift
//  helper
//
//  Created by weizhen on 2018/1/22.
//  Copyright © 2018年 aceasy. All rights reserved.
//

import UIKit
import SpriteKit

/// 场景宽度
let scene_width : CGFloat = 320

/// 场景高度
let scene_height : CGFloat = 480

/// 包裹中, 卡片矩阵与场景(320x480)顶部的距离
let package_top : CGFloat = 137

/// 包裹中, 卡片矩阵与场景(320x480)底部的距离
let package_bottom : CGFloat = 100

/// 包裹中, 卡片矩阵的每一个单元格的宽、高
let card_map_tile_size : CGFloat = 60

/// 包裹中, 卡片之间的距离. value = 10
let card_space : CGFloat = (scene_width - card_map_tile_size * 5) / 2

/// 包裹中, 卡片的宽、高. 50x50
let card_size : CGSize = CGSizeMake(card_map_tile_size - card_space, card_map_tile_size - card_space)

/// 包裹中, 卡片矩阵与场景(320x480)顶部的距离
let storylist_top : CGFloat = 107

/// 包裹中, 卡片矩阵与场景(320x480)底部的距离
let storylist_bottom : CGFloat = 100

/// 屏幕的宽度
let view_width : CGFloat = UIScreen.main.bounds.size.width

/// 屏幕的高度
let view_height : CGFloat = UIScreen.main.bounds.size.height

/// 软件中所有需要的资源, 包括纹理、帧动画、声音等等. 与Assets.xcassets的差异在于, 这些资源没有用在sks文件中, 一般用于动态生成的SKSpriteNode
class SLGloabls {
    
    /// 普通符石图片
    static var normalStoneTextures = [SKTexture]()
    
    /// 强化符石图片
    static var strongStoneTextures = [SKTexture]()
    
    /// 卡片头像图片
    static var avatarTextures = [String : SKTexture]()
    
    /// 卡片形象图片
    static var imageTextures = [String : SKTexture]()
    
    /// 爆炸动画
    static var stoneBoomAnimation : SKAction?
    
    /// 转珠时, 移动符石的音效
    static var stoneMoveSound : SKAction = SKAction.playSoundFileNamed("stone_move.m4a", waitForCompletion: false)
    
    /// 消除时, 符石爆炸的音效
    static var stoneBoomSounds : [SKAction] = {
        return (0 ... 8).map { SKAction.playSoundFileNamed("boom\($0).m4a", waitForCompletion: false )}
    }()
    
    /// 符石类型变换时的音效
    static var stoneChangedSound : SKAction = SKAction.playSoundFileNamed("boom8.m4a", waitForCompletion: false)
    
    /// 卡片数据
    static var characters = [SLCharacter]()
    
    /// 数据库
    static var database = SQLite()
    
    /// 地图位置
    static var offsetOfWorldMap : CGPoint?
    
    /// 加载资源
    static func setupResources(withCompletionHandler completionHandler: @escaping () -> ()) {
        
        // 打开数据库
        let path = Bundle.main.url(forResource: "helper", withExtension: "db")!
        database.open(in: path.absoluteString)
        
        // 加载纹理图册
        SKTextureAtlas.preloadTextureAtlasesNamed(["stone", "boom", "avatar"]) { error, textureAtlases in
            
            // 普通符石 & 强化符石
            let stoneAtlases = textureAtlases[0]
            for index in 0 ... 5 {
                SLGloabls.normalStoneTextures.append(stoneAtlases.textureNamed("stone_\(index)"))
                SLGloabls.strongStoneTextures.append(stoneAtlases.textureNamed("stone_\(index)s"))
            }
            
            // 爆炸动画
            let stardust = textureAtlases[1]
            var textures = [SKTexture]()
            for index in  1 ... 38 {
                let name = String(format: "ef_Disipate_%03d", index)
                let texture = stardust.textureNamed(name)
                textures.append(texture)
            }
            SLGloabls.stoneBoomAnimation = SKAction.animate(with: textures, timePerFrame: 0.015)
            
            // 卡片头像
            let avatarAtlases = textureAtlases[2]
            for name in avatarAtlases.textureNames {
                SLGloabls.avatarTextures[name] = avatarAtlases.textureNamed(name)
            }
            
            // 加载卡片数据
            DispatchQueue.global().async {
                
                // 从json文件中取的卡片数据
                let json = SLGloabls.database.search("select * from character").asJSON
                
                for dictionary in json.arrayValue {
                    let character = SLCharacter(json: dictionary)
                    SLGloabls.characters.append(character)
                }
                
                DispatchQueue.main.async {
                    
                    completionHandler()
                }
            }
        }        
    }
}
