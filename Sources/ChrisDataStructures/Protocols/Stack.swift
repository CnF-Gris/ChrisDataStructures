//
//  File.swift
//  
//
//  Created by Christian Risi on 22/08/22.
//

import Foundation

/**
 LIFO Protocol to be Implemented on Collection to assure their Functionality
*/
protocol Stack {
    
    /// The Element Type Contained in the collection
    associatedtype Element
    
    /// The number of Items in the Collection
    var count : Int {get}
    
    /**
     Add the Item in the Collection following a LIFO order
    */
    func push()
    /**
     Removes and Returns the Lastt Element Pushed in the Collection
     - Returns:
    The First Element Pushed, following the LIFO order, or `nil` if the Collection is empty
    */
    func pop() -> Element?
    
}
