//
//  File.swift
//  
//
//  Created by Christian Risi on 27/08/22.
//

import Foundation

@available(watchOS 6.0, *)
@available(tvOS 13.0, *)
@available(iOS 13.0, *)
@available(macOS 10.15, *)

extension PerformanceList : RandomAccessCollection, ObservableObject {
    public var startIndex: Int {
        0
    }
    
    public var endIndex: Int {
        startIndex + count
    }
    
    
    public typealias Element = Element
    public typealias Index = Int
    public typealias Indices = Range<Int>
    public typealias SubSequence = PerformanceList<Element>
    
    public subscript(bounds: Range<Int>) -> PerformanceList<Element> {
        get{
            let tmp = PerformanceList<Element>()
            
            for index in bounds {
                tmp.addLast(element: self[index])
            }
            return tmp
        }
        
    }
    
}
