//
//  Munchkin
//
//  Created by Henry Moyerman in summer 2016
//  Copyright © 2016 Henry Moyerman. All rights reserved.
//

import Foundation

class SingleUseItem : Card {

	var eitherSideAmount:Int
    var shortTitle:String

    init(value:Int, eitherSideAmount:Int, title:String) {
        
		self.eitherSideAmount = eitherSideAmount
        shortTitle = title

        super.init(doorCard: false)
        
        physicalCard.stringValue = title + "\n\n" + "+/- " + String(eitherSideAmount)
        
        self.value = value * 100
        text = "Use during combat.  -" + String(eitherSideAmount) + " to the Monster if you are in combat.  +" + String(eitherSideAmount) +
            " to the Monster if another player is in combat.  Usable once only." + "\n\n" +
            String(self.value) + " Gold Pieces"

        otherButtonTitle = "Use In This Combat"
	}
    
    convenience init() { self.init(value:1, eitherSideAmount:1, title:"") }

}

