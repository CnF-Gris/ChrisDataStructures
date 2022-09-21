//
//  File.swift
//  
//
//  Created by Christian Risi on 21/09/22.
//

import Foundation

internal struct responseMessage<Element> {
    
     /**
     Pointers (Cause they belong to a class) of nodes used to
     organize the structure
      
      If there are 3 elements we have:
     - [0] -> Node Exposed
      
     - [1] -> Left Pillar
      
     - [2] -> Right Pillar
      
      If there are 2 elements we have:
      
      - [0] -> 1st Node Exposed
      
      - [1] -> 2nd Node Exposed
      
      - Important: This will trigger an implicit unwrapping,
      so, before calling this, verify that the result is `delegate` before
      proceding further
      */
    public var nodes : [Node4D<Element>]!
    public var operationType : ListOperation
    public var result : OperationResult
    public var count : Int
    {
        get {
            if result == .success {
                return 0
            } else {
                return nodes.count
            }
        }
    }

    
    internal init(nodes: [Node4D<Element>]?, operationType: ListOperation, result: OperationResult) {
        self.nodes = nodes
        self.operationType = operationType
        self.result = result
    }
    
}
