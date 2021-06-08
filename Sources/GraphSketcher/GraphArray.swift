//
//  GraphArray.swift
//  GraphSketcher
//
//  Copyright © 2020-2021 Maciej Chudzik. All rights reserved.
//

import Foundation
import ImageSketcher

@available(iOS 10.0, *)
public struct GraphDrawingMode{
    
    let drawingMode: DrawingMode
    let withBoldedPoints: Bool
    
    public init(drawingMode: DrawingMode, withBoldedPoints: Bool){
        
        self.drawingMode = drawingMode
        self.withBoldedPoints = withBoldedPoints
    }
    
}

@available(iOS 10.0, *)
public struct GraphArray {
    
    private(set) var storage: [Graph:GraphDrawingMode] = [:]
    private(set) var maxValuesCount: Int?
    
    
    public init(maxValuesCount: Int? = nil) {
        self.maxValuesCount = maxValuesCount
    }
    
    
    public init<S: Sequence>(from graphsSequence: S, maxValuesCount: Int, uniqueDrawingMode mode: GraphDrawingMode) where S.Element == Graph {
        
        self.maxValuesCount = maxValuesCount
        
        let keys: [Graph] = graphsSequence.map{
            
            $0.values = Array($0.values.prefix(maxValuesCount))
            return $0
            
        }
        let values = Array(repeating: mode, count: keys.count)
        self.storage = Dictionary(uniqueKeysWithValues: zip(keys,values))
        
    }
    
    
    public init(from dict: [Graph:GraphDrawingMode] , maxValuesCount: Int) {
        
        self.maxValuesCount = maxValuesCount
        
        
        let oldKeys = Array(dict.keys)
        
        let oldValues = Array(dict.values)
        
        let newKeys: [Graph] = oldKeys.map{
            
            $0.values = Array($0.values.prefix(maxValuesCount))
            return $0
            
        }
        
        self.storage = Dictionary(uniqueKeysWithValues: zip(newKeys,oldValues))
        
        
    }
    
    public init?(from dict: [Graph:GraphDrawingMode]){
        
        var tempGraphsAndModes = [Graph:GraphDrawingMode]()
        
        var maxValuesCount: Int?
        
        for pair in dict{
            
            guard pair.key.values.count > 0 else {return nil}
            
            if tempGraphsAndModes.isEmpty{
                
                maxValuesCount = pair.key.values.count
                tempGraphsAndModes[pair.key] = pair.value
                
                
            }else{
                
                
                
                if pair.key.values.count == tempGraphsAndModes.first?.key.values.count{
                    
                    tempGraphsAndModes[pair.key] = pair.value
                    
                    
                }else if pair.key.values.count > tempGraphsAndModes.first!.key.values.count{
                    
                    let tempPair = pair
                    tempPair.key.values = Array(pair.key.values.prefix(maxValuesCount!))
                    tempGraphsAndModes[tempPair.key] = pair.value
                    
                    
                }else{
                    
                    maxValuesCount = pair.key.values.count
                    
                    let oldKeys = Array(tempGraphsAndModes.keys)
                    
                    let oldValues = Array(tempGraphsAndModes.values)
                    
                    let newKeys: [Graph] = oldKeys.map{
                        
                        $0.values = Array($0.values.prefix(pair.key.values.count))
                        return $0
                        
                    }
                    
                    tempGraphsAndModes = Dictionary(uniqueKeysWithValues: zip(newKeys,oldValues))
                    
                    tempGraphsAndModes[pair.key] = pair.value
 
                }
                
            }
            
        }
        
        self.storage = tempGraphsAndModes

    }
    
    
    public init?<S: Sequence>(from graphsSequence: S, uniqueDrawingMode mode: GraphDrawingMode) where S.Element == Graph {
        
        var tempGraphsAndModes = [Graph:GraphDrawingMode]()
        
        var maxValuesCount: Int?
        
        for graph in graphsSequence{
            
            guard graph.values.count > 0 else {return nil}
            
            if tempGraphsAndModes.isEmpty{
                
                maxValuesCount = graph.values.count
                tempGraphsAndModes[graph] = mode
                
                
            }else{

                if graph.values.count == tempGraphsAndModes.first?.key.values.count{
                    
                    tempGraphsAndModes[graph] = mode
                    
                    
                }else if graph.values.count > tempGraphsAndModes.first!.key.values.count{
                    
                    let tempGraph = graph
                    tempGraph.values = Array(graph.values.prefix(maxValuesCount!))
                    tempGraphsAndModes[tempGraph] = mode
                    
                    
                }else{
                    
                    maxValuesCount = graph.values.count
                    
                    let oldKeys = Array(tempGraphsAndModes.keys)
                    
                    let oldValues = Array(tempGraphsAndModes.values)
                    
                    let newKeys: [Graph] = oldKeys.map{
                        
                        $0.values = Array($0.values.prefix(graph.values.count))
                        return $0
                        
                    }
                    
                    tempGraphsAndModes = Dictionary(uniqueKeysWithValues: zip(newKeys,oldValues))
                    
                    tempGraphsAndModes[graph] = mode

                }
                
            }
            
        }
        
        self.storage = tempGraphsAndModes
        
        
    }
    
    public func graphsWithNames(names: [String]) -> GraphArray?{
        
        guard !names.isEmpty else {return nil}
        
        var tempGraphs = GraphArray()
        
        for name in names{
            
            for graph in self.storage{
                
                
                if graph.key.name == name{
                    
                    
                    tempGraphs.add(graph.key, withMode: graph.value)
                }
                
            }
            
            
            
        }
        
        return tempGraphs
    }
    
    @discardableResult public mutating func add(_ graph: Graph, withMode mode: GraphDrawingMode) -> Bool {
        
        guard graph.values.count > 0 else {return false}
        
        if storage.isEmpty{
            
            maxValuesCount = graph.values.count
            storage[graph] = mode
            
            
            return true
            
        }else{
            
            if graph.values.count == storage.first!.key.values.count{
                
                storage[graph] = mode
                return true
                
                
            }else if graph.values.count > storage.first!.key.values.count{
                
                let tempGraph = graph
                tempGraph.values = Array(graph.values.prefix(maxValuesCount!))
                storage[tempGraph] = mode
                return true
                
                
            }else{
                
                return false
                
            }
            
            
        }
        
    }
    
    
}


@available(iOS 10.0, *)
extension GraphArray: Sequence {
 
 public typealias Iterator = DictionaryIterator<Graph, GraphDrawingMode>

  
 public func makeIterator() -> Iterator {
   
    return storage.makeIterator()
  }
}


@available(iOS 10.0, *)
extension GraphArray: Collection {


    public typealias Index = DictionaryIndex<Graph, GraphDrawingMode>


    public var startIndex: Index {
    return storage.startIndex
  }

    public var endIndex: Index {
    return storage.endIndex
  }

    
    public subscript (position: Index) -> Iterator.Element {
    precondition(indices.contains(position), "out of bounds")
    
    let dictionaryElement = storage[position]
    
    return (key: dictionaryElement.key,
      value: dictionaryElement.value)

  }


    public func index(after i: Index) -> Index {
    return storage.index(after: i)
    }
    
 
    
    public init(element: Element){
        
        self.add(element.key, withMode: element.value)
    }
}
