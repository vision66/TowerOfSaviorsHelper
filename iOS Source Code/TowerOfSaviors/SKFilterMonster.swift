//
//  SKFilterMonster.swift
//  TowerOfSaviors
//
//  Created by weizhen on 2018/10/16.
//  Copyright © 2018 aceasy. All rights reserved.
//

import UIKit

/// 过滤卡片时的面板
class SKFilterMonster: SKNode {

    /// 已选中的[排序], 按钮的点击, 不在本类中处理
    var sort = "编号"
    
    /// 已选中的[属性], 按钮的点击, 在类中处理
    private(set) var types = [Int]()
    
    /// 已选中的[种族], 按钮的点击, 在类中处理
    private(set) var races = [Int]()
    
    /// 已选中的[星级], 按钮的点击, 在类中处理
    private(set) var stars = [Int]()
    
    /// 属性选项
    private lazy var btnTypes = self["filter_option/type/item"] as! [SKButton]
    
    /// 种族选项
    private lazy var btnRaces = self["filter_option/race/item"] as! [SKButton]
    
    /// 星级选项
    private lazy var btnStars = self["filter_option/star/item"] as! [SKButton]
    
    ///
    override init() {
        super.init()
    }
    
    ///
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self["filter_in_use"].first?.position = CGPointMake(0, statusbar_position_y - 57)
        self["filter_option"].first?.position = CGPointMake(0, statusbar_position_y - 267)
        
        for button in btnTypes {
            button.addTarget(self, action: #selector(selectType(_:)), for: .touchUpInside)
        }
        
        for button in btnRaces {
            button.addTarget(self, action: #selector(selectRace(_:)), for: .touchUpInside)
        }
        
        for button in btnStars {
            button.addTarget(self, action: #selector(selectStar(_:)), for: .touchUpInside)
        }
    }
    
    /// 选项面板是否显示. 注意, 隐藏时, 顶部的[已选项目]区域不会隐藏
    var isFilterOptionHidden : Bool {
        return self["filter_option"].first!.isHidden
    }
    
    /// 加载上一次的配置, 显示[过滤]和[排序]的条件
    func show() {
        
        self["filter_option"].first?.isHidden = false
        
        loadConfiguration()        
    }
    
    /// 隐藏面板, 默认会保存配置
    func hide(_ save: Bool) {
        
        self["filter_option"].first?.isHidden = true
        
        showFilterCondition()
        
        if save == false { return }
        
        saveConfiguration()
    }
    
    /// 从参数文件中读取[搜索条件]和[过滤方案]
    func loadConfiguration() {
        loadConfigurationEx(array1: &types, array2: &btnTypes, key: "select member with types", defaultValue: "0,0,0,0,0")
        loadConfigurationEx(array1: &races, array2: &btnRaces, key: "select member with races", defaultValue: "0,0,0,0,0,0,0,0,0")
        loadConfigurationEx(array1: &stars, array2: &btnStars, key: "select member with stars", defaultValue: "0,0,0,0,0,0,0,0")
        sort = UserDefaults.standard.string(forKey: "select member by sort") ?? "编号"
    }
    
    /// 从参数文件中读取[搜索条件]和[过滤方案]
    private func loadConfigurationEx(array1: inout [Int], array2: inout [SKButton], key: String, defaultValue: String) {
        array1.removeAll()
        let string = UserDefaults.standard.string(forKey: key) ?? defaultValue
        let values = string.components(separatedBy: ",")
        for index in 0 ..< array2.count {
            let selected = values[index].asBool
            array2[index].isSelected = selected
            if selected { array1.append(index) }
        }
    }
    
    /// 将[搜索条件]和[过滤方案]保存到参数文件
    func saveConfiguration() {
        
        let typeString = btnTypes.map { $0.isSelected ? "1" : "0" }.joined(separator: ",")
        let raceString = btnRaces.map { $0.isSelected ? "1" : "0" }.joined(separator: ",")
        let starString = btnStars.map { $0.isSelected ? "1" : "0" }.joined(separator: ",")
        let sortString = sort
        
        UserDefaults.standard.set(typeString, forKey: "select member with types")
        UserDefaults.standard.set(raceString, forKey: "select member with races")
        UserDefaults.standard.set(starString, forKey: "select member with stars")
        UserDefaults.standard.set(sortString, forKey: "select member by sort")
    }
    
    ///
    private func selectButton(sender: SKButton, array1: inout [Int], array2: inout [SKButton]) {
        
        let index = array2.firstIndex(of: sender)!
        
        let isSelected = !sender.isSelected
        sender.isSelected = isSelected
        
        if isSelected {
            if array1.contains(index) == false {
                array1.append(index)
            }
        } else {
            if let arrayIndex = array1.firstIndex(of: index) {
                array1.remove(at: arrayIndex)
            }
        }
        
        showFilterCondition()
    }
    
    ///
    @objc private func selectType(_ sender: SKButton) {
        selectButton(sender: sender, array1: &types, array2: &btnTypes)
    }
    
    ///
    @objc private func selectRace(_ sender: SKButton) {
        selectButton(sender: sender, array1: &races, array2: &btnRaces)
    }
    
    ///
    @objc private func selectStar(_ sender: SKButton) {
        selectButton(sender: sender, array1: &stars, array2: &btnStars)
    }
    
    ///
    private func showFilterCondition() {
        
        let container = self["filter_in_use"].first!
        
        let removeds = self["filter_in_use/item"]
        container.removeChildren(in: removeds)
        
        var newnode = [SKSpriteNode]()
        
        for (index, button) in btnTypes.enumerated() {
            if button.isSelected {
                let node = SKSpriteNode(imageNamed: "icon_sort_type_\(index)")
                newnode.append(node)
            }
        }
        
        for (index, button) in btnRaces.enumerated() {
            if button.isSelected {
                let node = SKSpriteNode(imageNamed: "icon_sort_race_\(index)")
                newnode.append(node)
            }
        }
        
        for (index, button) in btnStars.enumerated() {
            if button.isSelected {
                let node = SKSpriteNode(imageNamed: "icon_sort_star_\(index + 1)")
                newnode.append(node)
            }
        }
        
        var maxCount = 10
        
        for (index, node) in newnode.enumerated() {
            
            if maxCount == 0 { break }
            maxCount -= 1
            
            node.position = CGPoint(x: 24 * index - 112, y: 0)
            node.name = "item"
            container.addChild(node)
        }
    }
    
    /// 右上角的卡片数量
    func setMonsterCount(_ number: Int) {
        let label = self["filter_in_use/label"].first! as! SKLabelNode
        label.text = "\(number)"
    }
}
