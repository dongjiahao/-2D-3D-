//
//  ViewController.swift
//  作死
//
//  Created by 董嘉豪 on 2017/5/7.
//  Copyright © 2017年 董嘉豪. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imageView = UIImageView()
    
    func selector() {
        present(selectorController, animated: true, completion: nil)
    }
    
    func fromPhotoLibrary() {
        //判断设置是否支持图片库
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            //弹出控制器，显示界面
            self.present(picker, animated: true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }
    }
    
    var flag: Bool = false
    
    func fromCamera() {
        //判断设置是否支持照相机
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            flag = true
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.camera
//            picker.showsCameraControls = false
//            let cameraTransform = CGAffineTransform(scaleX: 9, y: 16)
//            picker.cameraViewTransform = cameraTransform
//            picker.cameraOverlayView = self.view
            self.present(picker, animated: true, completion: {
                () -> Void in
            })
        }else{
            print("启动照相机错误")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //显示的图片，并且做处理
        image = info[UIImagePickerControllerOriginalImage] as? UIImage
        imageView.frame = CGRect(x: 0, y: (self.view.frame.height / 2) - (image!.size.height * self.view.frame.width / image!.size.width) / 2, width: self.view.frame.width, height: image!.size.height * self.view.frame.width / image!.size.width)
        imageView.image = image
        
        if flag {
            // 保存图片到系统相册
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image!)
            }, completionHandler: { (isSuccess: Bool, error: NSError?) in
                if isSuccess {
                    print("保存成功!")
                } else {
                    print("保存失败：", error!.localizedDescription)
                }
                } as? (Bool, Error?) -> Void)
            flag = false
        }
        
        //图片控制器退出
        picker.dismiss(animated: true, completion: {
            () -> Void in
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let select: UIButton = UIButton(type: .system)
        select.frame = CGRect(x: 10, y: 10, width: 100, height: 50)
        select.setTitle("选择图片", for: UIControlState.normal)
        select.addTarget(self, action: #selector(ViewController.selector), for:.touchUpInside)
        self.view.addSubview(select)
        
        self.view.addSubview(imageView)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

