//
//  ImagePickerController.swift
//  TowerOfSaviors
//
//  Created by weizhen on 2018/10/23.
//  Copyright © 2018 aceasy. All rights reserved.
//

import UIKit

class ImagePickerController: UIImagePickerController {

    //var statusBarHidden: Bool = true
    //
    //override func viewWillAppear(_ animated: Bool) {
    //    super.viewWillAppear(animated)
    //    statusBarHidden = false
    //    UIView.animate(withDuration: 0.5) {
    //        self.setNeedsStatusBarAppearanceUpdate()
    //    }
    //}
    //
    //override func viewWillDisappear(_ animated: Bool) {
    //    super.viewWillDisappear(animated)
    //    statusBarHidden = true
    //    UIView.animate(withDuration: 0.5) {
    //        self.setNeedsStatusBarAppearanceUpdate()
    //    }
    //}
    //
    //override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
    //    return .slide
    //}
    //
    //override var prefersStatusBarHidden: Bool {
    //    return statusBarHidden
    //}
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
}
