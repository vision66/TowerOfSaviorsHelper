//
//  SKSkillNode.swift
//  TowerOfSaviors
//
//  Created by weizhen on 2018/10/22.
//  Copyright © 2018 aceasy. All rights reserved.
//

import UIKit

class SKSkillNode: SKNode {
    
    private func updateBackground() {
        
        let background = self["内容背景"].first?.sprite

        background?.removeFromParent()

        let descriptionNode = self["技能描述"].first as! SKLabelNode
        
        let texture = SKTexture(imageNamed: "卡片边框_技能内容")
        
        let bgnew = SKSpriteNode(texture: texture, color: .blue, size: CGSizeMake(scene_width, descriptionNode.frame.size.height + 4))
        bgnew.anchorPoint = CGPointMake(0.5, 1.0)
        bgnew.position = CGPointMake(0, -24)
        bgnew.name = "内容背景"
        insertChild(bgnew, at: 0)
        
        //使用下面的方法没有产生效果, 所以使用了上面的方法: 将该节点移去, 重新生成一个节点加入进来
        //background?.size = CGSizeMake(scene_width, descriptionNode.frame.size.height + 4)
    }
    
    func setSkill(_ skill: SLActiveSkill) {
        if skill.技能类型 == .CD {
            self["最小消耗"].first?.sprite?.firstChild?.label?.text = "MinCD " + skill.最小消耗.asString
        } else {
            self["最小消耗"].first?.sprite?.firstChild?.label?.text = "MinEP " + skill.最小消耗.asString
        }
        self["最大等级"].first?.sprite?.firstChild?.label?.text = "MaxLv." + (skill.最大消耗 - skill.最小消耗 + 1).asString
        self["技能类型"].first?.sprite?.texture = SKTexture(imageNamed: "卡片边框_技能标题_主动技能")
        self["技能名称"].first?.label?.text = skill.技能名称
        self["技能描述"].first?.label?.text = skill.技能描述
        updateBackground()
    }
    
    func setSkill(_ skill: SLLeaderSkill) {
        self["最小消耗"].first?.sprite?.isHidden = true
        self["最大等级"].first?.sprite?.isHidden = true
        self["技能类型"].first?.sprite?.texture = SKTexture(imageNamed: "卡片边框_技能标题_队长技能")
        self["技能名称"].first?.label?.text = skill.队长技能
        self["技能描述"].first?.label?.text = skill.技能描述
        updateBackground()
    }
    
    func setSkill(_ skill: SLTeamSkill) {
        self["最小消耗"].first?.sprite?.isHidden = true
        self["最大等级"].first?.sprite?.isHidden = true
        self["技能类型"].first?.sprite?.texture = SKTexture(imageNamed: "卡片边框_技能标题_团队技能")
        self["技能名称"].first?.label?.text = ""
        self["技能描述"].first?.label?.text = skill.发动条件 + "\n" + skill.技能描述
        updateBackground()
    }
    
    func setSkill(_ skill: SLAmeliorationSkill) {
        self["最小消耗"].first?.sprite?.isHidden = true
        self["最大等级"].first?.sprite?.isHidden = true
        self["技能类型"].first?.sprite?.texture = SKTexture(imageNamed: "卡片边框_技能标题_升华技能")
        self["技能名称"].first?.label?.text = skill.排列序号.asString
        self["技能描述"].first?.label?.text = skill.技能描述
        updateBackground()
    }
    
    func setSkill(_ skill: SLCombineSkill) {
        self["最小消耗"].first?.sprite?.isHidden = true
        self["最大等级"].first?.sprite?.isHidden = true
        self["技能类型"].first?.sprite?.texture = SKTexture(imageNamed: "卡片边框_技能标题_组合技能")
        self["技能名称"].first?.label?.text = skill.技能名称
        self["技能描述"].first?.label?.text = skill.限制条件 + "\n" + skill.技能描述
        updateBackground()
    }
}
