//
//  Munchkin
//
//  Created by Henry Moyerman in summer 2016
//  Copyright © 2016 Henry Moyerman. All rights reserved.
//

import Foundation

class WishingRing : Card {
    
    init() {
        
        super.init(doorCard: false)
        
        value = 500
        
        physicalCard.stringValue = "Wishing Ring"
        
        text = "Cancel any curse.  Play at any time.  Usable once only." + "\n\n" + String(value) + " Gold Pieces"
        
        otherButtonTitle = "Use In This Combat"
    }
}
