/*
 File.swift
 
 MARK: TODO: In next versions just take the next Pillar by using one you already found
 
 Created by Christian Risi on 29/08/22.
 */

import Foundation

internal class SelfExposingList<Element> {
    
    private let header: Node4D<Element>
    private let trailer: Node4D<Element>
    
    public var count: Int
    public var isEmpty: Bool {return count == 0}
    
    private var startOffset: Int
    private var endOffset: Int
    private let divider: Int
    
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
    
    public func addFirst(element: Element) -> Node4D<Element>? {
        
        let bufferNode = Node4D(element: element)
        
        if addBetween(leftNode: header, node: bufferNode, rightNode: header.rightNode) {
            return exposeNode(node: bufferNode, operationType: .addFirst)?.exposedNode
        }
        
        return nil
        
    }
    
    public func addLast(element: Element) -> Node4D<Element>? {
        
        let bufferNode = Node4D(element: element)
        
        if addBetween(leftNode: trailer.leftNode, node: bufferNode, rightNode: trailer) {
            return exposeNode(node: bufferNode, operationType: .addLast)?.exposedNode
        }
        
        return nil
        
    }
    
//    public func addFromDown() -> Element? {
//
//
//
//    }
    
    internal func addElement(after node: Node4D<Element>, element: Element)
    -> (exposedNode: Node4D<Element>,
        upperLeftNode: Node4D<Element>?,
        upperRightNode: Node4D<Element>?)? {
        
        let bufferNode = Node4D(element: element)
        
        if addBetween(leftNode: node, node: bufferNode, rightNode: node.rightNode) {
            return exposeNode(node: bufferNode, operationType: .addBetween)
        }
        
        return nil
        
    }
    
    internal func addElement(before: Node4D<Element>, element: Element)
    -> (exposedNode: Node4D<Element>,
        upperLeftNode: Node4D<Element>?,
        upperRightNode: Node4D<Element>?)? {
        
        let bufferNode = Node4D(element: element)
        
        if addBetween(leftNode: header, node: bufferNode, rightNode: header.rightNode) {
            return exposeNode(node: bufferNode, operationType: .addBetween)
        }
        
        return nil
        
    }
    
    @inline(__always)
    internal func getFirst() -> Node4D<Element> {
        return header.rightNode
    }
    
    @inline(__always)
    internal func getLast() -> Node4D<Element> {
        return trailer.leftNode
    }
    
    public func removeFirst() -> (Element, ListOperation?)? {
        
        if isEmpty {
            return nil
        } else {
            let operation = deExposeNode(node: getFirst(), operationType: .removeFirst)?.operation
            return (removeBetween(node: header.rightNode),operation)
            
        }
        
    }
    
    public func removeLast() -> (Element, ListOperation?)? {
        
        if isEmpty {
            return nil
        } else {
            let operation = deExposeNode(node: getLast(), operationType: .removeLast)?.operation
            return (removeBetween(node: trailer.leftNode), operation)
            
        }
        
    }
    
//    public func removeFromDown() -> Element? {
//
//
//
//    }
    
    //Theoretically, it should need a position and then a subscript, BUT the actual structure will have the subscript, so this one can just receive the parameter
    public func removeElement(node: Node4D<Element>) -> (element: Element, operation: ListOperation?, upperLeftNode: Node4D<Element>?, upperRightNode: Node4D<Element>?)? {
        
        if isEmpty {
            return nil
        } else {
            let result = deExposeNode(node: node, operationType: .removeBetween)
            return (removeBetween(node: node), result?.operation, result?.upperLeftNode, result?.upperRightNode)
            
        }
        
    }
    
    private func addBetween(leftNode: Node4D<Element>,
                            node: Node4D<Element>,
                            rightNode: Node4D<Element>) -> Bool {
        
        leftNode.rightNode = node
        node.leftNode = leftNode
        node.rightNode = rightNode
        rightNode.leftNode = node
        
        count = count + 1
        
        return true
        
    }
    
