//
//  File.swift
//
//  TODO: CHECK IF YOU ARE ADDING NODES OF THE LOWER LAYERS DIRECTLY BEFORE WRAPPING
//
//  Created by Christian Risi on 29/08/22.


import Foundation

public class ListArray<Element> {
    
    internal var layers : DoublyLinkedList<SelfExposingList<Element>>
    internal var base : SelfExposingList<Element> {return layers.getFirst()!}
    
    public var count : Int { return layers.getFirst()!.count}
    public var isEmpty : Bool {return count == 0}
    private unowned var lastTakenNode : Node4D<Element>?
    
    public init() {
        
        layers = DoublyLinkedList()
        layers.addFirst(SelfExposingList<Element>(divider: 100))
        
    }
    
    //MARK: Public functions
    //--------------------------------------------------------------------------------------
    public func getFirst() -> Element? {
        
        if let node = base.getFirst() {
            return node.element
        }
        
        return nil
    }
    
    public func getLast() -> Element? {
        
        if let node = base.getLast() {
            return node.element
        }
        
        return nil
    }
    
    public func addFirst(_ item: Element) {
        let node2Add = Node4D(element: item)
        
        let response = base.addFirst(node: node2Add)
        
        if response.result == .delegating {
            try! kernelAdd(message: response,startLayer: nil)
        }
        
    }
    
    public func addLast(_ item: Element) {
        let node2Add = Node4D(element: item)
        
        let response = layers.getFirst()!.addLast(node: node2Add)
        
        if response.result == .delegating {
            try! kernelAdd(message: response,startLayer: nil)
        }
    }
    
    public func addBefore(position: Int, item: Element) {
        
        //FIXME: There's a problem with the search
        let target = try! efficientSearch(position: position) //To be implemented
        let node2Add = Node4D(element: item)
        
        let message = try! base.addBetween(add: node2Add, how: .before, target: target)
        
        if message.result == .delegating {
            
            try! kernelAdd(message: message, startLayer: nil)
            
        } else if message.result == .success {
            
            return
            
        } else {
            
            kernelExpansion(message: message)
            
        }
        
    }
    
    public func addAfter(position: Int, item: Element) {
        
        let target = try! efficientSearch(position: position) //To be implemented
        let node2Add = Node4D(element: item)
        
        let message = try! base.addBetween(add: node2Add, how: .after, target: target)
        
        if message.result == .delegating {
            
            try! kernelAdd(message: message, startLayer: nil)
            
        } else if message.result == .success {
            
            return
            
        } else {
            
            kernelExpansion(message: message)
            
        }
        
    }
    
    public func removeFirst() -> Element? {
        if isEmpty {
            return nil
        }
        
        let response = base.removeFirst()
        
        if response.result == .delegating {
            try! kernelRemove(message: response)
        }
        
        return response.nodes[0].element
    }
    
    public func removeLast() -> Element? {
        if isEmpty {
            return nil
        }
        
        let response = base.removeLast()
        
        if response.result == .delegating {
            try! kernelRemove(message: response)
        }
        
        return response.nodes[0].element
    }
    
    public func removeAt(position: Int) -> Element? {
        
        if isEmpty {
            return nil
        }
        
        let response = base.removeNode(remove: try! efficientSearch(position: position))
        
        if response.result == .delegating {
            try! kernelRemove(message: response)
        } else if response.result == .notifyContraction {
            
        }
        
        return response.nodes[0].element
        
    }
    //--------------------------------------------------------------------------------------
    
    //MARK: Private "Kernel" Functions
    //--------------------------------------------------------------------------------------
    
    //This method is ok for AddFirst an AddLast and some cases of AddBetween, but the latter needs another method
    private func kernelAdd(message: responseMessage<Element>, startLayer : Int?) throws {
        
        var currentMessage = message
        var currentLayer = 0  //Like indices
        if startLayer != nil {
            currentLayer = startLayer!
        }
       
        
       
        
        while currentMessage.result == .delegating {
            
            if currentMessage.count == 1 {
                
                let tmp = Node4D<Element>()
                switch currentMessage.operationType {
                    
                case .addFirst:
                    tmp.lowerLevelNode = currentMessage.nodes[0]
                    currentMessage.nodes[0].upperLevelNode = tmp
                    currentMessage = layers[currentLayer + 1].addFirst(node: tmp)
                case .addLast:
                    tmp.lowerLevelNode = currentMessage.nodes[0]
                    currentMessage.nodes[0].upperLevelNode = tmp
                    currentMessage = layers[currentLayer + 1].addLast(node: tmp)
                default:
                    throw ListArrayExceptions.IllegalActionException
                }
                
                
            } else if currentMessage.count == 2 { //Common zone for every adding operation
                
                let tmp_L = Node4D<Element>()
                let tmp_R = Node4D<Element>()
                
                tmp_L.lowerLevelNode = currentMessage.nodes[0]
                tmp_R.lowerLevelNode = currentMessage.nodes[1]
                
                currentMessage.nodes[0].upperLevelNode = tmp_L
                currentMessage.nodes[1].upperLevelNode = tmp_R
                
                
                if layers.count <= currentLayer + 1 {
                    layers.addLast(SelfExposingList(divider: 10))
                }
                
                
                let _ = layers[currentLayer + 1].addFirst(node: tmp_L)
                currentMessage = layers[currentLayer + 1].addLast(node: tmp_R)
                
            }
            
            currentLayer = currentLayer + 1
        }
        
    }
    
