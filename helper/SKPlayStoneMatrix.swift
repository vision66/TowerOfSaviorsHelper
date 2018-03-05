//
//  SLNMatrix.swift
//  helper
//
//  Created by weizhen on 2017/11/2.
//  Copyright © 2017年 aceasy. All rights reserved.
//

import SpriteKit

/// 一次Combo
typealias SLElementStoneCombo = [SKElementStone]

/**
 1. 手指按下, 并且移动. 但是这并不代表就开始转珠了. 只有存在符石发生交换, 才认为是转珠.
 2. 发生转珠后, 手指松开屏幕, 才认为是结束转珠. 此时需要禁止手指操作.
 3. 结束转珠后, 根据规则, 检测可以发生爆炸的符石, 并对符石分组:
 3.1 没有发现发生爆炸的符石, 认为是爆炸&天降结束. 此时需要解除手指禁止.
 3.2 发现可以爆炸的符石. 第1组符石爆炸时, 让第2组符石延迟x秒后爆炸, ..., 第n组符石延迟x秒后爆炸, 当第n组符石爆炸完全结束后, 才开始执行天降
 4. 天降结束后, 转入3
 */
class SKPlayStoneMatrix: SKTileMapNode {
    
    weak var delegate : SLNMatrixDelegate?
    
    /// 跟随手指移动的符石替身, 它并不在elementStones中. 如果值为nil, 不认为当前手指在按下, 并企图拖拽符石
    private var stoneIndicator : SKElementStone?
    
    /// 正在操纵的符石, 它在elementStones中. 如果值为nil, 不认为当前手指在按下, 并企图拖拽符石
    private var stoneTouched : SKElementStone?
    
    /// 位于`矩阵`上的30颗符石
    private var allStones = [SKElementStone]()
    
    /// 总的combo数
    var allCombos = [SLElementStoneCombo]()
    
    /// 移动符石时, 交换的次数. 如果值为0, 不认为当前进行的移动符石的操作
    private var steps = 0
    
    /// 发生天降的次数
    private var falls = 0
    
    /// 当前队伍
    private let team: SLTeam
    
    /// 这些元素可以3消
    private let any3 : [SLElement]
    
    /// 这些元素可以2消
    private let any2 : [SLElement]
    
    /// 针对这种类型计数: "移动符石时触碰的首 5 粒符石转化为光强化符石"
    private var swapCount : Int = 0
    
    /// 针对这种类型计数: "每首批消除一组水、火或木符石将掉落 4 粒火强化符石；每首批消除一组光、暗或心符石，将掉落 4 粒心强化符石；"
    /// 天降池. 即将天降的符石, 一定会从其中获取, 只有池空时才会随机取的
    private var pool = [SLStone]()
    
    /// 针对这种类型计数: "每累计消除 10 粒火或心符石，将掉落 1 粒火妖族强化符石"
    private var 樱樱火妖 : Int = 0
    
