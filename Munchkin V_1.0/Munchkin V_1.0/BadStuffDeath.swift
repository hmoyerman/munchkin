//
//  Munchkin
//
//  Created by Henry Moyerman in summer 2016
//  Copyright © 2016 Henry Moyerman. All rights reserved.
//

import Foundation

class BadStuffDeath : BadStuff {
    
    override init() {
        
        super.init()
        
        self.badStuffDescription = "Bad Stuff: You die!"
        self.badStuffPastAction = " died!"
    }
    
    override func execute(player: Player) -> [Card] {
        var returnCards = player.hand
        for slot in player.itemSlot { for card in slot { returnCards.append(card)}}
        player.hand.removeAll()
        for i in 0...1 { player.itemSlot[i].removeAll() }

        return returnCards
    }
}
