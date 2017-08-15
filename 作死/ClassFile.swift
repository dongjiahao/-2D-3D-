//
//  ClassFile.swift
//  作死
//
//  Created by 董嘉豪 on 2017/8/14.
//  Copyright © 2017年 董嘉豪. All rights reserved.
//

import UIKit
import GPUImage
import Photos

//类的定义及声明，以及类的扩展

extension UIViewController {
    //界面跳转函数
    func skip(_ string: String) {
        let myStoryBoard = self.storyboard
        let anotherView: UIViewController = (myStoryBoard?.instantiateViewController(withIdentifier: string))! as UIViewController
        self.present(anotherView, animated: true, completion: nil)
    }
    
    //创建常规按钮的函数
    func initButton(title: String,
                    x: CGFloat,
                    y: CGFloat,
                    width: CGFloat,
                    height: CGFloat,
                    function: Selector) {           //点击后调用的函数
        let button = UIButton(type: .system)
        button.frame = CGRect(x: x,
                              y: y,
                              width: width,
                              height: height)
        button.setTitle(title, for: UIControlState.normal)
        button.addTarget(self, action: function, for:.touchUpInside)
        self.view.addSubview(button)
    }
    
    //保存图片函数
    func SavePicture(_ image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }, completionHandler: { (isSuccess: Bool, error: NSError?) in
            if isSuccess {
                print("保存成功!")
            } else {
                print("保存失败：", error!.localizedDescription)
            }
        } as? (Bool, Error?) -> Void)
    }
}

//——————————————————————————————————————————————————————————————————————————————————————————

class SelectTheImageUIViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //用来展示所选底面的UIImageView
    let imageView = UIImageView()
    
    //选择器调用函数，三个选项“拍照选择”、“相册选择”、“取消”，用于选择底面的图片
    func selector() {
        present(selectorController, animated: true, completion: nil)
    }
    
    //是否调用过照相机的标记，调用过照相机为 true，反之为 false
    var flag: Bool = false
    
    //照相机调用函数
    func fromCamera() {
        //判断设置是否支持照相机
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
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
            flag = true
        }else{
            print("启动照相机错误")
        }
    }
    
    //相册调用函数
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
    
    var selectorController: UIAlertController {
        let controller = UIAlertController(title: nil,
                                           message: nil,
                                           preferredStyle: .actionSheet)
        // 取消按钮
        controller.addAction(UIAlertAction(title: "取消",
                                           style: .cancel,
                                           handler: nil))
        // 拍照选择
        controller.addAction(UIAlertAction(title: "拍照选择",
                                           style: .default) { action in self.fromCamera() } )
        // 相册选择
        controller.addAction(UIAlertAction(title: "相册选择",
                                           style: .default) { action in self.fromPhotoLibrary() } )
        return controller
    }
}

//——————————————————————————————————————————————————————————————————————————————————————————

class FilterUIViewController: UIViewController {
    
    //gaussianBlurFilter高斯模糊滤镜
    func gBFilter(inputImage: UIImage,        //要处理的图片，和处理强度
                  strength: CGFloat) -> UIImage {
        
        var imagePicture = GPUImagePicture()
        imagePicture = GPUImagePicture(image: inputImage)
        
        let gaussianBlurFilter = GPUImageGaussianBlurFilter()
        //模糊处理程度，值越大，噪声影响越小，但会少量降低边界清晰度
        gaussianBlurFilter.texelSpacingMultiplier = strength
        imagePicture.addTarget(gaussianBlurFilter)
        gaussianBlurFilter.addTarget(self.view as! GPUImageInput!)
        imagePicture.processImage()
        //获取图片
        gaussianBlurFilter.useNextFrameForImageCapture()
        
        return gaussianBlurFilter.imageFromCurrentFramebuffer()
    }
    
