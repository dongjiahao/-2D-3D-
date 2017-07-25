//
//  FXViewController.swift
//  作死
//
//  Created by 董嘉豪 on 2017/7/12.
//  Copyright © 2017年 董嘉豪. All rights reserved.
//

import UIKit

var xMax: CGFloat?
var yMax: CGFloat?

//希望能从数据上分析出
class FXViewController: UIViewController {
    
    //候选的UIButton
    var candidate: MyButton?
    //是否允许选中点的标志
    var allow: Bool = true
    
    var num: Int = 0  //记录添加的点数
    
    func awaitOrders(_ button: MyButton) {
        if allow {
            button.yellow = true
            candidate = button
            allow = false
        }
    }
    
    //取消选中
    func repeal() {
        candidate?.blue = true
        candidate = nil
        allow = true
    }
    
    //移除点
    func remove() {
        candidate?.removeFromSuperview()
        candidate = nil
        allow = true
    }
    
    //添加顶点
    func addP() {
        list.appendToHead(val: candidate!)
        candidate?.red = true
        candidate = nil
        allow = true
        num += 1
    }
    
    //取消添加上一个点
    func qXAddP() {
        if num > 0 {
            list.head?.val.blue = true
            list.head = list.head?.next
            num -= 1
        }
    }
    
