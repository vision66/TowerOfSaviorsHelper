//
//  main.swift
//  imageLoader
//
//  Created by weizhen on 2018/9/20.
//  Copyright © 2018年 Wuhan Mengxin Technology Co., Ltd. All rights reserved.
//

import Foundation

let filePath = "/Users/weizhen/Downloads/怪兽索引.json"
let fileURL = URL(fileURLWithPath: filePath)
guard let fileData = try? Data(contentsOf: fileURL) else {
    print("load '\(filePath)' failed")
    exit(0)
}
print("load '\(filePath)' success")



guard let json = try? JSONSerialization.jsonObject(with: fileData, options: JSONSerialization.ReadingOptions.mutableLeaves) else {
    print("convert to json failed")
    exit(0)
}
print("convert to json success")



let saveFile = "/Users/weizhen/Downloads/icons/"
let monsters = json as! [[String : Any]]
for (index, monster) in monsters.enumerated() {
    
    let name = monster["怪兽名称"] as! String
    let source = monster["怪兽头像"] as! String
    let target = saveFile + name + "@2x.png"
    let sourceURL = URL(string: source)!
    let targetURL = URL(fileURLWithPath: target)
    
    var isDirectory = ObjCBool(false)
    if FileManager.default.fileExists(atPath: target, isDirectory: &isDirectory) || isDirectory.boolValue {
        print("load \(index) \(name) exists")
        continue
    }
    
    guard let data = try? Data(contentsOf: sourceURL) else {
        print("load \(index) \(name) failed")
        continue
    }
    
    do {
        try data.write(to: targetURL)
    } catch {
        print("save \(index) \(name) failed")
        continue
    }
    
    print("load \(index) \(name) success")
}