    init(team: SLTeam) {
        
        self.team = team
        
        var any3 = [SLElement]()
        if team.effects.contains(where: { $0 == "符石三消" }) {
            any3 = [.水, .火, .木, .光, .暗, .心]
        }
        self.any3 = any3
        
        var any2 = [SLElement]()
        if team.effects.contains(where: { $0 == "符石二消 水" }) {
            any2.append(.水)
        }
        if team.effects.contains(where: { $0 == "符石二消 火" }) {
            any2.append(.火)
        }
        if team.effects.contains(where: { $0 == "符石二消 木" }) {
            any2.append(.木)
        }
        if team.effects.contains(where: { $0 == "符石二消 光" }) {
            any2.append(.光)
        }
        if team.effects.contains(where: { $0 == "符石二消 暗" }) {
            any2.append(.暗)
        }
        if team.effects.contains(where: { $0 == "符石二消 心" }) {
            any2.append(.心)
        }
        self.any2 = any2
        
        super.init()
        
        let cols = 6
        let rows = 5
        
        self.numberOfRows = rows
        self.numberOfColumns = cols
        self.tileSize = CGSize(width: 53.333, height: 53.333)
        self.isUserInteractionEnabled = true
        
        for index in 0 ..< cols * rows {
            let object = SLStone(type: .水)
            let stone = SKElementStone(stone: object)
            stone.position = self.centerOfTile(atColumn: index % cols, row: index / cols)
            self.addChild(stone)
            self.allStones.append(stone)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 将符石重置为档案中的情况
    func reset(animated: Bool = true) {
        
        if let matrixData = UserDefaults.standard.array(forKey: "stones matrix") as? [[String: Int]] {
            for (index, dict) in matrixData.enumerated() {
                let type = SLElement(rawValue: dict["type"]!)!
                let status = SLElementStatus(rawValue: dict["status"]!)!
                let overlay = SLStoneOverlay(rawValue: dict["overlay"]!)!
                let object = SLStone(type: type, status: status, overlay: overlay)
                allStones[index].setStone(stone: object, animation: animated)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        let location = touches.first!.location(in: self)
        let node = atPoint(location)
        
        if let stone = allStones.first(where: { node === $0 }) {
            
            stoneIndicator = SKElementStone(stone: stone.object)
            stoneIndicator!.position = stone.position
            addChild(stoneIndicator!)
            
            stoneTouched = stone
            stoneTouched!.alpha = 0.4
            
            steps = 0
            falls = 0
            return
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // 如果值为nil, 不认为当前手指在按下, 并企图拖拽符石
        guard let stoneIndicator = self.stoneIndicator, let stoneTouched = self.stoneTouched else { return }
        
        // 手指的位置
        var location = touches.first!.location(in: self)
        
        // 手指在哪里, 指示器就在哪里
        stoneIndicator.position = location
        
        // 手指超出矩阵区域后, 将超出范围的数据, 调整到矩阵边缘
        if location.y >  106 { location.y =  106 }
        if location.y < -106 { location.y = -106 }
        
        // 指定位置有哪些node. 它可能包括: stoneIndicator、stoneTouched、stone. 如果手指在矩阵外count=1, 否则count=2
        let nodes = self.nodes(at: location)
        
        // 如果指示器下面的符石, 是当前符石
        if nodes.contains(stoneTouched) {
            //KSLog("touch the current stone")
            return
        }
        
        // 如果指示器下面的某个符石, 是剩下的29个符石中的一个. ps: 由于上面的位置调整, findNode必然有值
        let findNode = nodes.first { (node: SKNode) -> Bool in
            allStones.contains(where: { node === $0 })
        }
        
        // 触摸的位置, 需要的目标符石的40x40范围内, 才会交换
        if abs(findNode!.position.x - location.x) > 22 || abs(findNode!.position.y - location.y) > 22 {
            //KSLog("touch the stone, but not in fit position")
            return
        }
        
        // 交换符石
        swapHappened(from: stoneTouched, to: findNode as! SKElementStone)
        swap(&findNode!.position, &stoneTouched.position)
        steps += 1
        delegate?.matrix(self, swapAtIndex: steps)
        run(SLGloabls.stoneMoveSound)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        swapEnded()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        swapEnded()
    }
    
    /// 即将交换符石
    private func swapHappened(from stone1: SKElementStone, to stone2: SKElementStone) {
        
        if swapCount < 5 && team.effects.contains(where: { $0 == "道罗斯&道罗斯"}) {
            let object = SLStone(type: .光, status: .strong)
            stone2.setStone(stone: object)
            swapCount += 1
        }
    }
    
    /// 结束转珠环节
    /// - 手指松开屏幕
    /// - 转珠时间结束(未实现)
    /// - 遇到特殊符石(未实现)
    /// - 生命值被清空(未实现)
    private func swapEnded() {
        
        KSLog("Move stone ended! steps = %d", steps)
        
        // 恢复被控制的那个符石; 将指示器移除
        if stoneTouched != nil || stoneIndicator != nil {
          
            stoneTouched?.alpha = 1.0
            stoneTouched = nil
            
            stoneIndicator?.removeFromParent()
            stoneIndicator = nil
        }
        
        // 恢复计数器
        swapCount = 0
        
        // 实际发生了符石交换, 才能开始[boom ~ fall]流程, 在这个流程中禁止触摸屏幕
        if steps > 0 {
            isUserInteractionEnabled = false
            stoneBoomAnalysis()
            return
        }
    }
    
    /// 分析面板布局, 准备进入爆炸环节消. 矩阵会进入[boom ~ fall]循环, 直至无法消去符石
    private func stoneBoomAnalysis() {
        
        let rows = numberOfRows
        let cols = numberOfColumns
        
        // 调整位置, 为排序做准备. (注意: fall后的position不一定是在标准位置)
        for stone in allStones {
            stone.position = centerOfTile(atPosition: stone.position)
        }
        
        // 根据位置, 重新排列数组, 从而有`数组序号`与`矩阵位置`的对应关系
        allStones = allStones.sorted {
            if $0.position.y < $1.position.y { return true }
            if $0.position.y > $1.position.y { return false }
            return $0.position.x < $1.position.x
        }
        
        // 标记出boom的符石. boom规则由队伍类型决定
        for (index, stone) in allStones.enumerated() {
            
            let row = index / cols
            let col = index % cols
            
            let top    = (row > 0)        ? allStones[index-cols] : nil
            let bottom = (row < rows - 1) ? allStones[index+cols] : nil
            let left   = (col > 0)        ? allStones[index-1] : nil
            let right  = (col < cols - 1) ? allStones[index+1] : nil
            
            markBoom(center: stone, top: top, bottom: bottom, left: left, right: right, byAnyThree: any3, byAnyTwo: any2)
        }
        
        // 保存原来的combo数
        let lastComboCount = allCombos.count
        
        // 对boom的符石分组, 并构建combo
        for index in 0 ..< allStones.count {
            
            var stonesInCombo = [SKElementStone]()
            makeCombo(index: index, combo: &stonesInCombo)
            
            if stonesInCombo.isEmpty == false {
                
                allCombos.append(stonesInCombo)
                
                // append操作导致count增加, 正好作为combo序号
                stonesInCombo.forEach {
                    $0.comboId = allCombos.count
                    $0.fallId = falls
                }
            }
        }
        
        // 打印矩阵信息
        KSLog("count of combos in this fall : \(allCombos.count - lastComboCount)")
        //for row in 0 ..< rows {
        //    let min = row * cols
        //    let max = row * cols + cols
        //    let subs = allStones[min ..< max]
        //    let strs = subs.map { $0.description }
        //    print(strs.joined(separator: " "))
        //}
        
        // 如果没有发生boom, [boom ~ fall]流程结束, 玩家可以重新开始转珠
        if lastComboCount == allCombos.count {
            allCombos.removeAll()
            isUserInteractionEnabled = true
            樱樱火妖 = 0
            delegate?.matrix(self, boomAndFall: true)
            
//            // 流程结束后, 随机生成2颗火和2颗木
//            if team.skills.contains(where: { $0.技能效果 == "符石二消 燃灯杨戬" }) {
//                var indexs = [Int]()
//                repeat {
//                    let num = Int(arc4random() % 30)
//                    if indexs.contains(num) == false { indexs.append(num) }
//                } while indexs.count < 4
//                allStones[indexs[0]].setType(type: .fire, animation: true)
//                allStones[indexs[1]].setType(type: .fire, animation: true)
//                allStones[indexs[2]].setType(type: .wood, animation: true)
//                allStones[indexs[3]].setType(type: .wood, animation: true)
//            }
            return
        }
        
        // 如果发生了boom, 根据计算好的combo, 执行boom
        stoneBoom(at: lastComboCount)
    }
    
    /// 符石爆炸
    private func stoneBoom(at index: Int) {
        
        let combo = allCombos[index]
        
        let first = combo.first!
        
        for stone in combo {
            if stone == first {continue}
            stone.boom(whenHappen: { }, completion: { })
        }
        
        if index != allCombos.count - 1 {
            
            first.boom(whenHappen: {
                self.delegate?.matrix(self, boomAtIndex: index)
                self.run(SKAction.wait(forDuration: 0.2), completion: {
                    self.stoneBoom(at: index + 1)
                })
            }, completion: {})
        }
        else {
            
            first.boom(whenHappen: {
                self.delegate?.matrix(self, boomAtIndex: index)
            }, completion: {
                self.stoneFall()
            })
        }
    }
    
    /// 将会天降哪些符石, 做准备
    private func prepareForFall() {
        
        // 对`本轮消除`的判定
        for combo in allCombos {
            
            if combo.first!.fallId != falls { continue }
            
            // 如果1次combo中包含5颗符石, 就会产生1颗对应的强化符石
            if combo.count >= 5 {
                let object = SLStone(type: combo.first!.object.type, status: .strong, overlay: .normal)
                pool.append(object)
            }
        }
        
        // 对`首轮消除`的判定
        if falls == 0 {
            
            // 樱&樱: 每首批消除一组水、火或木符石将掉落 4 粒火强化符石；每首批消除一组光、暗或心符石，将掉落 4 粒心强化符石
            if team.effects.contains(where: { $0 == "樱&樱" }) {
                
                for combo in allCombos {
                    let type = combo.first!.object.type
                    if type == .水 || type == .火 || type == .木 {
                        let object = SLStone(type: .火, status: .strong, overlay: .normal)
                        let objects = Array(repeating: object, count: 4)
                        pool.append(contentsOf: objects)
                    } else {
                        let object = SLStone(type: .心, status: .strong, overlay: .normal)
                        let objects = Array(repeating: object, count: 4)
                        pool.append(contentsOf: objects)
                    }
                }
            }
        }
        
        // 对`累积消除`的判定
        if team.effects.contains(where: { $0 == "樱&樱" }) {
            var 火心Whole : Int = 0
            for combo in allCombos {
                for stone in combo {
                    if stone.object.type == .火 || stone.object.type == .心 {
                        火心Whole += 1
                    }
                }
            }
            let 火心Added = 火心Whole - 樱樱火妖 * 10
            let 火妖Added = 火心Added / 10
            樱樱火妖 += 火妖Added
            
            let object = SLStone(type: .火, status: .normal, overlay: .妖精)
            let objects = Array(repeating: object, count: 火妖Added)
            pool.append(contentsOf: objects)
        }
    }
    
    /// 天降符石. 此环节由外部控制开始
    private func stoneFall() {
        
        // 填充pool
        prepareForFall()
        
        let cols = self.numberOfColumns
        
        // 有num个符石需要天降
        var num = 0
        
        // 准备stonesByColumn对象, 它是用于对符石按照column分组
        var stonesByColumn = [Int : [SKElementStone]]()
        for col in 0 ..< cols {
            stonesByColumn[col] = [SKElementStone]()
        }
        
        // 按col分组, 将boom的符石挑选出来, 从而确定如何增加新符石
        for (index, stone) in allStones.enumerated().reversed() {
            if stone.comboId == 0 {continue}
            num += 1
            allStones.remove(at: index) // 从stones中移除
            let col = tileColumnIndex(fromPosition: stone.position)
            stonesByColumn[col]?.append(stone) // 加入column中
        }
        
        // 从pool中, 按照元素类型的顺序, 取出num个元素. 如果个数不足, 增加随机元素
        var objects = [SLStone]()
        while pool.isEmpty == false && num > 0 {
            for element in [SLElement.水, .火, .木, .光, .暗, .心] {
                if let index = pool.index(where: { $0.type == element }) {
                    objects.append(pool[index])
                    pool.remove(at: index)
                    num -= 1
                    break
                }
            }
        }
        while num > 0 {
            let object = SLStone(type: .random)
            objects.append(object)
            num -= 1
        }

        // 根据分组结果, 新增符石. 这些符石添加在self版面以上, 被clip以致看不见
        for (col, stones) in stonesByColumn {
            for row in 0 ..< stones.count {
                
                let index = Int(arc4random()) % objects.count
                let object = objects[index]
                objects.remove(at: index)
               
                let newStone = SKElementStone(stone: object)
                newStone.position = centerOfTile(atColumn: col, row: 5 + row)
                allStones.append(newStone)
                self.addChild(newStone)
            }
        }
        
        // 按col分组, 将所有的符石挑选出来, 从而确定如何降落
        for col in 0 ..< cols {
            stonesByColumn[col]?.removeAll()
        }
        for stone in allStones {
            let col = self.tileColumnIndex(fromPosition: stone.position)
            stonesByColumn[col]?.append(stone)
        }
        for col in 0 ..< cols {
            stonesByColumn[col] = stonesByColumn[col]?.sorted(by: { $0.position.y < $1.position.y })
        }
        
        // 每落下1像素, 所消耗的时间(秒)
        let durationPerPixel: Double = 0.002
        
        // 收集每颗符石降落的结果, 所有符石降落结束后, 执行下一步
        let progress = Progress(totalUnitCount: 30)
        progress.addObserver(self, forKeyPath: "fractionCompleted", options: .new, context: nil)
        
        // 执行符石的坠落动画, 并找到最长耗时
        for (col, stones) in stonesByColumn {
            for (row, stone) in stones.enumerated() {
                let targetY = centerOfTile(atColumn: col, row: row).y
                var duration = Double(stone.position.y - targetY) * durationPerPixel
                if duration <= 0 { duration = 0.01 }
                let action = SKAction.moveTo(y: targetY, duration: duration)
                action.timingMode = .easeIn
                stone.run(action) {
                    progress.completedUnitCount += 1
                }
            }
        }
        
        falls += 1
        delegate?.matrix(self, fallAtIndex: falls)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "fractionCompleted", let progress = object as? Progress, progress.fractionCompleted >= 1.0 {
            progress.removeObserver(self, forKeyPath: keyPath!)
            stoneBoomAnalysis()
        }
    }

    /// three: 这些属性将会三消
    /// two:   这些属性将会二消
    private func markBoom(center: SKElementStone, top: SKElementStone?, bottom: SKElementStone?, left: SKElementStone?, right: SKElementStone?, byAnyThree any3:[SLElement], byAnyTwo any2: [SLElement]) {
       
        if any3.contains(center.object.type) && markBoomByAny3(center: center, top: top, bottom: bottom, left: left, right: right) {
            return
        }
        
        if any2.contains(center.object.type) && markBoomByAny2(center: center, top: top, bottom: bottom, left: left, right: right) {
            return
        }
        
        _ = markBoomByLine(center: center, top: top, bottom: bottom, left: left, right: right)
    }
    
    /// 属性相同的三颗符石相邻时, 可消除
    private func markBoomByAny3(center: SKElementStone, top: SKElementStone?, bottom: SKElementStone?, left: SKElementStone?, right: SKElementStone?) -> Bool {
        
        var marked = [center]
        
        if center.object.type == top?.object.type {
            marked.append(top!)
        }
        
        if center.object.type == bottom?.object.type {
            marked.append(bottom!)
        }
        
        if center.object.type == left?.object.type {
            marked.append(left!)
        }
        
        if center.object.type == right?.object.type {
            marked.append(right!)
        }
        
        if marked.count >= 3 {
            marked.forEach { $0.comboId = -1 }
        }
        
        return (marked.count >= 3)
    }
    
    /// 属性相同的两颗符石相邻时, 可消除
    private func markBoomByAny2(center: SKElementStone, top: SKElementStone?, bottom: SKElementStone?, left: SKElementStone?, right: SKElementStone?) -> Bool {
        
        var marked = [center]
        
        if center.object.type == top?.object.type {
            marked.append(top!)
        }
        
        if center.object.type == bottom?.object.type {
            marked.append(bottom!)
        }
        
        if center.object.type == left?.object.type {
            marked.append(left!)
        }
        
        if center.object.type == right?.object.type {
            marked.append(right!)
        }
        
        if marked.count >= 2 {
            marked.forEach { $0.comboId = -1 }
        }
        
        return (marked.count >= 2)
    }
    
    /// 横排或直排连续三颗属性相同的符石, 才可消除
    private func markBoomByLine(center: SKElementStone, top: SKElementStone?, bottom: SKElementStone?, left: SKElementStone?, right: SKElementStone?) -> Bool {
        
        var marked = [center]
        
        if center.object.type == top?.object.type && center.object.type == bottom?.object.type {
            marked.append(top!)
            marked.append(bottom!)
        }
        
        if center.object.type == left?.object.type && center.object.type == right?.object.type {
            marked.append(left!)
            marked.append(right!)
        }
        
        if marked.count >= 3 {
            marked.forEach { $0.comboId = -1 }
        }
        
        return (marked.count >= 3)
    }
    
    /// 对已标记的符石分组, 每一组就是一个combo.
    private func makeCombo(index: Int, combo: inout [SKElementStone]) {
        
        let center = allStones[index]
        
        if center.comboId >= 0 { return } // 不能boom, 或者已经加入其它combo中
        
        if combo.contains(center) { return } // 已经加入本combo中
        
        combo.append(center) // 加入到本combo中
        
        /* 后面的代码是, 找到四周的符石进行递归 */
        let cols = self.numberOfColumns
        let rows = self.numberOfRows
        let col  = index % cols
        let row  = index / cols
        
        var nexts = [Int]()
        
        if row > 0        { nexts.append(index - cols) } // bottom
        if row < rows - 1 { nexts.append(index + cols) } // top
        if col < cols - 1 { nexts.append(index + 1) }    // right
        if col > 0        { nexts.append(index - 1) }    // left
        
        for next in nexts {
            let stone = allStones[next]
            if center.object.type == stone.object.type, stone.comboId < 0 {
                self.makeCombo(index: next, combo: &combo)
            }
        }
    }
}

protocol SLNMatrixDelegate : NSObjectProtocol {
    
    /// 符石转动环节. finished=true时, 表示转动结束
    func matrix(_ sender: SKPlayStoneMatrix, swapAtIndex index: Int)
    
    /// 符石天降环节. index是本轮天降的序号
    func matrix(_ sender: SKPlayStoneMatrix, fallAtIndex index: Int)
    
    /// 符石爆炸环节. 从combo=index的符石开始爆炸
    func matrix(_ sender: SKPlayStoneMatrix, boomAtIndex index: Int)
    
    /// [爆炸~天降]结束了, 可以开始下一次手转. finished永远是true
    func matrix(_ sender: SKPlayStoneMatrix, boomAndFall finished: Bool)
}