    private func kernelExpansion(message: responseMessage<Element>) {
        
        var currentMessage = message
        var currentLayer = 0 //Like indices
        
        var pillar_L = message.nodes[1].upperLevelNode!
        var pillar_R = message.nodes[2].upperLevelNode!
        
        //Increasing sectionOffsets
        //-------------------------------------------------------------------------------------
        while currentLayer < layers.count {
            
            //FIXME: Am I passing things to the right layer?
            let tmp = layers[currentLayer + 1].notifyInsertion(left: pillar_L, right: pillar_R)
            
            if tmp[0] != nil && tmp[1] != nil {
                
                pillar_L = tmp[0]!.upperLevelNode!
                pillar_R = tmp[1]!.upperLevelNode!
                
                currentLayer = currentLayer + 1
            } else {
                currentLayer = layers.count
            }
        }
        //-------------------------------------------------------------------------------------
        
        //Resetting Variables
        //------------------------------------------
        currentLayer = 0
        //------------------------------------------
        
        var repeatCycle = true
        
        while repeatCycle && currentLayer < layers.count - 1 {
            
            pillar_L = currentMessage.nodes[1].upperLevelNode!
            pillar_R = currentMessage.nodes[2].upperLevelNode!
            
            
            pillar_L.localOffset_R = pillar_L.localOffset_R + 1
            pillar_R.localOffset_L = pillar_L.localOffset_R
            
            //MARK: Here there could be a bug, but I don't really know, but if there's any issue, this may likely be the problem
            if (pillar_L.localOffset_R % (layers[currentLayer].divider - 1)) == 0 && pillar_L.localOffset_R != 0 {
                
                //divider - 1
                
                pillar_L.localOffset_R = 0
                pillar_R.localOffset_L = 0
                
                pillar_L.sectionOffset_L = 0
                pillar_R.sectionOffset_R = 0
                
                var node = pillar_L.lowerLevelNode!
                
                for _ in 0..<layers[currentLayer + 1].divider {
                    
                    node = node.rightNode
                    
                }
                
                let tmp = Node4D<Element>()
                tmp.lowerLevelNode = node
                node.upperLevelNode = tmp
                
                currentMessage = try! layers[currentLayer + 1].addBetween(add: tmp, how: .after, target: pillar_L)
                
                //Counting
                let pillar_M = pillar_L.rightNode!
                pillar_L.sectionOffset_R = getSectionOffset(pillar: pillar_L)
                pillar_R.sectionOffset_L = getSectionOffset(pillar: pillar_M)
                pillar_M.sectionOffset_L = pillar_L.sectionOffset_R
                pillar_M.sectionOffset_R = pillar_R.sectionOffset_L
                
                
                if currentMessage.count < 3 {
                    repeatCycle = false
                    try! kernelAdd(message: currentMessage, startLayer: currentLayer + 1)
                }
                
                currentLayer = currentLayer + 1
                
            } else {
                
                repeatCycle = false
                
            }
        }
        
    }
    
    private func kernelRemove(message: responseMessage<Element>) throws {
        
        //now we just said that we were removing a pillar
        var currentMessage = message
        var currentLayer = 0
        
        while currentMessage.result == .delegating && currentLayer < layers.count - 1{
            
            //That's where the unowned property comes handy
            switch currentMessage.operationType {
            case .removeFirst:
                
                if layers[currentLayer + 1].getFirst()?.lowerLevelNode != nil {
                    currentMessage = layers[currentLayer + 1].removeFirst()
                }
                
            case .removeLast:
                
                if layers[currentLayer + 1].getLast()?.lowerLevelNode != nil {
                    currentMessage = layers[currentLayer + 1].removeLast()
                }
                
            default:
                
                throw ListArrayExceptions.IllegalActionException
                        
            }
            
            if layers[currentLayer + 1].count < 2 && currentLayer != 0 {
                
                let _ = layers[currentLayer + 1].removeFirst()
                
                if currentLayer + 1 != layers.count - 1 {
                    throw ListArrayExceptions.IllegalStateException //Every lower layer should have more nodes than the upper ones
                }
                
                let _ = layers.removeLast() //Removing the last layer
                
                
            }
            
            currentLayer = currentLayer + 1
            
            
        }
        
    }
    
