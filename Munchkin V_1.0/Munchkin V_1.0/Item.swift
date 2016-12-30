//
//  Munchkin
//
//  Created by Henry Moyerman in summer 2016
//  Copyright © 2016 Henry Moyerman. All rights reserved.
//

import Foundation

class Item : Card {

    var bonus:Int
	var usableBy:String
    var category:String

    init(value:Int, bonus:Int, usableBy:String, category:String, title:String) {

		self.bonus = bonus
        self.usableBy = usableBy
		self.category = category

        super.init(doorCard: false)
        
        physicalCard.stringValue = title
        self.value = value * 100
        
        let stringBonus = "+" + String(bonus) + " Bonus"
        var categoryString = ""
        if category != "None" { categoryString = category}
        
        var useString = ""
        if usableBy.containsString("All") { useString = "Usable By " + usableBy }
        else { useString = "Usable By " + usableBy + " Only" }
        
        text = stringBonus + "\n\n" + categoryString + "\n\n" + useString
                
        text = text + "\n\n" + String(self.value) + " Gold Pieces"
	}
    
    func getShortInfo() -> String {
        var returnString = physicalCard.stringValue
        switch category {
        case "Headgear":
            returnString = returnString + " (H)"
        case "Armor":
            returnString = returnString + " (A)"
        case "Footgear":
            returnString = returnString + " (F)"
        default:break
        }
        return returnString
    }
}

