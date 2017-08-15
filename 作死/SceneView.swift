//
//  SceneView.swift
//  作死
//
//  Created by 董嘉豪 on 2017/7/21.
//  Copyright © 2017年 董嘉豪. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

//展示3D模型
class SceneView: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = SCNScene(named: "a.scnassets/a.scn")!
        
        //底面x方向所占最大宽度
        var xMax: CGFloat? = 0
        //例如：-------
        //          -----
        //xMax = 10
        //底面y方向所占最大宽度
        var yMax: CGFloat? = 0
        var xMin: CGFloat? = list!.head!.val.p!.x
        var yMin: CGFloat? = list!.head!.val.p!.y
        var targetOne = list!.head
        
        repeat {
            if xMin! > targetOne!.val.p!.x {
                xMin = targetOne!.val.p!.x
            }
            if yMin! > targetOne!.val.p!.y {
                yMin = targetOne!.val.p!.y
            }
            if xMax! < targetOne!.val.p!.x {
                xMax = targetOne!.val.p!.x
            }
            if yMax! < targetOne!.val.p!.y {
                yMax = targetOne!.val.p!.y
            }
            targetOne = targetOne!.next
        } while targetOne!.next != nil
        
        xMax! -= xMin!
        yMax! -= yMin!
        xMin = nil
        yMin = nil
        
        //中心点
        let centralPoint: CGPoint = CGPoint(x: xMax! / 2,
                                            y: yMax! / 2)
        
        var widthMax = widthArray[0]
        
        for i in 1..<widthArray.count {
            if widthArray[i] > widthMax {
                widthMax = widthArray[i]
            }
        }
        
        let rate = 1 / widthMax
        
        for i in stride(from: 1, to: widthArray.count, by: 1) {
            //~~~~~~~~~~~~~~~~~~~~
            //创建路径
            let linePath = UIBezierPath()
            var targetTwo = list!.head
            var px = ((targetTwo!.val.p!.x - centralPoint.x) * (widthArray[widthArray.count - i] * rate) + centralPoint.x) / 1000
//            var py = (centralPoint.y - (centralPoint.y - 0.5 * target!.val.p!.y * (widthArray[i] * rate))) / 1000
            var py = ((targetTwo!.val.p!.y - centralPoint.y) * (widthArray[widthArray.count - i] * rate) + centralPoint.y) / 1000
            //起点
            let start = CGPoint(x: px, y: py)
            linePath.move(to: start)
            //添加其他点
            repeat {
                targetTwo = targetTwo!.next
                px = ((targetTwo!.val.p!.x - centralPoint.x) * (widthArray[widthArray.count - i] * rate) + centralPoint.x) / 1000
                py = ((targetTwo!.val.p!.y - centralPoint.y) * (widthArray[widthArray.count - i] * rate) + centralPoint.y) / 1000
                linePath.addLine(to: CGPoint(x: px, y: py))
            } while targetTwo!.next != nil
            
            //设置底面和高
            let dh = CGFloat((xMax! * rateHW! / CGFloat(widthArray.count)) / 1000)
            let shape: SCNShape = SCNShape(path: linePath, extrusionDepth: dh)
            
            let node: SCNNode = SCNNode(geometry: shape)
            node.position = SCNVector3(0,
                                       0,
                                       CGFloat(i - 1) * dh)
            //在场景中添加物体
            scene.rootNode.addChildNode(node)
            //~~~~~~~~~~~~~~~~~~~~~~
        }
        
        widthArray = []
        list = nil

        // 为场景创建并添加一个新的照相机
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        let t: Float = pow((Float(pow(Float(xMax!), 2) + pow(Float(yMax!), 2))), 0.5)
        
        // 定位照相机
        cameraNode.position = SCNVector3(x: Float(xMax! / 2),
                                         y:Float(yMax! / 2),
                                         z: t)
        
        // 为场景创建并添加一个新的点光源
        // Omni Light类似于吊灯
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: t / 10,
                                        y: t / 10,
                                        z: t / 10)
        scene.rootNode.addChildNode(lightNode)
        
        // 为场景创建并添加一个新的环境光源
        // Ambient Light是模拟漫反射的一种光源。所有对象的底光源。
        // 它能将灯光均匀地照射在场景中每个物体上面，在使用Ambient Light时可以忽略方向和角度，只考虑光源的位置。
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // 声明 the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // 允许用户操纵照相机
        scnView.allowsCameraControl = true
        
        // 显示统计fps和时间等信息
        scnView.showsStatistics = true
        
        // 为 the view 设置背景颜色
        scnView.backgroundColor = UIColor.black
        
        // 添加一个手势识别器
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
    }
    
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // 声明 the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // 检查我们点击至少一个对象
        if hitResults.count > 0 {
            // 声明第一个被点击的对象
            let result: AnyObject = hitResults[0]
            
            // 获取材料                     几何
            let material = result.node!.geometry!.firstMaterial!
            
            // 高光
            SCNTransaction.begin()
            // 动画时间
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