    private func removeBetween(node: Node4D<Element>) -> Element {
        
        let leftNode = node.leftNode
        let rightNode = node.rightNode
        
        node.rightNode = nil
        node.leftNode = nil
        
        leftNode?.rightNode = rightNode
        rightNode?.leftNode = leftNode
        
        count = count - 1
        
        return node.element
        
    }
    //Delegating to the real structure for the section offsets
    private func exposeNode(node: Node4D<Element>, operationType: ListOperation) -> (exposedNode: Node4D<Element>, upperLeftNode: Node4D<Element>?, upperRightNode: Node4D<Element>?)? {
        
        if isEmpty {
            return (node, nil, nil)
        }
        
        switch operationType {
          
        //MARK: ADD FIRST
        case .addFirst:
            
            if let result = exposeAtStart(node: node) {
                return (result, nil, nil)
            }
            //Else it will return nil
            
        //MARK: ADD BETWEEN
        case .addBetween:
            
            var node : Node4D<Element> = node
            
            let pillars = lockNodes(node: node, operation: .addBetween)
            
            if pillars.leftPillar === header { //It means that we are in the First Block
                
                if let result = exposeAtStart(node: node) {
                    return (result, nil, nil)
                }
            
            } else if pillars.rightPillar === trailer { //It means that we are in the last Block
                
                if let result = exposeAtEnd(node: node) {
                    return(result, nil, nil)
                }
                
            } else { //It means that we are in a Block in the Middle
                
                let leftPillar = pillars.leftPillar.upperLevelNode!
                let rightPillar = pillars.rightPillar.upperLevelNode!
                
                rightPillar.localOffset_L += 1
                leftPillar.localOffset_R += 1
                
                //Let's check if I can add another Pillar
                //-----------------------------------------------------------
                if  leftPillar.localOffset_R % divider == 0 {
                    
                    leftPillar.localOffset_R = 0
                    rightPillar.localOffset_L = 0
                    
                    node = pillars.leftPillar
                    
                    for _ in 0..<divider {
                        
                        node = node.rightNode
                        
                    }
                    
                }
                //-----------------------------------------------------------
                //If node === parameter -> Notify changes in offsets
                //else -> expand
                return (node, leftPillar, rightPillar)
                
            }
            
        //MARK: ADD LAST
        case .addLast:
            
            if let result = exposeAtEnd(node: node) {
                return (result, nil, nil)
            }
            //It will return nil
            
        default:
            return nil
        }
        
        return nil
        
    }
    
    @inline(__always)
    private func exposeAtStart(node: Node4D<Element>) -> Node4D<Element>? {
        
        startOffset = startOffset + 1
        if startOffset % divider == 0 {
            startOffset = 0
            return node
        }
        
        return nil
        
    }
    
    @inline(__always)
    private func exposeAtEnd(node: Node4D<Element>) -> Node4D<Element>? {
        
        endOffset = endOffset + 1
        if endOffset % divider == 0 {
            endOffset = 0
            return node
        }
        
        return nil
        
    }
    
