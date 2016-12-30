//
//  Munchkin
//
//  Created by Henry Moyerman in summer 2016
//  Copyright © 2016 Henry Moyerman. All rights reserved.
//

import Foundation

class BadStuffOnLevels : BadStuff {
    
    var levelEffect:Int
    
    init(levelEffect: Int) {
        
        self.levelEffect = levelEffect
        
        super.init()
        
        var levelString = " levels"
        if levelEffect == 1 {levelString = " level" }
        
        self.badStuffDescription = "Bad Stuff: Lose " + String(levelEffect) + levelString
        self.badStuffPastAction = " lost " + String(levelEffect) + levelString
    }
    
    override func execute(player: Player) -> [Card] {
        player.level -= levelEffect
        if player.level < 1 { player.level = 1 }
        return [Card]()
    }
}