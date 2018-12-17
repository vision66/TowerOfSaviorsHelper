//
//  SLSkillEffect.swift
//  TowerOfSaviors
//
//  Created by weizhen on 2018/11/2.
//  Copyright © 2018 aceasy. All rights reserved.
//

import UIKit

enum SLSkillEffect : Int {
    
    /// 符石二消 水
    case e000 = 0
    /// 符石二消 火
    case e001 = 1
    /// 符石二消 木
    case e002 = 2
    /// 符石二消 光
    case e003 = 3
    /// 符石二消 暗
    case e004 = 4
    /// 符石二消 心
    case e005 = 5

    /// 符石三消 水
    case e010 = 10
    /// 符石三消 火
    case e011 = 11
    /// 符石三消 木
    case e012 = 12
    /// 符石三消 光
    case e013 = 13
    /// 符石三消 暗
    case e014 = 14
    /// 符石三消 心
    case e015 = 15
    
    /// 每回合移动符石时触碰的首 5 粒符石转化为光强化符石
    case e023 = 23
    
    /// 每首批消除一组水、火或木符石将掉落 4 粒火强化符石；每首批消除一组光、暗或心符石，将掉落 4 粒心强化符石；每累计消除 10 粒火或心符石，将掉落 1 粒火妖族强化符石
    case e031 = 31
    
    /// 回合结束时，将 2 粒符石转化为水符石 (光及暗符石优先转换)
    case e040 = 40
    /// 回合结束时，将 2 粒符石转化为火符石 (光及暗符石优先转换)
    case e041 = 41
    /// 回合结束时，将 2 粒符石转化为木符石 (光及暗符石优先转换)
    case e042 = 42
}
