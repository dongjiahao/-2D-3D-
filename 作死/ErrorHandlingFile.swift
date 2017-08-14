//
//  ErrorHandlingFile.swift
//  作死
//
//  Created by 董嘉豪 on 2017/8/14.
//  Copyright © 2017年 董嘉豪. All rights reserved.
//

import UIKit

//错误处理的定义及声明

//错误枚举
enum EnrollError: Error {
    case noImageFound
    case noPointFound
    case insufficientPoints
    case indexOutOfRange
}
//抛出错误函数：用于检查是否选择了图片
func isThereAnImage(_ image: UIImage?) throws {
    guard image != nil else {
        throw EnrollError.noImageFound
    }
}
//抛出错误函数：用于检查是否选中点
func isThereAnPoint(_ point: MyButton?) throws {
    guard point != nil else {
        throw EnrollError.noPointFound
    }
}
//抛出错误函数：用于检查是否添加了足够的顶点，至少3个点围成一个面
func areThereEnoughPoints(_ num: Int) throws {
    guard num >= 3 else {
        throw EnrollError.insufficientPoints
    }
}
//抛出错误函数：用于检查所选 cell 是否有效
func whetherTndexOutOfRange(_ indexPathRow: Int,_ arrayCount: Int) throws {
    guard indexPathRow < arrayCount else {
        throw EnrollError.indexOutOfRange
    }
}
