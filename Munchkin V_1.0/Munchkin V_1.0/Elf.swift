//
//  Munchkin
//
//  Created by Henry Moyerman in summer 2016
//  Copyright © 2016 Henry Moyerman. All rights reserved.
//

import Foundation

class Elf : Race {
    
    override init() {
        
        super.init()
        
        physicalCard.stringValue = "Elf"
        
        text = "You go up a level for every monster you help someone else kill." + "\n\n" +
            "Race"
    }
}