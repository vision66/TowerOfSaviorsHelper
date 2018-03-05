//
//  KosmosSpriteKit.swift
//  Kosmos
//
//  Created by weizhen on 2017/10/9.
//  Copyright © 2017年 aceasy. All rights reserved.
//

import SpriteKit

extension SKTileMapNode {
    
    /// https://developer.apple.com/library/content/documentation/Xcode/Reference/xcode_markup_formatting_ref/index.html
    /// - Parameter position: A point in the area of some tile
    /// - Returns: The coordinates in points of the center of the tile for a given position.
    func centerOfTile(atPosition position: CGPoint) -> CGPoint {
        let col = tileColumnIndex(fromPosition: position)
        let row = tileRowIndex(fromPosition: position)
        return centerOfTile(atColumn: col, row: row)
    }
}

extension SKNode {
    
    /// Searches the children of the receiving node for a node with a specific name.
    ///
    /// If more than one child share the same name, the first node discovered is returned.
    /// - Parameter name: The name to search for. This may be either the literal name of the node or a customized search string. See [Searching the Node Tree](apple-reference-documentation://hsY9-_wZau).
    /// - Returns: If a node object with that name is found, the method returns the node object. Otherwise, it returns nil.
    func labelNode(withName name: String) -> SKLabelNode? {
        return childNode(withName: name) as? SKLabelNode
    }
}

extension UIGestureRecognizer {
    
    /// - Parameter scene: A SKScene object on which the gesture took place.
    /// - Returns: A point in the local coordinate system of scene that identifies the location of the gesture.
    func location(in scene: SKScene) -> CGPoint? {
        guard let view = scene.view else { return nil }
        let position = self.location(in: view)
        return scene.convertPoint(fromView: position)
    }
}

protocol SceneClickableType {
    
    /// If a `SKButton` is pressed, this method will be called.
    ///
    /// - Parameters:
    ///   - scene: the receiving scence
    ///   - button: the receiving button
    func scene(_ scene: SKScene, click button: SKButton)
}

class SKButton: SKSpriteNode {
    
    /// 按钮被按下时
    private(set) var isHighlighted = false {
        
        didSet {
            
            // 如果是相同的行为, 就忽略
            guard oldValue != isHighlighted else { return }
            
            // 清除所有的动作
            removeAllActions()
            
            // 当按钮按下时, 执行`缩小`的动作
            let newScale: CGFloat = isHighlighted ? 0.99 : 1.00
            let scaleAction = SKAction.scale(to: newScale, duration: 0.15)
            
            // 当按钮被按下时, 执行`变暗`的动作
            let newColorBlendFactor: CGFloat = isHighlighted ? 0.5 : 0.0
            let colorBlendAction = SKAction.colorize(withColorBlendFactor: newColorBlendFactor, duration: 0.15)
            
            // 当按钮按下时的音效
            let newSound = isHighlighted ? "button_down.m4a" : "button_up.m4a"
            let soundAction = SKAction.playSoundFileNamed(newSound, waitForCompletion: false)

            // 几个动作同时执行
            run(SKAction.group([scaleAction, colorBlendAction, soundAction]))
        }
    }
    
    /// 按钮被选中时
    var isSelected = false {
        
        didSet {

            // 如果是相同的行为, 就忽略
            //guard oldValue != isSelected else { return }
            
            /// 如果设置了纹理图片
            if let textureX = selectedTexture {
                texture = textureX
                return
            }
            
            // 清除所有的动作
            removeAllActions()
            
            // 当按钮被按下时, 执行`变暗`的动作
            let newColorBlendFactor: CGFloat = isSelected ? 0.5 : 0.0
            let colorBlendAction = SKAction.colorize(withColorBlendFactor: newColorBlendFactor, duration: 0.15)

            // 执行选中动画
            run(colorBlendAction)
        }
    }
    
    /// 普通状态下的按钮纹理. see [isSelected]()
    var defaultTexture: SKTexture?
    
    /// 选中状态下的按钮纹理. @see isSelected
    var selectedTexture: SKTexture?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // 保存按钮的default纹理
        defaultTexture = texture
        
        // 需要专门制定这个参数
        selectedTexture = nil
        
        // 使NodeButton能够接受用户触摸
        isUserInteractionEnabled = true
    }
    
    override init(texture: SKTexture?, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        // 保存按钮的default纹理
        defaultTexture = texture
        
        // 需要专门制定这个参数
        selectedTexture = nil
        
        // 使NodeButton能够接受用户触摸
        isUserInteractionEnabled = true
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        
        let newButton = super.copy(with: zone) as! SKButton
        
        newButton.defaultTexture = defaultTexture?.copy() as? SKTexture
        newButton.selectedTexture = selectedTexture?.copy() as? SKTexture
        
        return newButton
    }
    
    private var allEvents = [(target: AnyObject, action: Selector, controlEvents: UIControlEvents)]()
    
    func addTarget(_ target: AnyObject, action: Selector, for controlEvents: UIControlEvents) {
        allEvents.append((target, action, controlEvents))
    }
    
    func removeTarget(_ target: AnyObject, action: Selector?, for controlEvents: UIControlEvents) {
        
        let index = allEvents.index {
            if action == nil {
                return $0.target === target && $0.controlEvents == controlEvents
            } else {
                return $0.target === target && $0.controlEvents == controlEvents && $0.action == action
            }
        }
        
        if let myIndex = index {
            allEvents.remove(at: myIndex)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isHighlighted = true
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        isHighlighted = false
        
        guard let scene = scene else { fatalError("Button must be used within a SKScene.") }
        
        let isTouched = touches.contains { touch in
            let touchPoint = touch.location(in: scene)
            let touchedNode = scene.atPoint(touchPoint)
            return touchedNode === self || touchedNode.inParentHierarchy(self)
        }
        
        if isTouched && isUserInteractionEnabled {
            
            var done = false
            
            for myEvent in allEvents {
                if myEvent.controlEvents.contains(.touchUpInside) {
                    _ = myEvent.target.perform(myEvent.action, with: self)
                    done = true
                }
            }
            
            if done == false {
                
                if let myScene = scene as? SceneClickableType {
                    myScene.scene(scene, click: self)
                }
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        super.touchesCancelled(touches!, with: event)
        isHighlighted = false
    }
}
