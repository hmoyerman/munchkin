//
//  Munchkin
//
//  Created by Henry Moyerman in summer 2016
//  Copyright © 2016 Henry Moyerman. All rights reserved.
//

import Foundation

class OutToLunch : Card {
    
    init() {
        
        super.init(doorCard: false)
        
        value = 700
        
        physicalCard.stringValue = "Out To Lunch"
        
        text = "The monster in this room is on break.  Play this card during any combat.  " +
        "The board is cleared and you draw two Treasure cards immediately.  Usable once only." + "\n\n" + String(value)
        + " Gold Pieces"
        
        otherButtonTitle = "Use In This Combat"
    }
}

