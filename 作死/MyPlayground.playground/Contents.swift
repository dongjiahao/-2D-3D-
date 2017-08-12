//: Playground - noun: a place where people can play

import UIKit

//性能测试
//生成一个 100*100 储存 false 的二维数组(不用Array(repeating:, count:))，再全部改为 true 用时 16.26
//生成一个 100*100 储存 false 的二维矩阵，再全部改为 true 用时 1.17
//说明二维矩阵的性能远好于二维数组(不用Array(repeating:, count:))
//但是略差于二维数组(用Array(repeating:, count:))(用时 0.79)

//struct Matrix<Element> {
//    //任意元素类型二维矩阵
//    let rows: Int, columns: Int
//    var grid: [Element]
//    var example: Element
//    init(rows: Int,
//         columns: Int,
//         example: Element) {
//        self.rows = rows
//        self.columns = columns
//        self.example = example
//        grid = Array<Element>(repeating: example,
//                              count: rows * columns)
//    }
//    func indexIsValidForRow(_ row: Int,
//                            _ column: Int) -> Bool {
//        return row >= 0 && row < rows && column >= 0 && column < columns
//    }
//    subscript(row: Int,
//              column: Int) -> Element {
//        get {
//            assert(indexIsValidForRow(row, column), "Index out of range")
//            return grid[(row * columns) + column]
//        }
//        set {
//            assert(indexIsValidForRow(row, column), "Index out of range")
//            grid[(row * columns) + column] = newValue
//        }
//    }
//}
////
//var start: CFAbsoluteTime = 0
//start = CACurrentMediaTime()
////————————————————————————————————
////var a:[[Bool]] = []
////for i in 0..<100 {
////    var a1: [Bool] = []
////    for j in 0..<100 {
////        a1.append(false)
////    }
////    a.append(a1)
////}
////16.26
////————————————————————————————————
//var a1 = Array(repeating: false, count: 100)
//var a = Array(repeating: a1, count: 100)
////0.79
////————————————————————————————————
//for i in 0..<a.count {
//    for j in 0..<a[i].count {
//        a[i][j] = true
//    }
//}
//a
//print(CACurrentMediaTime() - start)
//
//
//start = CACurrentMediaTime()
//var b = Matrix<Bool>(rows: 100, columns: 100, example: false)
//
//for i in 0..<b.rows {
//    for j in 0..<b.columns {
//        b[i,j] = true
//    }
//}
//b
////1.17
//print(CACurrentMediaTime() - start)





















