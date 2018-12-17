//
//  SLLeaderSkill.swift
//  TowerOfSaviors
//
//  Created by weizhen on 2018/10/22.
//  Copyright © 2018 aceasy. All rights reserved.
//

import UIKit

/// 队长技能
class SLLeaderSkill {
    
    var 队长技能 : String = ""
    
    var 技能描述 : String = ""
    
    init() {
        
    }
    
    init(json: JSON) {
        self.队长技能 = json["队长技能"].stringValue
        self.技能描述 = json["技能描述"].stringValue
    }
}
