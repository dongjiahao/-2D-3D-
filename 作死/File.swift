//
//  File.swift
//  作死
//
//  Created by 董嘉豪 on 2017/5/8.
//  Copyright © 2017年 董嘉豪. All rights reserved.
//

import Foundation
import Photos

var image: UIImage? = UIImage()
var s: UIImage? = UIImage()
//二维矩阵储存：像素化的图片再经筛选后的点
var matrix: Matrix<Bool>? = nil
var list: List = List()
//时间测试
var start: CFAbsoluteTime = 0

extension ViewController {
    var selectorController: UIAlertController {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        // 取消按钮
        controller.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        // 拍照选择
        controller.addAction(UIAlertAction(title: "拍照选择", style: .default) { action in self.fromCamera() } )
        // 相册选择
        controller.addAction(UIAlertAction(title: "相册选择", style: .default) { action in self.fromPhotoLibrary() } )
        return controller
    }
}

class MyButton: UIButton {
    
    var p: CGPoint? = nil
    
    var blue: Bool? {
        didSet {
            if self.blue! {
                self.yellow = false
                self.red = false
                self.setImage(UIImage(named: "blue"), for: .normal)
            }
        }
    }
    var yellow: Bool? {
        didSet {
            if self.yellow! {
                self.blue = false
                self.red = false
                self.setImage(UIImage(named: "yellow"), for: .normal)
            }
        }
    }

    var red: Bool? {
        didSet {
            if self.red! {
                self.yellow = false
                self.blue = false
                self.setImage(UIImage(named: "red"), for: .normal)
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
    init(rows: Int, columns: Int, example: Element) {
        self.rows = rows
        self.columns = columns
        self.example = example
        grid = Array<Element>(repeating: example, count: rows * columns)
    }
    func indexIsValidForRow(_ row: Int, _ column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    subscript(row: Int, column: Int) -> Element {
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
     
     - returns: 颜色值，亮度，色度
     */
    func getPixelColor(pos: CGPoint) -> (alpha: CGFloat, red: CGFloat, green: CGFloat, blue: CGFloat, y: CGFloat) {
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo + 1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo + 2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo + 3]) / CGFloat(255.0)
        let y = CGFloat(r * 0.299 + g * 0.587 + b * 0.114)
        //        let u = -0.147 * r - 0.289 * g + 0.436 * b
        
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
