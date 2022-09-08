//
//  File.swift
//  
//  TODO: CHECK IF YOU ARE ADDING NODES OF THE LOWER LAYERS DIRECTLY BEFORE WRAPPING
//
//  Created by Christian Risi on 29/08/22.
//

import Foundation

public class ListArray<Element> {
    
    internal var layers : DoublyLinkedList<SelfExposingList<Element>>
    
    public var count : Int { return layers.getFirst()!.count}
    public var isEmpty : Bool {return count == 0}
    
    public init() {
        
        layers = DoublyLinkedList()
        layers.addFirst(SelfExposingList<Element>(divider: 100))
        
    }
    
    public func addFirst(_ element: Element){
        
        if let exposedNode = layers.getFirst()!.addFirst(element: element) {
            layering_F(node: exposedNode)
        }
        
    }
    
    public func addLast(_ element: Element){
        
        if let exposedNode = layers.getFirst()!.addLast(element: element) {
            layering_L(node: exposedNode)
        }
        
    }
    
    public func addElement(before: Int, element: Element) {
        
        let list =  layers.getFirst()!
        let bufferNode = Node4D<Element>(element: element)
        var currentLayer = 1
        
        var result = list.addElement(before: try! efficentSeach(position: before), bufferNode: bufferNode)
        
        while result != nil {
            
            if result!.upperLeftNode == nil {
                
                if before < (list.count / 2) {
                    
                    layering_F(node: result!.exposedNode)
                    
                } else {
                    
                    layering_L(node: result!.exposedNode)
                    
                }
                
            } else {
                
                var pillar_L : Node4D<Element>
                var pillar_R : Node4D<Element>
                
                if result!.exposedNode === bufferNode {
                    
                    pillar_L = result!.upperLeftNode!
                    pillar_R = result!.upperRightNode!
                    
                    //Notify changes
                    addSectionOffset(pillar_L: &pillar_L, pillar_R: &pillar_R)
                    
                } else {
                    
                    //Add a new node
                    addLayer(layer: currentLayer)
                    result = layers[currentLayer].addElement(after: result!.upperLeftNode!, bufferNode: result!.exposedNode)
                    
                    pillar_L = result!.upperLeftNode!
                    pillar_R = result!.upperRightNode!
                    
                    pillar_L.rightNode = result!.exposedNode
                    pillar_R.leftNode = result!.exposedNode
                    
                    if currentLayer == 1 {
                        
                        pillar_L.sectionOffset_R = 0
                        pillar_R.sectionOffset_L = 0
                        
                    } else {
                        
                        findNewOffset(pillar_L: &pillar_L, pillar_R: &pillar_R)
                        
                    }
                    
                    
                    
                }
                
            }
            
            currentLayer = currentLayer + 1
            
        }
        
    }
    
    public func addElement(after: Int, element: Element) {
        
        let list =  layers.getFirst()!
        let bufferNode = Node4D<Element>(element: element)
        var currentLayer = 1
        
        var result = list.addElement(before: try! efficentSeach(position: after), bufferNode: bufferNode)
        
        while result != nil {
            
            if result!.upperLeftNode == nil {
                
                if after < (list.count / 2) {
                    
                    layering_F(node: result!.exposedNode)
                    
                } else {
                    
                    layering_L(node: result!.exposedNode)
                    
                }
                
            } else {
                
                var pillar_L : Node4D<Element>
                var pillar_R : Node4D<Element>
                
                if result!.exposedNode === bufferNode {
                    
                    pillar_L = result!.upperLeftNode!
                    pillar_R = result!.upperRightNode!
                    
                    //Notify changes
                    addSectionOffset(pillar_L: &pillar_L, pillar_R: &pillar_R)
                    
                } else {
                    
                    //Add a new node
                    addLayer(layer: currentLayer)
                    result = layers[currentLayer].addElement(after: result!.upperLeftNode!, bufferNode: result!.exposedNode)
                    
                    pillar_L = result!.upperLeftNode!
                    pillar_R = result!.upperRightNode!
                    
                    pillar_L.rightNode = result!.exposedNode
                    pillar_R.leftNode = result!.exposedNode
                    
                    if currentLayer == 1 {
                        
                        pillar_L.sectionOffset_R = 0
                        pillar_R.sectionOffset_L = 0
                        
                    } else {
                        
                        findNewOffset(pillar_L: &pillar_L, pillar_R: &pillar_R)
                        
                    }
                    
                    
                    
                }
                
            }
            
            currentLayer = currentLayer + 1
            
        }
        
    }
    
