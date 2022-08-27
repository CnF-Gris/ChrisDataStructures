//
//  File.swift
//  
//
//  Created by Christian Risi on 22/08/22.
//

import Foundation

/**
 FIFO Protocol to be Implemented on Collection to assure their Functionality
*/
protocol Queue {
    
    /// The Element Type Contained in the collection
    associatedtype Element
    
    /// The number of Items in the Collection
    var count : Int {get}
    
    /// Puts the Item into the Collection
    func enqueue(element: Element)
    /**
     Removes and Returns the First Element Enqueued in the Collection
     - Returns:
    The First Element Enqueued, following the FIFO order, or `nil` if the Collection is empty
    */
    func deque() -> Element?
    
}
