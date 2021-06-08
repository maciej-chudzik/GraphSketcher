//
//  GraphAxis.swift
//  GraphSketcher
//
//  Copyright © 2020-2021 Maciej Chudzik. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit
import ImageSketcher

class GraphAxis: Axis{
    
    
    //MARK: Enums
    
    enum DivisionLengthRatio: Int{
        
        case oneTenth = 10
        case oneFifth = 5
        case oneFourth = 4
        case oneThird = 3
        
        
    }
    
    //MARK: Computed properties
    
    
    private var labelWidthHeight: CGFloat?{
        
        guard let divLineLengthRatio = self.divLineLengthRatio else {return nil}
        
        
        let unit = 10/divLineLengthRatio.rawValue
        
        let fraction: CGFloat = ((10 - CGFloat(unit))/2)/10
        
        
        
        switch self.boundingBox.orientation {
        
        case .topLefCorner, .bottomRightCorner:
            
            return self.boundingBox.height * fraction
            
        case .bottomLeftCorner, .topRightCorner:
            
            return self.boundingBox.width * fraction
            
        }
        
    }
    
    
    
    private var divLineLength: CGFloat?{
        
        guard let divLineLengthRatio  = divLineLengthRatio else{return nil}
        
        switch self.boundingBox.orientation {
        
        case .topLefCorner, .bottomRightCorner:
            
            return self.boundingBox.height / CGFloat(divLineLengthRatio.rawValue)
            
        case .bottomLeftCorner, .topRightCorner:
            
            return self.boundingBox.width / CGFloat(divLineLengthRatio.rawValue)
            
        }
        
    }
    
    
    //MARK: Stored Properties
    
    private var divLineLengthRatio: DivisionLengthRatio?
    
    private var labels: LinkedList<Text>?
    
    private var divisionSegments: [LineSegment]?
    
    
    //MARK: Inits
    
    override init(in boundingBox: CGRect, arrowed: Bool){
        super.init(in: boundingBox, arrowed: arrowed)
    }
    
    //MARK: API
    