    func nextView() {
        let myStoryBoard = self.storyboard
        let anotherView:UIViewController = (myStoryBoard?.instantiateViewController(withIdentifier: "SceneView"))! as UIViewController
        self.present(anotherView, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rem: UIButton = UIButton(type: .system)
        rem.frame = CGRect(x: 150, y: 10, width: 100, height: 40)
        rem.setTitle("移除点", for: UIControlState.normal)
        rem.addTarget(self, action: #selector(FXViewController.remove), for:.touchUpInside)
        self.view.addSubview(rem)
        
        let rep: UIButton = UIButton(type: .system)
        rep.frame = CGRect(x: 10, y: 10, width: 100, height: 40)
        rep.setTitle("取消选中", for: UIControlState.normal)
        rep.addTarget(self, action: #selector(FXViewController.repeal), for:.touchUpInside)
        self.view.addSubview(rep)
        
        let add: UIButton = UIButton(type: .system)
        add.frame = CGRect(x: self.view.frame.width - 110, y: 10, width: 100, height: 40)
        add.setTitle("添加顶点", for: UIControlState.normal)
        add.addTarget(self, action: #selector(FXViewController.addP), for:.touchUpInside)
        self.view.addSubview(add)
        
        let qX: UIButton = UIButton(type: .system)
        qX.frame = CGRect(x: 10, y: 50, width: 150, height: 40)
        qX.setTitle("取消添加上一个点", for: UIControlState.normal)
        qX.addTarget(self, action: #selector(FXViewController.qXAddP), for:.touchUpInside)
        self.view.addSubview(qX)
        
        let ne: UIButton = UIButton(type: .system)
        ne.frame = CGRect(x: self.view.frame.width - 110, y: 50, width: 100, height: 40)
        ne.setTitle("下一步", for: UIControlState.normal)
        ne.addTarget(self, action: #selector(FXViewController.nextView), for:.touchUpInside)
        self.view.addSubview(ne)
        
        //可疑的顶点
        var point: [MyCGPoint]? = []
        
        //自上而下纵向扫描得出的点数组
        var arraySZ: [CGPoint]? = []
        //自上而下纵向扫描得出的斜率数组
        var slopeSZ: [CGFloat]? = []
        //自下而上纵向扫描得出的点数组
        var arrayXZ: [CGPoint]? = []
        //自下而上纵向扫描得出的斜率数组
        var slopeXZ: [CGFloat]? = []
        //自左而右纵向扫描得出的点数组
        var arrayZH: [CGPoint]? = []
        //自左而右纵向扫描得出的斜率数组
        var slopeZH: [CGFloat]? = []
        //自右而左纵向扫描得出的点数组
        var arrayYH: [CGPoint]? = []
        //自右而左纵向扫描得出的斜率数组
        var slopeYH: [CGFloat]? = []

        //纵向检查数组中是否包含某值
        func checkZ(a: Int, array: [CGPoint]) -> Bool {
            for j in 0..<array.count {
                if Int(array[j].y) == a {
                    return true
                }
            }
            return false
        }
        
        //纵向
        func getSlopeZ(array: [CGPoint]) -> [CGFloat] {
            var slopeArray: [CGFloat] = []
            for i in 0..<(array.count - 1) {
                slopeArray.append(CGFloat(array[i].x - array[i + 1].x))
            }
            return slopeArray
        }
        
        //横向检查数组中是否包含某值
        func checkH(a: Int, array: [CGPoint]) -> Bool {
            for j in 0..<array.count {
                if Int(array[j].x) == a {
                    return true
                }
            }
            return false
        }
        
        //横向向
        func getSlopeH(array: [CGPoint]) -> [CGFloat] {
            var slopeArray: [CGFloat] = []
            for i in 0..<(array.count - 1) {
                slopeArray.append(CGFloat(array[i].y - array[i + 1].y))
            }
            return slopeArray
        }
        start = CACurrentMediaTime()
        for i in 1..<(matrix!.rows - 1) {
            for j in 1..<(matrix!.columns - 1) {
                //第三层门槛，再次减少冲击信号的干扰
                var around: Int = 0
                if matrix![i,j] {
                    //检查这个点周围为ture的点（包括它自己）是否小于4个，如果是，则认为它是冲击信号
                    for m in (i - 1)...(i + 1) {
                        for n in (j - 1)...(j + 1) {
                            if matrix![m,n] {
                                around += 1
                            }
                        }
                    }
                    if around < 4 {
                        matrix![i,j] = false
                    }
                }
            }
        }
        print(1)
        print(CACurrentMediaTime() - start)
        
        start = CACurrentMediaTime()
        for j in 0..<matrix!.columns {
            //上纵向筛选有点的列,并记录坐标
            for i in 0..<matrix!.rows {
                guard !(matrix?[i,j])! else {
                    guard checkZ(a: j, array: arraySZ!) else {
                        //x 代表行数，y 代表列数
                        arraySZ!.append(CGPoint(x: i, y: j))
                        continue
                    }
                    continue
                }
            }
            //下纵向筛选有点的列,并记录坐标
            for i in (0...(matrix!.rows - 1)).reversed() {
                guard !(matrix?[i,j])! else {
                    guard checkZ(a: j, array: arrayXZ!) else {
                        //x 代表行数，y 代表列数
                        arrayXZ!.append(CGPoint(x: i, y: j))
                        continue
                    }
                    continue
                }
            }
        }
        print(2)
        print(CACurrentMediaTime() - start)
        
        start = CACurrentMediaTime()
        for i in 0..<matrix!.rows {
            //左横向筛选有点的行,并记录坐标
            for j in 0..<matrix!.columns {
                guard !(matrix?[i,j])! else {
                    guard checkH(a: i, array: arrayZH!) else {
                        //x 代表行数，y 代表列数
                        arrayZH!.append(CGPoint(x: i, y: j))
                        continue
                    }
                    continue
                }
            }
            //右横向筛选有点的行,并记录坐标
            for j in (0...(matrix!.columns - 1)).reversed() {
                guard !(matrix?[i,j])! else {
                    guard checkH(a: i, array: arrayYH!) else {
                        //x 代表行数，y 代表列数
                        arrayYH!.append(CGPoint(x: i, y: j))
                        continue
                    }
                    continue
                }
            }
        }
        print(3)
        print(CACurrentMediaTime() - start)
        
        start = CACurrentMediaTime()
        //CGPoint数组排序
        arraySZ!.sort() { $1.y > $0.y }
        arrayXZ!.sort() { $1.y > $0.y }
        arrayZH!.sort() { $1.x > $0.x }
        arrayYH!.sort() { $1.x > $0.x }
        matrix = nil
        print(4)
        print(CACurrentMediaTime() - start)
        
        start = CACurrentMediaTime()
        //获得斜率
        slopeSZ! = getSlopeZ(array: arraySZ!)
        slopeXZ! = getSlopeZ(array: arrayXZ!)
        slopeZH = getSlopeH(array: arrayZH!)
        slopeYH = getSlopeH(array: arrayYH!)
        
        //取平均值
        func mean(_ array: [CGFloat]) -> [CGFloat] {
            var a: CGFloat = 0
            var newArray:[CGFloat] = []
            for i in stride(from: 0, to: array.count / 3, by: 1) {
                a = (array[3 * i] + array[3 * i + 1] + array[3 * i + 2]) / 3
                //仅仅是循环，不需要命名变量
                for _ in 0...2 {
                    newArray.append(a)
                }
            }
            if newArray.count < array.count {
                for i in newArray.count..<array.count {
                    newArray.append(array[i])
                }
            }
            return newArray
        }
        print(5)
        print(CACurrentMediaTime() - start)
        
        start = CACurrentMediaTime()
        slopeSZ = mean(slopeSZ!)
        slopeXZ = mean(slopeXZ!)
        slopeZH = mean(slopeZH!)
        slopeYH = mean(slopeYH!)
        print(6)
        print(CACurrentMediaTime() - start)
        
        //判断可疑的顶点规则：
        //1、首尾为顶点
        //2、斜率数组取平均值后，相邻两点斜率差值的绝对值大于等于10
        //
        //检查是否存在点
        func checkP(_ p: CGPoint) -> Bool {
            for i in 0..<point!.count {
                if CGPoint(x: point![i].x, y: point![i].y) == CGPoint(x: p.x, y: p.y) {
                    return true
                }
            }
            return false
        }
        //添加点         //注：此函数在本文件里为通用函数
        func addPoint(_ p: CGPoint) {
            if !checkP(p) {
                point!.append(MyCGPoint(x: p.x, y: p.y, ed: false))
            }
        }
        //储存顶点
        func tip(_ array: [CGPoint], _ slope: [CGFloat]) {
            addPoint(array[0])
            addPoint(array[array.count - 1])
            for i in 0..<(slope.count - 1) {
                if abs(slope[i] - slope[i + 1]) >= 10 {
                    addPoint(array[i])
                    addPoint(array[i + 1])
                }
                var l: CGFloat = 0
                var r: CGFloat = 0
                for j in ((i > 10) ? (i - 10) : 0)..<i {
                    //利用三目运算符防止"Index out of range"
                    l += slope[j]
                }
                for j in (i + 1)...(((slope.count - 1 - i) >= 10) ? (i + 10) : (slope.count - 1)) {
                    //利用三目运算符防止"Index out of range"
                    r += slope[j]
                }
                if l < 0 && r > 0 || l > 0 && r < 0 {
                    addPoint(array[i])
                }
            }
        }
        
        start = CACurrentMediaTime()
        tip(arraySZ!, slopeSZ!)
        tip(arrayXZ!, slopeXZ!)
        tip(arrayZH!, slopeZH!)
        tip(arrayYH!, slopeYH!)
        print(7)
        print(CACurrentMediaTime() - start)
        
        //不在用了，释放内存
        arraySZ = nil
        arrayXZ = nil
        arrayZH = nil
        arrayYH = nil
        slopeSZ = nil
        slopeXZ = nil
        slopeZH = nil
        slopeYH = nil
        
        var simplePoint: [CGPoint] = []
        var temporary: [CGPoint]? = []
        
        func nearby(_ p: CGPoint) {
            for j in 0..<point!.count {
                if !point![j].ed {
                    let a = pow(pow(abs(p.x - point![j].x), 2) + pow(abs(p.y - point![j].y), 2), 0.5)
                    if a <= 5 {
                        temporary!.append(CGPoint(x: point![j].x, y: point![j].y))
                        point![j].ed = true
                    }
                }
            }
        }
        
        start = CACurrentMediaTime()
        //简化Point数组，把位置相近的点合为一个点
        for i in 0..<point!.count {
            temporary = []
            if !point![i].ed {
                nearby(CGPoint(x: point![i].x, y: point![i].y))
                for _ in 0...1 {
                    for j in 0..<temporary!.count {
                        nearby(temporary![j])
                    }
                }
                var meanX: CGFloat = 0
                var meanY: CGFloat = 0
                for i in 0..<temporary!.count {
                    meanX += temporary![i].x
                    meanY += temporary![i].y
                }
                meanX /= CGFloat(temporary!.count)
                meanY /= CGFloat(temporary!.count)
                simplePoint.append(CGPoint(x: meanY, y: meanX))
            }
        }
        print(8)
        print(CACurrentMediaTime() - start)
        
        temporary = nil
        point = nil
        
        //用于以后将点展示在屏幕上
        //平移因子
        var xMin: CGFloat?
        xMin = simplePoint[0].x
        var yMin: CGFloat?
        yMin = simplePoint[0].y
        
        xMax = simplePoint[0].x
        
        yMax = simplePoint[0].y
        
        start = CACurrentMediaTime()
        for i in 0..<simplePoint.count {
            if xMin! > simplePoint[i].x {
                xMin = simplePoint[i].x
            }
            if yMin! > simplePoint[i].y {
                yMin = simplePoint[i].y
            }
            if xMax! < simplePoint[i].x {
                xMax = simplePoint[i].x
            }
            if yMax! < simplePoint[i].y {
                yMax = simplePoint[i].y
            }
        }
        print(9)
        print(CACurrentMediaTime() - start)
        
        xMax! -= xMin!
        yMax! -= yMin!
        
        var o: CGFloat? = 0
        
        //缩放因子o
        if (yMax! / self.view.frame.height) >= (xMax! / self.view.frame.width) {
            o = (self.view.frame.height - 110 - 13) / yMax!
        } else {
            o = (self.view.frame.width - 5 - 13 - 5) / xMax!
        }
        
        start = CACurrentMediaTime()
        for i in 0..<simplePoint.count {
            simplePoint[i] = CGPoint(x: simplePoint[i].x - xMin!, y: simplePoint[i].y - yMin!)
            let button = MyButton(frame: CGRect(x: (simplePoint[i].x * o!) + 5, y: (simplePoint[i].y * o!) + 110, width: 13, height: 13))
            button.p = simplePoint[i]
            button.blue = true
            button.adjustsImageWhenHighlighted=false //使触摸模式下按钮也不会变暗（半透明）
            button.adjustsImageWhenDisabled=false //使禁用模式下按钮也不会变暗（半透明）
            button.addTarget(self, action: #selector(FXViewController.awaitOrders(_ :)), for:.touchUpInside)
            self.view.addSubview(button)
        }
        print(10)
        print(CACurrentMediaTime() - start)
        
        xMin = nil
        yMin = nil
        o = nil

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
