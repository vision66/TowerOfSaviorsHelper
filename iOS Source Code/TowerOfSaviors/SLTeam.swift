//
//  SLTeam.swift
//  helper
//
//  Created by weizhen on 2018/2/2.
//  Copyright © 2018年 aceasy. All rights reserved.
//

import UIKit

/// 由1~6个角色组成的队伍, 某些位置可能为空
class SLTeam {
    
    /// 队伍共6个成员
    static let MaxMemebersCount : Int = 6
    
    /// 队伍成员. 角色所在队伍的位置, 将作为key使用
    private var basicMembers = [Int : SLMonster]()
    
    /// 经过队伍技能处理后的队伍成员. 角色所在队伍的位置, 将作为key使用.
    private var finalMembers = [Int : SLMonster]()
    
    /// 队伍效果
    private(set) var effects = [SLSkillEffect]()
    
    /// 在[模拟组队]界面, 展示出来的描述
    private(set) var strings = [String]()
    
    /// 下标脚本, 用于访问队伍成员members
    subscript(index: Int) -> SLMonster? {
        
        get {
            return basicMembers[index]
        }
        
        set {
            basicMembers[index] = newValue
            newValue?.getSkills()
            update()
        }
    }
    
    /// 取的属性和
    private func capabilities(at members: [Int : SLMonster]) -> [String : Int] {
        
        let 空间 = members.reduce(0) { $0 + $1.value.占据空间 }
        let 生命 = members.reduce(0) { $0 + $1.value.满级生命 }
        let 回复 = members.reduce(0) { $0 + $1.value.满级回复 }
        
        let 水攻 = members.reduce(0) { ($1.value.元素属性 == .水) ? ($0 + $1.value.满级攻击) : $0 }
        let 火攻 = members.reduce(0) { ($1.value.元素属性 == .火) ? ($0 + $1.value.满级攻击) : $0 }
        let 木攻 = members.reduce(0) { ($1.value.元素属性 == .木) ? ($0 + $1.value.满级攻击) : $0 }
        let 光攻 = members.reduce(0) { ($1.value.元素属性 == .光) ? ($0 + $1.value.满级攻击) : $0 }
        let 暗攻 = members.reduce(0) { ($1.value.元素属性 == .暗) ? ($0 + $1.value.满级攻击) : $0 }
        
        return ["空间": 空间, "生命": 生命, "水攻": 水攻, "火攻": 火攻, "木攻": 木攻, "光攻": 光攻, "暗攻": 暗攻, "回复": 回复]
    }
    
    /// 原始的能力值
    func basicCapabilities() -> [String : Int] {
        return capabilities(at: basicMembers)
    }
    
    /// 经过队伍加成后的能力值
    func finalCapabilities() -> [String : Int] {
        return capabilities(at: finalMembers)
    }
    
    /// 从配置文件中读取
    func loadConfiguration() {
        
        guard let dictionary = UserDefaults.standard.object(forKey: "team members") as? [String : String] else { return }
        
        basicMembers.removeAll()
        
        for (key, obj) in dictionary {
            basicMembers[key.asInt] = SLGloabls.shared.monsters.first { $0.怪兽名称 == obj }
        }
        
        update()
    }
    
    /// 保存到配置文件中
    func saveConfiguration() {
        var dictionary = [String : String]()
        for (key, obj) in basicMembers {
            dictionary[key.asString] = obj.怪兽名称
        }
        UserDefaults.standard.set(dictionary, forKey: "team members")
    }
    
