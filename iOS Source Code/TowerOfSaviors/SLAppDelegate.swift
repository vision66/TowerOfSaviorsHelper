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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
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
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}


/*
 320x480 ~ 320x480 ~ iPhone 4, iPhone 4s,
 320x568 ~ 320x568 ~ iPhone 5, iPhone 5s, iPhone 5c, iPhone SE
 320x569 ~ 375x667 ~ iPhone 6, iPhone 6s, iPhone 7, iPhone 8
 320x568 ~ 414x736 ~ iPhone 6 Plus, iPhone 6s Plus, iPhone 7 Plus, iPhone 8 Plus
 320x693 ~ 375x812 ~ iPhone X, iPhone XS
 320x692 ~ 414x896 ~ iPhone XS Max, iPhone XR
 */
