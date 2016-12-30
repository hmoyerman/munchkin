//
//  Munchkin
//
//  Created by Henry Moyerman in summer 2016
//  Copyright © 2016 Henry Moyerman. All rights reserved.
//

import Foundation

class Dwarf : Race {
    
    override init() {
        
        super.init()
        
        physicalCard.stringValue = "Dwarf"
        
        text = "You can have 6 cards in your hand." + "\n\n" +
            "Race"
    }
}
