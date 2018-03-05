//
//  KosmosCoreGraphics.swift
//  Kosmos
//
//  Created by weizhen on 2017/11/10.
//  Copyright © 2017年 aceasy. All rights reserved.
//

import CoreGraphics

func CGPointMake(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
    return CGPoint(x: x, y: y)
}

func CGSizeMake(_ width: CGFloat, _ height: CGFloat) -> CGSize {
    return CGSize(width: width, height: height)
}

func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
    return CGRect(x: x, y: y, width: width, height: height)
}

extension CGContext {
    
    func setStrokeColor(hex: Int, alpha: CGFloat) {
        self.setStrokeColor(red: ((hex >> 16) & 0xFF) / 255.0, green: ((hex >> 8) & 0xFF) / 255.0, blue: ((hex) & 0xFF) / 255.0, alpha: alpha)
    }
    
    func setFillColor(hex: Int, alpha: CGFloat) {
        self.setFillColor(red: ((hex >> 16) & 0xFF) / 255.0, green: ((hex >> 8) & 0xFF) / 255.0, blue: ((hex) & 0xFF) / 255.0, alpha: alpha)
    }
}
