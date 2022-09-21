//
//  File.swift
//
//  TODO: CHECK IF YOU ARE ADDING NODES OF THE LOWER LAYERS DIRECTLY BEFORE WRAPPING
//
//  Created by Christian Risi on 29/08/22.


import Foundation

public class ListArray<Element> {
    
    internal var layers : DoublyLinkedList<SelfExposingList<Element>>
    private var base : SelfExposingList<Element> {return layers.getFirst()!}
    
    public var count : Int { return layers.getFirst()!.count}
    public var isEmpty : Bool {return count == 0}
    
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
            try! kernelAdd(message: response)
        }
        
    }
    
    public func addLast(_ item: Element) {
        let node2Add = Node4D(element: item)
        
        let response = layers.getFirst()!.addLast(node: node2Add)
        
        if response.result == .delegating {
            try! kernelAdd(message: response)
        }
    }
    
    public func addBefore(position: Int, item: Element) {
        
        let target = efficientSearch(position: position) //To be implemented
        let node2Add = Node4D(element: item)
        
        let message = try! base.addBetween(add: node2Add, how: .before, target: target)
        
        if message.result == .delegating {
            
            kernelAdd(message: message)
            
        } else {
            
            kernelExpansion(message: message)
            
        }
        
    }
    
    //--------------------------------------------------------------------------------------
    
   
    
//    public func addElement(before: Int, element: Element) {
//        
//    }
//    
//    public func addElement(after: Int, element: Element) {
//        
//    }
//    
//    public func removeFirst() -> Element? {
//        
//        
//    }
//    
//    public func removeLast() -> Element? {
//        
//    }
//    
//    public func removeElement(at position: Int) -> Element? {
//        
//        
//        
//        
//    }
    
    //MARK: Private "Kernel" Functions
    //--------------------------------------------------------------------------------------
    
    //This method is ok for AddFirst an AddLast and some cases of AddBetween, but the latter needs another method
    private func kernelAdd(message: responseMessage<Element>) throws {
        
        var currentMessage = message
        var currentLayer = 0 //Like indeces
        
       
        
        while currentMessage.result == .delegating {
            
            if currentMessage.count == 1 {
                
                let tmp = Node4D<Element>()
                switch currentMessage.operationType {
                    
                case .addFirst:
                    tmp.lowerLevelNode = currentMessage.nodes[0]
                    currentMessage = layers[currentLayer + 1].addFirst(node: tmp)
                case .addLast:
                    tmp.lowerLevelNode = currentMessage.nodes[0]
                    currentMessage = layers[currentLayer + 1].addLast(node: tmp)
                default:
                    throw ListArrayExceptions.IllegalActionException
                }
                
                
            } else if currentMessage.count == 2 { //Common zone for every adding operation
                
                let tmp_L = Node4D<Element>()
                let tmp_R = Node4D<Element>()
                
                tmp_L.lowerLevelNode = currentMessage.nodes[0]
                tmp_R.lowerLevelNode = currentMessage.nodes[1]
                
                if layers.count < currentLayer + 1 {
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
        var currentLayer = 0 //Like indeces
        
        var pillar_L = message.nodes[1].upperLevelNode!
        var pillar_R = message.nodes[2].upperLevelNode!
        
        //Increasing sectionOffsets
        //-------------------------------------------------------------------------------------
        while currentLayer < layers.count {
            let tmp = layers[currentLayer + 1].notifyInsertion(left: pillar_L, right: pillar_R)
            
            if tmp[0] != nil && tmp[1] != nil {
                
                pillar_L = tmp[0]!
                pillar_R = tmp[1]!
                
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
        
        while repeatCycle && currentLayer < layers.count {
            
            pillar_L = currentMessage.nodes[1].upperLevelNode!
            pillar_R =  currentMessage.nodes[2].upperLevelNode!
            
            
            pillar_L.localOffset_R = pillar_L.localOffset_R + 1
            pillar_R.localOffset_L = pillar_L.localOffset_R
            
            if (pillar_L.localOffset_R % layers[currentLayer + 1].divider - 1) == 0 {
                
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
                
                currentMessage = try! layers[currentLayer + 1].addBetween(add: tmp, how: .after, target: pillar_L)
                
                //Counting
                let pillar_M = pillar_L.rightNode!
                pillar_L.sectionOffset_R = getSectionOffset(pillar: pillar_L)
                pillar_R.sectionOffset_L = getSectionOffset(pillar: pillar_M)
                pillar_M.sectionOffset_L = pillar_L.sectionOffset_R
                pillar_M.sectionOffset_R = pillar_R.sectionOffset_L
                
                
                if currentMessage.count < 3 {
                    repeatCycle = false
                    try! kernelAdd(message: currentMessage)
                }
                
                currentLayer = currentLayer + 1
                
            } else {
                
                repeatCycle = false
                
            }
        }
        
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
    
    @inline(__always)
    private func layering_F(node: Node4D<Element>) {
        
        
        
    }
    
    @inline(__always)
    private func layering_L(node: Node4D<Element>) {
        
        
    }
    
    @inline(__always)
    private func addLayer(layer: Int) {
        
        
        
    }
    
    @inline(__always)
    private func collapse_F(layerLevel: Int) {
        
    }
    
    @inline(__always)
    private func collapse_L(layerLevel: Int) {
        
    }
    
    @inline(__always)
    private func removeLayer() {
        
        
        
    }
    
    @inline(__always)
    private func addSectionOffset( pillar_L: inout Node4D<Element>, pillar_R: inout Node4D<Element>) {
        
        
    }
    
    @inline(__always)
    private func removeSectionOffset( pillar_L: inout Node4D<Element>, pillar_R: inout Node4D<Element>) {
        
        
    }
    
    @inline(__always)
    private func findNewOffset( pillar_L: inout Node4D<Element>, pillar_R: inout Node4D<Element>) {
        
        
    }
    
    @inline(__always)
    private func findNewOffsetOnRemoval( pillar_L: inout Node4D<Element>, pillar_R: inout Node4D<Element>) {
        
    }
    
    
}
