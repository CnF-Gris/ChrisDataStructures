/*
 File.swift
 
 MARK: TODO: In next versions just take the next Pillar by using one you already found
 
 This is a SLAVE structure, hence each method is called by another class
 
 Created by Christian Risi on 29/08/22.
 */

import Foundation

internal class SelfExposingList<Element> {
    
    private let header: Node4D<Element>
    private let trailer: Node4D<Element>
    
    /**
     Tells the number of Items inside the Collection
     
     - Note: The Methods that modifies this value are:
     `kernelAdd` and `KernelRemove`
     */
    public var count: Int //Modified only by kernelAdd and kernelRemove
    public var isEmpty: Bool {return count == 0}
    
    internal var startOffset: Int
    internal var endOffset: Int
    internal let divider: Int
    
    init(divider: Int) {
        
        header = Node4D()
        trailer = Node4D()
        
        header.rightNode = trailer
        header.leftNode = header
        
        trailer.leftNode = header
        trailer.rightNode = trailer
        
        count = 0
        startOffset = 0
        endOffset = 0
        self.divider = divider
        
    }
    
    deinit {
        
        header.leftNode = nil
        header.rightNode = nil
        
        trailer.leftNode = nil
        trailer.rightNode = nil
    }
    
    //MARK: Public functions
    //--------------------------------------------------------------------------------------
    public func getFirst() -> Node4D<Element>? {
        
        if isEmpty {
            return nil
        }
        return self.header.rightNode
    }
    
    public func getLast() -> Node4D<Element>? {
        
        if isEmpty {
            return nil
        }
        return self.trailer.leftNode
        
    }
    
    public func addFirst(node: Node4D<Element>) -> responseMessage<Element> {
        
        //Esposes a node if empty
        let _ = try! kernelAdd(leftNode: self.header, node: node, rightNode: self.header.rightNode)
        
        return kernelAddFirst(node: node)
        
    }
    
    public func addLast(node: Node4D<Element>) -> responseMessage<Element> {
        
        let _ = try! kernelAdd(leftNode: self.trailer.leftNode, node: node, rightNode: self.trailer)
        
        return kernelAddLast(node: node)
        
    }
    
    public func addBetween(add node: Node4D<Element>, how: ListOperation, target: Node4D<Element>) throws -> responseMessage<Element> {
        
        if how == .after {
            return  addAfter(add: node, target: target)
        } else if how == .before {
            return addBefore(add: node, target: target)
        }
        
        throw ListArrayExceptions.IllegalActionException
        
    }
    
    public func removeFirst() -> responseMessage<Element> {
        
        if isEmpty {
            return responseMessage(nodes: nil, operationType: .removeFirst, result: .success)
        }
        
        let response = try! kernelRemove(node: self.header.rightNode)
        
        return kernelRemoveFirst(node: response.nodes[0])
        
    }
    
    public func removeLast() -> responseMessage<Element> {
        
        if isEmpty {
            return responseMessage(nodes: nil, operationType: .removeLast, result: .success)
        }
        
        let response = try! kernelRemove(node: self.trailer.leftNode)
        
        return kernelRemoveLast(node: response.nodes[0])
        
    }
    
    public func removeNode(remove node: Node4D<Element>)  -> responseMessage<Element> {
        
        let nodes = try! sectionLocker(node: node)
        let _ = try! kernelRemove(node: node)
        
        if nodes[0] == nil && nodes[1] == nil {
            
            return kernelRemoveLast(node: self.getLast()!)
            
        } else if nodes[0] == nil {
            
            return kernelRemoveFirst(node: self.getFirst()!)
            
        } else if nodes[1] == nil {
            
            return kernelRemoveLast(node: self.getLast()!)
            
        }
        
        return responseMessage(nodes: [node, nodes[0]!, nodes[1]!], operationType: .removeBetween, result: .notifyContraction)
        
    }
    //--------------------------------------------------------------------------------------
    
    //MARK: Private "Helper" functions
    //--------------------------------------------------------------------------------------
    @inline(__always)
    private func addAfter(add node: Node4D<Element>, target: Node4D<Element>) -> responseMessage<Element> {
        
        let _ = try! kernelAdd(leftNode: target, node: node, rightNode: target.rightNode)
        let nodes = try! sectionLocker(node: node)
        
        if nodes[0] == nil && nodes[1] == nil {
            
            return kernelAddLast(node: self.getLast()!)
            
        } else if nodes[0] == nil {
            
            return kernelAddFirst(node: self.getFirst()!)
            
        } else if nodes[1] == nil {
            
            return kernelAddLast(node: self.getLast()!)
            
        }
        
        return responseMessage(nodes: [node, nodes[0]!, nodes[1]!], operationType: .addBetween, result: .notifyExpansion)
    }
    
