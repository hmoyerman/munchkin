//
//  Munchkin
//
//  Created by Henry Moyerman in summer 2016
//  Copyright © 2016 Henry Moyerman. All rights reserved.
//

import Foundation

class CurseOnRacesAndClasses : Curse {
    
    var curseType:String
    
    init(curseType: String) {
        
        self.curseType = curseType
        
        super.init()
        let curseString = "Lose Your " + curseType

        physicalCard.stringValue = "Curse! " + curseString
    }
    
    convenience override init() { self.init(curseType:"") }
    
    override func execute(player: Player) -> Card {
        if curseType == "Race" { player.race = nil }
        else { player.classs = nil }
        return Card()
    }
}
