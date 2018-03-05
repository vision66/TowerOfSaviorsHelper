//
//  SKMenuLayer.swift
//  helper
//
//  Created by weizhen on 2017/11/3.
//  Copyright © 2017年 aceasy. All rights reserved.
//

import SpriteKit

enum SLMenuIdentify : String {
    case replay = "重新开始"
    case cards  = "编辑队伍"
    case stones = "编辑符石"
    case about  = "关于软件"
    case commit = "编辑完成"
    case cancel = "收起菜单"
}

class SKMenu: SKButton {
    
    let identify : SLMenuIdentify
    
    init(identify : SLMenuIdentify) {
        self.identify = identify
        let texture = SKTexture(imageNamed: "button1_nn")
        super.init(texture: texture, color: UIColor.red, size: texture.size())
        
        let label = SKLabelNode(fontNamed: "Helvetica")
        label.text = identify.rawValue
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.fontSize = 16
        addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SKMenuLayer: SKSpriteNode {

    private(set) var menus : [SKMenu]
    
    init(identifies: [SLMenuIdentify]) {

        menus = identifies.map { SKMenu(identify: $0) }
        
        let color = UIColor(white: 0.0, alpha: 0.5)
        let size = CGSize(width: 320, height: 480)
        
        super.init(texture: nil, color: color, size: size)
        
        let space = 10.0 as CGFloat
        let count = menus.count
        let height = menus.first!.size.height
        let firstY = CGFloat(count - 1) * (height + space) / 2
        
        for (index, menu) in menus.enumerated() {
            menu.position = CGPoint(x: 0, y: firstY - CGFloat(index) * (space + height))
            addChild(menu)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addTarget(_ target: AnyObject, action: Selector) {
        for menu in menus {
            menu.addTarget(target, action: action, for: .touchUpInside)
        }
    }
}
