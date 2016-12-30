//
//  Munchkin
//
//  Created by Henry Moyerman in summer 2016
//  Copyright © 2016 Henry Moyerman. All rights reserved.
//

import Foundation

class Curse : Card {
    
    init() {

        super.init(doorCard: true)
        
        otherButtonTitle = "Curse Someone"
    }

    

    func execute(player: Player) -> Card {
        print ("Curse Execution Error")
        return Card()
    }
}