    //edgeDetectionFilter边缘检测滤镜
    func eDFilter(inputImage: UIImage,        //要处理的图片，和处理强度
                  strength: CGFloat) -> UIImage {
        
        var imagePicture = GPUImagePicture()
        imagePicture = GPUImagePicture(image: inputImage)
        
        let edgeDetectionFilter = GPUImageSobelEdgeDetectionFilter()
        //边界检测强度，值越大，边界线约清晰，但会少量增加噪声数量和强度
        edgeDetectionFilter.edgeStrength = strength
        imagePicture.addTarget(edgeDetectionFilter)
        edgeDetectionFilter.addTarget(self.view as! GPUImageInput!)
        imagePicture.processImage()
        //获取图片
        edgeDetectionFilter.useNextFrameForImageCapture()
        
        return edgeDetectionFilter.imageFromCurrentFramebuffer()
    }
    
    func sharePhoto(_ button: ImageButton) {
        //保存图片
        SavePicture(button.image!)
    }
    
    func jump(_ button: JumpButton) {
        skip(button.string)
    }
}

//——————————————————————————————————————————————————————————————————————————————————————————

final class ImageButton: UIButton {
    var image: UIImage? = nil
}

//——————————————————————————————————————————————————————————————————————————————————————————

final class JumpButton: UIButton {
    var string: String = ""
}

//——————————————————————————————————————————————————————————————————————————————————————————

//可以记录自己坐标及状态的 Button
final class MyButton: UIButton {
    
    //该 button 所代表点的坐标
    var p: CGPoint? = nil
    //蓝色为备选状态，点击可变为黄色的选中状态
    var blue: Bool? {
        didSet {
            if self.blue! {
                self.yellow = false
                self.red = false
                self.setImage(UIImage(named: "blue"),
                              for: .normal)
            }
        }
    }
    //黄色为选中状态，点击 “添加顶点” Button 即可将其添加为顶点，变为红色的选定状态
    //                 “取消选中” Button 即可取消选中状态，变为蓝色的备选状态
    //                 “删除点” Button 即可将改 Button 从 View 中移除
    var yellow: Bool? {
        didSet {
            if self.yellow! {
                self.blue = false
                self.red = false
                self.setImage(UIImage(named: "yellow"),
                              for: .normal)
            }
        }
    }
    //红色为选定状态，点击“取消添加上一个点” Button 即可取消最近一次添加为顶点的点的选定状态，变为蓝色
    var red: Bool? {
        didSet {
            if self.red! {
                self.yellow = false
                self.blue = false
                self.setImage(UIImage(named: "red"),
                              for: .normal)
            }
        }
    }
    
}

//——————————————————————————————————————————————————————————————————————————————————————————

extension UIImage{
    /**
     获取图片中的像素颜色值
     
     - parameter pos: 图片中的位置
     
     - returns: 不透明度，颜色值，灰度
     */
    func getPixelColor(pos: CGPoint) -> (alpha: CGFloat, // 不透明度
        red: CGFloat,   // 红
        green: CGFloat, // 绿
        blue: CGFloat,  // 蓝
        y: CGFloat) {   // 灰度
            let pixelData = self.cgImage!.dataProvider!.data
            let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
            let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
            
            let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
            let g = CGFloat(data[pixelInfo + 1]) / CGFloat(255.0)
            let b = CGFloat(data[pixelInfo + 2]) / CGFloat(255.0)
            let a = CGFloat(data[pixelInfo + 3]) / CGFloat(255.0)
            let y = CGFloat(r * 0.299 + g * 0.587 + b * 0.114)
            
            return (a, r, g, b, y)
    }
}

//——————————————————————————————————————————————————————————————————————————————————————————

final class ListNode {
    //定义节点
    var val: MyButton
    var next: ListNode?
    init(_ val: MyButton) {
        self.val = val
        self.next = nil
    }
}

//——————————————————————————————————————————————————————————————————————————————————————————

final class List {
    //定义链表
    var head: ListNode?
    var tail: ListNode?
    // 尾插法
    func appendToTail(val: MyButton) {
        if tail == nil {
            tail = ListNode(val)
            head = tail
        } else {
            tail!.next = ListNode(val)
            tail = tail!.next
        }
    }
    // 头插法
    func appendToHead(val: MyButton) {
        if head == nil {
            head = ListNode(val)
            tail = head
        } else {
            let temp = ListNode(val)
            temp.next = head
            head = temp
        }
    }
}
