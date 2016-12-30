//
//  Munchkin
//
//  Created by Henry Moyerman in summer 2016
//  Copyright © 2016 Henry Moyerman. All rights reserved.
//

import Foundation
import Cocoa

class Card : NSObject {

	var text = ""
    var otherButtonTitle = ""
    var doorCard:Bool
    var value = 0
    var physicalCard:NSTextField = NSTextField(frame: NSMakeRect(0, 0, 60, 90))
    var naturalColor = NSColor()
    
    init(doorCard:Bool) {
        
        self.doorCard = doorCard
        
        physicalCard.hidden = true
        physicalCard.editable = false
        physicalCard.selectable = false
        physicalCard.alignment = NSCenterTextAlignment
//        physicalCard.backgroundColor = NSColor.brownColor()
        if doorCard { naturalColor = NSColor(red: 0.851, green: 0.639, blue: 0.435, alpha: 1) }
        else { naturalColor = NSColor(red: 0.671, green: 0.439, blue: 0.224, alpha: 1)}
        physicalCard.backgroundColor = naturalColor
        
        physicalCard.font = NSFont(name: (physicalCard.font?.fontName)!, size: 8)
    }
    
    convenience override init() {
        self.init(doorCard: false)
    }
    
    override var description : String {
        if self is Monster {
            let monsterCard = self as! Monster
            return "\"" + monsterCard.shortTitle + "\""
        } else if self is SingleUseItem {
            let oneUseCard = self as! SingleUseItem
            return "\"" + oneUseCard.shortTitle + "\""
        } else {
            return "\"" + physicalCard.stringValue + "\""
        }
    }
    
    
    
    func getDescription() -> String { return physicalCard.stringValue + "\n\n\n" + text }
    
    func sameTitle(card: Card) -> Bool {
        if physicalCard.stringValue == card.physicalCard.stringValue { return true }
        return false
    }
}

