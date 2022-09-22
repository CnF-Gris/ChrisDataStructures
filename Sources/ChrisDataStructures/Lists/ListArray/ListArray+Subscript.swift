//
//  File.swift
//
//
//  Created by Christian Risi on 06/09/22.


import Foundation

extension ListArray : RandomAccessCollection, Collection {
    
    public func index(after i: Int) -> Int {
        return i + 1
    }
    
    
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return startIndex + count - 1
    }
    

    public subscript(position: Int) -> Element {

        get {
            
            return try! efficentSeach(position: position).element

        }

        set(newValue) {

            let tmp = try! efficentSeach(position: position)
            tmp.element = newValue
            
        }

    }

    internal func efficentSeach(position: Int) throws -> Node4D<Element> {
        
        if position < startIndex || position > endIndex {
            throw ListArrayExceptions.IndexOutOfBoundException  
        }

        //We start by the 1st available node on the last layer
        var currentNode = layers.getLast()!.getFirst()!
        var currentLayer = layers.count - 1//Like Indices
        var currentPosition = countOffset()
        
        while abs(distance(from: currentPosition, to: position)) > 0  && currentLayer >= 0{
            
            let layerConstantOffset : Int
            
            if currentLayer > 0 {
                
                var tmp = 100
                
                for i in 2...currentLayer {
                    tmp = tmp * layers[i].divider
                }
                
                layerConstantOffset = tmp
                
            } else {
                layerConstantOffset = 1
            }
            
            if distance(from: currentPosition, to: position) > 0 {
                
                while (distance(from: currentPosition, to: position) - (currentNode.sectionOffset_R + layerConstantOffset)) > 0 {
                    
                    currentPosition = currentPosition + (currentNode.sectionOffset_R + layerConstantOffset)
                    currentNode = currentNode.rightNode
                    
                }
                
            } else if distance(from: currentPosition, to: position) < 0 && currentLayer < layers.count - 1 {
                
                while (abs(distance(from: currentPosition, to: position)) - (currentNode.sectionOffset_L + layerConstantOffset)) > 0 {
                    
                    currentPosition = currentPosition - (currentNode.sectionOffset_L + layerConstantOffset)
                    currentNode = currentNode.leftNode
                    
                }
                
            }
            //else means that distance currentPosition to position == 0 and exits the while
            if currentLayer != 0 {
                currentNode = currentNode.lowerLevelNode!
            }
            currentLayer = currentLayer - 1
            
        }
        
        //Check if we are on any upperLevel
        while currentNode.lowerLevelNode != nil {
            
            currentNode = currentNode.lowerLevelNode!
            
        }
        
        if distance(from: currentPosition, to: position) != 0 {
            throw ListArrayExceptions.IndexNotReachedException
        }
        
        return currentNode
        
        
    }
    
    private func countOffset() -> Int {
        
        var OFFSET = base.startOffset
        var currentLayer = 1 //Like Indices
            
        while currentLayer < layers.count {
            
            var node = layers[currentLayer].getFirst()!
            
            while node.upperLevelNode == nil {
                
                OFFSET = OFFSET + node.sectionOffset_R
                node = node.rightNode
                
            }
            
            currentLayer = currentLayer + 1
            
        }
            
        return OFFSET
        
    }
}
