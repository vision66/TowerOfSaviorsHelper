//
//  SLRacialType.swift
//  TowerOfSaviors
//
//  Created by weizhen on 2018/9/20.
//  Copyright © 2018年 aceasy. All rights reserved.
//

import UIKit

/// 种族
enum SLRacialType : Int {
    case 神族 = 0
    case 魔族 = 1
    case 人族 = 2
    case 兽族 = 3
    case 龙族 = 4
    case 妖精 = 5
    case 机械 = 6
    case 进化素材 = 7
    case 强化素材 = 8
    
    static func make(_ desc: String) -> SLRacialType {
        switch desc {
        case "神族": return .神族
        case "魔族": return .魔族
        case "人类": return .人族
        case "兽类": return .兽族
        case "龙类": return .龙族
        case "妖精类": return .妖精
        case "机械族": return .机械
        case "进化素材": return .进化素材
        case "强化素材": return .强化素材
        default: return .强化素材
        }
    }
}
