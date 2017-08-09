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
    
    //跳转到下一个页面
    func nextView() {
        let myStoryBoard = self.storyboard
        let anotherView:UIViewController = (myStoryBoard?.instantiateViewController(withIdentifier: "SceneView"))! as UIViewController
        self.present(anotherView, animated: true, completion: nil)
    }
    
    //候选的UIButton
    var candidate: MyButton?
    //是否允许选中点的标志
    var allow: Bool = true
    
    var num: Int = 0  //记录添加的点数
    
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
        list!.appendToHead(val: candidate!)
        candidate?.red = true
        candidate = nil
        allow = true
        num += 1
    }
    
    //取消添加上一个点
    func qXAddP() {
        if num > 0 {
            list!.head?.val.blue = true
            list!.head = list!.head?.next
            num -= 1
        }
    }
    
    //等待指示
    //CM() 和 viewDidLoad() 都完成工作才进行下一步任务
    var waitZ1 = false
    var waitZ2 = false
    
    //处理侧面的函数，该函数单开一个线程
    func CM() {
        //        第一步：创建Operation
        let cm = Operation.init()
        //        第二步：把要执行的代码放入operation中
        cm.completionBlock = {
            //记录侧面各点信息的矩阵，行数与图片宽度相关，列数与图片高度相关，为的是之后将图片信息转置（旋转90°）
            matrixCM = Matrix<Bool>(rows: Int(边缘检测后的侧面!.size.width / 2),
                                    columns: Int(边缘检测后的侧面!.size.height / 2),
                                    example: false)
            //取样间隔为2 先列后行
            for i in stride(from: 0, to: Int(边缘检测后的侧面!.size.width) - 1, by: 2) {
                for j in stride(from: 0, to: Int(边缘检测后的侧面!.size.height) - 1, by: 2) {
                    //第一层门槛，只有灰度大于某一数值的像素点会被进一步处理
                    if 边缘检测后的侧面!.getPixelColor(pos: CGPoint(x: i, y: j)).y >= 0.6{
                        //第二层门槛，起到medianBlur(中值滤波)的作用
                        //mean 记录以一点为中心周围25个点的灰度平均值
                        var mean: CGFloat = 0
                        for m in (i - 2)...(i + 2) {
                            for n in (j - 2)...(j + 2) {
                                mean += 边缘检测后的侧面!.getPixelColor(pos: CGPoint(x: m, y: n)).y
                            }
                        }
                        
                        mean /= 25
                        
                        if mean >= 0.3 {
                            //记录图片的信息到s的转置矩阵 前为行数后为列数
                            matrixCM![i / 2,j / 2] = true
                        }
                    }
                    
                }
            }
            
            //缩小矩阵的大小，摘除多余的行和列
            //行的最小值
            var rowMinCM: Int = 0
            //行的最大值
            var rowMaxCM: Int = 0
            //列的最小值
            var columnMinCM: Int = 0
            //列的最大值
            var columnMaxCM: Int = 0
            
            //寻找行的最小值的闭包
            let seekRowMinCM = {
                for i in 0..<matrixCM!.rows {
                    for j in 0..<matrixCM!.columns {
                        if matrixCM![i,j] {
                            rowMinCM = i
                            return
                        }
                    }
                }
            }
            
            //寻找行的最大值的闭包
            let seekRowMaxCM = {
                for i in (0..<matrixCM!.rows).reversed() {
                    for j in 0..<matrixCM!.columns {
                        if matrixCM![i,j] {
                            rowMaxCM = i
                            return
                        }
                    }
                }
            }
            
            //寻找列的最小值的闭包
            let seekColumnMinCM = {
                for i in 0..<matrixCM!.columns {
                    for j in 0..<matrixCM!.rows {
                        if matrixCM![j,i] {
                            columnMinCM = i
                            return
                        }
                    }
                }
            }
            
            //寻找列的最大值的闭包
            let seekColumnMaxCM = {
                for i in (0..<matrixCM!.columns).reversed() {
                    for j in 0..<matrixCM!.rows {
                        if matrixCM![j,i] {
                            columnMaxCM = i
                            return
                        }
                    }
                }
            }
            
            //等待指示
            //basicOperationCMOne() 和 下面的代码都完成工作才进行下一步任务
            var waitCMOne: Bool = false
            var waitCMTwo: Bool = false
            
            //开启一个新的线程
            func basicOperationCMOne() {
                //        第一步：创建Operation
                let op = Operation.init()
                //        第二步：把要执行的代码放入operation中
                op.completionBlock = {
                    
                    seekRowMaxCM()
                    seekColumnMaxCM()
                    waitCMTwo = true
                    
                }
                //        第三步：创建OperationQueue
                let opQueue = OperationQueue.init()
                //        第四步：把Operation加入到线程中
                opQueue.addOperation(op)
            }
            
            basicOperationCMOne()
            
            seekRowMinCM()
            seekColumnMinCM()
            waitCMOne = true
            while !waitCMOne || !waitCMTwo {
                //等待
            }
            waitCMOne = false
            waitCMTwo = false
            
            //重建新的矩阵
            var newMatrixCM: Matrix<Bool>? = nil
            newMatrixCM = Matrix<Bool>(rows: rowMaxCM - rowMinCM + 1,
                                       columns: columnMaxCM - columnMinCM + 1,
                                       example: false)
            
            for i in 0..<newMatrixCM!.rows {
                for j in 0..<newMatrixCM!.columns {
                    newMatrixCM![i,j] = matrixCM![i + rowMinCM, j + columnMinCM]
                }
            }
            
            matrixCM = newMatrixCM
            //高宽比 = 矩阵的行数比上矩阵的列数
            rateHW = CGFloat(matrixCM!.rows) / CGFloat(matrixCM!.columns)
            newMatrixCM = nil
            边缘检测后的侧面 = nil
            
            //取宽度
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
        
        let rem: UIButton = UIButton(type: .system)
        rem.frame = CGRect(x: 150,
                           y: 10,
                           width: 100,
                           height: 40)
        rem.setTitle("移除点", for: UIControlState.normal)
        rem.addTarget(self, action: #selector(FXViewController.remove), for:.touchUpInside)
        self.view.addSubview(rem)
        
        let rep: UIButton = UIButton(type: .system)
        rep.frame = CGRect(x: 10,
                           y: 10,
                           width: 100,
                           height: 40)
        rep.setTitle("取消选中", for: UIControlState.normal)
        rep.addTarget(self, action: #selector(FXViewController.repeal), for:.touchUpInside)
        self.view.addSubview(rep)
        
        let add: UIButton = UIButton(type: .system)
        add.frame = CGRect(x: self.view.frame.width - 110,
                           y: 10,
                           width: 100,
                           height: 40)
        add.setTitle("添加顶点", for: UIControlState.normal)
        add.addTarget(self, action: #selector(FXViewController.addP), for:.touchUpInside)
        self.view.addSubview(add)
        
        let qX: UIButton = UIButton(type: .system)
        qX.frame = CGRect(x: 10,
                          y: 50,
                          width: 150,
                          height: 40)
        qX.setTitle("取消添加上一个点", for: UIControlState.normal)
        qX.addTarget(self, action: #selector(FXViewController.qXAddP), for:.touchUpInside)
        self.view.addSubview(qX)
        
        let ne: UIButton = UIButton(type: .system)
        ne.frame = CGRect(x: self.view.frame.width - 110,
                          y: 50,
                          width: 100,
                          height: 40)
        ne.setTitle("下一步", for: UIControlState.normal)
        ne.addTarget(self, action: #selector(FXViewController.nextView), for:.touchUpInside)
        self.view.addSubview(ne)
        
        //侧面的数据分析
        CM()
        
        //底面的数据分析
        //记录侧面各点信息的矩阵，行数与图片宽度相关，列数与图片高度相关，为的是之后将图片信息转置（旋转90°）
        matrixDM = Matrix<Bool>(rows: Int(边缘检测后的底面!.size.width / 2), columns: Int(边缘检测后的底面!.size.height / 2), example: false)
        start = CACurrentMediaTime()
        //取样间隔为2 先列后行
        for i in stride(from: 0, to: Int(边缘检测后的底面!.size.width) - 1, by: 2) {
            for j in stride(from: 0, to: Int(边缘检测后的底面!.size.height) - 1, by: 2) {
                //第一层门槛，只有灰度大于某一数值的像素点会被进一步处理
                if 边缘检测后的底面!.getPixelColor(pos: CGPoint(x: i, y: j)).y >= 0.6{
                    //第二层门槛，起到medianBlur(中值滤波)的作用
                    //mean 记录以一点为中心周围25个点的灰度平均值
                    var mean: CGFloat = 0
                    for m in (i - 2)...(i + 2) {
                        for n in (j - 2)...(j + 2) {
                            mean += 边缘检测后的底面!.getPixelColor(pos: CGPoint(x: m, y: n)).y
                        }
                    }
                    
                    mean /= 25
                    
                    if mean >= 0.3 {
                        //记录图片的信息到转置矩阵 前为行数后为列数
                        matrixDM![i / 2,j / 2] = true
                    }
                }
                
            }
        }
        
        //缩小底面的矩阵，同侧面的注释
        var rowMinDM: Int = 0
        var rowMaxDM: Int = 0
        var columnMinDM: Int = 0
        var columnMaxDM: Int = 0
        
        let seekRowMinDM = {
            for i in 0..<matrixDM!.rows {
                for j in 0..<matrixDM!.columns {
                    if matrixDM![i,j] {
                        rowMinDM = i
                        return
                    }
                }
            }
        }
        
        let seekRowMaxDM = {
            for i in (0..<matrixDM!.rows).reversed() {
                for j in 0..<matrixDM!.columns {
                    if matrixDM![i,j] {
                        rowMaxDM = i
                        return
                    }
                }
            }
        }
        
        let seekColumnMinDM = {
            for i in 0..<matrixDM!.columns {
                for j in 0..<matrixDM!.rows {
                    if matrixDM![j,i] {
                        columnMinDM = i
                        return
                    }
                }
            }
        }
        
        let seekColumnMaxDM = {
            for i in (0..<matrixDM!.columns).reversed() {
                for j in 0..<matrixDM!.rows {
                    if matrixDM![j,i] {
                        columnMaxDM = i
                        return
                    }
                }
            }
        }
        
        //等待指示
        //basicOperationCMOne() 和 下面的代码都完成工作才进行下一步任务
        //之后
        //basicOperationDMOne() 和 下面的代码都完成工作才进行下一步任务
        var waitDMOne: Bool = false
        var waitDMTwo: Bool = false
        
        func basicOperationDMOne() {
            //        第一步：创建Operation
            let op = Operation.init()
            //        第二步：把要执行的代码放入operation中
            op.completionBlock = {
                
                seekRowMaxDM()
                seekColumnMaxDM()
                waitDMTwo = true
                
            }
            //        第三步：创建OperationQueue
            let opQueue = OperationQueue.init()
            //        第四步：把Operation加入到线程中
            opQueue.addOperation(op)
        }
        
        basicOperationDMOne()
        
        seekRowMinDM()
        seekColumnMinDM()
        waitDMOne = true
        while !waitDMOne || !waitDMTwo {
            //等待
        }
        waitDMOne = false
        waitDMTwo = false
        
        var newMatrixDM: Matrix<Bool>? = nil
        newMatrixDM = Matrix<Bool>(rows: rowMaxDM - rowMinDM + 1, columns: columnMaxDM - columnMinDM + 1, example: false)
        
        for i in 0..<newMatrixDM!.rows {
            for j in 0..<newMatrixDM!.columns {
                newMatrixDM![i,j] = matrixDM![i + rowMinDM, j + columnMinDM]
            }
        }
        
        matrixDM = newMatrixDM
        newMatrixDM = nil
        
        print("记录二维矩阵")
        print(CACurrentMediaTime() - start)
        //清理内存
        边缘检测后的底面 = nil
        
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
        
        func basicOperationDMTwo() {
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
                waitDMTwo = true
            }
            //        第三步：创建OperationQueue
            let opQueue = OperationQueue.init()
            //        第四步：把Operation加入到线程中
            opQueue.addOperation(op)
        }
        
        
        basicOperationDMTwo()
        
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
        waitDMOne = true
        while !waitDMOne || !waitDMTwo {
            //等待
        }
        waitDMOne = false
        waitDMTwo = false
        
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
        
        print("~~~")
        for i in 0..<widthArray.count {
            print(widthArray[i])
        }
        print("~~~")
        print(xMax!)
        print(yMax!)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