    @inline(__always)
    private func addBefore(add node: Node4D<Element>, target: Node4D<Element>) -> responseMessage<Element> {
        
        let _ = try! kernelAdd(leftNode: target.leftNode, node: node, rightNode: target)
        let nodes = try! sectionLocker(node: node)
        
        if nodes[0] == nil && nodes[1] == nil {
            
            return kernelAddLast(node: self.getLast()!)
            
        } else if nodes[0] == nil {
            
            return kernelAddFirst(node: self.getFirst()!)
            
        } else if nodes[1] == nil {
            
            return kernelAddLast(node: self.getLast()!)
            
        }
        
        return responseMessage(nodes: [node, nodes[0]!, nodes[1]!], operationType: .addBetween, result: .notifyExpansion)
    }
    //--------------------------------------------------------------------------------------
    
    
    //MARK: Private "Kernel" functions
    //--------------------------------------------------------------------------------------
    private func kernelAdd(leftNode: Node4D<Element>, node: Node4D<Element>, rightNode: Node4D<Element>) throws -> responseMessage<Element> {
        
        //MARK: Helper section to identify a bug of adding an element that points to itself and backtrace
        
        if leftNode === node || rightNode === node || leftNode === rightNode {
            throw ListArrayExceptions.IllegalActionException
        }
        
        //only after every operation increment the counter
        
        leftNode.rightNode = node
        rightNode.leftNode = node
        
        node.leftNode = leftNode
        node.rightNode = rightNode
        
        count = count + 1
        
        //This is just not to lose any info
        return responseMessage(nodes: [node, leftNode, rightNode], operationType: .addBetween, result: .delegating)
        
    }
    
    private func kernelRemove(node: Node4D<Element>) throws -> responseMessage<Element> {
        
        //Theoretically, I should be able to force unwrap
        let node_L = node.leftNode!
        let node_R = node.rightNode!
        
        node_L.rightNode = node_R
        node_R.leftNode = node_L
        
        count = count - 1
        
        //MARK: Helper section to identify a bug of adding an element that points to itself and backtrace
        
        if node_L === node || node_R === node || node_L === node_R {
            throw ListArrayExceptions.IllegalActionException
        }
        
        if node.leftNode === node || node.rightNode === node {
            throw ListArrayExceptions.IllegalActionException
        }
        
        //This is just not to lose any info
        return responseMessage(nodes: [node, node_L, node_R], operationType: .removeBetween, result: .delegating)
        
    }
    
    @inline(__always)
    private func kernelAddFirst(node: Node4D<Element>) -> responseMessage<Element> {
        
        //If not exposed, increments the startOffset
        startOffset = startOffset + 1
        
        if let response = kernelFirstExpose(node: node) {
            return response
        }
        
        //Checks if we arrived to the treshold and exposes the node
        if (startOffset % divider) == 0 && count > divider + 3 {
            
            startOffset = 0
            return responseMessage(nodes: [node], operationType: .addFirst, result: .delegating)
        }
        
        //Says that there's no need for further operations
        return responseMessage(nodes: nil, operationType: .addFirst, result: .success)
    }
    
    @inline(__always)
    private func kernelAddLast(node: Node4D<Element>) -> responseMessage<Element> {
        
        //If not exposed, increments the endOffset
        endOffset = endOffset + 1
        
        if let response = kernelFirstExpose(node: node) {
            return response
        }
        
        //Checks if we arrived to the threshold and exposes the node
        if (endOffset % divider) == 0 && count > divider + 3{
            
            endOffset = 0
            return responseMessage(nodes: [node], operationType: .addLast, result: .delegating)
        }
        
        //Says that there's no need for further operations
        return responseMessage(nodes: nil, operationType: .addLast, result: .success)
    }
    
    @inline(__always)
    private func kernelFirstExpose(node: Node4D<Element>) -> responseMessage<Element>? {
        
        if count > divider + 3 {
            
            return nil
            
        }
        
        if (startOffset + endOffset) == (divider + 1) {
            
            
            startOffset = 0
            endOffset = 0
            return responseMessage(nodes: [self.getFirst()!, self.getLast()!], operationType: .firstExposure, result: .delegating)
        }
        
        return nil
        
    }
    
    @inline(__always)
    private func kernelRemoveFirst(node: Node4D<Element>) -> responseMessage<Element> {
        
        if startOffset == 0 {
            
            startOffset = divider - 1
            return responseMessage(nodes: [node], operationType: .removeFirst, result: .delegating)
            
        }
        
        startOffset = startOffset - 1
        return responseMessage(nodes: [node], operationType: .removeFirst, result: .success)
    }
    
