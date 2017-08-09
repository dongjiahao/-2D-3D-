//
//  CeMian.swift
//  作死
//
//  Created by 董嘉豪 on 2017/8/2.
//  Copyright © 2017年 董嘉豪. All rights reserved.
//

import UIKit
import Photos

//获取侧面
class CeMian: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let imageView = UIImageView()
    
    func selector() {
        present(selectorController, animated: true, completion: nil)
    }
    
    func fromPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(picker, animated: true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }
    }
    
    var flag: Bool = false
    
    func fromCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            flag = true
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.camera
            self.present(picker, animated: true, completion: {
                () -> Void in
            })
        }else{
            print("启动照相机错误")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {

        侧面 = info[UIImagePickerControllerOriginalImage] as? UIImage
        imageView.frame = CGRect(x: 0,
                                 y: (self.view.frame.height / 2) - (侧面!.size.height * self.view.frame.width / 侧面!.size.width) / 2,
                                 width: self.view.frame.width,
                                 height: 侧面!.size.height * self.view.frame.width / 侧面!.size.width)
        imageView.image = 侧面
        
        if flag {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: 侧面!)
            }, completionHandler: { (isSuccess: Bool, error: NSError?) in
                if isSuccess {
                    print("保存成功!")
                } else {
                    print("保存失败：", error!.localizedDescription)
                }
                } as? (Bool, Error?) -> Void)
            flag = false
        }
        
        picker.dismiss(animated: true, completion: {
            () -> Void in
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let select: UIButton = UIButton(type: .system)
        select.frame = CGRect(x: 10,
                              y: 10,
                              width: 100,
                              height: 50)
        select.setTitle("选择图片", for: UIControlState.normal)
        select.addTarget(self, action: #selector(CeMian.selector), for:.touchUpInside)
        self.view.addSubview(select)
        
        self.view.addSubview(imageView)
        
    }
    
}