    private func kernelContrction(message: responseMessage<Element>) {
        
        var currentMessage = message
        var currentLayer = 0 //Like indeces
        var repeatCycle = true
        var removeSectionOffset = true
        
        var pillar_L = message.nodes[1].upperLevelNode!
        var pillar_R = message.nodes[2].upperLevelNode!
        
        
        
        //Decreasing sectionOffsets
        //-------------------------------------------------------------------------------------
        while repeatCycle && currentLayer < layers.count {
            
            repeatCycle = false
            
            pillar_L = currentMessage.nodes[1].upperLevelNode!
            pillar_R =  currentMessage.nodes[2].upperLevelNode!
            
            pillar_L.localOffset_R = pillar_L.localOffset_R - 1
            pillar_R.localOffset_L = pillar_L.localOffset_R
            
            if pillar_L.localOffset_R < 0 {
                
                //Best cases
                if pillar_L.localOffset_L > 0 {
                    
                    pillar_L.localOffset_R = 0
                    pillar_R.localOffset_L = 0
                    
                    let pillar_LL = pillar_L.leftNode!
                    
                    pillar_L.lowerLevelNode = pillar_L.lowerLevelNode!.leftNode
                    
                    pillar_L.localOffset_L = pillar_L.localOffset_L - 1
                    pillar_LL.localOffset_R = pillar_L.localOffset_L
                    
                    pillar_L = pillar_LL
                    
                } else if pillar_R.localOffset_R > 0 {
                    
                    pillar_L.localOffset_R = 0
                    pillar_R.localOffset_L = 0
                    
                    let pillar_RR = pillar_R.rightNode!
                    
                    pillar_R.localOffset_R = pillar_R.localOffset_R - 1
                    pillar_RR.localOffset_L = pillar_R.localOffset_R
                      
                } else if pillar_L.leftNode.lowerLevelNode == nil {
                    
                    if layers[currentLayer + 1].startOffset > 0 {
                        
                        layers[currentLayer + 1].startOffset = layers[currentLayer + 1].startOffset - 1
                            
                        pillar_L.localOffset_R = 0
                        pillar_R.localOffset_L = 0
                        pillar_L.lowerLevelNode = pillar_L.lowerLevelNode!.leftNode
                        
                    } else {
                        
                        let msg = layers[currentLayer + 1].removeFirst()
                        try! kernelRemove(message: msg)
                        
                    }
                    
                    removeSectionOffset = false
                    
                } else if pillar_R.rightNode.lowerLevelNode == nil {
                    
                    if layers[currentLayer + 1].endOffset > 0 {
                        
                        layers[currentLayer + 1].startOffset = layers[currentLayer + 1].startOffset - 1
                            
                        pillar_L.localOffset_R = 0
                        pillar_R.localOffset_L = 0
                        pillar_L.lowerLevelNode = pillar_L.lowerLevelNode!.leftNode
                        
                    } else {
                        
                        let msg = layers[currentLayer + 1].removeLast()
                        try! kernelRemove(message: msg)
                       
                    }
                    
                    removeSectionOffset = false
                    
                } else {
                    
                    repeatCycle = true
                    let pillar_R_NEW = pillar_R.rightNode!
                    currentMessage = layers[currentLayer + 1].removeNode(remove: pillar_R)
                    
                    pillar_L.sectionOffset_R = getSectionOffset(pillar: pillar_L)
                    pillar_R_NEW.sectionOffset_L = pillar_L.sectionOffset_R
                    
                    pillar_L.localOffset_R = layers[currentLayer + 1].divider - 2
                    pillar_R_NEW.localOffset_L = pillar_L.localOffset_R
                    pillar_R = pillar_R_NEW
                    
                    currentLayer = currentLayer + 1
                    
                }
   
            }
        }
        
        //Resetting Variables
        //------------------------------------------
        currentLayer = 0
        pillar_L = message.nodes[1].upperLevelNode! //Hoping that pointers magic works
        pillar_R = pillar_L.leftNode
        //------------------------------------------
        
        //Decreasing sectionOffsets
        //-------------------------------------------------------------------------------------
        while currentLayer < layers.count && removeSectionOffset {
            let tmp = layers[currentLayer + 1].notifyDeletion(left: pillar_L, right: pillar_R)
            
            if tmp[0] != nil && tmp[1] != nil {
                
                pillar_L = tmp[0]!
                pillar_R = tmp[1]!
                
            } else {
                currentLayer = layers.count
            }
        }
        //-------------------------------------------------------------------------------------
        
        
        
    }
    //--------------------------------------------------------------------------------------
    
    //MARK: Private "Helper" Functions
    //--------------------------------------------------------------------------------------
    private func getSectionOffset(pillar: Node4D<Element>) -> Int {
        
        var node = pillar.lowerLevelNode!
        var result : Int = 0
        
        repeat {
            result = result + node.sectionOffset_L
            node = node.rightNode
        } while node.upperLevelNode != nil
        
        return result
        
    }
    //--------------------------------------------------------------------------------------
    
    
}
