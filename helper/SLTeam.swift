//
//  SLTeam.swift
//  helper
//
//  Created by weizhen on 2018/2/2.
//  Copyright © 2018年 aceasy. All rights reserved.
//

import UIKit

/// 由1~6个角色组成的队伍, 某些位置可能为空
class SLTeam: NSObject {

    /// 队伍成员. 角色所在队伍的位置, 将作为key使用
    private var basicMembers = [Int : SLCharacter]()
    
    /// 经过队伍技能处理后的队伍成员. 角色所在队伍的位置, 将作为key使用.
    private var finalMembers = [Int : SLCharacter]()
    
    /// 队伍技能
    var skills = [SLSkill]()
    
    /// 队伍效果
    var effects = [String]()
    
    /// 下标脚本, 用于访问队伍成员members
    subscript(index: Int) -> SLCharacter? {
        get {
            return basicMembers[index]
        }
        set {
            basicMembers[index] = newValue
            fetchTeamSKills()
        }
    }
    
    /// 取的属性和
    private func capabilities(at members: [Int : SLCharacter]) -> [String : Int] {
        
        let size = members.reduce(0) { (result, member) -> Int in
            return result + member.value.size
        }
        
        let life = members.reduce(0) { (result, member) -> Int in
            return result + member.value.life
        }
        
        let recover = members.reduce(0) { (result, member) -> Int in
            return result + member.value.recover
        }
        
        let attribute0 = members.reduce(0) { (result, member) -> Int in
            if member.value.attribute == .水 {
                return result + member.value.attack
            }
            return result
        }
        
        let attribute1 = members.reduce(0) { (result, member) -> Int in
            if member.value.attribute == .火 {
                return result + member.value.attack
            }
            return result
        }
        
        let attribute2 = members.reduce(0) { (result, member) -> Int in
            if member.value.attribute == .木 {
                return result + member.value.attack
            }
            return result
        }
        
        let attribute3 = members.reduce(0) { (result, member) -> Int in
            if member.value.attribute == .光 {
                return result + member.value.attack
            }
            return result
        }
        
        let attribute4 = members.reduce(0) { (result, member) -> Int in
            if member.value.attribute == .暗 {
                return result + member.value.attack
            }
            return result
        }
        
        return ["size" : size, "life" : life, "water": attribute0, "fire" : attribute1, "wood": attribute2, "light": attribute3, "dark": attribute4, "recover": recover]
    }
    
    /// 原始的能力值
    func basicCapabilities() -> [String : Int] {
        return capabilities(at: basicMembers)
    }
    
    /// 经过队伍加成后的能力值
    func finalCapabilities() -> [String : Int] {
        return capabilities(at: finalMembers)
    }
    
