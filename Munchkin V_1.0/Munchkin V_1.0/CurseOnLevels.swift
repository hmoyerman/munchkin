//
//  Munchkin
//
//  Created by Henry Moyerman in summer 2016
//  Copyright © 2016 Henry Moyerman. All rights reserved.
//

import Foundation

class CurseOnLevels : Curse {
    
    var levelEffect:Int
    
    init(levelEffect: Int) {
        
        self.levelEffect = levelEffect
        
        super.init()
        var curseString = "Lose 2 Levels"
        if levelEffect == 1 { curseString = "Lose a Level" }
        
        physicalCard.stringValue = "Curse! " + curseString
    }
    
    convenience override init() { self.init(levelEffect:1) }
    
    override func execute(player: Player) -> Card {
        player.level -= levelEffect
        if player.level < levelEffect { player.level = 1 }
        return Card()
    }
}
