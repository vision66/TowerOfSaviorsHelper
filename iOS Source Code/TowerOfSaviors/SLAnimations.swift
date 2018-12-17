//
//  SLAnimations.swift
//  TowerOfSaviors
//
//  Created by weizhen on 2018/9/18.
//  Copyright © 2018年 aceasy. All rights reserved.
//

import UIKit

/// 帧动画
class SLAnimations {
    
    /// 符石爆炸
    static var stoneBoom : SKAction!
    
    /// 加载素材
    class func loadTextures(completionHandler: @escaping (Error?) -> Void) {
        
        /// TODO: 尝试将它放进sks中
        SKTextureAtlas.preloadTextureAtlasesNamed(["boom"]) { error, textureAtlases in
            
            // 爆炸动画
            let boomAtlases = textureAtlases[0]
            var textures = [SKTexture]()
            for index in  1 ... 38 {
                let name = String(format: "ef_Disipate_%03d", index)
                let texture = boomAtlases.textureNamed(name)
                textures.append(texture)
            }            
            stoneBoom = SKAction.animate(with: textures, timePerFrame: 0.016) // 38 x 0.016 = 0.608
            
            // 加载完成
            completionHandler(error)
        }
    }
}
