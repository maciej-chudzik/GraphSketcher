//
//  AxisGraphArea.swift
//  GraphSketcher
//
//  Copyright © 2020-2021 Maciej Chudzik. All rights reserved.
//

import Foundation
import CoreGraphics
import ImageSketcher

@available(iOS 10.0, *)
class AxisGraphArea: BasicArea<GraphAxis>,AreaOrientationChangable, AnotherAxisAreaSource{
    
    
    func modifyLabelsBoxHeight(anotherLabelsHeight: CGFloat) {
        
        guard (labels != nil) else {return}
        
        for label in labels!{
            
            
            if anotherLabelsHeight < label.value.boundingBox.height{
                
                
                let newSize = CGSize(width: label.value.boundingBox.width, height: anotherLabelsHeight)
                
                let yDiff = label.value.boundingBox.height - anotherLabelsHeight
                
                
                let newBox = CGRect(origin: CGPoint(x: label.value.boundingBox.origin.x, y: label.value.boundingBox.origin.y + yDiff/2), size: newSize)
                
                label.value = Text(in: newBox, text: label.value.getText())
                
            }
            
        }
    }
    
    
    
    func getAxisLabelBox() -> CGRect? {
        return labels?.last?.value.boundingBox
    }
    
    func getAreaWidth() -> CGFloat {
        
        switch piece.boundingBox.orientation{
        case .topLefCorner, .bottomRightCorner:
            return piece.boundingBox.height
        case .topRightCorner, .bottomLeftCorner:
            return piece.boundingBox.width
        }
    }
    
    
    //MARK: GraphsSource
    
    weak var graphsSource: GraphsSource?
    
    
    //MARK: AnotherAxisAreaSource
    
    weak var anothreAxisAreaSource: AnotherAxisAreaSource?
    
    //MARK: Private methods
    
    var labels: LinkedList<Text>?
    
    var axisDrawingMode: DrawingMode?
    
    
    
    private func modifyLabelsIfNeeded(){
        
        if let anothreAxisAreaSource = self.anothreAxisAreaSource{
            
            if  let anotherLabelBox = anothreAxisAreaSource.getAxisLabelBox(){
                
                modifyLabelsBoxHeight(anotherLabelsHeight: anotherLabelBox.height)
                
            }
        }
        
        
    }
    
    private func determineSpaceForLabels()-> CGFloat?{
    
        guard let spaceCount = graphsSource?.getSpace(from: .count) else {return nil}
        guard let spaceValue = graphsSource?.getSpace(from: .value) else {return nil}
        
        if spaceCount  < spaceValue{
            return spaceCount
            
        }else if spaceValue == spaceCount{
            return  spaceCount
            
        }else{
            return spaceValue
            
        }
        
    }

    //MARK: API
    
    func getAxisScheduledToDraw() -> GraphAxis?{
        
        return self.getLastDrawable()
    }
    
    
    func drawCountAxis(option: AxisOptions, mode: DrawingMode, arrowed: Bool) -> AxisGraphArea?{
        
        self.labels = nil
        
        let axis = GraphAxis(in: piece.boundingBox, arrowed: arrowed)
        
        switch option {
        case .withDivisionLines(let labelsOption):
            
            guard let graphsPoints =  graphsSource?.getGraphsPoints() else {break}
            
            guard let dimension = graphsSource?.getGraphsDimension(from: .count) else {break}
            
            axis.setDivisionSegments(graphPoints: graphsPoints, lengthRatio: .oneTenth)
            
            
            switch labelsOption {
            case .withLabels(onSide: let side, let sourceOption):
                
                guard let space = self.determineSpaceForLabels() else {return nil}
                
                switch sourceOption {
                case .typeSource:
                    
                    var countLabels = [String]()
                    
                    for i in 1...dimension{
                        
                        countLabels.append(String(i))
                    }
                
                    self.labels = axis.setLabels(graphPoints: graphsPoints, labels: countLabels, on: side, width: space)
                    
                case .withOwnSource(labels: let labels):
                    
                    self.labels = axis.setLabels(graphPoints: graphsPoints, labels: labels, on: side, width: space)
                }
            case .noLabels:
                break
                
            }
            
            
        case .withoutDivisionLines:
            
            break
        
        }
        
        if self.labels != nil{
            
            modifyLabelsIfNeeded()
        
        }
        
        onDrawShape(shape: axis, mode: mode)
        
        axisDrawingMode = mode
        
        return self
        
        
    }
    
    func drawValueAxis(option: AxisOptions, mode: DrawingMode, arrowed: Bool) -> AxisGraphArea?{
        
        self.labels = nil
        
        let axis = GraphAxis(in: piece.boundingBox, arrowed: arrowed)
        
        switch option {
        case .withDivisionLines(let labelsOption):
            
            guard let graphsPoints =  graphsSource?.getGraphsPoints() else {break}
            
            guard let graphsValues = graphsSource?.getGraphsPointsValues() else {break}
            
            
            let graphsValuesUnique =  Set(graphsValues).sorted()
            
            
            axis.setDivisionSegments(graphPoints: graphsPoints, lengthRatio: .oneTenth)
            
            switch labelsOption {
            case .withLabels(onSide: let side, let sourceOption):
                
                
                guard let space = self.determineSpaceForLabels() else {return nil}
                
                switch sourceOption {
                case .typeSource:
                    
                    var valueLabels = [String]()
                    
                    for graphValue in graphsValuesUnique{
                        
                        valueLabels.append(String(graphValue))
                    }
                    
                    self.labels =  axis.setLabels(graphPoints: graphsPoints, labels: valueLabels, on: side, width: space)
                    
                case .withOwnSource(labels: let labels):
                    
                    self.labels =   axis.setLabels(graphPoints: graphsPoints, labels: labels, on: side, width: space)
                }
            case .noLabels:
                break
                
            }
            
        case .withoutDivisionLines:
            
            break
        }
        
        
        if self.labels != nil{
            
            modifyLabelsIfNeeded()
            
        }
        
        
        onDrawShape(shape: axis, mode: mode)
        
        axisDrawingMode = mode
        
        return self
        
    }
    
    
    
    
    
}
