//
//  SobelEdgeDetection.swift
//  作死
//
//  Created by 董嘉豪 on 2017/5/8.
//  Copyright © 2017年 董嘉豪. All rights reserved.
//

import UIKit
import GPUImage
import Photos

//底面边缘检测
class SobelEdgeDetection: FilterUIViewController {
    
//    func xZBianHuan() {
//        //翻转图片的方向
//        let flipImageOrientation = (s.imageOrientation.rawValue + 3) % 8
//        //翻转图片
//        s = UIImage(cgImage: s.cgImage!,
//                    scale: s.scale,
//                    orientation: UIImageOrientation(rawValue: flipImageOrientation)!
//        )
////        print(image.size.width)
////        print(image.size.height)
////        print(s.size.width)
////        print(s.size.height)
//        showImage()
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        var imageView: GPUImageView? = GPUImageView(frame: self.view.frame)
//        self.view = imageView
        
        边缘检测后的底面 = eDFilter(inputImage: gBFilter(inputImage: 底面!, strength: 2), strength: 4)
        底面 = nil
        
        initButton(title: "下一步",
                   x: self.view.frame.width * 0.5 - 50,
                   y: 20,
                   width: 100,
                   height: 30,
                   tpye: .jump,
                   details: "CeMian",
                   function: #selector(SobelEdgeDetection.jump(_ :)))
        
        initButton(title: "保存图片",
                   x: self.view.frame.width - 116,
                   y: 20,
                   width: 100,
                   height: 30,
                   tpye: .image,
                   details: 边缘检测后的底面!,
                   function: #selector(SobelEdgeDetection.sharePhoto(_ :)))
        
//        let xuanZhuan: UIButton = UIButton(type: .system)
//        xuanZhuan.frame = CGRect(x: 10, y: 70, width: 200, height: 50)
//        xuanZhuan.setTitle("顺时针旋转90°后进入下一步", for: UIControlState.normal)
//        xuanZhuan.addTarget(self, action: #selector(SobelEdgeDetection.xZBianHuan), for:.touchUpInside)
//        self.view.addSubview(xuanZhuan)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
