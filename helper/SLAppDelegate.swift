//
//  AppDelegate.swift
//  SpriteKitDemo
//
//  Created by weizhen on 2017/10/31.
//  Copyright © 2017年 weizhen. All rights reserved.
//

import UIKit
import SpriteKit

@UIApplicationMain
class SLAppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        KSLog("doc: %@", NSHomeDirectory())
        KSLog("app: %@", Bundle.main.bundlePath)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = SLViewController()
        window?.backgroundColor = UIColor.white
        window?.makeKeyAndVisible()
        return true
    }
}


class SLViewController: UIViewController {
    
    override func loadView() {
        
        let skView = SKView(frame: UIScreen.main.bounds)
        self.view = skView
        
        let scene = SKScene(fileNamed: "SKLaunch")!
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
    }
}
