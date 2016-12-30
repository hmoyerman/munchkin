//
//  Munchkin
//
//  Created by Henry Moyerman in summer 2016
//  Copyright © 2016 Henry Moyerman. All rights reserved.
//

import Foundation

class LevelUpCard : Card {
    
    init(title:String) {
        
        super.init(doorCard: false)
        
        physicalCard.stringValue = title
        
        text = "Go Up A Level"
        
        otherButtonTitle = "Go up a level!!"
    }
}

