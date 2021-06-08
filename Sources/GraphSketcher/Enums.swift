//
//  Enums.swift
//  GraphSketcher
//
//  Copyright © 2020-2021 Maciej Chudzik. All rights reserved.
//

import Foundation

enum AxisDataSource{
    case count
    case value
}

public enum LabelsSide{
    
    case left
    case right
    
}

public enum AxisOptions{
    
    case withDivisionLines(LabelsOption)
    case withoutDivisionLines
    
    public enum LabelsOption{
        
        public enum LabelsSource{
            
            case withOwnSource(labels: [String])
            case typeSource
        }
        
        case withLabels(onSide: LabelsSide, LabelsSource)
        case noLabels
        
        
    }
}

public enum GraphOrientation{
    
    case regular
    case opposite
    case rotatedClockwise
    case rotatedCounterClockwise
}
