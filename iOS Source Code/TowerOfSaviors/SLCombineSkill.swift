//
//  SLCombineSkill.swift
//  TowerOfSaviors
//
//  Created by weizhen on 2018/10/22.
//  Copyright © 2018 aceasy. All rights reserved.
//

import UIKit

/// 组合技能
class SLCombineSkill {
    
    var 技能标识 : Int = 0
    
    var 技能名称 : String = ""
    
    var 限制条件 : String = ""
    
    var 技能描述 : String = ""
    
    init() {
        
    }
        
    init(json: JSON) {
        self.技能标识 = json["技能标识"].intValue
        self.技能名称 = json["技能名称"].stringValue
        self.限制条件 = json["限制条件"].stringValue        
        self.技能描述 = json["技能描述"].stringValue
    }
}
