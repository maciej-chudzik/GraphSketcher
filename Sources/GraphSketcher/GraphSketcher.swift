//
//  GraphSketcher.swift
//  GraphSketcher
//
//  Copyright © 2020-2021 Maciej Chudzik. All rights reserved.
//


import Foundation
import CoreGraphics
import UIKit
import ImageSketcher

@available(iOS 10.0, *)
public class GraphSketcher: ImageSketcher{
    
    //MARK: Enums
    
    public enum KeyPointsOption{
        case marked(mode: DrawingMode)
        case unmarked
    }
    
    //MARK: Inits
    
    public init?(drawOn bounds: CGRect, xMargin: CGFloat, yMargin: CGFloat) {
        
        super.init(drawOn: bounds, option: .withAdditionalAreas(xMargin: xMargin, yMargin: yMargin))
        
    }
    
    private var graphArea: GraphArea?
    
    private var countAxisArea: AxisGraphArea?
    private var countAxisLabelArea: TextArea?
    
    private var valueAxisArea: AxisGraphArea?
    private var valueAxisLabelArea: TextArea?
    
    private var orientation: GraphOrientation?
    
    
    
    
    private var countAxisKeyPointsMarkInstruction: ImageRendererContextModification?
    private var valueAxisKeyPointsMarkInstruction: ImageRendererContextModification?
    
    
    
    private func resetAssignedAreas(){
        
        graphArea = nil
        countAxisArea = nil
        valueAxisArea = nil
        orientation = nil
        
        
        countAxisKeyPointsMarkInstruction = nil
        valueAxisKeyPointsMarkInstruction = nil
        
        
    }
    
    
    //MARK: API
    
    public override func renderImage() -> UIImage? {
        
        
        
        guard graphArea != nil else {return nil}
        
        scheduleInstruction(with: graphArea!)
        
        if let countAxisArea = countAxisArea{
            
            scheduleInstruction(with: countAxisArea)
            
            if let mode = countAxisArea.axisDrawingMode{
                
                if let countLabels = countAxisArea.labels{
                    
                    for label in countLabels{
                        
                        scheduleInstruction(instruction: label.value.draw(mode: mode))
                        
                    }
                }
            }
            
            
        }
        
        if let valueAxisArea = valueAxisArea{
            
            scheduleInstruction(with: valueAxisArea)
            
            if let mode = valueAxisArea.axisDrawingMode{
                
                if let valueLabels = valueAxisArea.labels{
                    
                    for label in valueLabels{
                        
                        scheduleInstruction(instruction: label.value.draw(mode: mode))
                        
                    }
                }
            }
            
            
        }
        
        if let countAxisLabelArea = countAxisLabelArea{
            scheduleInstruction(with: countAxisLabelArea)
        }
        
        if let valueAxisLabelArea = valueAxisLabelArea{
            scheduleInstruction(with: valueAxisLabelArea)
        }
        
        
        if let countAxisKeyPointsMarkInstruction = countAxisKeyPointsMarkInstruction{
            
            scheduleInstruction(instruction: countAxisKeyPointsMarkInstruction)
        }
        
        if let valueAxisKeyPointsMarkInstruction = valueAxisKeyPointsMarkInstruction{
            
            scheduleInstruction(instruction: valueAxisKeyPointsMarkInstruction)
        }
        
        return super.renderImage()
    }
    
    @discardableResult
    public func setGraphsToDraw(graphs: GraphArray, orientation: GraphOrientation = .regular)->Self?{
        
        resetDrawingInstructions()
        resetAreas()
        resetAssignedAreas()
        
        self.orientation = orientation
        
        var middlepiece: CanvasPiece?
        
        switch orientation {
        
        case .regular:
            
            middlepiece = getCanvasPiece(part: .middle, withRotation: nil)
        case .opposite:
            
            middlepiece = getCanvasPiece(part: .middle, withRotation: .flip)
            
        case .rotatedClockwise:
            
            middlepiece = getCanvasPiece(part: .middle, withRotation: .rotateCounterClockwise)
            
        case .rotatedCounterClockwise:
            
            middlepiece = getCanvasPiece(part: .middle, withRotation: .rotateClockwise)
            
        }
        
        guard let middle = middlepiece else {return nil}
        
        graphArea =  GraphArea(area: middle, orientation: orientation)
        
        for graph in graphs{
            
            let _ = graphArea!.drawGraph(name: graph.key.name, values: graph.key.values, boldedPoints: graph.value.withBoldedPoints, mode: graph.value.drawingMode)
            
            
        }
        
        return self
        
    }
    
