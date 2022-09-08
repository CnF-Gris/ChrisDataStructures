//
//  File.swift
//  
//
//  Created by Christian Risi on 08/09/22.
//

import Foundation


///Used to transmit messages between functions
internal struct OperationInfos<Element> {
    
    internal let node: Node4D<Element>
    internal let pillar_L: Node4D<Element>?
    internal let pillar_R:  Node4D<Element>?
    internal let operation: ListOperation? 
    
}