    //TODO: The return type is a mess, create a Struct for this, please
    private func deExposeNode(node: Node4D<Element>, operationType: ListOperation) -> (operation: ListOperation, upperLeftNode: Node4D<Element>?, upperRightNode: Node4D<Element>?)? {
        
        /*
         Take a look at the operation Type
         
         case first -> expand towards the beginning or collapse
         case last -> expand towards the end or collapse
         case between -> check nodes distance
            
         if distance is 
         
         
         */
        
        switch operationType {
        
        case .removeFirst:
            if startOffset == 0 { //Collapse
                return (.collapse, nil, nil) //Delegating to the real struct for cascaded removal
            }
        case .removeBetween:
            //If distance in the section > "distance" -> Notice that to Pillars
            //Else: if it has space, expand
            //      else collapse
            
            let pillars = lockNodes(node: node, operation: .removeBetween)
            
            let node_L = pillars.leftPillar
            let node_R = pillars.rightPillar
            
            if node_L === header {
                
                if startOffset == 0 { //Collapse
                    return (.collapse, nil, nil) //Delegating to the real struct for cascaded removal
                }
                
            } else if node_R === trailer {
                
                if endOffset == 0 { //Collapse
                    return (.collapse, nil, nil) //Delegating to the real struct for cascaded removal
                }
                
            } else {
                
                let pillar_L = node_L.upperLevelNode!
                let pillar_R = node_R.upperLevelNode!
                
                if pillar_L.localOffset_R == 0 {
                    
                    if pillar_L.localOffset_L > 0 {
                        
                        pillar_L.lowerLevelNode = pillar_L.lowerLevelNode!.leftNode
                        
                        pillar_L.localOffset_L =  pillar_L.localOffset_L - 1
                        pillar_L.leftNode.localOffset_R =  pillar_L.leftNode.localOffset_R - 1
                        
                        if node === pillar_R.lowerLevelNode! {
                            pillar_R.lowerLevelNode = pillar_R.lowerLevelNode!.leftNode
                        }
                        
                        return nil
                        
                    } else if pillar_R.localOffset_R > 0 {
                        
                        pillar_R.lowerLevelNode = pillar_R.lowerLevelNode!.rightNode
                        
                        pillar_R.localOffset_R =  pillar_R.localOffset_R - 1
                        pillar_R.rightNode.localOffset_L =  pillar_R.rightNode.localOffset_L - 1
                        
                        if node === pillar_L.lowerLevelNode! {
                            pillar_L.lowerLevelNode = pillar_L.lowerLevelNode!.rightNode
                        }
                        
                        return nil
                        
                    } else {
                        
                        return (.collapse, pillar_L, pillar_R)
                        
                    }
                    
                } else {
                    
                    if node === pillar_R.lowerLevelNode! {
                        
                        pillar_R.lowerLevelNode = pillar_R.lowerLevelNode!.leftNode
                        
                    } else if node === pillar_L.lowerLevelNode! {
                        
                        pillar_L.lowerLevelNode = pillar_L.lowerLevelNode!.rightNode
                        
                    }
                    
                    pillar_L.localOffset_R = pillar_L.localOffset_R - 1
                    pillar_R.localOffset_L = pillar_R.localOffset_L - 1
                    
                    return nil
                    
                }
                
            }

        case .removeLast:
            if endOffset == 0 { //Collapse
                return (.collapse, nil, nil) //Delegating to the real struct for cascaded removal
            }
        default:
            //TODO: Throw an error
            break
        }
        
        return nil
    }
    
    //TODO: Make more research for actual iteration numbers
    private func lockNodes(node: Node4D<Element>, operation: ListOperation) -> (leftPillar:  Node4D<Element>,rightPillar: Node4D<Element>) {
        
        let stop : Int
        
        //Chooses the right amount of cycles to lock-in the Pillars
        switch operation {
        
        case .addBetween:
            
            //TODO: Make this the max amount of search
            stop = (divider * 2) - 1
            
        case .collapse:
            
            stop = (divider * 2) - 1
            
        default:
            stop = (divider * 2) - 1
            //TODO: Throw some error
        }
        
        //Let's hope that pointers do not fail us
        var leftNode = node
        var rightNode = node
        
        //Warning: It does not check for header or trailer, though it's safe to use cause of
        //header and trailer pointing to themselves
        //For now I delegate it to the caller
        for _ in 0..<stop {
            
            if leftNode.upperLevelNode == nil {
                leftNode = leftNode.leftNode
            }
            
            if rightNode.upperLevelNode == nil {
                rightNode = rightNode.rightNode
            }
            
            //Here just to break from the cycle before
            if leftNode.upperLevelNode != nil && rightNode.upperLevelNode != nil {
                
                return (leftNode.upperLevelNode!, rightNode.upperLevelNode!)
                
            }
            
        }
        
        //Just to be sure, but according to calculation, it should be fine
        return (leftNode.upperLevelNode!, rightNode.upperLevelNode!)
        
    }
    
}
