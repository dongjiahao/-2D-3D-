//
//  StructFile.swift
//  作死
//
//  Created by 董嘉豪 on 2017/8/14.
//  Copyright © 2017年 董嘉豪. All rights reserved.
//

import UIKit

//结构体的定义及声明

//记录自己是否被操作过的点
struct MyCGPoint {
    var x: CGFloat
    var y: CGFloat
    var ed: Bool
}

//——————————————————————————————————————————————————————————————————————————————————————————

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
