//
//  GraphArea.swift
//  GraphSketcher
//
//  Copyright © 2020-2021 Maciej Chudzik. All rights reserved.
//

import Foundation
import CoreGraphics
import ImageSketcher

@available(iOS 10.0, *)

class GraphArea: AreaWithDrawableRepresentable<Graph>{
    
    let orientation: GraphOrientation
    
    init(area: CanvasPiece, orientation: GraphOrientation ) {
        
        self.orientation = orientation
        super.init(area: area)
       
    }
    
    func drawGraph(name: String, values: [Int], boldedPoints: Bool = false, mode: DrawingMode) -> GraphArea?{
        
        if !drawableShapes.isEmpty{
            
            if values.count != drawableShapes.last?.shape.values.count{
                return nil
            }
            
        }
        
        let graph = Graph(name: name, values: values, boldedPoints: boldedPoints)
        graph.areaSource = self
        graph.otherGraphsSource = self
        
        
        onDrawShape(shape: graph, mode: mode)
        
        
        return self
    }
    
}


@available(iOS 10.0, *)
extension GraphArea:  GraphsSource{


    func getGraphsPointsValues() -> [Int] {
        return drawableShapes.map{$0.shape}.flatMap{$0.values}
    }
    
    func getGraphsDimension(from: AxisDataSource) -> Int {
        
        
        switch from {
        
        case .count:
        
            return  drawableShapes.last!.shape.values.count
            
        case .value:
            
            return abs(getGraphsPointsValues().max()! - getGraphsPointsValues().min()!)
            
        }
    }
    

    func getGraphsToDraw() -> [Graph] {
        return drawableShapes.map{$0.shape}
    }
    
    func getGraphsPoints() -> [CGPoint]{
        
        return drawableShapes.map{$0.shape}.flatMap{$0.points}.map{$0.coordinate}
    }
    
    func getSpace(from: AxisDataSource) -> CGFloat{
        

        let resolution = getGraphsDimension(from: from)
        
        
        switch self.orientation {
        
        case .regular, .opposite:
                
                switch from {
                
                    case .count:
                        
                        return piece.boundingBox.width / CGFloat(resolution - 1)
                        
                    case .value:
                        
                        if resolution == 0{
                            
                            return piece.boundingBox.height
                            
                        }else{
                            
                            return piece.boundingBox.height / CGFloat(resolution)
                        }
                }

        case .rotatedClockwise, .rotatedCounterClockwise:

                switch from {
                
                    case .count:
                        
                        return piece.boundingBox.height / CGFloat(resolution - 1)
                        
                    case .value:
                        
                        if resolution == 0{
                            
                            return piece.boundingBox.width
                            
                        }else{
                            
                            return piece.boundingBox.width / CGFloat(resolution)
                        }
                
                }
            
        }

    }
    
}
