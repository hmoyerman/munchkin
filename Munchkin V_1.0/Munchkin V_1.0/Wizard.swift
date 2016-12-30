//
//  Munchkin
//
//  Created by Henry Moyerman in summer 2016
//  Copyright © 2016 Henry Moyerman. All rights reserved.
//

import Foundation

class Wizard : Classs {
    
    override init() {
        
        super.init()
        
        physicalCard.stringValue = "Wizard"
        
        text = "Charm Spell: You may discard your whole hand (minimum 3 cards) to charm a single Monster instead of fighting it.  " +
            "Discard the Monster and take its Treasure, but don’t gain levels." + "\n\n" + "Class"
    }
}