//
//  Munchkin
//
//  Created by Henry Moyerman in summer 2016
//  Copyright © 2016 Henry Moyerman. All rights reserved.
//

import Foundation

class BadStuffOnHand : BadStuff {
    
    override init() {
    
        super.init()
        
        self.badStuffDescription = "Bad Stuff: Lose all of the cards in your hand"
        self.badStuffPastAction = " lost all of the cards in their hand"
    }
    
    override func execute(player: Player) -> [Card] {
        let returnCards = player.hand
        player.hand.removeAll()
        return returnCards
    }
}