    /// 分析出队伍技能
    private func fetchTeamSKills() {
        
        // 清除掉之前的数据
        skills.removeAll()
        effects.removeAll()
        finalMembers.removeAll()
        
        // 拷贝一份队员数据. 注意不要直接用'=', 因为需要修改finalMembers, 而不能修改basicMembers
        for (key, value) in basicMembers {
            finalMembers[key] = SLCharacter(json: value.rawValue)
        }

        // 玛雅&玛雅
        if  (basicMembers[0]?.no == 1439 && basicMembers[5]?.no == 1439) {
            
            let skill0 = SLSkill()
            skill0.发动条件 = "以创历者 ‧ 玛雅作队长及战友"
            skill0.队伍技能 = "队长的队长技能“光华独尊”变为“光华独尊 ‧ 极”，当中 3 粒或以上相同种类的符石相连，即可发动消除，所有符石掉落机率不受其他技能影响 (包括改变掉落符石属性的技能)。回合结束时，可点选“X 型”引爆 10 个固定位置的符石"
            skills.append(skill0)
            
            let skill1 = SLSkill()
            skill1.发动条件 = "以创历者 ‧ 玛雅作队长及战友"
            skill1.队伍技能 = "每任意消除 10 粒光、暗或心符石时，光属性攻击力提升，消除 30 粒可提升至最大 1.6 倍"
            skills.append(skill1)
            
            basicMembers[0]?.leaderName = "光华独尊 ‧ 极"
            basicMembers[0]?.leaderDesc = "光符石兼具 25% 心符石效果、暗符石兼具 25% 光符石效果、心符石兼具 50% 光符石效果 (效果可以叠加)。消除光、暗及心符石其中 2 种符石时，光属性攻击力 3 倍，当中 3 粒或以上相同种类的符石相连，即可发动消除，所有符石掉落机率不受其他技能影响 (包括改变掉落符石属性的技能)。回合结束时，可点选“X 型”引爆 10 个固定位置的符石"
        }
        
        // 关羽&关羽
        if  (basicMembers[0]?.no == 1277 && basicMembers[5]?.no == 1277) {
            
            let skill0 = SLSkill()
            skill0.发动条件 = "以青龙偃月 ‧ 关羽作队长及战友"
            skill0.队伍技能 = "队长的队长技能“结义之力”变为“结义之力 ‧ 强”，当中 3 粒或以上相同种类的符石相连，即可发动消除，所有符石掉落机率不受其他技能影响 (包括改变掉落符石属性的技能)"
            skills.append(skill0)
            
            basicMembers[0]?.leaderName = "结义之力 ‧ 强"
            basicMembers[0]?.leaderDesc = "队伍中只有水、火及木属性成员时：水符石兼具火及木符石 50% 效果、火符石兼具水及木符石 50% 效果、木符石兼具水符石及火符石 50% 效果 (兼具效果可以叠加) 。消除水、火、木及心符石其中 2 种符石时，全队攻击力 2.5 倍，消除其中 3 种符石时，则全队攻击力 3 倍. 当中 3 粒或以上相同种类的符石相连，即可发动消除，所有符石掉落机率不受其他技能影响 (包括改变掉落符石属性的技能)"
        }
        
        // 关羽&张飞&刘备
        if  basicMembers.contains(where: { $0.value.no == 1277 }) &&
            basicMembers.contains(where: { $0.value.no == 1281 }) &&
            basicMembers.contains(where: { $0.value.no == 1293 }) {
            
            let skill0 = SLSkill()
            skill0.发动条件 = "队伍中有青龙偃月 ‧ 关羽、铁血义师 ‧ 刘备及野熊将 ‧ 张飞作成员"
            skill0.队伍技能 = "所有成员的生命力、攻击力及回复力提升 1.2 倍"
            skills.append(skill0)
            
            for (_, value) in finalMembers {
                value.life = Int(value.life * 1.2)
                value.attack = Int(value.attack * 1.2)
                value.recover = Int(value.recover * 1.2)
            }
        }
        
        // 燃灯&杨戬
        if  (basicMembers[0]?.no == 1042 && basicMembers[5]?.no == 1043) ||
            (basicMembers[0]?.no == 1043 && basicMembers[5]?.no == 1042) {
            
            let skill0 = SLSkill()
            skill0.发动条件 = "弥勒世尊 ‧ 燃灯及显圣真君 ‧ 杨戬作队长及战友"
            skill0.队伍技能 = "火及木属性攻击力提升 3 倍"
            skills.append(skill0)
            
            let skill1 = SLSkill()
            skill1.发动条件 = "弥勒世尊 ‧ 燃灯及显圣真君 ‧ 杨戬作队长及战友"
            skill1.队伍技能 = "木符石兼具火符石效果, 同时火符石兼具木符石效果"
            skills.append(skill1)
        }
        
        // 燃灯&燃灯
        if  (basicMembers[0]?.no == 1042 && basicMembers[5]?.no == 1042) {
            
            let skill0 = SLSkill()
            skill0.发动条件 = "以弥勒世尊 ‧ 燃灯作队长及战友"
            skill0.队伍技能 = "火属性攻击力提升 6 倍"
            skills.append(skill0)
        }
        
        // 杨戬&杨戬
        if  (basicMembers[0]?.no == 1042 && basicMembers[5]?.no == 1042) {
            
            let skill0 = SLSkill()
            skill0.发动条件 = "以显圣真君 ‧ 杨戬作队长及战友"
            skill0.队伍技能 = "木属性攻击力提升 6 倍"
            skills.append(skill0)
        }
        
        // 樱&樱
        if  (basicMembers[0]?.no == 1604 && basicMembers[5]?.no == 1604) {
            
            let skill0 = SLSkill()
            skill0.发动条件 = "以闭锁心蕾 ‧ 樱作队长及战友"
            skill0.队伍技能 = "每首批消除一组水、火或木符石将掉落 4 粒火强化符石；每首批消除一组光、暗或心符石，将掉落 4 粒心强化符石；每累计消除 10 粒火或心符石，将掉落 1 粒火妖族强化符石"
            skills.append(skill0)
            
            effects.append("樱&樱")
        }
        
        // 娆花梦系.不死意志
        if  basicMembers[0]?.series == "妖娆花梦" && basicMembers[5]?.series == "妖娆花梦" &&
            basicMembers[0]?.star == 6 && basicMembers[5]?.star == 6 {
            let notOnlyElf = basicMembers.contains(where: { $0.value.race != .妖精 })
            let count = basicMembers.reduce(0, { ($1.value.series == "妖娆花梦") ? ($0 + 1) : ($0) })
            if notOnlyElf == false && count >= 3 {
                let skill0 = SLSkill()
                skill0.发动条件 = "以 6 星妖娆花梦系列召唤兽作队长及战友，队伍中有 3 个或以上 6 星的妖娆花梦系列召唤兽及只有妖精类成员"
                skill0.队伍技能 = "当前生命力全满时，下一次所受伤害不会使你死亡 (同一回合只会发动一次)"
                skills.append(skill0)
            }
        }
        
        // 迪亚布罗.溢血攻击
        if basicMembers[0]?.no == 742 {
            var elf = [Int : Bool]()
            for (_, value) in basicMembers {
                if elf[value.no] == true { continue }
                if (value.series == "妖女" && value.star > 4) || (value.series == "玩具精灵" && value.star > 5) || value.no == 876 || (value.series == "妖娆花梦" && value.star > 5) {
                    elf[value.no] = true
                }
            }
            if elf.count > 2 {
                let skill0 = SLSkill()
                skill0.发动条件 = "以噩耗元素噬者 ‧ 迪亚布罗作队长，并以 3 个或以上的 5 星或 6 星妖女系列、 6 星或 7 星玩具精灵系列的召唤兽、精灵使 ‧ 乌特博丽公主或 6 星妖娆花梦系列召唤兽作成员 (不可重复)"
                skill0.队伍技能 = "以回血溢出值作全体攻击，最大 10 倍"
                skills.append(skill0)
            }
        }
        
        // 道罗斯&道罗斯
        if  (basicMembers[0]?.no == 1643 && basicMembers[5]?.no == 1643) {
            
            let skill0 = SLSkill()
            skill0.发动条件 = "以悖论创造 ‧ 道罗斯作队长及战友"
            skill0.队伍技能 = "每回合移动符石时触碰的首 5 粒符石转化为光强化符石"
            skills.append(skill0)
            
            effects.append("道罗斯&道罗斯")
        }
        
        // 道罗斯&道罗斯&光龙兽妖
        if  (basicMembers[0]?.no == 1643 && basicMembers[5]?.no == 1643) {
            
            let notOnlyRaceOrAttribute = finalMembers.contains(where: { $0.value.attribute != .光 || !($0.value.race == .龙族 || $0.value.race == .兽族 || $0.value.race == .妖精) })
            
            if notOnlyRaceOrAttribute == false {
                
                let skill0 = SLSkill()
                skill0.发动条件 = "以悖论创造 ‧ 道罗斯作队长及战友，且队伍中只有光属性龙类、光属性兽类或光属性妖精类成员"
                skill0.队伍技能 = "龙类及兽类增加 400 点回复力"
                skills.append(skill0)
                
                for (_, value) in finalMembers {
                    if value.race == .龙族 || value.race == .兽族 {
                        value.recover = value.recover + 400
                    }
                }
            }
        }
        
        /* 消除方式 */
        
        if  basicMembers[0]?.leaderName == "结义之力 ‧ 强" ||
            basicMembers[0]?.leaderName == "光华独尊 ‧ 极" ||
            basicMembers[0]?.leaderName == "界限变革" ||
            basicMembers[5]?.leaderName == "界限变革" {
            effects.append("符石三消")
        }
        
        if  basicMembers[0]?.leaderName == "火灵符箓" ||
            basicMembers[5]?.leaderName == "火灵符箓" ||
            basicMembers[0]?.leaderName == "樱之花雨" ||
            basicMembers[5]?.leaderName == "樱之花雨" {
            effects.append("符石二消 火")
        }
        
        if  basicMembers[0]?.leaderName == "木灵符箓" ||
            basicMembers[5]?.leaderName == "木灵符箓" {
            effects.append("符石二消 木")
        }
        
        if  basicMembers[0]?.leaderName == "火灵符箓" ||
            basicMembers[5]?.leaderName == "火灵符箓" ||
            basicMembers[0]?.leaderName == "木灵符箓" ||
            basicMembers[5]?.leaderName == "木灵符箓" ||
            basicMembers[0]?.leaderName == "樱之花雨" ||
            basicMembers[5]?.leaderName == "樱之花雨" {
            effects.append("符石二消 心")
        }
    }
    
    /// 从配置文件中读取
    func loadConfiguration() {
        
        let membersS = UserDefaults.standard.string(forKey: "team members") ?? "1,1,1,1,1,1"
        let membersV = membersS.components(separatedBy: ",")
        for index in 0 ..< 6 {
            let characterId = membersV[index].asInt
            let character = SLGloabls.characters.first { $0.no == characterId }
            basicMembers[index] = character
        }
        
        fetchTeamSKills()
    }
    
    /// 保存到配置文件中
    func saveConfiguration() {
        
        var membersV = [String]()
        
        for index in 0 ..< 6 {
            if let character = basicMembers[index] {
                membersV.append(character.no.asString)
            } else {
                membersV.append("0")
            }
        }
        
        let membersS = membersV.joined(separator: ",")
        
        UserDefaults.standard.set(membersS, forKey: "team members")
    }
}
