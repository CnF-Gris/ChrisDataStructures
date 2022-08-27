//
//  File.swift
//  
//
//  Created by Christian Risi on 22/08/22.
//

import Foundation

//TODO: Conform DoublyLinkedList to the Protocol RandomAccessCollection
extension DoublyLinkedList : RandomAccessCollection {
    
    public typealias Element = Element
    public typealias Index = Int
    public typealias Indices = Range<Int>
    public typealias SubSequence = DoublyLinkedList<Element>
    
    public var startIndex: Int {return 0}
    public var endIndex: Int {return startIndex + count - 1}
    
    public subscript(bounds: Range<Int>) -> DoublyLinkedList<Element> {
        
        let tmpList = DoublyLinkedList<Element>()
        
        for i in bounds {
            tmpList.addLast(self[i])
        }
        
        return tmpList
    }
    
    public func distance(from start: Int, to end: Int) -> Int {
        return end - start
    }
    
    public func formIndex(after i: inout Int) {
       i = i + 1
    }
    
    public func formIndex(before i: inout Int) {
       i = i - 1
    }
    
    public func index(after i: Int) -> Int {
        return i + 1
    }
    
    public func index(before i: Int) -> Int {
        return i - 1
    }
    
    public func index(_ i: Int, offsetBy distance: Int) -> Int {
        return i + distance
    }
    
    public func index(_ i: Int, offsetBy distance: Int, limitedBy limit: Int) -> Int? {
        
        let tmp = i + distance
        if tmp < endIndex {
        return tmp
        }
        return nil
    }
    
}
