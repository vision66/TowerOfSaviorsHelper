//
//  SLMonster.swift
//  helper
//
//  Created by weizhen on 2018/1/29.
//  Copyright © 2018年 aceasy. All rights reserved.
//

import UIKit

/// 每一张卡片的素质
class SLMonster {

    var rawValue: JSON = JSON.null
    
    var 怪兽标识 : Int = 0
    
    var 怪兽名称 : String = ""
    
    var 怪兽头像 : URL?
    
    var 怪兽立绘 : URL?
    
    var 元素属性 : SLElementType = .水
    
    var 怪兽种族 : SLRacialType = .人族
    
    var 满级生命 : Int = 0
    
    var 满级攻击 : Int = 0
    
    var 满级回复 : Int = 0
    
    var 所属系列 : String = ""
    
    var 占据空间 : Int = 0
    
    var 怪兽星级 : Int = 1
    
    var 最大等级 : Int = 1
    
    var 队长技能 : SLLeaderSkill?
    
    var 主动技能 = [SLActiveSkill]()
    
    var 升华技能 = [SLAmeliorationSkill]()
    
    var 组合技能 = [SLCombineSkill]()
    
    var 团队技能 = [SLTeamSkill]()
   
    init(json: JSON) {
        load(json: json)
    }
    
    func load(json: JSON) {
        self.rawValue = json
        self.怪兽标识 = json["怪兽标识"].intValue
        self.怪兽名称 = json["怪兽名称"].stringValue
        self.满级攻击 = json["满级攻击"].intValue
        self.元素属性 = SLElementType.make(json["元素属性"].stringValue)
        self.满级生命 = json["满级生命"].intValue
        self.怪兽种族 = SLRacialType.make(json["怪兽种族"].stringValue)
        self.所属系列 = json["所属系列"].stringValue
        self.占据空间 = json["占据空间"].intValue
        self.怪兽星级 = json["怪兽星级"].intValue
        self.满级回复 = json["满级恢复"].intValue
        self.怪兽头像 = json["怪兽头像"].stringValue.asURL
        if let str = json["怪兽立绘"].string {
            //https://vignette.wikia.nocookie.net/tos/images/8/87/Pet408.png/revision/latest?cb=20130909124225&path-prefix=zh
            //https://vignette.wikia.nocookie.net/tos/images/8/87/Pet408.png/revision/latest/scale-to-width-down/700?path-prefix=zh
            self.怪兽立绘 = str.regularReplace(pattern: "latest[a-zA-Z0-9/?=&\\-]+path-prefix=zh", with: "latest/scale-to-width-down/640?path-prefix=zh").asURL
        }
        
        self.最大等级 = json["最大等级"].intValue        
        self.队长技能 = SLLeaderSkill(json: json)
    }
    
    func getSkills() {
        
        let array2 = SLGloabls.shared.database.search("SELECT * FROM 主动技能 WHERE 怪兽标识 = ?", 怪兽标识)
        主动技能 = array2.map { SLActiveSkill(json: $0.asJSON) }
        
        let array3 = SLGloabls.shared.database.search("SELECT * FROM 升华技能 WHERE 怪兽标识 = ?", 怪兽标识)
        升华技能 = array3.map { SLAmeliorationSkill(json: $0.asJSON) }
        
        let array4 = SLGloabls.shared.database.search("SELECT * FROM 组合技能 WHERE 怪兽标识 = ?", 怪兽标识)
        组合技能 = array4.map { SLCombineSkill(json: $0.asJSON) }
        
        let array5 = SLGloabls.shared.database.search("SELECT * FROM 团队技能 WHERE 怪兽标识 = ?", 怪兽标识)
        团队技能 = array5.map { SLTeamSkill(json: $0.asJSON) }
    }
}