    public func removeFirst() -> Element? {
        
        //Take the first element from the List
        //Apply the method of removal
        //Return its result
        
        if let result = layers.getFirst()!.removeFirst() {
            
            //result is not nil
            if result.1 == .collapse {
                
                collapse_F(layerLevel: 1)
                
            }
            
            return result.0.element
            
        }
        
        return nil
        
    }
    
    public func removeLast() -> Element? {
        
        //Take the first element from the List
        //Apply the method of removal
        //Return its result
        
        if let result = layers.getFirst()!.removeLast() {
            
            //result is not nil
            if result.1 == .collapse {
                
                collapse_L(layerLevel: 1)
                
            }
            
            return result.0.element
            
        }
        
        return nil
        
    }
    
    public func removeElement(at position: Int) -> Element? {
        
        let result = layers.getFirst()!.removeElement(node: try! self.efficentSeach(position: position))  //I want it to block things out
        
        var layerLevel = 1
        var tmp = result
        
        while layerLevel < layers.count {
            
            if tmp!.operation == .collapse {
                
                if tmp!.upperLeftNode == nil {
                    
                    if position < count/2 {
                        
                        collapse_F(layerLevel: layerLevel) //They will end the remaining cascaded collapse
                        return result!.removedNode.element
                        
                    } else {
                        
                        collapse_L(layerLevel: layerLevel) //They will end the cascaded collapse
                        return result!.removedNode.element
                        
                    }
                    
                } else {
                    
                    var pillar_L = tmp!.upperLeftNode!
                    
                    tmp = layers[layerLevel].removeElement(node: result!.upperRightNode!)
                    
                    if layerLevel == 1 {
                        
                        pillar_L.sectionOffset_R = layers[1].divider - 1
                        pillar_L.rightNode.sectionOffset_L = layers[1].divider - 1
                        
                    } else {
                        
                        var pillar_R = pillar_L.rightNode!
                        findNewOffsetOnRemoval(pillar_L: &pillar_L, pillar_R: &pillar_R)
                        
                    }
                    
                    layerLevel = layerLevel + 1
                    
                   
                    
                }
                
            } else if var pillar_L = tmp?.upperLeftNode { //contracted -> Still notify changes
                
                var pillar_R = tmp!.upperRightNode!
                
                removeSectionOffset(pillar_L: &pillar_L, pillar_R: &pillar_R)
                
                while layerLevel < layers.count - 1 {
                    
                    let pillars = layers[layerLevel].lockNodes(node: pillar_L , operation: .addBetween)
                    pillar_L = pillars.leftPillar
                    pillar_R = pillars.rightPillar
                    
                    removeSectionOffset(pillar_L: &pillar_L, pillar_R: &pillar_R)
                    
                    layerLevel = layerLevel + 1
                    
                }
                
                layerLevel = layers.count
                
            }
            
        }
        
        if result != nil {
            
            return result!.removedNode.element
            
        }
        
        return nil
        
    }
    
    @inline(__always)
    private func layering_F(node: Node4D<Element>) {
        
        var bufferNode : Node4D<Element>? = node
        var currentLayer = 1 //The layer where we are going to operate equals to the count we want
        
        while bufferNode != nil {
            
            addLayer(layer: currentLayer)
            bufferNode = layers[currentLayer].addFirst(node: bufferNode!)
            currentLayer = currentLayer + 1
            
        }
        
    }
    
    @inline(__always)
    private func layering_L(node: Node4D<Element>) {
        
        var bufferNode : Node4D<Element>? = node
        var currentLayer = 1 //The layer where we are going to operate equals to the count we want
        
        while bufferNode != nil {
            
            addLayer(layer: currentLayer)
            bufferNode = layers[currentLayer].addLast(node: bufferNode!)
            currentLayer = currentLayer + 1
            
        }
        
    }
    
