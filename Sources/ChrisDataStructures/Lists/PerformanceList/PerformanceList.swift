//
//  File.swift
//  
//
//  Created by Christian Risi on 25/08/22.
//

import Foundation

@available(watchOS 6.0, *)
@available(tvOS 13.0, *)
@available(iOS 13.0, *)
@available(macOS 10.15, *)
public class PerformanceList<Element> : RandomAccessCollection, ObservableObject {
    
    private var supportList: SupportList<Element>
    public var count : Int {return supportList.count}
    public var isEmpty: Bool {return count == 0}
    
    public var startIndex: Int {return 0}
    public var endIndex: Int {return startIndex + count - 1}
    
    public init() {
        supportList = SupportList()
        #if DEBUG
        print(supportList.count)
        #endif
    }
    
    
    public func addFirst(element: Element) {
        supportList.addFirst(element: element)
    }
    
    public func addLast(element: Element) {
        supportList.addLast(element: element)
    }
    
    public func removeFirst() -> Element? {
        return supportList.removeFirst()
    }
    
    public func removeLast() -> Element? {
        return supportList.removeLast()
    }
    
    public func getFirst() -> Element? {
        return supportList.getFirst()
    }
    
    public func getLast() -> Element? {
        return supportList.getLast()
    }
    
    public typealias Element = Element
    public typealias Index = Int
    public typealias Indices = Range<Int>
    public typealias SubSequence = PerformanceList<Element>
    
    public subscript(bounds: Range<Int>) -> PerformanceList<Element> {
        
        let tmp : PerformanceList<Element> = PerformanceList()
        
        for index in bounds {
            tmp.addLast(element: self[index])
        }
        return tmp
        
    }
    
    public subscript(position: Int) -> Element {
        get{
            print(supportList.count)
            return supportList[position]
        }
        
        set(newValue){
            
        }
    }
    
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
