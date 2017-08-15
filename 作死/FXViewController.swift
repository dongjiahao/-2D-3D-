//
//  FXViewController.swift
//  作死
//
//  Created by 董嘉豪 on 2017/7/12.
//  Copyright © 2017年 董嘉豪. All rights reserved.
//

import UIKit

//从数据上分析出物体的形状特征
class FXViewController: UIViewController {
    
    //记录添加的点数
    var num: Int = 0
    //候选的UIButton
    var candidate: MyButton?
    //是否允许选中点的标志
    var allow: Bool = true
    //等待指示
    //CM() 和 viewDidLoad() 都完成工作才进行下一步任务
    var waitZ1 = false
    var waitZ2 = false
    
    //跳转到下一个页面
    func nextView() {
        do {
            try areThereEnoughPoints(num)
            skip("SceneView")
        } catch EnrollError.insufficientPoints {
            let a = UIAlertController(title: "错误",
                                      message: "至少添加3个顶点才能围成一个面",
                                      preferredStyle: UIAlertControllerStyle.alert)
            a.addAction(UIAlertAction(title: "关闭",
                                      style: UIAlertActionStyle.default,
                                      handler: nil))
            self.present(a, animated: true, completion: nil)
        } catch {
            print("未知错误")
        }
    }
    
    //点击为选中状态
    func awaitOrders(_ button: MyButton) {
        if allow && button.blue! {
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
        do {
            try isThereAnPoint(candidate)
            list!.appendToHead(val: candidate!)
            candidate?.red = true
            candidate = nil
            allow = true
            num += 1
        } catch EnrollError.noPointFound {
            let a = UIAlertController(title: "错误",
                                      message: "请选择要添加为顶点的点",
                                      preferredStyle: UIAlertControllerStyle.alert)
            a.addAction(UIAlertAction(title: "关闭",
                                      style: UIAlertActionStyle.default,
                                      handler: nil))
            self.present(a, animated: true, completion: nil)
        } catch {
            print("未知错误")
        }
    }
    
    //取消添加上一个点
    func qXAddP() {
        if num > 0 {
            list!.head?.val.blue = true
            list!.head = list!.head?.next
            num -= 1
        }
    }
    
    func initMatrix(_ image: UIImage) -> Matrix<Bool> {
        //面的数据分析
        //记录侧面各点信息的矩阵，行数与图片宽度相关，列数与图片高度相关，为的是之后将图片信息转置（旋转90°）
        var matrix = Matrix<Bool>(rows: Int(image.size.width / 2),
                                columns: Int(image.size.height / 2),
                                example: false)
        //取样间隔为2 先列后行
        for i in stride(from: 0, to: Int(image.size.width) - 1, by: 2) {
            for j in stride(from: 0, to: Int(image.size.height) - 1, by: 2) {
                //第一层门槛，只有灰度大于某一数值的像素点会被进一步处理
                if image.getPixelColor(pos: CGPoint(x: i, y: j)).y >= 0.6{
                    //第二层门槛，起到medianBlur(中值滤波)的作用
                    //mean 记录以一点为中心周围25个点的灰度平均值
                    var mean: CGFloat = 0
                    for m in (i - 2)...(i + 2) {
                        for n in (j - 2)...(j + 2) {
                            mean += image.getPixelColor(pos: CGPoint(x: m, y: n)).y
                        }
                    }
                    
                    mean /= 25
                    
                    if mean >= 0.3 {
                        //记录图片的信息到转置矩阵 前为行数后为列数
                        matrix[i / 2, (Int(image.size.height) - 1 - j) / 2] = true
                    }
                }
                
            }
        }
        return matrix
    }
    
    //找出行列的最大值和最小值
    func CreateNewMatrix(_ old: Matrix<Bool>) -> Matrix<Bool> {
        //缩小矩阵的大小，摘除多余的行和列
        //行的最小值
        var rowMin: Int = 0
        //行的最大值
        var rowMax: Int = 0
        //列的最小值
        var columnMin: Int = 0
        //列的最大值
        var columnMax: Int = 0
        
        //寻找行的最小值的闭包
        let seekRowMin = {
            for i in 0..<old.rows {
                for j in 0..<old.columns {
                    if old[i,j] {
                        rowMin = i
                        return
                    }
                }
            }
        }
        
        //寻找行的最大值的闭包
        let seekRowMax = {
            for i in (0..<old.rows).reversed() {
                for j in 0..<old.columns {
                    if old[i,j] {
                        rowMax = i
                        return
                    }
                }
            }
        }
        
        //寻找列的最小值的闭包
        let seekColumnMin = {
            for i in 0..<old.columns {
                for j in 0..<old.rows {
                    if old[j,i] {
                        columnMin = i
                        return
                    }
                }
            }
        }
        
        //寻找列的最大值的闭包
        let seekColumnMax = {
            for i in (0..<old.columns).reversed() {
                for j in 0..<old.rows {
                    if old[j,i] {
                        columnMax = i
                        return
                    }
                }
            }
        }
        
        //等待指示
        //basicOperationCMOne() 和 下面的代码都完成工作才进行下一步任务
        var waitOne: Bool = false
        var waitTwo: Bool = false
        
        //开启一个新的线程
        func basicOperation() {
            //        第一步：创建Operation
            let op = Operation.init()
            //        第二步：把要执行的代码放入operation中
            op.completionBlock = {
                
                seekRowMax()
                seekColumnMax()
                waitTwo = true
                
            }
            //        第三步：创建OperationQueue
            let opQueue = OperationQueue.init()
            //        第四步：把Operation加入到线程中
            opQueue.addOperation(op)
        }
        
        basicOperation()
        
        seekRowMin()
        seekColumnMin()
        waitOne = true
        while !waitOne || !waitTwo {
            //等待
        }
        
        //重建新的矩阵
        var new = Matrix<Bool>(rows: rowMax - rowMin + 1,
                                    columns: columnMax - columnMin + 1,
                                    example: false)
        
        for i in 0..<new.rows {
            for j in 0..<new.columns {
                new[i,j] = old[i + rowMin, j + columnMin]
            }
        }
        
        return new
    }
    
    //处理侧面的函数，该函数单开一个线程
    func CM() {
        //        第一步：创建Operation
        let cm = Operation.init()
        //        第二步：把要执行的代码放入operation中
        cm.completionBlock = {
            
            //二维矩阵储存：像素化的图片再经筛选后的点
            //侧面
            var matrixCM: Matrix<Bool>? = self.CreateNewMatrix(self.initMatrix(边缘检测后的侧面!))
            
            //高宽比 = 矩阵的行数比上矩阵的列数
            rateHW = CGFloat(matrixCM!.rows) / CGFloat(matrixCM!.columns)
            边缘检测后的侧面 = nil
            
            //取宽度
            //决定分多少层
            for i in stride(from: 2, to: Int(matrixCM!.rows) - 1, by: 2) {
                
                var l = 0
                var r = 0
                var lr: [Int] = []
                
                for m in (1...2).reversed() {
                    for j in 0..<matrixCM!.columns {
                        guard !matrixCM![i - m,j] else {
                            l = j
                            continue
                        }
                    }
                    
                    for j in (0...(matrixCM!.columns - 1)).reversed() {
                        guard !matrixCM![i - m,j] else {
                            r = j
                            continue
                        }
                    }
                    lr.append(abs(r - l))
                }
                
                var sum: Int = 0
                
                for n in 0..<lr.count {
                    sum += lr[n]
                }
                
                widthArray.append(CGFloat(sum / lr.count))
                
            }
            
            matrixCM = nil
            
            //摘除突变的层
            var temporary: [CGFloat] = []
            for i in stride(from: 1, to: widthArray.count - 2, by: 1) {
                
                if !(abs(widthArray[i] - widthArray[i - 1]) > 0.5 * widthArray[i] && abs(widthArray[i] - widthArray[i + 1]) > 0.5 * widthArray[i]) && widthArray[i] != 0 {
                    temporary.append(widthArray[i])
                }
                
            }
            widthArray = temporary
            //移除开头和结尾，因为值一般情况下是不可取的
            widthArray.removeLast()
            widthArray.removeFirst()
            temporary = []
            self.waitZ1 = true
            
        }
        //        第三步：创建OperationQueue
        let opQueue = OperationQueue.init()
        //        第四步：把Operation加入到线程中
        opQueue.addOperation(cm)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initButton(title: "移除点",
                   x: self.view.frame.width * 0.5 - 50,
                   y: 20,
                   width: 100,
                   height: 30,
                   function: #selector(FXViewController.remove))
        
        initButton(title: "取消选中",
                   x: 16,
                   y: 20,
                   width: 100,
                   height: 30,
                   function: #selector(FXViewController.repeal))
        
        initButton(title: "添加顶点",
                   x: self.view.frame.width - 110,
                   y: 20,
                   width: 100,
                   height: 30,
                   function: #selector(FXViewController.addP))
        
        initButton(title: "取消添加上一个点",
                   x: self.view.frame.width - 160,
                   y: 60,
                   width: 150,
                   height: 30,
                   function: #selector(FXViewController.qXAddP))
        
        initButton(title: "下一步",
                   x: self.view.frame.width * 0.5 - 50,
                   y: 60,
                   width: 100,
                   height: 30,
                   function: #selector(FXViewController.nextView))
        
        //侧面的数据分析
        CM()
        
        start = CACurrentMediaTime()
        //二维矩阵储存：像素化的图片再经筛选后的点
        //底面
        var matrixDM: Matrix<Bool>? = CreateNewMatrix(initMatrix(边缘检测后的底面!))
        
        print("记录二维矩阵")
        print(CACurrentMediaTime() - start)
        //清理内存
        边缘检测后的底面 = nil
        
        //可疑的顶点
        var myCGPointArray: [MyCGPoint]? = []
        
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
        
        for i in 1..<(matrixDM!.rows - 1) {
            for j in 1..<(matrixDM!.columns - 1) {
                //第三层门槛，再次减少冲击信号的干扰
                var around: Int = 0
                if matrixDM![i,j] {
                    //检查这个点周围为ture的点（包括它自己）是否小于4个，如果是，则认为它是冲击信号
                    for m in (i - 1)...(i + 1) {
                        for n in (j - 1)...(j + 1) {
                            if matrixDM![m,n] {
                                around += 1
                            }
                        }
                    }
                    if around < 4 {
                        matrixDM![i,j] = false
                    }
                }
            }
        }

        print(1)
        print(CACurrentMediaTime() - start)
        
        var waitOne = false
        var waitTwo = false
        
        func basicOperation() {
            //        第一步：创建Operation
            let op = Operation.init()
            //        第二步：把要执行的代码放入operation中
            op.completionBlock = {
                
                for i in 0..<matrixDM!.rows {
                    //左横向筛选有点的行,并记录坐标
                    for j in 0..<matrixDM!.columns {
                        guard !matrixDM![i,j] else {
                            guard checkH(a: i, array: arrayZH!) else {
                                //x 代表行数，y 代表列数
                                arrayZH!.append(CGPoint(x: i, y: j))
                                continue
                            }
                            continue
                        }
                    }
                    //右横向筛选有点的行,并记录坐标
                    for j in (0...(matrixDM!.columns - 1)).reversed() {
                        guard !matrixDM![i,j] else {
                            guard checkH(a: i, array: arrayYH!) else {
                                //x 代表行数，y 代表列数
                                arrayYH!.append(CGPoint(x: i, y: j))
                                continue
                            }
                            continue
                        }
                    }
                }
                waitTwo = true
            }
            //        第三步：创建OperationQueue
            let opQueue = OperationQueue.init()
            //        第四步：把Operation加入到线程中
            opQueue.addOperation(op)
        }
        
        basicOperation()
        
        for j in 0..<matrixDM!.columns {
            //上纵向筛选有点的列,并记录坐标
            for i in 0..<matrixDM!.rows {
                guard !matrixDM![i,j] else {
                    guard checkZ(a: j, array: arraySZ!) else {
                        //x 代表行数，y 代表列数
                        arraySZ!.append(CGPoint(x: i, y: j))
                        continue
                    }
                    continue
                }
            }
            //下纵向筛选有点的列,并记录坐标
            for i in (0...(matrixDM!.rows - 1)).reversed() {
                guard !matrixDM![i,j] else {
                    guard checkZ(a: j, array: arrayXZ!) else {
                        //x 代表行数，y 代表列数
                        arrayXZ!.append(CGPoint(x: i, y: j))
                        continue
                    }
                    continue
                }
            }
        }
        
        waitOne = true
        while !waitOne || !waitTwo {
            //等待
        }
        waitOne = false
        waitTwo = false
        
        //CGPoint数组排序
        arraySZ!.sort() { $1.y > $0.y }
        arrayXZ!.sort() { $1.y > $0.y }
        arrayZH!.sort() { $1.x > $0.x }
        arrayYH!.sort() { $1.x > $0.x }
        
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

        slopeSZ = mean(slopeSZ!)
        slopeXZ = mean(slopeXZ!)
        slopeZH = mean(slopeZH!)
        slopeYH = mean(slopeYH!)
        
        //判断可疑的顶点规则：
        //1、首尾为顶点
        //2、斜率数组取平均值后，相邻两点斜率差值的绝对值大于等于10
        //
        //检查是否存在点
        func checkP(_ p: CGPoint) -> Bool {
            for i in 0..<myCGPointArray!.count {
                if CGPoint(x: myCGPointArray![i].x, y: myCGPointArray![i].y) == CGPoint(x: p.x, y: p.y) {
                    return true
                }
            }
            return false
        }
        //添加点
        func addPoint(_ p: CGPoint) {
            if !checkP(p) {
                myCGPointArray!.append(MyCGPoint(x: p.x, y: p.y, ed: false))
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
        
        tip(arraySZ!, slopeSZ!)
        tip(arrayXZ!, slopeXZ!)
        tip(arrayZH!, slopeZH!)
        tip(arrayYH!, slopeYH!)
        
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
            for j in 0..<myCGPointArray!.count {
                if !myCGPointArray![j].ed {
                    let a = pow(pow(abs(p.x - myCGPointArray![j].x), 2) + pow(abs(p.y - myCGPointArray![j].y), 2), 0.5)
                    if a <= 5 {
                        temporary!.append(CGPoint(x: myCGPointArray![j].x, y: myCGPointArray![j].y))
                        myCGPointArray![j].ed = true
                    }
                }
            }
        }
        
        //简化Point数组，把位置相近的点合为一个点
        for i in 0..<myCGPointArray!.count {
            temporary = []
            if !myCGPointArray![i].ed {
                nearby(CGPoint(x: myCGPointArray![i].x, y: myCGPointArray![i].y))
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
        
        temporary = nil
        myCGPointArray = nil
        
        //用于以后将点展示在屏幕上
        //平移因子
        //底面x方向所占最大宽度
        var xMax: CGFloat?
        //例如：-------
        //          -----
        //xMax = 10
        //底面y方向所占最大宽度
        var yMax: CGFloat?
        var xMin: CGFloat?
        xMin = simplePoint[0].x
        var yMin: CGFloat?
        yMin = simplePoint[0].y
        
        xMax = simplePoint[0].x
        
        yMax = simplePoint[0].y
        
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
        
        xMax! -= xMin!
        yMax! -= yMin!
        
        var o: CGFloat? = 0
        
        //缩放因子o
        if (yMax! / self.view.frame.height) >= (xMax! / self.view.frame.width) {
            o = (self.view.frame.height - 110 - 13) / yMax!
        } else {
            o = (self.view.frame.width - 5 - 13 - 5) / xMax!
        }
        
        for i in 0..<simplePoint.count {
            simplePoint[i] = CGPoint(x: simplePoint[i].x - xMin!,
                                     y: simplePoint[i].y - yMin!)
            let button = MyButton(frame: CGRect(x: (simplePoint[i].x * o!) + 5,
                                                y: (simplePoint[i].y * o!) + 110,
                                                width: 13,
                                                height: 13))
            button.p = simplePoint[i]
            button.blue = true
            button.adjustsImageWhenHighlighted=false //使触摸模式下按钮也不会变暗（半透明）
            button.adjustsImageWhenDisabled=false //使禁用模式下按钮也不会变暗（半透明）
            button.addTarget(self, action: #selector(FXViewController.awaitOrders(_ :)), for:.touchUpInside)
            self.view.addSubview(button)
        }
        
        xMin = nil
        yMin = nil
        o = nil
        simplePoint = []
        matrixDM = nil
        
        waitZ2 = true
        
        while !waitZ1 || !waitZ2 {
            //等待
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
