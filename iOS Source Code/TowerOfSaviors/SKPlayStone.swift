//
//  SKPlayStone.swift
//  SpriteKitDemo
//
//  Created by weizhen on 2017/10/31.
//  Copyright © 2017年 weizhen. All rights reserved.
//

import SpriteKit

class SKPlayStone: SKScene, SceneClickableType {
    
    typealias SKRunestoneCombo = [SKRunestone]
    
    /// 当前队伍
    private var team = SLTeam()
    
    /// 敌人 & 生命槽
    private lazy var emenyNode = self["敌人"].first?.firstChild?.firstChild as! SKEnemyNode
    
    /// 符石矩阵
    private lazy var matrixNode = self["版面/矩阵"].first as! SKTileMapNode
    
    /// 怪兽头像
    private lazy var memberNodes = self["队伍/成员"] as! [SKSpriteNode]
    
    /// 怪兽头像上的攻击力
    private lazy var attackNodes = self["队伍/攻击力"] as! [SKNumber]
    
    ///
    private lazy var combosLabel = self["统计转珠/达成连击/label"].first!.label!
    
    ///
    private lazy var stepsLabel = self["统计转珠/移动次数/label"].first!.label!
    
    ///
    private lazy var fallsLabel = self["统计转珠/天降次数/label"].first!.label!
    
    ///
    private lazy var elementLabels = self["统计符石/元素/label"] as! [SKLabelNode]
    
    /// 时间条
    private lazy var timerBar = self["版面/时间条"].first!.sprite!
    
    /// 矩阵行数
    private lazy var matrix_cols = matrixNode.numberOfColumns
    
    /// 矩阵列数
    private lazy var matrix_rows = matrixNode.numberOfRows
    
    /// 首次消除符石的数量. 注意: 如果直接从allCombos中获取, 将直接出现每一轮天降的最终结果, 而不会出现"每boom一组, 数值跳动"的效果
    private var stonesAtFirst = [SLElementType : Int]()
    
    /// 累积消除符石的数量
    private var stonesAtWhole = [SLElementType : Int]()
    
    /// 是否锁定转珠时间
    private var isTimeLocked = UserDefaults.standard.bool(forKey: steps_time_locked)
    
    /// 是否锁定敌人血条
    private var isLifeLocked = UserDefaults.standard.bool(forKey: enemy_life_locked)
    
    /// 连击数目、交换次数、天降次数, 发生变化时, 对应label的动画
    private var labelJump = SKAction.sequence([SKAction.scale(to: 1.2, duration: 0.15), SKAction.scale(to: 1.0, duration: 0.10)])
    
    /// 连击数目
    private var combos = 0 {
        didSet {
            combosLabel.text = String(combos)
            combosLabel.run(labelJump)
        }
    }
    
    /// 移动符石时, 交换的次数. 如果值为0, 不认为当前进行的移动符石的操作
    private var steps = 0 {
        didSet {
            stepsLabel.text = String(steps)
            stepsLabel.run(labelJump)
        }
    }
    
    /// 天降符石的次数
    private var falls = 0 {
        didSet {
            fallsLabel.text = String(falls)
            fallsLabel.run(labelJump)
        }
    }
    
    /// 菜单
    private lazy var menuLayer = self["菜单"].first!.sprite!
    
    ///
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // 更换BGM
        SKBackgroundMusicPlayer.Key.龙脉爆发.play()
        
        // 设置敌人
        emenyNode.maximumLife = 100_0000
        emenyNode.style = .木
        emenyNode.setCurrentLife(100_0000, animation: false)
        
        // 构造队伍
        team.loadConfiguration()
        
        let atlas = SKTextureAtlas(named: "number")
        for index in 0 ..< SLTeam.MaxMemebersCount {
            if let monster = team[index] {
                memberNodes[index].texture = SLTextures.monsterIcons[monster.怪兽名称]                
                let name : String
                switch monster.元素属性 {
                case .水: name = "number_water"
                case .火: name = "number_flame"
                case .木: name = "number_earth"
                case .光: name = "number_light"
                case .暗: name = "number_murky"
                default: name = "number_earth"
                }
                attackNodes[index].baseTexture = atlas.textureNamed(name)
                attackNodes[index].isHidden = true
                attackNodes[index].setNumber(0, animated: false)
            } else {
                memberNodes[index].texture = SKTexture(imageNamed: "item_null")
            }
        }
        
        // 构造面板
        isUserInteractionEnabled = true
        
        for index in 0 ..< matrix_cols * matrix_rows {
            let stone = SKRunestone(element: .水, status: .普通, stone: .正常)
            stone.position = matrixNode.centerOfTile(atColumn: index % matrix_cols, row: index / matrix_cols)
            matrixNode.addChild(stone)
            matrixStones.append(stone)
        }
        
