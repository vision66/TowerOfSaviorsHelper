//
//  SLTextures.swift
//  TowerOfSaviors
//
//  Created by weizhen on 2018/9/18.
//  Copyright © 2018年 aceasy. All rights reserved.
//

import UIKit

/// 纹理资源
class SLTextures {
    
    /// 符石状态, 包括元素类型、元素状态、符石状态
    static var stoneStatus = [String : SKTexture]()
    
    /// 卡片头像图片, 使用SLMonster.name作为key
    static var monsterIcons = [String : SKTexture]()
    
    /// 卡片形象图片
    static var monsterImages = [String : SKTexture]()
    
    /// 加载素材
    class func loadTextures(completionHandler: @escaping (Error?) -> Void) {
        
        SKTextureAtlas.preloadTextureAtlasesNamed(["stone", "monster"]) { error, textureAtlases in
            
            /// 符石状态
            let stoneAtlases = textureAtlases[0]
            for name in stoneAtlases.textureNames {
                let removed = name.substring(from: 0, to: name.count - 8) // from '%E5%8D%8A%E8%97%8F@2x.png' to '%E5%8D%8A%E8%97%8F'
                let decoded = removed.removingPercentEncoding!            // from '%E5%8D%8A%E8%97%8F' to '半藏'
                stoneStatus[decoded] = stoneAtlases.textureNamed(name)
            }
            
            // 卡片头像
            let monsterAtlases = textureAtlases[1]
            for name in monsterAtlases.textureNames {
                let removed = name.substring(from: 0, to: name.count - 8) // from '%E5%8D%8A%E8%97%8F@2x.png' to '%E5%8D%8A%E8%97%8F'
                let decoded = removed.removingPercentEncoding!            // from '%E5%8D%8A%E8%97%8F' to '半藏'
                monsterIcons[decoded] = monsterAtlases.textureNamed(name)
            }
            
            // 加载完成
            completionHandler(error)
        }
    }
}
