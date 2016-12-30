//
//  Munchkin
//
//  Created by Henry Moyerman in summer 2016
//  Copyright © 2016 Henry Moyerman. All rights reserved.
//

import Foundation

class Cleric : Classs {
    
    override init() {
        
        super.init()
        
        physicalCard.stringValue = "Cleric"
        
        text = "When facing an undead monster, -5 to the monster" + "\n\n" + "Class"
    }
}
