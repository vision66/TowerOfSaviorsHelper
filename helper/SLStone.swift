//
//  SLStone.swift
//  helper
//
//  Created by weizhen on 2018/2/11.
//  Copyright © 2018年 aceasy. All rights reserved.
//

import UIKit

/// 符石覆盖物
enum SLStoneOverlay : Int {
    case normal = 0     // 普通
    case weathering     // 风化
    case locked         // 锁定
    case frozen         // 冰冻
    case lightning      // 电击
    case stick          // 黏住
    
    case 神族
    case 魔族
    case 人族
    case 兽族
    case 龙族
    case 妖精
    case 机械
    case 进化素材
    case 强化素材
}

/// 元素石
class SLStone {

    /// 符石的类型. 例如水、火、木、光、暗、心
    var type : SLElement
    
    /// 符石的状态. 例如强化等
    var status : SLElementStatus
    
    /// 符石附着物. 例如种族标记、锁定、冰冻、隐藏等
    var overlay : SLStoneOverlay
    
    init(type : SLElement = .水, status : SLElementStatus = .normal, overlay : SLStoneOverlay = .normal) {
        self.type = type
        self.status = status
        self.overlay = overlay
    }
}

func ==(left: SLStone, right: SLStone) -> Bool {
    return left.type == right.type && left.status == right.status && left.overlay == right.overlay
}