    @discardableResult
    public func setCountAxis(options: AxisOptions, mode: DrawingMode, arrowed: Bool, keyPointsOption: KeyPointsOption, axisLabel: String? = nil)-> Self?{
        guard let graphArea = self.graphArea else {return nil}
        
        var countAxisPiece: CanvasPiece?
        var countAxisLabelPiece: CanvasPiece?
        
        
        
        switch self.orientation! {
        
        case .regular:
            
            countAxisPiece = getCanvasPiece(part: .bottomMiddle, withRotation: nil)
            if axisLabel != nil{
                countAxisLabelPiece = getCanvasPiece(part: .bottomRightCorner, withRotation: nil)
            }
        case .opposite:
            
            countAxisPiece = getCanvasPiece(part: .topMiddle, withRotation: .flip)
            if axisLabel != nil{
                countAxisLabelPiece = getCanvasPiece(part: .topLeftCorner, withRotation: nil)
            }
        case .rotatedClockwise:
            
            countAxisPiece = getCanvasPiece(part: .left, withRotation: .rotateClockwise)
            if axisLabel != nil{
                countAxisLabelPiece = getCanvasPiece(part: .bottomLeftCorner, withRotation: nil)
            }
            
        case .rotatedCounterClockwise:
            
            countAxisPiece = getCanvasPiece(part: .right, withRotation: .rotateCounterClockwise)
            if axisLabel != nil{
                countAxisLabelPiece = getCanvasPiece(part: .topRightCorner, withRotation: nil)
            }
        }
        
        guard let countPiece = countAxisPiece else {return nil}
        
        
        countAxisArea = AxisGraphArea(area: countPiece)
        countAxisArea?.graphsSource = self.graphArea
        countAxisArea?.anothreAxisAreaSource = valueAxisArea
        
        
        
        let _ = countAxisArea!.drawCountAxis(option: options, mode: mode, arrowed: arrowed)
        
        switch keyPointsOption {
        case .marked(let mode):
            
            countAxisKeyPointsMarkInstruction =  self.drawDashedLinesForKeyPoints(for: countAxisArea!.getAxisScheduledToDraw()!, points: graphArea.getGraphsPoints(), mode: mode)
        case .unmarked:
            countAxisKeyPointsMarkInstruction = nil
        }
        
        if var countAxisLabelPieceNew = countAxisLabelPiece{
            
           let dxy = countAxisLabelPiece!.boundingBox.size.height/4
        
            let newBox = countAxisLabelPiece!.boundingBox.insetBy(dx: dxy,dy: dxy)
            
            countAxisLabelPieceNew.boundingBox = newBox
            
            countAxisLabelArea = TextArea(area: countAxisLabelPieceNew)
            let _ = countAxisLabelArea!.drawText(text: axisLabel!, mode: mode, centerVertically: true)
        }
        
        
        
        return self
    }
    
    
    
    
    
    @discardableResult
    public func setValueAxis(options: AxisOptions, mode: DrawingMode, arrowed: Bool, keyPointsOption: KeyPointsOption, axisLabel: String? = nil)-> Self?{
        
        guard let graphArea = self.graphArea else {return nil}
    
        var valueAxisPiece: CanvasPiece?
        var valueAxisLabelPiece: CanvasPiece?
    
        switch self.orientation! {
        
            case .regular:
                
                valueAxisPiece = getCanvasPiece(part: .left, withRotation: .rotateCounterClockwise)
                if axisLabel != nil{
                    valueAxisLabelPiece = getCanvasPiece(part: .topLeftCorner, withRotation: nil)
                }
                
            case .opposite:
                
                valueAxisPiece = getCanvasPiece(part: .right, withRotation: .rotateClockwise)
                if axisLabel != nil{
                    valueAxisLabelPiece = getCanvasPiece(part: .bottomRightCorner, withRotation: nil)
                }
                
            case .rotatedClockwise:
                valueAxisPiece = getCanvasPiece(part: .topMiddle, withRotation: nil)
                if axisLabel != nil{
                    valueAxisLabelPiece = getCanvasPiece(part: .topRightCorner, withRotation: nil)
                }
                
            case .rotatedCounterClockwise:
                
                valueAxisPiece = getCanvasPiece(part: .bottomMiddle, withRotation: .flip)
                if axisLabel != nil{
                    valueAxisLabelPiece = getCanvasPiece(part: .bottomLeftCorner, withRotation: nil)
                }
                
        }
        
        valueAxisArea = AxisGraphArea(area: valueAxisPiece!)
        valueAxisArea?.graphsSource = self.graphArea
        valueAxisArea?.anothreAxisAreaSource = countAxisArea
        
        
        
        let _ =  valueAxisArea!.drawValueAxis(option: options, mode: mode, arrowed: arrowed)
        
        switch keyPointsOption {
        case .marked(let mode):
            
            valueAxisKeyPointsMarkInstruction = self.drawDashedLinesForKeyPoints(for: valueAxisArea!.getAxisScheduledToDraw()!, points: graphArea.getGraphsPoints(), mode: mode)
        case .unmarked:
            valueAxisKeyPointsMarkInstruction = nil
        }
        
        if var valueAxisLabelPieceNew = valueAxisLabelPiece{
            
           let dxy = valueAxisLabelPiece!.boundingBox.size.height/4
        
            let newBox = valueAxisLabelPiece!.boundingBox.insetBy(dx: dxy,dy: dxy)
            
            valueAxisLabelPieceNew.boundingBox = newBox
            
            valueAxisLabelArea = TextArea(area: valueAxisLabelPieceNew)
            let _ = valueAxisLabelArea!.drawText(text: axisLabel!, mode: mode, centerVertically: true)
        }
        
        return self
    }
    
