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
        
        //        let xuanZhuan: UIButton = UIButton(type: .system)
        //        xuanZhuan.frame = CGRect(x: 10, y: 70, width: 200, height: 50)
        //        xuanZhuan.setTitle("顺时针旋转90°后进入下一步", for: UIControlState.normal)
        //        xuanZhuan.addTarget(self, action: #selector(SobelEdgeDetection.xZBianHuan), for:.touchUpInside)
        //        self.view.addSubview(xuanZhuan)
        
        // Do any additional setup after loading the view.
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
