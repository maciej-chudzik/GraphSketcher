//
//  Axis.swift
//  GraphSketcher
//
//  Copyright © 2020-2021 Maciej Chudzik. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit
import ImageSketcher


class Axis: OrientationChangable, RectCalculatable, Drawable{
    
    //MARK: Properties
    
    var boundingBox: CGRect
    let arrowed: Bool
    
    //MARK: Enum
    
    enum Orientation{
        case vertical
        case horizontal
        
    }
    
    //MARK: Init
    
    init(in boundingBox: CGRect, arrowed: Bool){
        self.boundingBox = boundingBox
        self.arrowed = arrowed
    }
    
    //MARK: Computed properties
    
    var orientation: Orientation{
        
        switch self.boundingBox.orientation {
        
        case .topLefCorner, .bottomRightCorner:
            return .horizontal
            
        case .topRightCorner, .bottomLeftCorner:
            return .vertical
        }
        
    }
    
    
    var startPoint: CGPoint{
        
        switch self.boundingBox.orientation {
        
        case .topLefCorner:
            
            return CGPoint(x: boundingBox.origin.x, y: boundingBox.origin.y + boundingBox.size.height/2)
            
        case .topRightCorner:
            
            return CGPoint(x: boundingBox.origin.x + boundingBox.size.width/2, y: boundingBox.origin.y)
            
        case .bottomRightCorner:
            
            return CGPoint(x: boundingBox.origin.x, y: boundingBox.origin.y + boundingBox.size.height/2)
            
        case .bottomLeftCorner:
            
            return CGPoint(x: boundingBox.origin.x + boundingBox.size.width/2, y: boundingBox.origin.y)
            
        }
        
    }
    
    
    var endPoint: CGPoint{
        
        switch self.boundingBox.orientation {
        
        case .topLefCorner, .bottomRightCorner:
            
            return CGPoint(x: self.startPoint.x + self.boundingBox.size.width, y: self.startPoint.y)
            
        case .topRightCorner, .bottomLeftCorner:
            
            return CGPoint(x: self.startPoint.x, y: self.startPoint.y +  self.boundingBox.size.height)
            
        }
        
    }
    var coreLenght: CGFloat{
        
        return startPoint.distanceToPoint(toPoint: endPoint)
    }
    
    
    var coreLineSegment: LineSegment{
        return LineSegment(endPointA: startPoint, endPointB: endPoint)
        
    }
    
    var arrow: Arrow?{
        
        guard arrowed else {return nil}
        
        return Arrow(start: coreLineSegment.middlePoint(), end: endPoint, angle: 30.0, wingLength: 10.0)
        
        
    }
    
    
    //MARK: Drawable conformance
    @available(iOS 10.0, *)
    func draw(mode:DrawingMode) -> ImageRendererContextModification{
        
        return { [weak self](context) in
            
            guard let self = self else {return context}
            
            let _ = self.coreLineSegment.draw(mode: mode)(context)
            
            if let arrow = self.arrow{
                
                let _ = arrow.draw(mode: mode)(context)
                
            }
            return context}
    }
    
    
}
