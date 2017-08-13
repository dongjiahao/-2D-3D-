//
//  File.swift
//  作死
//
//  Created by 董嘉豪 on 2017/5/8.
//  Copyright © 2017年 董嘉豪. All rights reserved.
//

import Foundation
import Photos

//全局变量，类、结构体的定义及声明，以及类的扩展

//就是想体验一把中文变量，没别的想法。。。
var 底面: UIImage?
var 边缘检测后的底面: UIImage?
var 侧面: UIImage?
var 边缘检测后的侧面: UIImage?
//二维矩阵储存：像素化的图片再经筛选后的点
var single: [Bool] = []
//底面
//var matrixDM: Matrix<Bool>? = nil
var doubleDimensionalArrayDM: [[Bool]] = []
//侧面
//var matrixCM: Matrix<Bool>? = nil
var doubleDimensionalArrayCM: [[Bool]] = []
//单链表，用来储存底面顶点顺序
var list: List? = List()
//时间测试
var start: CFAbsoluteTime = 0
//记录侧面的高宽比
var rateHW: CGFloat?
//记录侧面所取宽度的数组
var widthArray: [CGFloat] = []

extension ViewController {
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

extension CeMian {
    var selectorController: UIAlertController {
        let controller = UIAlertController(title: nil,
                                           message: nil,
                                           preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "取消",
                                           style: .cancel,
                                           handler: nil))
        controller.addAction(UIAlertAction(title: "拍照选择",
                                           style: .default) { action in self.fromCamera() } )
        controller.addAction(UIAlertAction(title: "相册选择",
                                           style: .default) { action in self.fromPhotoLibrary() } )
        return controller
    }
}

//可以记录自己坐标及状态的 Button
class MyButton: UIButton {
    
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

//记录自己是否被操作过的点
struct MyCGPoint {
    var x: CGFloat
    var y: CGFloat
    var ed: Bool
}

struct Matrix<Element> {
    //任意元素类型二维矩阵
    let rows: Int, columns: Int
    var grid: [Element]
    var example: Element
    init(rows: Int,
         columns: Int,
         example: Element) {
        self.rows = rows
        self.columns = columns
        self.example = example
        grid = Array<Element>(repeating: example,
                              count: rows * columns)
    }
    func indexIsValidForRow(_ row: Int,
                            _ column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    subscript(row: Int,
              column: Int) -> Element {
        get {
            assert(indexIsValidForRow(row, column), "Index out of range")
            return grid[(row * columns) + column]
        }
        set {
            assert(indexIsValidForRow(row, column), "Index out of range")
            grid[(row * columns) + column] = newValue
        }
    }
}

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

class ListNode {
    //定义节点
    var val: MyButton
    var next: ListNode?
    init(_ val: MyButton) {
        self.val = val
        self.next = nil
    }
}

class List {
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

//错误枚举
enum EnrollError: Error {
    case NoImageFound
    case NoPointFound
    case InsufficientPoints
}
//抛出错误函数：用于检查是否选择了图片
func isThereAnImage(_ image: UIImage?) throws {
    guard image != nil else {
        throw EnrollError.NoImageFound
    }
}
//抛出错误函数：用于检查是否选中点
func isThereAnPoint(_ point: MyButton?) throws {
    guard point != nil else {
        throw EnrollError.NoPointFound
    }
}
//抛出错误函数：用于检查是否添加了足够的顶点，至少3个点围成一个面
func areThereEnoughPoints(_ num: Int) throws {
    guard num >= 3 else {
        throw EnrollError.InsufficientPoints
    }
}
