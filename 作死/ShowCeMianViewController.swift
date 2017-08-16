//
//  ShowCeMianViewController.swift
//  作死
//
//  Created by 董嘉豪 on 2017/8/2.
//  Copyright © 2017年 董嘉豪. All rights reserved.
//

import UIKit
import GPUImage
import Photos

//侧面边缘检测
class ShowCeMianViewController: FilterUIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        边缘检测后的侧面 = eDFilter(inputImage: gBFilter(inputImage: 侧面!, strength: 4), strength: 7)
        侧面 = nil
        
        initButton(title: "下一步",
                   x: self.view.frame.width * 0.5 - 50,
                   y: 20,
                   width: 100,
                   height: 30,
                   tpye: .jump,
                   details: "FXViewController",
                   function: #selector(ShowCeMianViewController.jump(_ :)))
        
        initButton(title: "保存图片",
                   x: self.view.frame.width - 116,
                   y: 20,
                   width: 100,
                   height: 30,
                   tpye: .image,
                   details: 边缘检测后的侧面!,
                   function: #selector(ShowCeMianViewController.sharePhoto(_ :)))
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