    func setLabels(graphPoints: [CGPoint], labels: [String], on side: LabelsSide, width: CGFloat)->LinkedList<Text>?{
        
        if graphPoints.isEmpty || labels.isEmpty{
            self.labels = nil
            return nil
        }
        
        var horizontally: Bool
        
        switch self.orientation {
        
        case .horizontal:
            
            horizontally = true
            
        case .vertical:
            
            horizontally = false
            
        }
        
        let graphPointsToAxisProjected = self.coreLineSegment.pointsProjected(points: graphPoints, horizontally: horizontally)
        
        
        var axisPointsWithLabels = [(coordinates: CGPoint, label: String)]()
        
        var reducedPoints = [CGPoint]()
        
        
        switch self.orientation {
        
        case .horizontal:
            
            let tupleCoordinates = graphPointsToAxisProjected!.map { ($0.x, $0.y) }
            
            let reducedToDicCoors = Dictionary(tupleCoordinates, uniquingKeysWith: +).sorted(by: {$0.key < $1.key})
            
            reducedPoints = reducedToDicCoors.map{CGPoint(x: $0.key, y: $0.value)}
            
            
            
            
        case .vertical:
            
            let tupleCoordinates = graphPointsToAxisProjected!.map { ($0.y, $0.x) }
            
            
            let reducedToDicCoors = Dictionary(tupleCoordinates, uniquingKeysWith: +).sorted(by: {$0.key > $1.key})
            
            reducedPoints = reducedToDicCoors.map{CGPoint(x: $0.value, y: $0.key)}
            
            
            
        }
        
        
        
        if labels.count == reducedPoints.count{
            
            for i in 0..<reducedPoints.count{
                
                axisPointsWithLabels.append(((reducedPoints[i]),labels[i]))
                
            }
        }else if labels.count > reducedPoints.count{
            
            let cutLabels = Array(labels.prefix(reducedPoints.count))
            
            for i in 0..<reducedPoints.count{
                
                axisPointsWithLabels.append(((reducedPoints[i]),cutLabels[i]))
                
            }
            
            
        }else{
            
            self.labels = nil
            return nil
        }
        
        
        let tempTexts = LinkedList<Text>()
        
        
        for axisPointWithLabel in axisPointsWithLabels{
            
            var textOrigin: CGPoint
            var textSize: CGSize
            
            switch self.boundingBox.orientation {
            
            
            case .topLefCorner, .bottomRightCorner:
                
                var height: CGFloat
                
                if let labelWidthHeight =  self.labelWidthHeight{
                    
                    height = labelWidthHeight
                    
                }else{
                    
                    height = self.boundingBox.height/2
                    
                }
                
                
                switch side{
                
                case .left:
                    
                    textOrigin = CGPoint(x: axisPointWithLabel.coordinates.x - width/2, y: self.boundingBox.minY)
                    
                case .right:
                    
                    textOrigin = CGPoint(x: axisPointWithLabel.coordinates.x - width/2, y: self.boundingBox.maxY - height)
                    
                }
                
                textSize = CGSize(width: width, height: height)
                
                
            case .bottomLeftCorner, .topRightCorner:
                
                let height = width
                
                var width: CGFloat
                
                if let labelWidthHeight =  self.labelWidthHeight{
                    
                    width = labelWidthHeight
                    
                }else{
                    
                    width = self.boundingBox.width/2
                    
                }
                
                switch side{
                
                case .left:
                    
                    textOrigin = CGPoint(x:  self.boundingBox.minX, y: axisPointWithLabel.coordinates.y - height/2)
                    
                case .right:
                    
                    textOrigin = CGPoint(x:  self.boundingBox.maxX - width, y: axisPointWithLabel.coordinates.y - height/2)
                    
                }
                
                textSize = CGSize(width: width, height:  height)
                
            }
            
            
            let text = Text(in: CGRect(origin: textOrigin, size: textSize), text: NSString(string: axisPointWithLabel.label))
            
            
            if let last = tempTexts.last {
                
                if text.getTextSize() > last.value.getTextSize() {
                    
                    text.changeCurrentFontsize(size: last.value.getTextSize() )
                    
                    
                }else if text.getTextSize() < last.value.getTextSize(){
                    
                    tempTexts.modifyBackwards { (eachText) in
                        eachText.changeCurrentFontsize(size: text.getTextSize())
                        eachText.centerVerticallyIfNeeded()
                        // eachText.adjustBoundingBox()
                    }
                    
                    
                }
                text.centerVerticallyIfNeeded()
                //  text.adjustBoundingBox()
                tempTexts.append(value: text)
                
                
                
            }else{
                text.centerVerticallyIfNeeded()
                //  text.adjustBoundingBox()
                tempTexts.append(value: text)
            }
            
        }
        
        self.labels = tempTexts
        
        return tempTexts
    }
    
    func getLabelWidthHeight()->CGFloat?{
        
        return self.labelWidthHeight
    }
    
    
    
    func setDivisionSegments(graphPoints: [CGPoint], lengthRatio: DivisionLengthRatio){
        
        
        self.divLineLengthRatio = lengthRatio
        
        var tempArray = [LineSegment]()
        
        var axisPoints: [CGPoint]?
        
        
        switch self.boundingBox.orientation {
        
        case .topLefCorner, .bottomRightCorner:
            
            
            axisPoints = self.coreLineSegment.pointsProjected(points: graphPoints, horizontally: true)
            
        case .topRightCorner, .bottomLeftCorner:
            
            
            axisPoints = self.coreLineSegment.pointsProjected(points: graphPoints, horizontally: false)
            
        }
        
        if self.arrowed{
            
            axisPoints = axisPoints?.dropLast()
            
        }
        
        
        for point in axisPoints!{
            
            let divisionLineSegment = self.coreLineSegment.perpendicularLineSegment(atDistance: self.divLineLength!, anchor: point)
            tempArray.append(divisionLineSegment!)
            
        }
        
        divisionSegments =  tempArray
        
    }
    
    
    
    
    @available(iOS 10.0, *)
    override func draw(mode:DrawingMode) -> ImageRendererContextModification{
        
        
        return {(context) in
            
            let _ = super.draw(mode: mode)(context)
            
            if let divisionSegments = self.divisionSegments{
                
                for divisionSegment in divisionSegments{
                    
                    let _ =  divisionSegment.draw(mode: mode)(context)
                    
                    
                }
            }

            return context
            
        }
    }

}

