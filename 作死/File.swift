//
//  File.swift
//  作死
//
//  Created by 董嘉豪 on 2017/5/8.
//  Copyright © 2017年 董嘉豪. All rights reserved.
//

import UIKit

//全局变量定义及声明

//就是想体验一把中文变量，没别的想法。。。
var 底面: UIImage?
var 边缘检测后的底面: UIImage?
var 侧面: UIImage?
var 边缘检测后的侧面: UIImage?
//二维矩阵储存：像素化的图片再经筛选后的点
//底面
var matrixDM: Matrix<Bool>? = nil
//侧面
var matrixCM: Matrix<Bool>? = nil
//单链表，用来储存底面顶点顺序
var list: List? = List()
//时间测试
var start: CFAbsoluteTime = 0
//记录侧面的高宽比
var rateHW: CGFloat?
//记录侧面所取宽度的数组
var widthArray: [CGFloat] = []