        // 布局符石
        reset(animated: false)
    }
    
    /// 场景中的SKButton被点击时
    func scene(_ scene: SKScene, click button: SKButton) {
        
        if button.name == "设置" {
            menuLayer.isHidden = false
            return
        }
        
        if button.name == "item" {
            
            menuLayer.isHidden = true
            
            let title = button.firstLabel!.text!
            
            if title == "重新开始" {
                reset(animated: true)
                return
            }
            
            if title == "编辑队伍" {
                let scene = SKScene(fileNamed: "SKShowTeam")!
                scene.scaleMode = .aspectFill
                view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
                return
            }
            
            if title == "编辑符石" {
                let scene = SKScene(fileNamed: "SKEditStone")!
                scene.scaleMode = .aspectFill
                view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.6))
                return
            }
            
            return
        }
    }
    
    /// 即将交换时,
    /// - 返回true, 可以交换
    /// - 返回false, 交换失败, 例如碰到了风化、电击之类
    private func stoneWillSwap(from stone1: SKRunestone, to stone2: SKRunestone) -> Bool {
        
        // 开始转珠时
        if steps == 0 {
            // TODO: 产生风化
        }
        
        // 道罗斯&道罗斯 特效
        if steps < 5 && team.effects.contains(where: { $0 == .e023}) {
            stone2.change(element: .光, status: .强化, stone: .正常)
        }
        
        // TODO: 碰到风化
        
        return true
    }
    
    /// 符石交换时, 应该做些什么
    private func stoneDidSwap(atIndex index: Int) {
        
    }
    
    /// 怪兽头上的攻击力数值, 缩放动画
    private let labelConvergeAttackAction = SKAction.sequence([SKAction.scale(to: 1.2, duration: 0.2), SKAction.scale(to: 1.0, duration: 0.2)])
    
    /// 符石爆炸时, 应该做些什么
    private func stoneDidBoom(atCombo combo: SKRunestoneCombo) {
        
        // combo中的一个符石
        let first = combo.first!
        
        // 怪兽累积力量的粒子效果
        for monster_index in 0 ... 5 {
            
            guard let monster = team[monster_index] else { continue }
            
            if monster.元素属性 == first.元素属性 {
                
                let member_pos = memberNodes[monster_index].position
                let target = convert(member_pos, to: self)
                let source = matrixNode.convert(first.position, to: self)
                
                let emitter = SKEmitterNode(fileNamed: "shoot")!
                emitter.targetNode = self
                emitter.position = source
                addChild(emitter)
                
                let move_x = SKAction.moveTo(x: target.x, duration: 0.6)
                move_x.timingFunction = { $0 * $0 * $0 }
                let move_y = SKAction.moveTo(y: target.y, duration: 0.6)
                move_y.timingFunction = { $0 * $0 }

                let move = SKAction.group([move_x, move_y])
                let wait = SKAction.wait(forDuration: 0.2) // 保证SKEmitterNode到达memberNodes后, 不会立刻消失
                let remove = SKAction.removeFromParent()
                let sequence = SKAction.sequence([move, wait, remove])
                emitter.run(sequence)

                let oldAttack = attackNodes[monster_index].number
                let rate = combo.reduce(0.25, { ($1.元素状态 == .普通) ? ($0 + 0.25) : ($0 + 0.50) })
                let newAttack = oldAttack + rate * monster.满级攻击
                attackNodes[monster_index].isHidden = false
                attackNodes[monster_index].setNumber(newAttack.asInt, animated: true)
                attackNodes[monster_index].run(labelConvergeAttackAction)
            }
        }
        
        /* combo at first and whole */
        self.combos = self.combos + 1
        
        /* stone at first and whole */
        let elementType = first.元素属性
        var countAtFirst = self.stonesAtFirst[elementType] ?? 0
        
        if falls == 0 {
            countAtFirst += combo.count
            self.stonesAtFirst[elementType] = countAtFirst
        }
        if countAtFirst > 99 {
            countAtFirst = 99
        }
        
        var countAtWhole = self.stonesAtWhole[elementType] ?? 0
        countAtWhole += combo.count
        self.stonesAtWhole[elementType] = countAtWhole
        if countAtWhole > 99 {
            countAtWhole = 99
        }
        
        self.elementLabels[elementType.rawValue].label?.text = String(format: "%02d | %02d", countAtFirst, countAtWhole)
        
        var anyOfFirst = 0
        for (_, value) in self.stonesAtFirst {
            anyOfFirst += value
        }
        if anyOfFirst > 99 {
            anyOfFirst = 99
        }
        var anyOfWhole = 0
        for (_, value) in self.stonesAtWhole {
            anyOfWhole += value
        }
        if anyOfWhole > 99 {
            anyOfWhole = 99
        }
        self.elementLabels[6].label?.text = String(format: "%02d | %02d", anyOfFirst, anyOfWhole)
    }
    
    /// 即将天降时, 应该做些什么
    private func stoneWillFall() {
        
        /* 对`本轮消除`的判定 */
        
        for combo in allCombos {
            
            if combo.first!.天降标记 != falls { continue }
            
            // 如果1次combo中包含5颗符石, 就会产生1颗对应的强化符石
            if combo.count >= 5 {
                let object = SKRunestone(element: combo.first!.元素属性, status: .强化, stone: .正常)
                reserveStones.append(object)
            }
        }
        
        /* 对`首轮消除`的判定 */
        
        if falls == 0 {
            
            // 樱&樱: 每首批消除一组水、火或木符石将掉落 4 粒火强化符石；每首批消除一组光、暗或心符石，将掉落 4 粒心强化符石
            if team.effects.contains(where: { $0 == .e031 }) {
                
                for combo in allCombos {
                    let type = combo.first!.元素属性
                    if type == .水 || type == .火 || type == .木 {
                        let object = SKRunestone(element: .火, status: .强化, stone: .正常)
                        let objects = Array(repeating: object, count: 4)
                        reserveStones.append(contentsOf: objects)
                    } else {
                        let object = SKRunestone(element: .心, status: .强化, stone: .正常)
                        let objects = Array(repeating: object, count: 4)
                        reserveStones.append(contentsOf: objects)
                    }
                }
            }
        }
        
        /* 对`累积消除`的判定 */
        
        if team.effects.contains(where: { $0 == .e031 }) {
            var 累计火心 : Int = 0
            for combo in allCombos {
                for stone in combo {
                    if stone.元素属性 == .火 || stone.元素属性 == .心 {
                        累计火心 += 1
                    }
                }
            }
            let 新消火心 = 累计火心 - accumulativeCount * 10
            let 生效次数 = 新消火心 / 10
            accumulativeCount += 生效次数
            
            let object = SKRunestone(element: .火, status: .强化, stone: .妖精)
            let objects = Array(repeating: object, count: 生效次数)
            reserveStones.append(contentsOf: objects)
        }
    }

    /// 天降符石时, 应该做些什么
    private func stoneDidFall() {
        // TODO: [1499 冥縱之凶獅 ‧ 基加美修]的主动技能: 天降后引爆火以外数量最多的符石
        // TODO: [1453 高潔騎士 ‧ 亞瑟]的团队技能: 天降后引爆所有的光符石
    }
    
    /// 攻击结束后(回合结束时), 应该做些什么
    @objc private func memberDidAttack() {
        
        for effect in team.effects {
            
            // [1042 彌勒世尊 ‧ 燃燈]的队长技能: 回合结束时，将 2 粒符石转化为火符石 (光及暗符石优先转换)
            if effect == .e041 {
                var indexs = [Int]()
                while indexs.count < 2 {
                    let num = Int(arc4random() % 30)
                    if indexs.contains(num) == false { indexs.append(num) }
                }
                matrixStones[indexs[0]].change(element: .火, status: .普通, stone: .正常, animation: true)
                matrixStones[indexs[1]].change(element: .火, status: .普通, stone: .正常, animation: true)
                run(SKAction.playSoundEffect(.stoneChanged))
            }
            
            // [1043 顯聖真君 ‧ 楊戩]的队长技能: 回合结束时，将 2 粒符石转化为木符石 (光及暗符石优先转换)
            if effect == .e042 {
                var indexs = [Int]()
                while indexs.count < 2 {
                    let num = Int(arc4random() % 30)
                    if indexs.contains(num) == false { indexs.append(num) }
                }
                matrixStones[indexs[0]].change(element: .木, status: .普通, stone: .正常, animation: true)
                matrixStones[indexs[1]].change(element: .木, status: .普通, stone: .正常, animation: true)
                run(SKAction.playSoundEffect(.stoneChanged))
            }
        }
        
        allCombos.removeAll()
        isUserInteractionEnabled = true
        accumulativeCount = 0
    }
    
    //////////////////////////
    
    /// 手指按住版面上的某颗符石(即stoneTouched), 准备转珠(或正在转珠)时, 手指下方会生成一个符石(即stoneIndicator), 它跟随手指移动, 它并不在版面的30颗符石中, 它代表手指最开始按住的那颗符石.
    /// - 准备转珠(或正在转珠)时, 这个属性才有值;
    /// - 如果只是按住并稍微移动符石, 并没有发生符石交换, 这种情况下, 这个属性也会有值;
    /// - 反而言之, 如果这个属性的值为nil, 则一定没有进行转珠操作
    private var stoneIndicator : SKRunestone?
    
    /// 这个属性的相关行为可以参考stoneIndicator, 因为它们代表的状态完全相同.
    /// - 准备转珠(或正在转珠)时, 这颗版面上的符石会变暗, 结束转珠时恢复原状
    /// - 记住这个值, 可以方便符石交换的行为
    private var stoneTouched : SKRunestone?
    
    /// 位于矩阵上的30颗符石
    private var matrixStones = [SKRunestone]()
    
    /// 本轮[step ~ boom ~ fall ~ attack]的过程中, 所有连击的符石
    private var allCombos = [SKRunestoneCombo]()
    
    /// 天降池
    /// - 即将天降的符石, 一定会从其中获取, 只有池空时才会随机取的
    /// - 这个池子存放的是因为各种效果造成的, 必然会降落的符石
    private var reserveStones = [SKRunestone]()
    
    /// 针对这种类型计数: "每累计消除 10 粒火或心符石，将掉落 1 粒火妖族强化符石"、"每累计消除 3 粒水符石 ，将产生 1 粒水强化符石"
    private var accumulativeCount : Int = 0
    
    /// 将符石重置为档案中的情况
    func reset(animated: Bool) {
        
        if let matrixData = UserDefaults.standard.array(forKey: "stones matrix") as? [[String: Int]] {
            for (index, dict) in matrixData.enumerated() {
                let element = SLElementType(rawValue: dict["元素属性"]!)!
                let status = SLElementStatus(rawValue: dict["元素状态"]!)!
                let stone = SLRunestoneStatus(rawValue: dict["符石状态"]!)!
                matrixStones[index].change(element: element, status: status, stone: stone, animation: animated)
            }
            if animated {
                run(SKAction.playSoundEffect(.stoneChanged))
            }
        }
    }
    
    /// [boom ~ fall ~ attack]的过程中, isUserInteractionEnabled被设置为false, 所以不会触发这个方法
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let location = touches.first!.location(in: matrixNode)
        let node = matrixNode.atPoint(location)
        
        guard let stone = matrixStones.first(where: { node === $0 }) else {
            //KSLog("not find the stone node when touch began")
            return
        }
        
        stoneIndicator = SKRunestone(element: stone.元素属性, status: stone.元素状态, stone: stone.符石状态)
        stoneIndicator!.position = stone.position
        matrixNode.addChild(stoneIndicator!)
        
        stoneTouched = stone
        stoneTouched!.alpha = 0.4
        
        steps = 0
        falls = 0
    }
    
    /// [boom ~ fall ~ attack]的过程中, isUserInteractionEnabled被设置为false, 所以不会触发这个方法
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // 如果值为nil, 不认为当前手指在按下, 并企图拖拽符石
        guard let stoneIndicator = stoneIndicator, let stoneTouched = stoneTouched else { return }
        
        // 手指的位置
        var location = touches.first!.location(in: matrixNode)
        
        // 手指在哪里, 指示器就在哪里, 手指移出SKTileMapNode时, 指示器也会移出去
        stoneIndicator.position = location
        
        // SKTileMapNode被认为是一个320x212的矩形, 中心对准父节点的锚点
        // 手指超出矩阵区域后, 将超出范围的数据, 调整到矩阵边缘.
        // location不再表示手指的位置, 而是对应在矩阵上的投影, 将会用这个坐标定位矩阵上的符石
        if location.y >  106 { location.y =  106 }
        if location.y < -106 { location.y = -106 }
        
        // 指定位置有哪些node. 它可能包括: stoneIndicator、stoneTouched.
        // 如果手指在矩阵外count=1, 否则count=2
        let nodes = matrixNode.nodes(at: location)
        
        // 如果指示器下面的符石, 是当前符石
        // 刚刚发生交换, 手指还未移动到其他符石上时, 会触发这个
        if nodes.contains(stoneTouched) {
            //KSLog("touch the current stone")
            return
        }
        
        // 如果指示器下面的某个符石, 是剩下的29个符石中的一个. ps: 由于上面的位置调整, findNode必然有值
        let stoneNext = nodes.first { node -> Bool in
            matrixStones.contains(where: { node === $0 })
        }
        
        // 触摸的位置, 需要的目标符石的50x50范围内, 才会交换
        if abs(stoneNext!.position.x - location.x) > 25 || abs(stoneNext!.position.y - location.y) > 25 {
            //KSLog("touch the stone, but not in fit position")
            return
        }
        
        // 开始转珠时
        if steps == 0 {
            
            falls = 0
            combos = 0
            
            for index in 0 ... 6 {
                elementLabels[index].text = "首消 | 累积"
            }
            stonesAtFirst.removeAll()
            stonesAtWhole.removeAll()
            
            // 开始计时, 时间到就结束转珠
            if isTimeLocked == false {
                timerBar.run(SKAction.scaleX(to: 1.0, duration: steps_base_time), completion: swapEnded)
            }
        }
        
        // 即将交换符石
        if stoneWillSwap(from: stoneTouched, to: stoneNext as! SKRunestone) == false {
            return
        }
        
        swap(&stoneNext!.position, &stoneTouched.position)
        steps += 1
        SKSoundEffect.Key.stoneMove.play()
        
        stoneDidSwap(atIndex: steps)
    }
    
    /// 因手指离开屏幕, 而结束转珠
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        swapEnded()
    }
    
    /// 因电话接入等等, 而结束转珠
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        swapEnded()
    }
    
    /// 结束转珠环节
    /// - 手指松开屏幕
    /// - 转珠时间结束
    /// - 遇到特殊符石(未实现)
    /// - 生命值被清空(未实现)
    private func swapEnded() {
        
        // 因各种原因结束转珠, 可能会多次触发swapEnded
        if isUserInteractionEnabled == false { return }
        
        // 在面板区域滑动手指, 会触发swapEnded, 需要避免这种情况
        if stoneTouched == nil && stoneIndicator == nil { return }
        
        //KSLog("Move stone ended! steps = %d", steps)
        
        // 恢复被控制的那个符石
        stoneTouched?.alpha = 1.0
        stoneTouched = nil
        
        // 将指示器移除
        stoneIndicator?.removeFromParent()
        stoneIndicator = nil
        
        // 实际发生了符石交换, 才能开始[boom ~ fall]流程, 在这个流程中禁止触摸屏幕
        if steps > 0 {
            timerBar.removeAllActions()
            timerBar.xScale = 0.0
            isUserInteractionEnabled = false
            analysisCombo()
        }
    }
    
    /// 分析面板布局, 准备进入爆炸环节消. 矩阵会进入[boom ~ fall]循环, 直至无法消去符石
    private func analysisCombo() {
        
        // 校准位置, 为排序做准备. (注意: fall后的position不一定是在标准位置)
        for stone in matrixStones {
            stone.position = matrixNode.centerOfTile(atPosition: stone.position)
        }
        
        // 根据位置, 重新排列数组, 从而有`数组序号`与`矩阵位置`的对应关系
        matrixStones = matrixStones.sorted {
            if $0.position.y < $1.position.y { return true }
            if $0.position.y > $1.position.y { return false }
            return $0.position.x < $1.position.x
        }
        
        // 标记出boom的符石. boom规则由队伍类型决定
        for (index, stone) in matrixStones.enumerated() {
            
            let row = index / matrix_cols
            let col = index % matrix_cols
            
            let top    = (row > 0)               ? matrixStones[index - matrix_cols] : nil
            let bottom = (row < matrix_rows - 1) ? matrixStones[index + matrix_cols] : nil
            let left   = (col > 0)               ? matrixStones[index - 1] : nil
            let right  = (col < matrix_cols - 1) ? matrixStones[index + 1] : nil
            
            // 记录可以被三消的符石
            // 记录可以被二消的符石
            var any2 = [SLElementType]()
            var any3 = [SLElementType]()
            
            for effect in team.effects {
                switch effect {
                case .e000: any2.append(.水)
                case .e001: any2.append(.火)
                case .e002: any2.append(.木)
                case .e003: any2.append(.光)
                case .e004: any2.append(.暗)
                case .e005: any2.append(.心)
                    
                case .e010: any3.append(.水)
                case .e011: any3.append(.火)
                case .e012: any3.append(.木)
                case .e013: any3.append(.光)
                case .e014: any3.append(.暗)
                case .e015: any3.append(.心)
                    
                default: continue
                }
            }
            
            markBoom(center: stone, top: top, bottom: bottom, left: left, right: right, byAnyThree: any3, byAnyTwo: any2)
        }
        
        // 保存原来的combo数
        let lastComboCount = allCombos.count
        
        // 对boom的符石分组, 并构建combo
        for index in 0 ..< matrixStones.count {
            
            var combo = [SKRunestone]()
            makeCombo(index: index, combo: &combo)
            
            if combo.isEmpty { continue }
            
            allCombos.append(combo)
            
            // append操作导致count增加, 正好作为combo序号
            combo.forEach {
                $0.爆炸标记 = allCombos.count
                $0.天降标记 = falls
            }
        }
        
        // 打印矩阵信息
        //KSLog("count of combos in this fall : \(allCombos.count - lastComboCount)")
        //for row in 0 ..< matrix_rows {
        //    let min = row * matrix_cols
        //    let max = row * matrix_cols + matrix_cols
        //    let subs = matrixStones[min ..< max]
        //    let strs = subs.map { $0.description }
        //    print(strs.joined(separator: " "))
        //}
        
        // 如果没有发生boom, [boom ~ fall]流程结束, 玩家可以重新开始转珠
        if lastComboCount == allCombos.count {
            afterFall()
            return
        }
        
        // 如果发生了boom, 根据计算好的combo, 执行boom
        run(waitForThisBatch) {
            self.stoneBoom(at: lastComboCount)
        }
    }
    
    /// 结算攻击力时, 头像的跳动
    private var memberJump : SKAction = {
        let jumpUp = SKAction.moveBy(x: 0, y:  8, duration: 0.2)
        let jumpDn = SKAction.moveBy(x: 0, y: -8, duration: 0.2)
        return SKAction.sequence([jumpUp, jumpDn])
    }()
    
    /// 本轮[step ~ boom ~ fall]结束后, 在进行攻击之前, 根据连击次数、队长技能、团队技能等等, 计算最终攻击力
    private func afterFall() {
        
        // 队长跳动
        if let monster = team[0] {
            memberNodes[0].run(memberJump)
        }
        
        // 战友跳动
        if let monster = team[5] {
            memberNodes[5].run(memberJump)
        }
        
        // 攻击力跳动
        for monster_index in 0 ... 5 {
            
            guard let monster = team[monster_index] else { continue }
            
            let oldAttack = attackNodes[monster_index].number
            
            let rate = 1.00 + (combos - 1) * 0.25
            let newAttack = oldAttack * rate
            attackNodes[monster_index].isHidden = false
            attackNodes[monster_index].setNumber(newAttack.asInt, animated: true)
            attackNodes[monster_index].run(SKAction.sequence([SKAction.scale(to: 1.2, duration: 0.2), SKAction.scale(to: 1.0, duration: 0.2)]))
        }
        
        // 发起攻击
        perform(#selector(attackEmeny), with: nil, afterDelay: 0.4)
    }
    
    /// 敌人被击中时, 伤害往上跳动的效果
    private var damageAction : SKAction = {
        let fade = SKAction.fadeOut(withDuration: 1.0)
        let move = SKAction.moveBy(x: 0, y: 100, duration: 1.0)
        let disappearAndUp = SKAction.group([fade, move])
        let remove = SKAction.removeFromParent()
        return SKAction.sequence([disappearAndUp, remove])
    }()
    
    /// 发起攻击的音效
    private let attackReadySound = SKAction.playSoundEffect(SKSoundEffect.Key.attackReady)
    
    /// 发起攻击后等待一段时间, 才将emitter移去
    private let waitForDisappear = SKAction.wait(forDuration: 0.2)
    
    /// 敌人被不同属性的成员击中时, 击中的音效
    private let hitKeys : [SKSoundEffect.Key] = [
        .hitByWater,
        .hitByFlame,
        .hitByEarth,
        .hitByLight,
        .hitByMurky
    ]
    
    /// 敌人被不同属性的成员击中时, 伤害文字的颜色
    private let labelColors : [Int] = [
        0x0000ff,
        0xff0000,
        0x00ff00,
        0xffff00,
        0x000000
    ]
    
    /// 成员攻击时, emitter使用的纹理
    private let particleNames : [SKTexture] = [
        SKTexture(imageNamed: "水元素攻击"),
        SKTexture(imageNamed: "火元素攻击"),
        SKTexture(imageNamed: "木元素攻击"),
        SKTexture(imageNamed: "光元素攻击"),
        SKTexture(imageNamed: "暗元素攻击")
    ]
    
    /// 攻击敌人
    @objc private func attackEmeny() {
        
        run(attackReadySound)
        
        let target = emenyNode.convert(emenyNode.position, to: self)
        
        // 虽然队伍能够拥有6个成员, 但是可能出现没有编满的队伍, 也可能出现某个成员没有攻击力的情况
        var attackerCount = 0
        
        for monster_index in 0 ..< SLTeam.MaxMemebersCount {
            
            guard let monster = team[monster_index] else { continue }
            
            if attackNodes[monster_index].number == 0 { continue }
            
            let memberPos = memberNodes[monster_index].position
            let source = convert(memberPos, to: self)
            
            let elementIndex = monster.元素属性.rawValue
            
            let emitter = SKEmitterNode(fileNamed: "shoot")!
            emitter.targetNode = self
            emitter.position = source
            emitter.particleTexture = particleNames[elementIndex]
            addChild(emitter)
            
            let waitForAttack = SKAction.wait(forDuration: 0.2 * attackerCount)
            
            let moveX = SKAction.moveTo(x: target.x, duration: 0.3)
            moveX.timingFunction = { $0 * $0 * $0 }
            let moveY = SKAction.moveTo(y: target.y, duration: 0.3)
            moveY.timingFunction = { $0 * $0 }
            let shoot = SKAction.group([moveX, moveY])
            
            let remove = SKAction.removeFromParent()
            
            let sequence = SKAction.sequence([waitForAttack, shoot, waitForDisappear, remove])
            emitter.run(sequence) {
                
                let attackNode = self.attackNodes[monster_index]
                let attack = attackNode.number
                
                attackNode.isHidden = true
                attackNode.setNumber(0, animated: false)
                
                let label = SKLabelNode(fontNamed: "Helvetica")
                label.text = attack.asString
                label.fontSize = 12
                label.fontColor = UIColor(hexInteger: self.labelColors[elementIndex])
                self.emenyNode.addChild(label)
                
                let sound = SKAction.playSoundEffect(self.hitKeys[elementIndex])
                label.run(sound)
                
                label.run(self.damageAction)

                if self.isLifeLocked == false {
                    
                    var newLife = self.emenyNode.currentLife - attack
                    if newLife < 0 {
                        newLife = 0
                    }
                    self.emenyNode.setCurrentLife(newLife, animation: true)
                }
            }
            
            attackerCount += 1
        }
        
        perform(#selector(memberDidAttack), with: nil, afterDelay: 0.4 * attackerCount)
    }
    
    /// 爆炸音效
    private let sounds = [SKSoundEffect.Key.stoneBoom0, .stoneBoom1, .stoneBoom2, .stoneBoom3, .stoneBoom4, .stoneBoom5, .stoneBoom6, .stoneBoom7, .stoneBoom8]
    
    /// 这批符石爆炸前, 等待0.1s, 不然[手指刚松开就开始炸符石], 体验不好
    private let waitForThisBatch = SKAction.wait(forDuration: 0.2)
    
    /// 下一组符石爆炸前, 需要等待0.2s
    private let waitForNextCombo = SKAction.wait(forDuration: 0.4)
    
    /// 符石爆炸后天降前, 需要等待0.2s
    private let waitForNextFall = SKAction.wait(forDuration: 0.4)
    
    /// 符石爆炸的动画
    private var stoneBoomAction : SKAction = {
        let boom = SLAnimations.stoneBoom!
        let remove = SKAction.removeFromParent()
        return SKAction.sequence([boom, remove])
    }()
    
    /// 符石爆炸
    private func stoneBoom(at index: Int) {
        
        // 这次爆炸的一组符石
        let combo = allCombos[index]

        // 告诉父节点, 发生爆炸了 TODO: 导致boom的节奏不正常
        stoneDidBoom(atCombo: combo)

        // 爆炸时, 响起音效
        let soundId = (index < 8) ? index : 8
        sounds[soundId].play()
        
        // 符石爆炸
        let boom = SKAction.run {
            for stone in combo {
                //KSLog("stone boom: %@", stone)
                stone.run(self.stoneBoomAction)
            }
        }
        
        if index < allCombos.count - 1 {
            // 下一组
            run(SKAction.sequence([boom, waitForNextCombo])) {
                self.stoneBoom(at: index + 1)
            }
        }
        else {
            // 最后一组, 这组符石爆炸结束后, 执行天降
            run(SKAction.sequence([boom, waitForNextFall]), completion: stoneFall)
        }
    }
    
    /// 天降符石
    private func stoneFall() {

        stoneWillFall()

        // 有num个符石需要天降
        var num = 0
        
        // 准备stonesByColumn对象, 它是用于对符石按照column分组
        var stonesByColumn = [Int : [SKRunestone]]()
        for col in 0 ..< matrix_cols {
            stonesByColumn[col] = [SKRunestone]()
        }
        
        // 按col分组, 将boom的符石挑选出来, 从而确定如何增加新符石
        for (index, stone) in matrixStones.enumerated().reversed() {
            if stone.爆炸标记 == 0 {continue}
            num += 1
            matrixStones.remove(at: index) // 从stones中移除
            let col = matrixNode.tileColumnIndex(fromPosition: stone.position)
            stonesByColumn[col]?.append(stone) // 加入column中
        }
        
        // 从reserveStones中, 按照元素类型的顺序, 取出num个元素. 如果个数不足, 增加随机元素
        let elementTypes = [SLElementType.水, .火, .木, .光, .暗, .心]
        var objects = [SKRunestone]()
        while reserveStones.isEmpty == false && num > 0 {
            for elementType in elementTypes {
                if let index = reserveStones.index(where: { $0.元素属性 == elementType }) {
                    objects.append(reserveStones[index])
                    reserveStones.remove(at: index)
                    num -= 1
                    break
                }
            }
        }
        while num > 0 {
            let object = SKRunestone(element: .random)
            objects.append(object)
            num -= 1
        }
        
        // 根据boom的结果, 将新增的符石添加在[版面/矩阵]上
        for (col, stones) in stonesByColumn {
            
            for row in 0 ..< stones.count {
                
                let index = Int(arc4random()) % objects.count
                let newStone = objects[index]
                objects.remove(at: index)
                
                newStone.position = matrixNode.centerOfTile(atColumn: col, row: 5 + row)
                matrixStones.append(newStone)
                matrixNode.addChild(newStone)
            }
        }
        
        // 按col分组, 将所有的符石挑选出来, 从而确定如何降落
        for col in 0 ..< matrix_cols {
            stonesByColumn[col]?.removeAll()
        }
        for stone in matrixStones {
            let col = matrixNode.tileColumnIndex(fromPosition: stone.position)
            stonesByColumn[col]?.append(stone)
        }
        for col in 0 ..< matrix_cols {
            stonesByColumn[col] = stonesByColumn[col]?.sorted(by: { $0.position.y < $1.position.y })
        }
        
        // 每落下1像素, 所消耗的时间(秒)
        let durationPerPixel: Double = 0.002
        
        // 收集每颗符石降落的结果, 执行符石的坠落动画, 并找到最长耗时
        let group = DispatchGroup()
        for (col, stones) in stonesByColumn {
            for (row, stone) in stones.enumerated() {
                let targetY = matrixNode.centerOfTile(atColumn: col, row: row).y
                var duration = Double(stone.position.y - targetY) * durationPerPixel
                if duration <= 0 { duration = 0.01 }
                let action = SKAction.moveTo(y: targetY, duration: duration)
                action.timingMode = .easeIn
                group.enter()
                stone.run(action) {
                    group.leave()
                }
            }
        }
        
        falls += 1
        stoneDidFall()
        
        // 所有符石降落结束后, 执行下一步
        group.notify(queue: .main, execute: analysisCombo)
    }
    
    /// three: 这些属性将会三消
    /// two:   这些属性将会二消
    private func markBoom(center: SKRunestone, top: SKRunestone?, bottom: SKRunestone?, left: SKRunestone?, right: SKRunestone?, byAnyThree any3:[SLElementType], byAnyTwo any2: [SLElementType]) {
        
        if any3.contains(center.元素属性) && markBoomByAny3(center: center, top: top, bottom: bottom, left: left, right: right) {
            return
        }
        
        if any2.contains(center.元素属性) && markBoomByAny2(center: center, top: top, bottom: bottom, left: left, right: right) {
            return
        }
        
        _ = markBoomByLine(center: center, top: top, bottom: bottom, left: left, right: right)
    }
    
    /// 属性相同的三颗符石相邻时, 可消除
    private func markBoomByAny3(center: SKRunestone, top: SKRunestone?, bottom: SKRunestone?, left: SKRunestone?, right: SKRunestone?) -> Bool {
        
        var marked = [center]
        
        if center.元素属性 == top?.元素属性 {
            marked.append(top!)
        }
        
        if center.元素属性 == bottom?.元素属性 {
            marked.append(bottom!)
        }
        
        if center.元素属性 == left?.元素属性 {
            marked.append(left!)
        }
        
        if center.元素属性 == right?.元素属性 {
            marked.append(right!)
        }
        
        if marked.count >= 3 {
            marked.forEach { $0.爆炸标记 = -1 }
        }
        
        return (marked.count >= 3)
    }
    
    /// 属性相同的两颗符石相邻时, 可消除
    private func markBoomByAny2(center: SKRunestone, top: SKRunestone?, bottom: SKRunestone?, left: SKRunestone?, right: SKRunestone?) -> Bool {
        
        var marked = [center]
        
        if center.元素属性 == top?.元素属性 {
            marked.append(top!)
        }
        
        if center.元素属性 == bottom?.元素属性 {
            marked.append(bottom!)
        }
        
        if center.元素属性 == left?.元素属性 {
            marked.append(left!)
        }
        
        if center.元素属性 == right?.元素属性 {
            marked.append(right!)
        }
        
        if marked.count >= 2 {
            marked.forEach { $0.爆炸标记 = -1 }
        }
        
        return (marked.count >= 2)
    }
    
    /// 横排或直排连续三颗属性相同的符石, 才可消除
    private func markBoomByLine(center: SKRunestone, top: SKRunestone?, bottom: SKRunestone?, left: SKRunestone?, right: SKRunestone?) -> Bool {
        
        var marked = [center]
        
        if center.元素属性 == top?.元素属性 && center.元素属性 == bottom?.元素属性 {
            marked.append(top!)
            marked.append(bottom!)
        }
        
        if center.元素属性 == left?.元素属性 && center.元素属性 == right?.元素属性 {
            marked.append(left!)
            marked.append(right!)
        }
        
        if marked.count >= 3 {
            marked.forEach { $0.爆炸标记 = -1 }
        }
        
        return (marked.count >= 3)
    }
    
    /// 对已标记的符石分组, 每一组就是一个combo.
    private func makeCombo(index: Int, combo: inout [SKRunestone]) {
        
        let center = matrixStones[index]
        
        if center.爆炸标记 >= 0 { return } // 不能boom, 或者已经加入其它combo中
        
        if combo.contains(center) { return } // 已经加入本combo中
        
        combo.append(center) // 加入到本combo中
        
        /* 后面的代码是, 找到四周的符石进行递归 */
        let col  = index % matrix_cols
        let row  = index / matrix_cols
        
        var nexts = [Int]()
        
        if row > 0        { nexts.append(index - matrix_cols) } // bottom
        if row < matrix_rows - 1 { nexts.append(index + matrix_cols) } // top
        if col < matrix_cols - 1 { nexts.append(index + 1) }    // right
        if col > 0        { nexts.append(index - 1) }    // left
        
        for next in nexts {
            let stone = matrixStones[next]
            if center.元素属性 == stone.元素属性, stone.爆炸标记 < 0 {
                makeCombo(index: next, combo: &combo)
            }
        }
    }
}