    @inline(__always)
    private func addLayer(layer: Int) {
        
        if layer + 1 > layers.count {
            
            layers.addLast(SelfExposingList(divider: 10))
            
        }
        
    }
    
    @inline(__always)
    private func collapse_F(layerLevel: Int) {
        
        //This is where the unowned property comes handy
        var count = layerLevel
        
        while count < layers.count {
            
            let element = layers[count].getFirst()
            
            if element!.lowerLevelNode == nil {
                
                let result = layers[count].removeFirst()
                
                if let node = layers[count].getFirst() {
                    node.sectionOffset_L = 0
                }
                
                if layers[count].isEmpty {
                    
                    removeLayer()
                    
                }
                
                if result?.1 != .collapse {
                    
                    count = layers.count //exit from the cycle
                    
                }
                
            }
            
        }
        
    }
    
    @inline(__always)
    private func collapse_L(layerLevel: Int) {
        
        //This is where the unowned property comes handy
        var count = layerLevel
        
        while count < layers.count - 1 {
            
            let element = layers[count].getLast()
            
            if element!.lowerLevelNode == nil {
                
                let result = layers[count].removeLast()
                
                if let node = layers[count].getLast() {
                    node.sectionOffset_R = 0
                }
                
                
                if layers[count].isEmpty {
                    
                    removeLayer()
                    
                }
                
                if result?.1 != .collapse {
                    
                    count = layers.count //exit from the cycle
                    
                }
                
            }
            
        }
        
    }
    
    @inline(__always)
    private func removeLayer() {
        
        let _ = layers.removeLast()
        
    }
    
    @inline(__always)
    private func addSectionOffset( pillar_L: inout Node4D<Element>, pillar_R: inout Node4D<Element>) {
        
        pillar_L.sectionOffset_L =  pillar_L.sectionOffset_L + 1
        pillar_R.sectionOffset_R = pillar_R.sectionOffset_R + 1
        
    }
    
    @inline(__always)
    private func removeSectionOffset( pillar_L: inout Node4D<Element>, pillar_R: inout Node4D<Element>) {
        
        pillar_L.sectionOffset_L =  pillar_L.sectionOffset_L - 1
        pillar_R.sectionOffset_R = pillar_R.sectionOffset_R - 1
        
    }
    
    @inline(__always)
    private func findNewOffset( pillar_L: inout Node4D<Element>, pillar_R: inout Node4D<Element>) {
        
        let node = pillar_L.rightNode!
        var buffer_L = pillar_L.lowerLevelNode!
        var buffer_R = pillar_R.lowerLevelNode!
        
        pillar_L.sectionOffset_R = 0
        pillar_R.sectionOffset_L = 0
        
        while buffer_L.upperLevelNode !== node {
            
            pillar_L.sectionOffset_R = pillar_L.sectionOffset_R + buffer_L.sectionOffset_R
            buffer_L = buffer_L.rightNode!
            
        }
        
        while buffer_R.upperLevelNode !== node {
            
            pillar_R.sectionOffset_L = pillar_R.sectionOffset_L + buffer_R.sectionOffset_R
            buffer_R = buffer_R.leftNode
            
        }
        
        node.sectionOffset_L = pillar_L.sectionOffset_R
        node.sectionOffset_R = pillar_R.sectionOffset_L
        
    }
    
    @inline(__always)
    private func findNewOffsetOnRemoval( pillar_L: inout Node4D<Element>, pillar_R: inout Node4D<Element>) {
        
        var buffer_L = pillar_L.lowerLevelNode!
        
        pillar_L.sectionOffset_R = 0
        pillar_R.sectionOffset_L = 0
        
        while buffer_L.upperLevelNode !== pillar_R {
            
            pillar_L.sectionOffset_R = pillar_L.sectionOffset_R + buffer_L.sectionOffset_R
            buffer_L = buffer_L.rightNode!
            
        }
        
        pillar_R.sectionOffset_L = pillar_L.sectionOffset_L
        
    }
    
    
}
