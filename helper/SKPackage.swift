//
//  SKPackage.swift
//  SaintLisa
//
//  Created by weizhen on 2017/10/12.
//  Copyright © 2017年 weizhen. All rights reserved.
//

import SpriteKit

/// 卡片图鉴
class SKPackage: SKScene, SceneClickableType {
    
    /// 由卡片组成的矩阵, 单元格大小 60x60, 间隙大小 10
    private lazy var cardMatrix = childNode(withName: "card_matrix") as! SKTileMapNode
    
    /// 展示查询条件的节点. `card_filter`
    private lazy var cardFilter = childNode(withName: "card_filter")!
    
    /// 右上角的过滤按钮
    private lazy var sortButton = childNode(withName: "title/btn_right")!
    
    /// 右上角的过滤按钮
    private lazy var sortTitle = childNode(withName: "title/btn_right/title") as! SKLabelNode
    
    /// 所有的卡片
    private var allCards = [SKPackageCard]()
    
    /// 当前的排序方式
    private var sortType : String = "no"
    
    /// 监听pan手势
    private lazy var panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPanGesture(_:)))
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)

        for character in SLGloabls.characters {
            let card = SKPackageCard(character: character, size: card_size)
            card.name = "card"
            allCards.append(card)
        }
        
        // 加载配置
        loadConfiguration()

        // 将这些卡片显示在TileMap中
        layoutCards()
        
        // 添加拖拽手势
        view.addGestureRecognizer(panGesture)
    }

    override func willMove(from view: SKView) {
        super.willMove(from: view)
        view.removeGestureRecognizer(panGesture)
        saveConfiguration()
    }
    
    func scene(_ scene: SKScene, click button: SKButton) {
        
        if button.name == "team" {
            let scene = SKScene(fileNamed: "SKShowTeam")!
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
            return
        }
        
        if button.name == "energy" {
            let scene = SKScene(fileNamed: "SKWorld")!
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
            return
        }
        
        if button.name == "btn_right" {
            cardFilter.isHidden = false
            panGesture.isEnabled = false
            sortButton.isUserInteractionEnabled = false
            return
        }
        
        if button.name == "item" {
            button.isSelected = !button.isSelected
            return
        }
        
        if button.name == "no" ||
            button.name == "attribute" ||
            button.name == "life" ||
            button.name == "attack" ||
            button.name == "recover" ||
            button.name == "size" ||
            button.name == "series" {
            cardFilter.isHidden = true
            panGesture.isEnabled = true
            sortButton.isUserInteractionEnabled = true
            sortType = button.name!
            layoutCards()
            return
        }
        
        if button.name == "card" {
            let scene = SKScene(fileNamed: "SKCharacter") as! SKCharacter
            scene.character = (button as? SKPackageCard)?.character
            scene.scaleMode = .aspectFill
            scene.userData = ["card map offset" : cardMatrix.position.y, "from scene": "SKPackage"]
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
            return
        }
    }
    
    private func layoutCards() {
        
        // 移除掉原有的
        allCards.forEach {
            $0.removeFromParent()
        }
        
        // 经过过滤后的
        let filtered = filteredCards()
        
        // 经过排序后的
        let sorted = sortedCards(cards: filtered, type: sortType)
        
        // 把卡片加入到tiles中, 并调整cardMatrix的位置
        let cols = 5
        let rows = Int(ceil(sorted.count * 1.0 / cols))
        cardMatrix.numberOfColumns = cols
        cardMatrix.numberOfRows = rows
        
        for (index, card) in sorted.enumerated() {
            let col = index % cols
            let row = rows - index / cols - 1 // item(0, 0)是cardMap的左上角
            card.position = cardMatrix.centerOfTile(atColumn: col, row: row)
            cardMatrix.addChild(card)
        }
        
        // 如果从其他scene过来, 检查offset, 使偏移到这个位置; 否则, 移动到顶部
        let target : CGFloat
        if let offset = userData?["card map offset"] as? CGFloat {
            userData?["card map offset"] = nil
            target = offset
        } else {
            target = scene_height / 2 - cardMatrix.mapSize.height / 2 - package_top
        }
        
        cardMatrix.position = CGPoint(x: cardMatrix.position.x, y: target)
        
        // 更新显示的过滤条件
        showFilterCondition(sorted: sorted)
    }
    
    private func filteredCards() -> [SKPackageCard] {
        
        let types = self["card_filter/type/item"] as! [SKButton]
        let races = self["card_filter/race/item"] as! [SKButton]
        let stars = self["card_filter/star/item"] as! [SKButton]
        
        let needType = types.contains(where: { $0.isSelected })
        let needRace = races.contains(where: { $0.isSelected })
        let needStar = stars.contains(where: { $0.isSelected })
        
        return allCards.filter {
            
            return (needType == false || types[$0.character.attribute.rawValue].isSelected) &&
                (needRace == false || races[$0.character.race.rawValue].isSelected) &&
                (needStar == false || stars[$0.character.star - 1].isSelected)
        }
    }
    
    private func sortedCards(cards: [SKPackageCard], type: String) -> [SKPackageCard] {
        
        if type == "no" {
            let sorted = cards.sorted { return $0.character.no < $1.character.no }
            for card in sorted { card.titleLabel.text = "No.\(card.character.no)" }
            sortTitle.text = "序号"
            return sorted
        }
        
        if type == "attribute" {
            let sorted = cards.sorted { return $0.character.attribute.rawValue < $1.character.attribute.rawValue }
            for card in sorted { card.titleLabel.text = "No.\(card.character.no)" }
            sortTitle.text = "属性"
            return sorted
        }
        
        if type == "life" {
            let sorted = cards.sorted { return $0.character.life < $1.character.life }
            for card in sorted { card.titleLabel.text = "\(card.character.life)" }
            sortTitle.text = "生命"
            return sorted
        }
        
        if type == "attack" {
            let sorted = cards.sorted { return $0.character.attack < $1.character.attack }
            for card in sorted { card.titleLabel.text = "\(card.character.attack)" }
            sortTitle.text = "攻击"
            return sorted
        }
        
        if type == "recover" {
            let sorted = cards.sorted { return $0.character.recover < $1.character.recover }
            for card in sorted { card.titleLabel.text = "\(card.character.recover)" }
            sortTitle.text = "回复"
            return sorted
        }
        
        if type == "size" {
            let sorted = cards.sorted { return $0.character.size < $1.character.size }
            for card in sorted { card.titleLabel.text = "\(card.character.size)" }
            sortTitle.text = "空间"
            return sorted
        }
        
        if type == "series" {
            let sorted = cards.sorted { return $0.character.series < $1.character.series }
            for card in sorted { card.titleLabel.text = "No.\(card.character.no)" }
            sortTitle.text = "系列"
            return sorted
        }
        
        return cards
    }
    
    private func showFilterCondition(sorted: [SKPackageCard]) {
        
        let container = childNode(withName: "pack_filter")!
        
        let removed = self["pack_filter/item"]
        container.removeChildren(in: removed)
        
        var newnode = [SKSpriteNode]()
        
        let types = self["card_filter/type/item"] as! [SKButton]
        for (index, button) in types.enumerated() {
            if button.isSelected {
                let node = SKSpriteNode(imageNamed: "icon_sort_type_\(index)")
                newnode.append(node)
            }
        }
        
        let races = self["card_filter/race/item"] as! [SKButton]
        for (index, button) in races.enumerated() {
            if button.isSelected {
                let node = SKSpriteNode(imageNamed: "icon_sort_race_\(index)")
                newnode.append(node)
            }
        }
        
        let stars = self["card_filter/star/item"] as! [SKButton]
        for (index, button) in stars.enumerated() {
            if button.isSelected {
                let node = SKSpriteNode(imageNamed: "icon_sort_star_\(index + 1)")
                newnode.append(node)
            }
        }
        
        var maxCount = 10
        
        for (index, node) in newnode.enumerated() {
            
            if maxCount == 0 { break }
            maxCount -= 1
            
            node.position = CGPoint(x: 20 * index - 120, y: 0)
            container.addChild(node)
        }
        
        let label = childNode(withName: "pack_filter/label") as! SKLabelNode
        label.text = sorted.count.asString
    }
    
    private func loadConfiguration() {
        
        let types = self["card_filter/type/item"] as! [SKButton]
        let races = self["card_filter/race/item"] as! [SKButton]
        let stars = self["card_filter/star/item"] as! [SKButton]
        
        let typeString = UserDefaults.standard.string(forKey: "card map types") ?? "0,0,0,0,0"
        let typeValues = typeString.components(separatedBy: ",")
        for index in 0 ..< types.count {
            types[index].isSelected = typeValues[index].asBool
        }
        
        let raceString = UserDefaults.standard.string(forKey: "card map races") ?? "0,0,0,0,0,0,0,0,0"
        let raceValues = raceString.components(separatedBy: ",")
        for index in 0 ..< races.count {
            races[index].isSelected = raceValues[index].asBool
        }
        
        let starString = UserDefaults.standard.string(forKey: "card map stars") ?? "0,0,0,0,0,0,0,0"
        let starValues = starString.components(separatedBy: ",")
        for index in 0 ..< stars.count {
            stars[index].isSelected = starValues[index].asBool
        }
        
        sortType = UserDefaults.standard.string(forKey: "card map sort") ?? "no"
    }
    
    private func saveConfiguration() {
        
        let types = self["card_filter/type/item"] as! [SKButton]
        let races = self["card_filter/race/item"] as! [SKButton]
        let stars = self["card_filter/star/item"] as! [SKButton]
        
        let typeValues = types.map { $0.isSelected ? "1" : "0" }.joined(separator: ",")
        let raceValues = races.map { $0.isSelected ? "1" : "0" }.joined(separator: ",")
        let starValues = stars.map { $0.isSelected ? "1" : "0" }.joined(separator: ",")
        
        UserDefaults.standard.set(typeValues, forKey: "card map types")
        UserDefaults.standard.set(raceValues, forKey: "card map races")
        UserDefaults.standard.set(starValues, forKey: "card map stars")
        
        UserDefaults.standard.set(sortType, forKey: "card map sort")
    }
    
    @objc func onPanGesture(_ recognizer: UIPanGestureRecognizer) {
        
        let offsetY = recognizer.translation(in: view).y * scene_width / view_width
        
        var targetY = cardMatrix.position.y - offsetY
        
        let cHeight = cardMatrix.mapSize.height
        
        if targetY > cHeight / 2 + package_bottom - scene_height / 2 {
            targetY = cHeight / 2 + package_bottom - scene_height / 2
        }
        
        if targetY < scene_height / 2 - cHeight / 2 - package_top {
            targetY = scene_height / 2 - cHeight / 2 - package_top
        }
        
        cardMatrix.position = CGPoint(x: 0, y: targetY)
        
        recognizer.setTranslation(.zero, in: view)
    }
}
