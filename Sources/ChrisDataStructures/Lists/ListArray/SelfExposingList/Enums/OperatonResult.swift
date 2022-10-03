//
//  File.swift
//  
//
//  Created by Christian Risi on 21/09/22.
//

import Foundation

internal enum OperationResult {
    
    //All done, nothing more to do
    case success
    //Now it is the Mother Structure that have to make further changes
    case delegating
    //Now it is the Mother Structure that have to make further changes
    case specialDelegation
    //Throws an error
    case failure
    
    //Successfully added an Item between 2 Pillars without adding a new Pillar
    case notifyExpansion
    //Added an Item that will bring a new Pillar to emerge
    case Mitosis
    //Successfully removed an Item between 2 Pillars without destroing any of them
    case notifyContraction
    //Removed an Item that will bring an Existing Pillar to collapse
    case Collapse
    
}
