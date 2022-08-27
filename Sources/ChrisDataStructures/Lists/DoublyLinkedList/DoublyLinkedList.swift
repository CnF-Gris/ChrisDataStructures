//
//  File.swift
//  
//
//  Created by Christian Risi on 22/08/22.
//

import Foundation

public class DoublyLinkedList<Element> {
    
    private let header : DoublyLinkedNode<Element>
    private let trailer : DoublyLinkedNode<Element>
    
    public var count : Int
    public var isEmpty : Bool { return count == 0 }
    
    private var lastItemTaken: (node: DoublyLinkedNode<Element>, index: Int)
    
    public init() {
        //Initialization of Attributes
        count = 0
        
        //Initialization of Header and Trailer
        header = DoublyLinkedNode()
        trailer = DoublyLinkedNode()
        
        //Header Setup
        header.next = trailer
        header.previous = header // This allows to never go out of bounds
        
        //Trailer Setup
        trailer.previous = header
        trailer.next = trailer
        
        lastItemTaken = (node: header, index: -1)
    }
    
    //Public functions
    //----------------------------------------------------------------------------
    
    public func addFirst(_ element: Element) {
        
        addNode(previous: header, node: DoublyLinkedNode(structure: self, element: element), next: header.next!)
        
    }
    
    public func addFirst(_ node: DoublyLinkedNode<Element>) {
        
        node.structure = self
        addNode(previous: header, node: node, next: header.next!)
        
    }
    
    public func addLast(_ element: Element) {
        
        addNode(previous: trailer.previous!, node: DoublyLinkedNode(structure: self, element: element), next: trailer)
        
    }
    
    public func addLast(_ node: DoublyLinkedNode<Element>) {
        
        node.structure = self
        addNode(previous: trailer.previous!, node: node, next: trailer)
    }
    
    public func removeFirst() -> Element? {
        
        if !isEmpty {
            return removeNode(node: header.next!)
        }
        
        return nil
        
    }
    
    public func removeLast() -> Element? {
        
        if !isEmpty {
            return removeNode(node: trailer.previous!)
        }
        
        return nil
        
    }
    
    public func getFirst() -> Element? {
        return header.next?.element
    }
    
    public func getFirstNode() -> DoublyLinkedNode<Element>? {
        return header.next
    }
    
    public func getLast() -> Element? {
        return trailer.previous?.element
    }
    
    public func getLastNode() -> DoublyLinkedNode<Element>? {
        return trailer.previous
    }
    
    //----------------------------------------------------------------------------
    
    //Subscript functions
    //----------------------------------------------------------------------------
    
    public subscript(position: Int) -> Element {
        
        let startDistance = distance(from: startIndex, to: position)
        let endDistance = -distance(from: endIndex, to: position)
        let lastAccessDistance = distance(from: lastItemTaken.index, to: position)
        
        let minDistance = Swift.min(startDistance, endDistance, abs(lastAccessDistance))
        
        var tmpNode : DoublyLinkedNode<Element>
        
        if minDistance == startDistance {
            
            tmpNode = header.next!
            advanceBy(startIndex: 0, endIndex: position, startNode: &tmpNode)
            
            
        } else if minDistance == endDistance {
            
            tmpNode = trailer.previous!
            if position > endIndex {
                print(self.count)
                print(endIndex)
                print(position)
            }
            reverseBy(startIndex: position, endIndex: endIndex, startNode: &tmpNode)
            
        } else {
            
            tmpNode = lastItemTaken.node
            if lastItemTaken.index < position {
                advanceBy(startIndex: lastItemTaken.index, endIndex: position, startNode: &tmpNode)
            } else {
                reverseBy(startIndex: position, endIndex: lastItemTaken.index, startNode: &tmpNode)
            }
            
        }
        
        if startDistance > count/5 && endDistance > count/5 {
            lastItemTaken = (tmpNode, position)
        }
        
        return tmpNode.element
        
    }
    
    private func advanceBy(startIndex: Int, endIndex: Int, startNode: inout DoublyLinkedNode<Element>) {
        for _ in startIndex..<endIndex {
            startNode = startNode.next!
        }
    }
    
    private func reverseBy(startIndex: Int, endIndex: Int, startNode: inout DoublyLinkedNode<Element>) {
        for _ in startIndex..<endIndex {
            startNode = startNode.previous!
        }
    }
    
    //----------------------------------------------------------------------------
    
    //Private functions
    //----------------------------------------------------------------------------
    
    private func addNode(previous: DoublyLinkedNode<Element>,
                         node: DoublyLinkedNode<Element>,
                         next: DoublyLinkedNode<Element>) {
        
        node.structure = self
        
        previous.next = node
        next.previous = node
        
        node.previous = previous
        node.next = next
        
        count = count + 1
        
    }
    
    private func removeNode(node: DoublyLinkedNode<Element>) -> Element {
        
        let nextNode = node.next!
        let previousNode = node.previous!
        
        if node === lastItemTaken.node {
            lastItemTaken.node = node.next!
        }
        
        nextNode.previous = previousNode
        previousNode.next = nextNode
        
        //Helping the ARC
        node.previous = nil
        node.next = nil
        
        count = count - 1
        
        return node.element
        
    }
    
    private func validateNode(node: DoublyLinkedNode<Element>) -> Bool {
        
        if node.structure === self {
            return true
        }
        return false
        
    }
    
    //----------------------------------------------------------------------------
    
}
