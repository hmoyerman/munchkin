//
//  Munchkin
//
//  Created by Henry Moyerman in summer 2016
//  Copyright © 2016 Henry Moyerman. All rights reserved.
//

import Foundation

class BadStuff : NSObject {
    
    var badStuffDescription = ""
    var badStuffPastAction = ""
    
    override init() { super.init() }

    func execute(player: Player) -> [Card] {
        print("Bad Stuff Execution Error")
        return [Card]()
    }

}