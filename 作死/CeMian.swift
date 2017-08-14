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
class CeMian: SelectTheImageUIViewController {
    
    func theNextStep() {
        do {
            try isThereAnImage(侧面)
            skip("ShowCeMianViewController")
        } catch EnrollError.noImageFound {
            let a = UIAlertController(title: "错误",
                                      message: "请选择图片后再进入下一步",
                                      preferredStyle: UIAlertControllerStyle.alert)
            a.addAction(UIAlertAction(title: "选择图片",
                                      style: UIAlertActionStyle.default,
                                      handler: { (_) -> Void in self.selector()}))
            a.addAction(UIAlertAction(title: "关闭",
                                      style: UIAlertActionStyle.default,
                                      handler: nil))
            self.present(a, animated: true, completion: nil)
        } catch {
            print("未知错误")
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
        
        let select = UIButton(type: .system)
        select.frame = CGRect(x: 16,
                              y: 20,
                              width: 100,
                              height: 30)
        select.setTitle("选择图片", for: UIControlState.normal)
        select.addTarget(self, action: #selector(CeMian.selector), for:.touchUpInside)
        self.view.addSubview(select)
        
        let next = UIButton(type: .system)
        next.frame = CGRect(x: self.view.frame.width * 0.5 - 50,
                            y: 20,
                            width: 100,
                            height: 30)
        next.setTitle("下一步", for: UIControlState.normal)
        next.addTarget(self, action: #selector(CeMian.theNextStep), for:.touchUpInside)
        self.view.addSubview(next)
        
        self.view.addSubview(imageView)
        
    }
    
}
