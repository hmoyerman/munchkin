//
//  Munchkin
//
//  Created by Henry Moyerman in summer 2016
//  Copyright © 2016 Henry Moyerman. All rights reserved.
//

import Foundation

class MonsterModifier : Card {

	var modifierAmount:Int
	var treasureEffect:Int

	init(modifierAmount:Int, treasureEffect:Int, title:String) {

		self.modifierAmount = modifierAmount
        self.treasureEffect = treasureEffect

        super.init(doorCard: true)
        
        physicalCard.stringValue = title
        text = "Play during combat.  If the monster is defeated, draw " + String(treasureEffect) + " more Treasure."

        otherButtonTitle = "Use In This Combat"

	}
    
    convenience init() { self.init(modifierAmount:1, treasureEffect:1, title:"") }
}

