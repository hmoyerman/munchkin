//
//  Munchkin
//
//  Created by Henry Moyerman in summer 2016
//  Copyright © 2016 Henry Moyerman. All rights reserved.
//

import Foundation

class InvisibilityPotion : Card {
    
    init() {
                
        super.init(doorCard: false)
        
        value = 200
        
        physicalCard.stringValue = "Invisibility Potion"
        
        text = "When played, the combatant escapes from the monster automatically and the board is cleared.  "
        + "Usable once only." + "\n\n" + String(value)
            + " Gold Pieces"
        
        otherButtonTitle = "Use In This Combat"
    }
}

