//
//  Protocols.swift
//  GraphSketcher
//
//  Copyright © 2020-2021 Maciej Chudzik. All rights reserved.
//
import Foundation
import UIKit
import CoreGraphics


protocol GraphsSource: AnyObject{
    
    func getGraphsToDraw()-> [Graph]
    func getGraphsPoints() -> [CGPoint]
    func getGraphsPointsValues() -> [Int]
    func getGraphsDimension(from: AxisDataSource) -> Int
    func getSpace(from: AxisDataSource) -> CGFloat
    
}

protocol AnotherAxisAreaSource: AnyObject{

    func getAreaWidth() -> CGFloat
    func getAxisLabelBox() -> CGRect?
    func modifyLabelsBoxHeight(anotherLabelsHeight: CGFloat)
    
}
