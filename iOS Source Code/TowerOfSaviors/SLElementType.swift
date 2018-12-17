//
//  SLElement.swift
//  helper
//
//  Created by weizhen on 2018/1/30.
//  Copyright © 2018年 aceasy. All rights reserved.
//

import UIKit

/// 元素类型
enum SLElementType : Int {
    case 水 = 0
    case 火
    case 木
    case 光
    case 暗
    case 心
    
    static var random : SLElementType {
        return SLElementType(rawValue: Int(arc4random() % 6))!
    }
    
    var description : String {
        switch self {
        case .水: return "水"
        case .火: return "火"
        case .木: return "木"
        case .光: return "光"
        case .暗: return "暗"
        case .心: return "心"
        }
    }

    static func make(_ desc: String) -> SLElementType {
        switch desc {
        case "水": return .水
        case "火": return .火
        case "木": return .木
        case "光": return .光
        case "暗": return .暗
        case "心": return .心
        default:   return .心
        }
    }
}

/// 元素状态: 普通、强化
enum SLElementStatus : Int {
    case 普通 = 0
    case 强化
    
    func texture(_ element: SLElementType) -> SKTexture {
        let status = (self == .普通) ? "普通元素" : "强化元素"
        return SLTextures.stoneStatus["\(status)_\(element.description)"]!
    }
}

/// 符石状态
enum SLRunestoneStatus : Int {
    case 正常 = 0
    case 风化
    case 锁定
    case 冻结
    case 冰封
    case 电击
    case 黏着
    
    case 神族
    case 魔族
    case 人族
    case 兽族
    case 龙族
    case 妖精
    case 机械
    
    func texture() -> SKTexture {
        switch self {
        case .正常: return SLTextures.stoneStatus["符石状态_正常"]!
        case .风化: return SLTextures.stoneStatus["符石状态_风化"]!
        case .锁定: return SLTextures.stoneStatus["符石状态_正常"]!
        case .冻结: return SLTextures.stoneStatus["符石状态_冻结"]!
        case .冰封: return SLTextures.stoneStatus["符石状态_正常"]!
        case .电击: return SLTextures.stoneStatus["符石状态_电击"]!
        case .黏着: return SLTextures.stoneStatus["符石状态_风化"]!
            
        case .神族: return SLTextures.stoneStatus["符石状态_风化"]!
        case .魔族: return SLTextures.stoneStatus["符石状态_风化"]!
        case .人族: return SLTextures.stoneStatus["符石状态_风化"]!
        case .兽族: return SLTextures.stoneStatus["符石状态_风化"]!
        case .龙族: return SLTextures.stoneStatus["符石状态_风化"]!
        case .妖精: return SLTextures.stoneStatus["符石状态_风化"]!
        case .机械: return SLTextures.stoneStatus["符石状态_风化"]!
        }
    }
}

