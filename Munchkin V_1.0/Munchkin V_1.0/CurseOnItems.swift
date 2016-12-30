//
//  Munchkin
//
//  Created by Henry Moyerman in summer 2016
//  Copyright © 2016 Henry Moyerman. All rights reserved.
//

import Foundation

class CurseOnItems : Curse {
    
    var curseType:String
    
    init(curseType: String) {
        
        self.curseType = curseType
        
        super.init()
        let curseString = "Lose Your Equipped " + curseType
        
        physicalCard.stringValue = "Curse! " + curseString
    }
    
    convenience override init() { self.init(curseType:"") }

    override func execute(player: Player) -> Card {
        for (index, card) in player.itemSlot[0].enumerate() { if card.category == curseType {
            player.itemSlot[0].removeAtIndex(index)
            return card }}
        return Card()
    }
}