    /// 分析出队伍技能
    private func update() {
        
        // 清除掉之前的数据
        strings.removeAll()
        effects.removeAll()
        finalMembers.removeAll()
        
        // 拷贝一份队员数据. 注意不要直接用'=', 因为需要修改finalMembers, 而不能修改basicMembers
        for (key, obj) in basicMembers {
            finalMembers[key] = SLMonster(json: obj.rawValue)
        }
        
        // [1493 創曆者 ‧ 瑪雅] & [1493 創曆者 ‧ 瑪雅]
        if  finalMembers[0]?.怪兽标识 == 1439 &&
            finalMembers[5]?.怪兽标识 == 1439 {
            
            strings.append("队长的队长技能“光华独尊”变为“光华独尊 ‧ 极”，当中 3 粒或以上相同种类的符石相连，即可发动消除，所有符石掉落机率不受其他技能影响 (包括改变掉落符石属性的技能)。回合结束时，可点选“X 型”引爆 10 个固定位置的符石")
            strings.append("每任意消除 10 粒光、暗或心符石时，光属性攻击力提升，消除 30 粒可提升至最大 1.6 倍")
            
            finalMembers[0]?.队长技能?.队长技能 = "光华独尊 ‧ 极"
            finalMembers[0]?.队长技能?.技能描述 = "光符石兼具 25% 心符石效果、暗符石兼具 25% 光符石效果、心符石兼具 50% 光符石效果 (效果可以叠加)。消除光、暗及心符石其中 2 种符石时，光属性攻击力 3 倍，当中 3 粒或以上相同种类的符石相连，即可发动消除，所有符石掉落机率不受其他技能影响 (包括改变掉落符石属性的技能)。回合结束时，可点选“X 型”引爆 10 个固定位置的符石"
            
            effects.append(.e010)
            effects.append(.e011)
            effects.append(.e012)
            effects.append(.e013)
            effects.append(.e014)
            effects.append(.e015)
        }
        
        // [1277 青龍偃月 ‧ 關羽] & [1277 青龍偃月 ‧ 關羽]
        if  finalMembers[0]?.怪兽标识 == 1277 &&
            finalMembers[5]?.怪兽标识 == 1277 {
            
            strings.append("队长的队长技能“结义之力”变为“结义之力 ‧ 强”，当中 3 粒或以上相同种类的符石相连，即可发动消除，所有符石掉落机率不受其他技能影响 (包括改变掉落符石属性的技能)")
            
            finalMembers[0]?.队长技能?.队长技能 = "结义之力 ‧ 强"
            finalMembers[0]?.队长技能?.技能描述 = "队伍中只有水、火及木属性成员时：水符石兼具火及木符石 50% 效果、火符石兼具水及木符石 50% 效果、木符石兼具水符石及火符石 50% 效果 (兼具效果可以叠加) 。消除水、火、木及心符石其中 2 种符石时，全队攻击力 2.5 倍，消除其中 3 种符石时，则全队攻击力 3 倍. 当中 3 粒或以上相同种类的符石相连，即可发动消除，所有符石掉落机率不受其他技能影响 (包括改变掉落符石属性的技能)"
            
            effects.append(.e010)
            effects.append(.e011)
            effects.append(.e012)
            effects.append(.e013)
            effects.append(.e014)
            effects.append(.e015)
        }
        
        // [1277 青龍偃月 ‧ 關羽] & [1281 鐵血義師 ‧ 劉備] & [1293 野熊將 ‧ 張飛]
        if  finalMembers.contains(where: { $0.value.怪兽标识 == 1277 }) &&
            finalMembers.contains(where: { $0.value.怪兽标识 == 1281 }) &&
            finalMembers.contains(where: { $0.value.怪兽标识 == 1293 }) {
            
            strings.append("所有成员的生命力、攻击力及回复力提升 1.2 倍")
            
            for (_, value) in finalMembers {
                value.满级生命 = Int(value.满级生命 * 1.2)
                value.满级攻击 = Int(value.满级攻击 * 1.2)
                value.满级回复 = Int(value.满级回复 * 1.2)
            }
        }
        
        // [1042 彌勒世尊 ‧ 燃燈] & [1043 顯聖真君 ‧ 楊戩]
        if  finalMembers[0]?.怪兽标识 == 1042 && finalMembers[5]?.怪兽标识 == 1043 {
            strings.append("火及木属性攻击力提升 3 倍")
            strings.append("木符石兼具火符石效果, 同时火符石兼具木符石效果")
        }
        
        // [1042 彌勒世尊 ‧ 燃燈]
        if  finalMembers[0]?.怪兽标识 == 1042 {
            strings.append("回合结束时，将 2 粒符石转化为火符石 (光及暗符石优先转换)")
            effects.append(.e041)
        }
        
        // [1042 彌勒世尊 ‧ 燃燈]
        if  finalMembers[5]?.怪兽标识 == 1042 {
            strings.append("回合结束时，将 2 粒符石转化为火符石 (光及暗符石优先转换)")
            effects.append(.e041)
        }
        
        // [1043 顯聖真君 ‧ 楊戩]
        if  finalMembers[0]?.怪兽标识 == 1043 {
            strings.append("回合结束时，将 2 粒符石转化为木符石 (光及暗符石优先转换)")
            effects.append(.e042)
        }
        
        // [1043 顯聖真君 ‧ 楊戩]
        if  finalMembers[5]?.怪兽标识 == 1043 {
            strings.append("回合结束时，将 2 粒符石转化为木符石 (光及暗符石优先转换)")
            effects.append(.e042)
        }
        
        // [1043 顯聖真君 ‧ 楊戩] & [1042 彌勒世尊 ‧ 燃燈]
        if  finalMembers[0]?.怪兽标识 == 1043 && finalMembers[5]?.怪兽标识 == 1042 {
            strings.append("火及木属性攻击力提升 3 倍")
            strings.append("木符石兼具火符石效果, 同时火符石兼具木符石效果")
        }
        
        // [1042 彌勒世尊 ‧ 燃燈] & [1042 彌勒世尊 ‧ 燃燈]
        if  finalMembers[0]?.怪兽标识 == 1042 &&
            finalMembers[5]?.怪兽标识 == 1042 {
            strings.append("火属性攻击力提升 6 倍")
        }
        
        // [1043 顯聖真君 ‧ 楊戩] & [1043 顯聖真君 ‧ 楊戩]
        if  finalMembers[0]?.怪兽标识 == 1043 &&
            finalMembers[5]?.怪兽标识 == 1043 {
            strings.append("木属性攻击力提升 6 倍")
        }
        
        // [1604 閉鎖心蕾 ‧ 櫻] & [1604 閉鎖心蕾 ‧ 櫻]
        if  finalMembers[0]?.怪兽标识 == 1604 &&
            finalMembers[5]?.怪兽标识 == 1604 {
            strings.append("每首批消除一组水、火或木符石将掉落 4 粒火强化符石；每首批消除一组光、暗或心符石，将掉落 4 粒心强化符石；每累计消除 10 粒火或心符石，将掉落 1 粒火妖族强化符石")
            effects.append(.e031)
        }
        
        // 娆花梦系.不死意志
        if  finalMembers[0]?.所属系列 == "妖嬈花夢" &&
            finalMembers[5]?.所属系列 == "妖嬈花夢" &&
            finalMembers[0]?.怪兽星级 == 6 &&
            finalMembers[5]?.怪兽星级 == 6 {
            let notOnlyElf = finalMembers.contains(where: { $0.value.怪兽种族 != .妖精 })
            let count = finalMembers.reduce(0, { ($1.value.所属系列 == "妖嬈花夢") ? ($0 + 1) : ($0) })
            if notOnlyElf == false && count >= 3 {
                strings.append("当前生命力全满时，下一次所受伤害不会使你死亡 (同一回合只会发动一次)")
            }
        }
        
        // [ 285 元素操縱者 ‧ 迪亞布羅] & 溢血攻击
        // [ 742 噩耗元素噬者 ‧ 迪亞布羅] & 溢血攻击
        if  finalMembers[0]?.怪兽标识 == 742 {
            var elf = [Int : Bool]()
            for (_, value) in finalMembers {
                if elf[value.怪兽标识] == true { continue }
                if (value.所属系列 == "妖女" && value.怪兽星级 > 4) || (value.所属系列 == "玩具精灵" && value.怪兽星级 > 5) || value.怪兽标识 == 876 || (value.所属系列 == "妖嬈花夢" && value.怪兽星级 > 5) {
                    elf[value.怪兽标识] = true
                }
            }
            if elf.count > 2 {
                strings.append("以回血溢出值作全体攻击，最大 10 倍")
            }
        }
        
        // [1643 悖論創造 ‧ 道羅斯] & [1643 悖論創造 ‧ 道羅斯]
        if  finalMembers[0]?.怪兽标识 == 1643 &&
            finalMembers[5]?.怪兽标识 == 1643 {
            effects.append(.e023)
        }
        
        // [1643 悖論創造 ‧ 道羅斯] & 光龙兽妖
        if  finalMembers[0]?.怪兽标识 == 1643 &&
            finalMembers[5]?.怪兽标识 == 1643 {
            
            let notOnlyRaceOrAttribute = finalMembers.contains(where: { $0.value.元素属性 != .光 || !($0.value.怪兽种族 == .龙族 || $0.value.怪兽种族 == .兽族 || $0.value.怪兽种族 == .妖精) })
            
            if notOnlyRaceOrAttribute == false {
                
                strings.append("龙类及兽类增加 400 点回复力")
                
                for (_, value) in finalMembers {
                    if value.怪兽种族 == .龙族 || value.怪兽种族 == .兽族 {
                        value.满级回复 = value.满级回复 + 400
                    }
                }
            }
        }
        
        // [1136 蓬托斯]
        if  finalMembers[0]?.队长技能?.队长技能 == "浪濤界限 ‧ 變革" ||
            finalMembers[5]?.队长技能?.队长技能 == "浪濤界限 ‧ 變革" {
            effects.append(.e010)
        }
        
        // [1144 厄瑞玻斯]
        if  finalMembers[0]?.队长技能?.队长技能 == "幽冥界限 ‧ 變革" ||
            finalMembers[5]?.队长技能?.队长技能 == "幽冥界限 ‧ 變革" {
            effects.append(.e014)
        }
        
        // [1137 浪濤海神 ‧ 蓬托斯]
        // [1145 暗影夜神 ‧ 厄瑞玻斯]
        if  finalMembers[0]?.队长技能?.队长技能 == "界限變革" ||
            finalMembers[5]?.队长技能?.队长技能 == "界限變革" {
            effects.append(.e010)
            effects.append(.e011)
            effects.append(.e012)
            effects.append(.e013)
            effects.append(.e014)
            effects.append(.e015)
        }
        
        // [1375 滔天浪神 ‧ 蓬托斯]
        // [1379 混沌夜神 ‧ 厄瑞玻斯]
        if  finalMembers[0]?.队长技能?.队长技能 == "界限變革 ‧ 神" ||
            finalMembers[5]?.队长技能?.队长技能 == "界限變革 ‧ 神" {
            effects.append(.e010)
            effects.append(.e011)
            effects.append(.e012)
            effects.append(.e013)
            effects.append(.e014)
            effects.append(.e015)
        }
        
        // [1603 樱]
        // [1604 閉鎖心蕾 ‧ 櫻]
        if  finalMembers[0]?.队长技能?.队长技能 == "櫻之花雨" ||
            finalMembers[5]?.队长技能?.队长技能 == "櫻之花雨" {
            effects.append(.e001)
            effects.append(.e005)
        }
        
        // [ 533 道僧燃燈]
        // [ 534 錠光如來 ‧ 燃燈]
        // [1042 彌勒世尊 ‧ 燃燈]
        // [1042 奮力挺舉 ‧ 燃燈]
        if  finalMembers[0]?.队长技能?.队长技能 == "火靈符籙" ||
            finalMembers[5]?.队长技能?.队长技能 == "火靈符籙" {
            effects.append(.e001)
            effects.append(.e005)
        }
        
        // [ 535 靈將楊戩]
        // [ 536 清源仙將 ‧ 楊戩]
        // [1043 顯聖真君 ‧ 楊戩]
        // [1043 精準揮擊 ‧ 楊戩]
        if  finalMembers[0]?.队长技能?.队长技能 == "木靈符籙" ||
            finalMembers[5]?.队长技能?.队长技能 == "木靈符籙" {
            effects.append(.e002)
            effects.append(.e005)
        }
    }
}
