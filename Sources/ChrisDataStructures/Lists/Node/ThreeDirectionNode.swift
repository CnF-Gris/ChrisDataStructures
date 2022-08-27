//
//  File.swift
//  
//
//  Created by Christian Risi on 25/08/22.
//

import Foundation

public class ThreeDirectionNode<Element>: DoublyLinkedNode<Element> {
    
    public unowned var down: DoublyLinkedNode<Element>?
    
}
