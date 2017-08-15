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
        
        let next = JumpButton(type: .system)
        next.frame = CGRect(x: self.view.frame.width * 0.5 - 50,
                            y: 20,
                            width: 100,
                            height: 30)
        next.setTitle("下一步", for: UIControlState.normal)
        next.string = "FXViewController"
        next.addTarget(self, action: #selector(ShowCeMianViewController.jump(_ :)), for:.touchUpInside)
        self.view.addSubview(next)
        
        let share = ImageButton(type: .system)
        share.frame = CGRect(x: self.view.frame.width - 116,
                             y: 20,
                             width: 100,
                             height: 30)
        share.setTitle("保存图片", for: UIControlState.normal)
        share.image = 边缘检测后的侧面
        share.addTarget(self, action: #selector(ShowCeMianViewController.sharePhoto(_ :)), for:.touchUpInside)
        self.view.addSubview(share)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
