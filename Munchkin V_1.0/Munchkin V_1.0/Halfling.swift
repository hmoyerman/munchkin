//
//  Munchkin
//
//  Created by Henry Moyerman in summer 2016
//  Copyright © 2016 Henry Moyerman. All rights reserved.
//

import Foundation

class Halfling : Race {
    
    override init() {
        
        super.init()
        
        physicalCard.stringValue = "Halfling"
        
        text = "You may sell one item each turn for double price (other items are at normal price)." + "\n\n" +
            "Race"
    }
}