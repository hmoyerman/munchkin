//
//  Munchkin
//
//  Created by Henry Moyerman in summer 2016
//  Copyright © 2016 Henry Moyerman. All rights reserved.
//

import Foundation

class Monster : Card {
    
    var level:Int
    var levelModifierAmount = 0
	var levelsGained:Int
    var rewardNumber:Int
    var rewardNumberModifierAmount = 0
	var undead:Bool
    var shortTitle:String
    var minPursueLevel = 1
    var badStuff = BadStuff()

    init(level:Int, levelsGained:Int, rewardNumber:Int, undead:Bool, minPursueLevel:Int, badStuff:String, title:String) {

		self.level = level
		self.levelsGained = levelsGained
        self.rewardNumber = rewardNumber
		self.undead = undead
        self.minPursueLevel = minPursueLevel
        shortTitle = title

		super.init(doorCard: true)
        
        physicalCard.stringValue = title + "\n\n" + "Level " + String(level)
        
        self.badStuff = badStuffFactory(badStuff)
        
        var t = " Treasures"
        if rewardNumber == 1 { t = " Treasure" }
        
        text = "Levels gained: " + String(levelsGained) + "\n\n" + String(rewardNumber) + t
        
        text = text + "\n\n" + self.badStuff.badStuffDescription
        
        if minPursueLevel > 1 { text = text + "\n\n" + "Will not pursue anyone below Level " + String(minPursueLevel) }
        
        if undead { text = text + "\n\n" + "Undead" }

        otherButtonTitle = "Fight This Monster"
	}
    
    convenience init() { self.init(level:1, levelsGained:1, rewardNumber:1, undead:false, minPursueLevel:1, badStuff:"1", title:"") }
    
    func badStuffFactory(badStuffType: String) -> BadStuff {
        
        if badStuffType == "death" { return BadStuffDeath() }
        else if badStuffType == "hand" { return BadStuffOnHand() }
        else { return BadStuffOnLevels(levelEffect: Int(badStuffType)!) }
    }

    func levelAfterModifiers() -> Int { return level + levelModifierAmount }
    
    func rewardAfterModifiers() -> Int {
        let fullReward = rewardNumber + rewardNumberModifierAmount
        if fullReward == 0 { return 1}
        else { return fullReward }
    }
    
    func normalizeMonster() {
        levelModifierAmount = 0
        rewardNumberModifierAmount = 0
    }
}