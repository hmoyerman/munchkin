//
//  Munchkin
//
//  Created by Henry Moyerman in summer 2016
//  Copyright © 2016 Henry Moyerman. All rights reserved.
//

import Foundation

class Warrior : Classs {
    
    override init() {
        
        super.init()
        
        physicalCard.stringValue = "Warrior"
        
        text = "You win ties in combat." + "\n\n" + "Class"
    }
}