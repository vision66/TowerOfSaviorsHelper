//
//  SLActiveSkill.swift
//  TowerOfSaviors
//
//  Created by weizhen on 2018/10/22.
//  Copyright © 2018 aceasy. All rights reserved.
//

import UIKit

/// 主动技能类型
enum SLActiveSkillType : String {
    case CD = "cd"
    case EP = "ep"
}

/// 主动技能
class SLActiveSkill {
    
    var 技能标识 : Int = 0
    
    var 技能类型 : SLActiveSkillType = .CD
    
    var 最小消耗 : Int = 0
    
    var 最大消耗 : Int = 0
    
    var 技能名称 : String = ""
    
    var 技能描述 : String = ""
    
    init() {
        
    }
        
    init(json: JSON) {
        self.技能标识 = json["技能标识"].intValue
        self.技能类型 = (json["技能类型"].stringValue == "ep") ? .EP : .CD
        self.最小消耗 = json["最小消耗"].intValue
        self.最大消耗 = json["最大消耗"].intValue
        self.技能名称 = json["技能名称"].stringValue
        self.技能描述 = json["技能描述"].stringValue
    }
}
