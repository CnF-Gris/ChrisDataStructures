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
        header.rightNode = trailer
        header.leftNode = header // This allows to never go out of bounds
        
        //Trailer Setup
        trailer.leftNode = header
        trailer.rightNode = trailer
        
        lastItemTaken = (node: header, index: -1)
    }
    
    //Public functions
    //----------------------------------------------------------------------------
    
    public func addFirst(_ element: Element) {
        
        addNode(previous: header, node: DoublyLinkedNode(structure: self, element: element), next: header.rightNode!)
        
    }
    
    public func addFirst(_ node: DoublyLinkedNode<Element>) {
        
        node.structure = self
        addNode(previous: header, node: node, next: header.rightNode!)
        
    }
    
    public func addLast(_ element: Element) {
        
        addNode(previous: trailer.leftNode!, node: DoublyLinkedNode(structure: self, element: element), next: trailer)
        
    }
    
    public func addLast(_ node: DoublyLinkedNode<Element>) {
        
        node.structure = self
        addNode(previous: trailer.leftNode!, node: node, next: trailer)
    }
    
    public func removeFirst() -> Element? {
        
        if !isEmpty {
            return removeNode(node: header.rightNode!)
        }
        
        return nil
        
    }
    
    public func removeLast() -> Element? {
        
        if !isEmpty {
            return removeNode(node: trailer.leftNode!)
        }
        
        return nil
        
    }
    
    public func getFirst() -> Element? {
        return header.rightNode?.element
    }
    
    public func getFirstNode() -> DoublyLinkedNode<Element>? {
        return header.rightNode
    }
    
    public func getLast() -> Element? {
        return trailer.leftNode?.element
    }
    
    public func getLastNode() -> DoublyLinkedNode<Element>? {
        return trailer.leftNode
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
            
            tmpNode = header.rightNode!
            advanceBy(startIndex: 0, endIndex: position, startNode: &tmpNode)
            
            
        } else if minDistance == endDistance {
            
            tmpNode = trailer.leftNode!
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
            startNode = startNode.rightNode!
        }
    }
    
    private func reverseBy(startIndex: Int, endIndex: Int, startNode: inout DoublyLinkedNode<Element>) {
        for _ in startIndex..<endIndex {
            startNode = startNode.leftNode!
        }
    }
    
    //----------------------------------------------------------------------------
    
    //Private functions
    //----------------------------------------------------------------------------
    
    private func addNode(previous: DoublyLinkedNode<Element>,
                         node: DoublyLinkedNode<Element>,
                         next: DoublyLinkedNode<Element>) {
        
        node.structure = self
        
        previous.rightNode = node
        next.leftNode = node
        
        node.leftNode = previous
        node.rightNode = next
        
        count = count + 1
        
    }
    
    private func removeNode(node: DoublyLinkedNode<Element>) -> Element {
        
        let nextNode = node.rightNode!
        let previousNode = node.leftNode!
        
        if node === lastItemTaken.node {
            lastItemTaken.node = node.rightNode!
        }
        
        nextNode.leftNode = previousNode
        previousNode.rightNode = nextNode
        
        //Helping the ARC
        node.leftNode = nil
        node.rightNode = nil
        
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
