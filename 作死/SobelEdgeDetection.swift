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

class SobelEdgeDetection: UIViewController {
    
    var imagePicture: GPUImagePicture? = GPUImagePicture()
    
    
    func jump() {
        self.presentingViewController!.dismiss(animated: true, completion: nil)
    }
    
    func showImage() {

        let myStoryBoard = self.storyboard
        let anotherView:UIViewController = (myStoryBoard?.instantiateViewController(withIdentifier: "FXViewController"))! as UIViewController
        self.present(anotherView, animated: true, completion: nil)

    }
    
    func sharePhoto() {
        //保存图片
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: s!)
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
        
        var imageView: GPUImageView? = GPUImageView(frame: self.view.frame)
        self.view = imageView
        imagePicture = GPUImagePicture(image: image!)
        image = nil
        
        var gaussianBlurFilter: GPUImageGaussianBlurFilter? = GPUImageGaussianBlurFilter()
        //模糊处理程度，值越大，噪声影响越小，但会少量降低边界清晰度
        gaussianBlurFilter!.texelSpacingMultiplier = 2

        var edgeDetectionFilter: GPUImageSobelEdgeDetectionFilter? = GPUImageSobelEdgeDetectionFilter()
        //边界检测强度，值越大，边界线约清晰，但会少量增加噪声数量和强度
        edgeDetectionFilter!.edgeStrength = 4

        imagePicture!.addTarget(gaussianBlurFilter)
        gaussianBlurFilter!.addTarget(imageView!)
        imagePicture!.processImage()
        gaussianBlurFilter!.useNextFrameForImageCapture()
        s = gaussianBlurFilter!.imageFromCurrentFramebuffer()
        
        gaussianBlurFilter = nil
        

        imagePicture = GPUImagePicture(image: s)
        imagePicture!.addTarget(edgeDetectionFilter)
        edgeDetectionFilter!.addTarget(imageView!)
        imagePicture!.processImage()
        //获取图片
        edgeDetectionFilter!.useNextFrameForImageCapture()
        s = edgeDetectionFilter!.imageFromCurrentFramebuffer()
        
        imageView = nil
        edgeDetectionFilter = nil
        imagePicture = nil

        let button: UIButton = UIButton(type: .system)
        button.frame = CGRect(x: 10, y: 10, width: 100, height: 50)
        button.setTitle("返回", for: UIControlState.normal)
        button.addTarget(self, action: #selector(SobelEdgeDetection.jump), for:.touchUpInside)
        self.view.addSubview(button)

        let next: UIButton = UIButton(type: .system)
        next.frame = CGRect(x: 150, y: 10, width: 100, height: 50)
        next.setTitle("下一步", for: UIControlState.normal)
        next.addTarget(self, action: #selector(SobelEdgeDetection.showImage), for:.touchUpInside)
        self.view.addSubview(next)
        
        let share: UIButton = UIButton(type: .system)
        share.frame = CGRect(x: self.view.frame.width - 110, y: 10, width: 100, height: 50)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