    @inline(__always)
    private func kernelRemoveLast(node: Node4D<Element>) -> responseMessage<Element> {
        
        if endOffset == 0 {
            
            endOffset = divider - 1
            return responseMessage(nodes: [node], operationType: .removeLast, result: .delegating)
            
        }
        
        endOffset = endOffset - 1
        return responseMessage(nodes: [node], operationType: .removeLast, result: .success)
    }
    //--------------------------------------------------------------------------------------
    
    //MARK: Internal "Service" functions
    //--------------------------------------------------------------------------------------
    
    //TODO: Verify that there are no errors due to not checking for pillar
    internal func sectionLocker(node: Node4D<Element>) throws -> [Node4D<Element>?] {
        
        if count < divider + 3 {
            return [nil, nil]
        }
        
        var node_L = node
        var node_R = node.rightNode!
        
        var Booleans = try! sectionLockerHelper(node_L: node_L, node_R: node_R)
        
        while Booleans[0] {
            
            if !Booleans[1] {
                node_L = node_L.leftNode
                
            }
            
            if !Booleans[2] {
                node_R = node_R.rightNode
                
            }
            
            Booleans = try! sectionLockerHelper(node_L: node_L, node_R: node_R)
            
        }
        
        if Booleans[3] {
            return [nil, node_R]
        } else if Booleans[4] {
            return [node_L, nil]
        }
        
        return [node_L, node_R]
    }
    
    //MARK: Possible Culprit?
    internal func notifyInsertion(left: Node4D<Element> , right: Node4D<Element>) -> [Node4D<Element>?] {
        
        left.sectionOffset_R =  left.sectionOffset_R + 1
        right.sectionOffset_L =  left.sectionOffset_R
        
        return try! sectionLocker(node: left)
        
    }
    
    internal func notifyDeletion(left: Node4D<Element> , right: Node4D<Element>) -> [Node4D<Element>?] {
        
        left.sectionOffset_R =  left.sectionOffset_R - 1
        right.sectionOffset_L =  left.sectionOffset_R
        
        return try! sectionLocker(node: left)
        
    }
    //--------------------------------------------------------------------------------------
    
    //MARK: Private Inline(__always) functions
    //--------------------------------------------------------------------------------------
    @inline(__always)
    private func sectionLockerHelper(node_L: Node4D<Element>, node_R: Node4D<Element>) throws -> [Bool] {
        
        /*
         [0] -> while value
         [1] -> L_FOUND
         [2] -> R_FOUND
         [3] -> L_IS_HEADER
         [4] -> R_IS_TRAILER
         */
        let L_FOUND = node_L.upperLevelNode != nil //A
        let R_FOUND = node_R.upperLevelNode != nil //B
        
        let L_IS_HEADER = (node_L === header ) || (node_L === node_L.leftNode)//C
        let R_IS_TRAILER = (node_R === trailer) || (node_R === node_R.rightNode) //D
        
        //TRUTH TABLE
        /*
         
         A B C D  0 3 4
         
         0 0 0 0  1 0 0
         0 0 0 1  0 0 1
         0 0 1 0  0 1 0
         0 0 1 1  0 1 1 -> Throw Error
         0 1 0 0  1 0 0
         0 1 0 1  0 0 1
         0 1 1 0  0 1 0
         0 1 1 1  0 1 1 -> Throw Error
         1 0 0 0  1 0 0
         1 0 0 1  0 0 1
         1 0 1 0  0 1 0
         1 0 1 1  0 1 1 -> Throw Error (Can't find Both Header and Trailer before encountering a node connected to an upper layer)
         1 1 0 0  0 0 0
         1 1 0 1  0 0 1 -> Throw Error (Trailer can't have an upper level)
         1 1 1 0  0 1 0 -> Throw Error (Trailer can't have an upper level)
         1 1 1 1  0 1 1 -> Throw Error (Can't find Both Header and Trailer before encountering a node connected to an upper layer and can't have an upper level)
         
         */
        
        let WHILE =  (!L_FOUND || !R_FOUND) && (!L_IS_HEADER && !R_IS_TRAILER)
        
        if L_IS_HEADER && R_IS_TRAILER {
            throw ListArrayExceptions.SplitterNotFoundException
        }
        
        return [WHILE,L_FOUND, R_FOUND, L_IS_HEADER, R_IS_TRAILER]
        
    }
    //--------------------------------------------------------------------------------------
    
}
