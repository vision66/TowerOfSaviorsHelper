//
//  SLCharacter.swift
//  helper
//
//  Created by weizhen on 2018/1/29.
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
        case "神族": return . 神族
        case "魔族": return . 魔族
        case "人类": return .人族
        case "兽类": return .兽族
        case "龙类": return . 龙族
        case "妖精类": return . 妖精
        case "机械族": return . 机械
        case "进化素材": return . 进化素材
        case "强化素材": return . 强化素材
        default: return .强化素材
        }
    }
}

/// 便利方法
extension Int {
    
    var asRacialType : SLRacialType? { return SLRacialType(rawValue: self) }
}

/// 每一张卡片的素质
class SLCharacter: NSObject {

    /// 原始数据
    var rawValue: JSON = JSON(NSNull())
    
    /// 序号
    var no : Int = 0
    
    /// 名字
    var name : String = ""
    
    /// 头像
    var icon : String = ""
    
    /// 全身像
    var image : String = ""
    
    /// 属性
    var attribute : SLElement = .水
    
    /// 种族
    var race : SLRacialType = .人族
    
    /// 生命
    var life : Int = 0
    
    /// 攻击
    var attack : Int = 0
    
    /// 回复
    var recover : Int = 0
    
    /// 系列
    var seriesid : Int = 0
    
    /// 系列
    var series : String = ""
    
    /// 空间
    var size : Int = 0
    
    /// 稀有度
    var star : Int = 1
    
    /// 最大等级
    var maxLevel : Int = 1
    
    /// 队长技能名称
    var leaderName : String = ""
    
    /// 队长技能描述
    var leaderDesc : String = ""
    
    init(json: JSON) {
        super.init()
        load(json: json)
    }
    
    func load(json: JSON) {
        self.rawValue = json
        self.no = json["no"].intValue
        self.name = json["name"].stringValue
        self.attack = json["attack"].intValue
        self.attribute = SLElement.make(json["attribute"].stringValue)
        self.life = json["life"].intValue
        self.race = SLRacialType.make(json["race"].stringValue) 
        self.series = json["series"].stringValue
        self.size = json["size"].intValue
        self.star = json["star"].intValue
        self.recover = json["recover"].intValue
        self.icon = json["icon"].stringValue
        self.image = json["image"].stringValue
        self.leaderName = json["leader_name"].stringValue
        self.leaderDesc = json["leader_desc"].stringValue
        self.maxLevel = json["max_level"].intValue
    }
}
