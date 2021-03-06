//
//  ViewController.swift
//  作死
//
//  Created by 董嘉豪 on 2017/5/7.
//  Copyright © 2017年 董嘉豪. All rights reserved.
//

import UIKit
import Photos

//获取底面
class ViewController: SelectTheImageUIViewController {

    //下一步
    @objc func theNextStep() {
        //错误处理
        do {
            //抛出错误
            try isThereAnImage(底面)
            skip("SobelEdgeDetection")
        } catch EnrollError.noImageFound {
            //解决错误
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
    
    //选择图片后的调用函数，自动调用
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        //显示的图片，并且做处理
        底面 = info[UIImagePickerControllerOriginalImage] as? UIImage
        imageView.frame = CGRect(x: 0,
                                 y: (self.view.frame.height / 2) - (底面!.size.height * self.view.frame.width / 底面!.size.width) / 2 + 34,
                                 width: self.view.frame.width,
                                 height: 底面!.size.height * self.view.frame.width / 底面!.size.width)
        imageView.image = 底面
        
        if flag {
            // 保存图片到系统相册
            SavePicture(底面!)
        }
        
        //图片控制器退出
        picker.dismiss(animated: true, completion: {
            () -> Void in
        })
        
        flag = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initButton(title: "选择图片",
                   x: 16,
                   y: 72,
                   width: 100,
                   height: 30,
                   function: #selector(ViewController.selector))
        
        initButton(title: "下一步",
                   x: self.view.frame.width * 0.5 - 50,
                   y: 72,
                   width: 100,
                   height: 30,
                   function: #selector(ViewController.theNextStep))
        
        self.view.addSubview(imageView)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

