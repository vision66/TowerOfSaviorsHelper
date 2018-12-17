//
//  SLTeamSkill.swift
//  helper
//
//  Created by weizhen on 2018/2/2.
//  Copyright © 2018年 aceasy. All rights reserved.
//

import UIKit

/// 团队技能
class SLTeamSkill {
    
    var 技能标识 : Int = 0
    
    var 发动条件 : String = ""
    
    var 技能描述 : String = ""
    
    init() {
        
    }
    
    init(json: JSON) {
        self.技能标识 = json["技能标识"].intValue
        self.发动条件 = json["限制条件"].stringValue
        self.技能描述 = json["技能描述"].stringValue
    }
}
