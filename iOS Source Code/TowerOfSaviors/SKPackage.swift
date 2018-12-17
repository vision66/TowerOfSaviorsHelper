//
//  SKPackage.swift
//  SaintLisa
//
//  Created by weizhen on 2017/10/12.
//  Copyright © 2017年 weizhen. All rights reserved.
//

import SpriteKit

/// 卡片图鉴
class SKPackage: SKScene, SceneClickableType, SKGridViewDelegate {
    
    /// 卡片矩阵
    private let collection = SKGridView()
    
    /// 查询条件
    private lazy var monsterFilter = self["过滤器"].first!.children.first!.children.first! as! SKFilterMonster
    
    /// 右上角的排序按钮
    private lazy var sortTitle = self["标题栏/右按钮/title"].first! as! SKLabelNode
    
    /// 显示的怪兽
    private var monsters = [SLMonster]()
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // 读取参数
        monsterFilter.loadConfiguration()
        monsterFilter.hide(false)
        
        /// 卡片矩阵
        let width = scene_width - 20
        let height = statusbar_position_y * 2 - 40
        
        collection.bounds = CGRectMake(-width / 2, -height / 2, width, height)
        collection.position = CGPointMake(0, -24)
        collection.itemSize = package_cell_size
        collection.minimumLineSpacing = 12
        collection.minimumInteritemSpacing = 10
        collection.contentInset = UIEdgeInsetsMake(40, 0, 40, 0)
        collection.delegate = self
        collection.register(SKPackageMonsterCell.self, forCellReuseIdentifier: SKPackageMonsterCell.defaultIdentifier)
        collection.register(SKPackageRemoveCell.self, forCellReuseIdentifier: SKPackageRemoveCell.defaultIdentifier)
        insertChild(collection, at: 1)
        collection.didMove(to: self)
        
        // 卡片加入到矩阵中
        monsters.append(contentsOf: SLGloabls.shared.monsters)
        
        reloadCards()
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        collection.willRemove(from: self)
    }
    
    func scene(_ scene: SKScene, click button: SKButton) {
                
        if button.name == "能量" {
            let scene = SKScene(fileNamed: "SKWorld")!
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
            return
        }
        
        // 点击标题栏右侧按钮
        if button.name == "右按钮" {
            if monsterFilter.isFilterOptionHidden {
                monsterFilter.show()
                collection.isUserInteractionEnabled = false
            } else {
                monsterFilter.hide(false)
                collection.isUserInteractionEnabled = true
            }
            return
        }
        
        // 点击右侧排序方法, 用以确认排序和过滤的条件
        if button.name == "item" {
            if button.parent?.name != "sort" { return }
            guard let label = button["title"].first as? SKLabelNode else { return }
            monsterFilter.sort = label.text!
            monsterFilter.hide(true)
            collection.isUserInteractionEnabled = true
            reloadCards()
            return
        }
        
        // 点击怪兽
        if button.name == "monster" {
            
            let cell = button.parent as! SKPackageMonsterCell
            let monster = monsters[cell.indexPath!]
            
            let scene = SKScene(fileNamed: "SKMonster") as! SKMonster
            scene.monster = monster
            scene.scaleMode = .aspectFill
            scene.userData = ["from scene": "SKPackage"]
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
            
            return
        }
    }
    
    private func reloadCards() {
        
        let sortType = monsterFilter.sort
        
        let needType = monsterFilter.types.count > 0
        let needRace = monsterFilter.races.count > 0
        let needStar = monsterFilter.stars.count > 0
        
        // 更新右上角按钮文字
        sortTitle.text = sortType
        
        // 经过过滤后的
        let filtered = SLGloabls.shared.monsters.filter {
            return (needType == false || monsterFilter.types.contains($0.元素属性.rawValue)) &&
                (needRace == false || monsterFilter.races.contains($0.怪兽种族.rawValue)) &&
                (needStar == false || monsterFilter.stars.contains($0.怪兽星级 - 1))
        }
        
        // 经过排序后的
        switch sortType {
        case "编号": monsters = filtered.sorted { return $0.怪兽标识 < $1.怪兽标识 }
        case "属性": monsters = filtered.sorted { return $0.元素属性.rawValue < $1.元素属性.rawValue }
        case "生命": monsters = filtered.sorted { return $0.满级生命 > $1.满级生命 }
        case "攻击": monsters = filtered.sorted { return $0.满级攻击 > $1.满级攻击 }
        case "回复": monsters = filtered.sorted { return $0.满级回复 > $1.满级回复 }
        case "空间": monsters = filtered.sorted { return $0.占据空间 < $1.占据空间 }
        case "系列": monsters = filtered.sorted { return $0.所属系列 < $1.所属系列 }
        default: monsters = filtered
        }
        
        monsterFilter.setMonsterCount(monsters.count)
        
        collection.reloadData()
    }
    
    func gridView(_ gridView: SKGridView, numberOfItems unuse: Int) -> Int {
        return monsters.count
    }
    
    func gridView(_ gridView: SKGridView, cellForItemAt indexPath: Int) -> SKGridViewCell {
        
        let monster = monsters[indexPath]

        let cell = collection.dequeueReusableCell(withIdentifier: SKPackageMonsterCell.defaultIdentifier, for: indexPath) as! SKPackageMonsterCell
        cell.iconNode.texture = SLTextures.monsterIcons[monster.怪兽名称] ?? SKTexture(imageNamed: "item_unknown")
        cell.labelNode.text = monster.满级攻击.asString
        
        switch monsterFilter.sort {
        case "生命": cell.labelNode.text = "\(monster.满级生命)"
        case "攻击": cell.labelNode.text = "\(monster.满级攻击)"
        case "回复": cell.labelNode.text = "\(monster.满级回复)"
        case "空间": cell.labelNode.text = "\(monster.占据空间)"
        default: cell.labelNode.text = "No.\(monster.怪兽标识)"
        }
        
        return cell
    }
}
