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
class SobelEdgeDetection: UIViewController {
    
    var imagePicture: GPUImagePicture? = GPUImagePicture()
    
    func showImage() {
        let myStoryBoard = self.storyboard
        let anotherView:UIViewController = (myStoryBoard?.instantiateViewController(withIdentifier: "CeMian"))! as UIViewController
        self.present(anotherView, animated: true, completion: nil)
    }
        
    func sharePhoto() {
        //保存图片
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: 边缘检测后的底面!)
        }, completionHandler: { (isSuccess: Bool, error: NSError?) in
            if isSuccess {
                print("保存成功!")
            } else {
                print("保存失败：", error!.localizedDescription)
            }
            } as? (Bool, Error?) -> Void)
    }
    
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
        imagePicture = GPUImagePicture(image: 底面!)
        底面 = nil
        
        var gaussianBlurFilter: GPUImageGaussianBlurFilter? = GPUImageGaussianBlurFilter()
        //模糊处理程度，值越大，噪声影响越小，但会少量降低边界清晰度
        gaussianBlurFilter!.texelSpacingMultiplier = 2

        var edgeDetectionFilter: GPUImageSobelEdgeDetectionFilter? = GPUImageSobelEdgeDetectionFilter()
        //边界检测强度，值越大，边界线约清晰，但会少量增加噪声数量和强度
        edgeDetectionFilter!.edgeStrength = 4
        
        imagePicture!.addTarget(gaussianBlurFilter)
        gaussianBlurFilter!.addTarget(self.view as! GPUImageInput!)
        imagePicture!.processImage()
        gaussianBlurFilter!.useNextFrameForImageCapture()
        边缘检测后的底面 = gaussianBlurFilter!.imageFromCurrentFramebuffer()
        
        gaussianBlurFilter = nil
        

        imagePicture = GPUImagePicture(image: 边缘检测后的底面)
        imagePicture!.addTarget(edgeDetectionFilter)
        edgeDetectionFilter!.addTarget(self.view as! GPUImageInput!)
        imagePicture!.processImage()
        //获取图片
        edgeDetectionFilter!.useNextFrameForImageCapture()
        边缘检测后的底面 = edgeDetectionFilter!.imageFromCurrentFramebuffer()
        
        edgeDetectionFilter = nil
        imagePicture = nil
        
        let next: UIButton = UIButton(type: .system)
        next.frame = CGRect(x: self.view.frame.width * 0.5 - 50,
                            y: 10,
                            width: 100,
                            height: 50)
        next.setTitle("下一步", for: UIControlState.normal)
        next.addTarget(self, action: #selector(SobelEdgeDetection.showImage), for:.touchUpInside)
        self.view.addSubview(next)
        
        let share: UIButton = UIButton(type: .system)
        share.frame = CGRect(x: self.view.frame.width - 116,
                             y: 20,
                             width: 100,
                             height: 30)
        share.setTitle("保存图片", for: UIControlState.normal)
        share.addTarget(self, action: #selector(SobelEdgeDetection.sharePhoto), for:.touchUpInside)
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

}
