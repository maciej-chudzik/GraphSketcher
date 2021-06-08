//
//  Graph.swift
//  GraphSketcher
//
//  Copyright © 2020-2021 Maciej Chudzik. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit
import ImageSketcher


public class Graph{
    
    //MARK: Public Properties
    public var name: String
    public var values: [Int]
    
    //MARK: Private Properties
    private var withBoldedPoints = false
    
    
    //MARK: Enums
    enum Source{
        case count
        case value
    }
    
    
    //MARK: Sources
    
    public weak var areaSource: AreaSource?
    
    weak var otherGraphsSource: GraphsSource?

    
    //MARK: Inits
    
    public init(name: String, values: [Int], boldedPoints: Bool = false){
        self.name = name
        self.values = values
        self.withBoldedPoints = boldedPoints
    }
    
    
    public init(name: String, values: [Int]){
        self.name = name
        self.values = values
    }
    
    
    //MARK: Public computed properties
    
    var points: [GraphPoint]{
        
        var tempPoints = [GraphPoint]()
        
        var heightOrWidth: CGFloat
        
        guard let spaceCount  = otherGraphsSource?.getSpace(from: .count) else { return []}
        
        guard let spaceValues = otherGraphsSource?.getSpace(from: .value) else { return []}
        
        guard let graphsValues = otherGraphsSource?.getGraphsPointsValues() else {return []}
        
        guard let area = areaSource?.getArea() else {return []}
        
        switch area.orientation{
        
        case .topLefCorner, .bottomRightCorner:
            
            heightOrWidth = area.size.height
            
        case .topRightCorner, .bottomLeftCorner:
            
            heightOrWidth = area.size.width
        }
        
        let valuesOffsetbyMin = self.values.map{$0 - graphsValues.min()!}
        
        
        
        for i in 0..<self.values.count{
            
            var x: CGFloat
            var y: CGFloat
            
            switch area.orientation{
            
            case .topLefCorner, .bottomRightCorner:
                
                x = area.origin.x + spaceCount * CGFloat(i)
                y = area.origin.y + heightOrWidth  - CGFloat(valuesOffsetbyMin[i]) * spaceValues
                
                
            case .topRightCorner, .bottomLeftCorner:
                
                x = area.origin.x + heightOrWidth - CGFloat(valuesOffsetbyMin[i]) * spaceValues
                y = area.origin.y + spaceCount * CGFloat(i)
  
            }

            tempPoints.append(GraphPoint(coordinate: CGPoint(x: x , y: y), value: self.values[i]))
        }
        
        return tempPoints
        
        
    }
    
}


@available(iOS 10.0, *)
extension Graph: DrawableRepresentable{
    
    public var drawableRepresentation: [Drawable]{
        
        var tempDrawables = [Drawable]()
        
        tempDrawables.append(PolygonalChain(points: points.map{$0.coordinate})!)
        
        if withBoldedPoints {
            
            for point in points.map({$0.coordinate}){
                
                tempDrawables.append(Circle(radius: UIScreen.main.nativeScale/2, center: point)!)
                
            }
            
        }
        
        return tempDrawables
    }
    
}

extension Graph: Equatable{
   public static func == (lhs: Graph, rhs: Graph) -> Bool {
        return lhs.values == rhs.values && lhs.name == rhs.name
    }
    

}

extension Graph: Hashable{

    public func hash(into hasher: inout Hasher) {

        hasher.combine(name)
        hasher.combine(values)
     }
    
}
