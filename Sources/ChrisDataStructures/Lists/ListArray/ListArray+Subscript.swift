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
            
            return try! efficientSearch(position: position).element

        }

        set(newValue) {

            let tmp = try! efficientSearch(position: position)
            tmp.element = newValue
            
        }

    }

    internal func efficientSearch(position: Int) throws -> Node4D<Element> {
        
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
                if currentLayer >= 2 {
                    for i in 2...currentLayer {
                        tmp = tmp * layers[i].divider
                    }
                }
                layerConstantOffset = tmp
                
            } else {
                layerConstantOffset = 1
            }
            
            var distance = distance(from: currentPosition, to: position)
            
            if distance > 0 {
                
                while (distance - (currentNode.sectionOffset_R + layerConstantOffset)) >= 0 {
                    
                    currentPosition = currentPosition + (currentNode.sectionOffset_R + layerConstantOffset)
                    currentNode = currentNode.rightNode
                    distance = distance - (currentNode.sectionOffset_R + layerConstantOffset)
                    
                }
                
            } else if distance < 0 && currentLayer < layers.count - 1 {
                
                while (abs(distance) - (currentNode.sectionOffset_L + layerConstantOffset)) >= 0 {
                    
                    currentPosition = currentPosition - (currentNode.sectionOffset_L + layerConstantOffset)
                    currentNode = currentNode.leftNode
                    distance = position - currentPosition
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
            
        while currentLayer < layers.count - 1 {
            
            var node = layers[currentLayer].getFirst()!
            let layerConstantOffset : Int
            
            if currentLayer > 0 {
                
                var tmp = 100
                if currentLayer >= 2 {
                    for i in 2...currentLayer {
                        tmp = tmp * layers[i].divider
                    }
                }
                layerConstantOffset = tmp
                
            } else {
                layerConstantOffset = 1
            }
            
            while node.upperLevelNode == nil {
                
                OFFSET = OFFSET + node.sectionOffset_R + layerConstantOffset
                node = node.rightNode
                
            }
            
            currentLayer = currentLayer + 1
            
        }
            
        return OFFSET
        
    }
}
