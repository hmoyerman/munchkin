//
//  Munchkin
//
//  Created by Henry Moyerman in summer 2016
//  Copyright © 2016 Henry Moyerman. All rights reserved.
//

import Foundation

extension MutableCollectionType where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}



class Deck : NSObject {

	var doordeck:Bool
	var discard:Bool
    var cards:[Card] = [Card]()

	init(doordeck:Bool, discard:Bool) {

		self.doordeck = doordeck
		self.discard = discard

		super.init()
	}

    
    
	func shuffleDeck() { cards.shuffleInPlace() }
}

