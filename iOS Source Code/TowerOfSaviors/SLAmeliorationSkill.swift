//
//  SLAmeliorationSkill.swift
//  TowerOfSaviors
//
//  Created by weizhen on 2018/10/22.
//  Copyright © 2018 aceasy. All rights reserved.
//

import UIKit

/// 升华技能
class SLAmeliorationSkill {
    
    var 技能标识 : Int = 0
    
    var 消耗灵魂 : Int = 0
    
    var 排列序号 : Int = 0
    
    var 技能描述 : String = ""
    
    init() {
        
    }
        
    init(json: JSON) {
        self.技能标识 = json["技能标识"].intValue
        self.消耗灵魂 = json["消耗灵魂"].intValue
        self.排列序号 = json["排列序号"].intValue
        self.技能描述 = json["技能描述"].stringValue
    }
}
