//
//  NewViewController.swift
//  作死
//
//  Created by 董嘉豪 on 2017/7/10.
//  Copyright © 2017年 董嘉豪. All rights reserved.
//

import UIKit

class NewViewController: UIViewController {
    
    func jump() {
        self.presentingViewController!.dismiss(animated: true, completion: nil)
    }
    
    func fX() {
        let myStoryBoard = self.storyboard
        let anotherView:UIViewController = (myStoryBoard?.instantiateViewController(withIdentifier: "FXViewController"))! as UIViewController
        self.present(anotherView, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let frame = CGRect(x: 0, y: (self.view.frame.height / 2) - (s!.size.height * self.view.frame.width / s!.size.width) / 2, width: self.view.frame.width, height: s!.size.height * self.view.frame.width / s!.size.width)

        let cgView = CGView(frame: frame)
        self.view.addSubview(cgView)

        let button: UIButton = UIButton(type: .system)
        button.frame = CGRect(x: 10, y: 10, width: 100, height: 50)
        button.setTitle("返回", for: UIControlState.normal)
        button.addTarget(self, action: #selector(NewViewController.jump), for:.touchUpInside)
        self.view.addSubview(button)
        
        let next: UIButton = UIButton(type: .system)
        next.frame = CGRect(x: 150, y: 10, width: 100, height: 50)
        next.setTitle("下一步", for: UIControlState.normal)
        next.addTarget(self, action: #selector(NewViewController.fX), for:.touchUpInside)
        self.view.addSubview(next)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

}

class CGView: UIView {
    
    //线宽
    let lineWidth = 1 / UIScreen.main.scale
    
    //线偏移量
    let lineAdjustOffset = 1 / UIScreen.main.scale / 2
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //设置背景色为透明，否则是黑色背景
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        //获取绘图上下文
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        //创建并设置路径
        let path = CGMutablePath()
        
        matrix = Matrix<Bool>(rows: Int(s!.size.height / 2), columns: Int(s!.size.width / 2), example: false)
        start = CACurrentMediaTime()
        //取样间隔为2 先列后行
        for i in stride(from: 0, to: Int(s!.size.width) - 1, by: 2) {
            for j in stride(from: 0, to: Int(s!.size.height) - 1, by: 2) {
                //第一层门槛，只有灰度大于某一数值的像素点会被进一步处理
                if s!.getPixelColor(pos: CGPoint(x: i, y: j)).y >= 0.6{
                    //第二层门槛，起到medianBlur(中值滤波)的作用
                    var flag: CGFloat = 0
                    
                    for m in (i - 2)...(i + 2) {
                        for n in (j - 2)...(j + 2) {
                            flag += s!.getPixelColor(pos: CGPoint(x: m, y: n)).y
                        }
                    }
                    
                    flag /= 25
                    
                    if flag >= 0.3 {
                        //记录图片 s 的信息到矩阵 前为行数后为列数
                        matrix![j / 2,i / 2] = true
                        
                        if i % 8 == 0 && j % 8 == 0 {
                            path.move(to: CGPoint(x: CGFloat(CGFloat(i) / 10 + lineAdjustOffset), y: CGFloat(CGFloat(j) / 10 + lineAdjustOffset)))
                            path.addLine(to: CGPoint(x: CGFloat(CGFloat(i) / 10 + lineAdjustOffset + 1), y: CGFloat(CGFloat(j) / 10 + lineAdjustOffset)))
                            //添加路径到图形上下文
                            context.addPath(path)
                            //设置笔触颜色
                            context.setStrokeColor(UIColor.black.cgColor)
                            //设置笔触宽度
                            context.setLineWidth(lineWidth)
                            //绘制路径
                            context.strokePath()
                        }
                    }
                }
                
            }
        }
        print("记录二维矩阵和绘图")
        print(CACurrentMediaTime() - start)
        //清理内存
        s = nil
    }
}
