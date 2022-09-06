//
//  File.swift
//  
//
//  Created by Christian Risi on 29/08/22.
//

import Foundation

public class ListArray<Element> {
    
    internal var layers : DoublyLinkedList<SelfExposingList<Element>>
    
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
                
                
                
                if result!.exposedNode === bufferNode {
                    
                    //Notify changes
                    
                } else {
                    
                    //Add a new node
                    addLayer(layer: currentLayer)
                    result = layers[currentLayer].addElement(after: result!.upperLeftNode!, bufferNode: result!.exposedNode)
                    
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
                
                
                
                if result!.exposedNode === bufferNode {
                    
                    //Notify changes
                    
                } else {
                    
                    //Add a new node
                    addLayer(layer: currentLayer)
                    result = layers[currentLayer].addElement(after: result!.upperLeftNode!, bufferNode: result!.exposedNode)
                    
                }
                
            }
            
        currentLayer = currentLayer + 1
            
        }
        
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
    private func removeLayer(layer: Int) {
        
        if layer <= layers.count {
            
            let _ = layers.removeLast()
            
        }
        
    }
    
    
}
