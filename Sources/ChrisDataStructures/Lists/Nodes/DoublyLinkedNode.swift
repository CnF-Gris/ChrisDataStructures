//
//  File.swift
//  
//
//  Created by Christian Risi on 22/08/22.
//

import Foundation

public class DoublyLinkedNode<Element> {
    ///A pointer to the previous Node
    public var leftNode : DoublyLinkedNode?
    ///A pointer to the next Node
    public var rightNode : DoublyLinkedNode?
    
    /**
     The Structure to validate the Node in the collection.
     
     The `!` is used cause every  Node, other than Trailer and Header, must have one. Also it is impossible to require it while initializing `self`
     
     It is `unowned` as the Structure has a longer lifetime than the Node
     */
    public unowned var structure : DoublyLinkedList<Element>!
    
    /**
     The Element contained in the Node.
     
     The `!` is used cause other than Trailer and Header, every accessible node should have an Element
     */
    public var element: Element!
    
    init(structure: DoublyLinkedList<Element>, element: Element){
        self.structure = structure
        self.element = element
    }
    
    init(structure: DoublyLinkedList<Element>){
        self.structure = structure
    }
    
    init(){
        
    }
    
}
