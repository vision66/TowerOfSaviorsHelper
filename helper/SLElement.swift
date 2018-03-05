//
//  SLElement.swift
//  helper
//
//  Created by weizhen on 2018/1/30.
//  Copyright © 2018年 aceasy. All rights reserved.
//

import UIKit

/// 元素类型: 水、火、木、光、暗、心
enum SLElement : Int {
    case 水 = 0
    case 火
    case 木
    case 光
    case 暗
    case 心
    
    static var random : SLElement {
        return SLElement(rawValue: Int(arc4random() % 6))!
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
    
    static func make(_ desc: String) -> SLElement {
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

/// 便利方法
extension Int {
    
    var asElement : SLElement? { return SLElement(rawValue: self) }
}

/// 元素状态: 普通、强化
enum SLElementStatus : Int {
    case normal = 0
    case strong
}