    //MARK: Private Methods
    
    private func  getKeyPoints(points: [CGPoint]) -> [CGPoint]{
        
        var tempArray = [CGPoint]()
        let pointsY = points.map{$0.y}
        
        for i in 0..<points.count{
            if i >= 1 && i <= points.count - 2 {
                //local minimum
                if points[i].y > points[i+1].y &&  points[i].y > points[i-1].y{
                    tempArray.append(points[i])
                }
                //local maximum
                if points[i].y < points[i+1].y &&  points[i].y < points[i-1].y{
                    tempArray.append(points[i])
                }
            }
            //three consecutive equal points without first
            if  i >= 1 && i <= points.count - 3{
                if points[i].y == points[i+1].y && points[i].y == points[i+2].y && points[i].y != points[i-1].y{
                    tempArray.append(points[i])
                }
            }
            //three consecutive equal points starting from first
            if i == 0 && points[0] == points[1] &&  points[0] == points[2]{
                tempArray.append(points[0])
            }
            //minimum
            if points[i].y == pointsY.max(){
                tempArray.append(points[i])
            }
            //maximum
            if points[i].y == pointsY.min(){
                tempArray.append(points[i])
            }
        }
        return Array(Set(tempArray))
    }
    
    private func getDashedSegments(graphsPoints: [CGPoint], axis: Axis) -> [LineSegment]? {
        
        
        var tempArray = [LineSegment]()
        
        guard !graphsPoints.isEmpty else { return nil }
        
        
        for point in graphsPoints{
            
            var toBeDashedSegment: LineSegment
            
            switch axis.boundingBox.orientation{
            
            case .topLefCorner, .bottomRightCorner:
                
                toBeDashedSegment = LineSegment(endPointA: CGPoint(x: point.x, y: axis.coreLineSegment.middlePoint().y), endPointB: point)
                
                
            case .topRightCorner, .bottomLeftCorner:
                
                toBeDashedSegment = LineSegment(endPointA: CGPoint(x: axis.coreLineSegment.middlePoint().x, y: point.y), endPointB: point)
                
            }
            
            tempArray.append(toBeDashedSegment)
            
            
        }
        return tempArray
    }
    
    private func drawDashedLinesForKeyPoints(for axis: GraphAxis, points: [CGPoint], mode: DrawingMode) -> ImageRendererContextModification{
        
        return { [weak self](context) in
            
            guard let self = self else {return context}
            
            var dashedSegements = [LineSegment]()
            
            let keyPoints = self.getKeyPoints(points: points)
            
            if !keyPoints.isEmpty{
                
                dashedSegements += self.getDashedSegments(graphsPoints: keyPoints, axis: axis)!
            }
            
            context.cgContext.saveGState()
            
            
            let _ =  mode.apply(context)
            
            
            for dashedSegment in dashedSegements{
                
                let _ =   dashedSegment.draw(mode: mode)(context)
                
            }
            
            switch mode {
            case .stroke(_, _):
                context.cgContext.drawPath(using: .stroke)
            case .strokeAndFill(_, _, _):
                context.cgContext.drawPath(using: .fillStroke)
            case .dashedStroke(strokecolor: _, width: _, phase: _, pattern: _):
                context.cgContext.drawPath(using: .stroke)
            }
        
            context.cgContext.restoreGState()
            
            return context
        }
        
        
    }
    
}

