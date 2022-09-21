//
//  File.swift
//
//  TODO: CHECK IF YOU ARE ADDING NODES OF THE LOWER LAYERS DIRECTLY BEFORE WRAPPING
//
//  Created by Christian Risi on 29/08/22.


import Foundation

public class ListArray<Element> {
    
    internal var layers : DoublyLinkedList<SelfExposingList<Element>>
    
    public var count : Int { return layers.getFirst()!.count}
    public var isEmpty : Bool {return count == 0}
    
    public init() {
        
        layers = DoublyLinkedList()
        layers.addFirst(SelfExposingList<Element>(divider: 100))
        
    }
    
    //MARK: Public functions
    //--------------------------------------------------------------------------------------
    public func addFirst(_ item: Element){
        let node2Add = Node4D(element: item)
        
        let response = layers.getFirst()!.addFirst(node: node2Add)
        
        if response.result == .delegating {
            try! kernelAdd(message: response)
        }
        
    }
    
    public func addLast(_ item: Element){
        let node2Add = Node4D(element: item)
        
        let response = layers.getFirst()!.addLast(node: node2Add)
        
        if response.result == .delegating {
            try! kernelAdd(message: response)
        }
    }
    
    //--------------------------------------------------------------------------------------
    
   
    
    public func addElement(before: Int, element: Element) {
        
    }
    
    public func addElement(after: Int, element: Element) {
        
    }
    
    public func removeFirst() -> Element? {
        
        
    }
    
    public func removeLast() -> Element? {
        
    }
    
    public func removeElement(at position: Int) -> Element? {
        
        
        
        
    }
    
    //MARK: Private "Kernel" Functions
    //--------------------------------------------------------------------------------------
    
    //This method is ok for AddFirst an AddLast and some cases of AddBetween, but the latter needs another method
    private func kernelAdd(message: responseMessage<Element>) throws {
        
        var currentMessage = message
        var currentLayer = 0 //Like indeces
        
        while currentMessage.result == .delegating {
            
            if currentMessage.count == 1 {
                
                switch currentMessage.operationType {
                    
                case .addFirst:
                    currentMessage = layers[currentLayer].addFirst(node: currentMessage.nodes[0])
                case .addLast:
                    currentMessage = layers[currentLayer].addLast(node: currentMessage.nodes[0])
                default:
                    throw ListArrayExceptions.IllegalActionException
                }
                
                
            } else if currentMessage.count == 2 { //Common zone for every adding operation
            
            if layers.count < currentLayer + 1 {
                layers.addLast(SelfExposingList(divider: 10))
            }
            
            let _ = layers[currentLayer + 1].addFirst(node: message.nodes[0])
            currentMessage = layers[currentLayer + 1].addLast(node: message.nodes[1])
            
        }
            
            currentLayer = currentLayer + 1
        }
        
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
