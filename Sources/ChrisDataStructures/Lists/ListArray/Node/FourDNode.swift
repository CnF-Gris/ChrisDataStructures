//
//  File.swift
//  
//
//  Created by Christian Risi on 29/08/22.
//

import Foundation

internal class Node4D<Element> {
    
    ///Node to the Lower Layer
    ///
    ///- Attention:
    ///It may be `nil` if there's either no element or you are on the Lowest Level
    public weak var lowerLevelNode : Node4D<Element>?
    ///Node to the Upper Layer
    ///
    ///- Attention:
    ///It may be `nil` if there's either no element or you are on the Uppest Level
    public weak var upperLevelNode: Node4D<Element>?
    ///Node to the left node
    public var leftNode: Node4D<Element>!
    ///Node to the left node
    public var rightNode: Node4D<Element>!
    
    public var sectionOffset_L : Int
    public var sectionOffset_R : Int
    public var localOffset_L : Int
    public var localOffset_R : Int
  
    
    public var element: Element!
    
    public init() {
        
        sectionOffset_L = 0
        sectionOffset_R = 0
        localOffset_L = 0
        localOffset_R = 0
        
    }
    
    public convenience init(element: Element){
        
        self.init()
        self.element = element
        
    }
    
}
