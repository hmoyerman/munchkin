//
//  Munchkin
//
//  Created by Henry Moyerman in summer 2016
//  Copyright © 2016 Henry Moyerman. All rights reserved.
//

import Foundation

class Player : NSObject {
    
    var playerName = "Henry"
    var level = 1
    var combatStrength = 1
    var classs:Classs? = nil
	var race:Race? = nil
    var itemSlot = [[Item](), [Item]()]
    var hand = [Card]()
    var playerNumber:Int
    var use2hand = false
    var preventLevelOneLosses:Bool
    var sellingStyle:Int
    var harmOthers:Bool
    var multiPlayStyle:Int
    var view:ViewController
    
    init(playerNumber:Int, view:ViewController) {
        
        self.playerNumber = playerNumber
        
        // Proven to be the best one player method
        self.preventLevelOneLosses = true
        self.sellingStyle = 3
        
        // Randomly select AI Multi Play Style and Priorities
        if Int(arc4random_uniform(2)) == 1 { self.harmOthers = false }
        else { self.harmOthers = true }
        self.multiPlayStyle = Int(arc4random_uniform(5))
        self.view = view
    }
    
    convenience override init() { self.init(playerNumber: -1, view:ViewController()) }
    
    
    
    override var description : String {
        return playerName + ", " + String(level) + ", " + String(combatStrength)
    }
    
    func getFullPlayerInfo() -> String {
        
        // Full information on a player for side bar
        
        var raceString = "None"
        var classString = "None"
        
        if race != nil { raceString = race!.physicalCard.stringValue }
        if classs != nil { classString = classs!.physicalCard.stringValue }
        
        var playerItems = "\n\n" + "Equipment:" + "\n"
        for item in itemSlot[0] { playerItems = playerItems + "\n" + item.getShortInfo() }
        
        playerItems = playerItems + "\n\n\n" + "Backpack:" + "\n"
        
        for item in itemSlot[1] { playerItems = playerItems + "\n" + item.getShortInfo() }
        
        return playerName + "\n\n" +
            "Combat Strength: " + String(combatStrength) + "\n" +
            "Level: " + String(level) + "\n\n" +
            "Race: " + raceString + "\n" +
            "Class: " + classString + "\n\n" +
            "Cards in Hand: " + String(hand.count) +
            playerItems
    }
    
    func getShortPlayerInfo() -> String {
        
    // Short information for top bar
        
        return playerName + "\n\n" +
            "Combat Strength: " + String(combatStrength) + "\n\n" +
            "Level: " + String(level)
    }
    
    func getAIInfoOnePlayer() -> String {
        
    // String representing the AI prefernces of a player
        
        var returnString = " using a \'"
        switch sellingStyle {
            case 0: returnString = returnString + "random"
            case 1: returnString = returnString + "never sell"
            case 2: returnString = returnString + "prioritze races and classes"
            case 3: returnString = returnString + "reasoned/Henry"
            default: returnString = returnString + "sell all"
        }
        
        returnString = returnString + "\' selling style and"
        
        if preventLevelOneLosses { returnString = returnString + " \'always\' using escape cards & charming" }
        else { returnString = returnString + " \'not\' using escape cards or charming when bad stuff is a level one loss" }
        return returnString
    }
    
    func getMultiPlayStyle() -> Int {
        
        // Returns a number from 0-9 to easily describe the muli play stype of an AI player
        
        var add = 0
        if harmOthers { add = 5 }
        return multiPlayStyle + add
    }
    
    func getMaxHandCount() -> Int { if race is Dwarf { return 6 } else { return 5 } }
    
    func getEffectiveCombatStrength() -> Int { if classs is Warrior { return combatStrength + 1 } else { return combatStrength } }
    
    func checkCombatStrength() {
        
        // Updates the combat strength of a player by adding their level and the bonus of any equipped items
        
        var tempCombatStrength = level
        for card in itemSlot[0] { tempCombatStrength += card.bonus }
        combatStrength = tempCombatStrength
    }
    
    func checkEquipment() {
        
        // Makes sure all items in equipment are permisable
        // If not, they are moved to the backpack
        
        for (index, card) in itemSlot[0].enumerate().reverse() {
            if !(isItemUsable(card, checkCategoory: false)) {
                itemSlot[1].append(card)
                itemSlot[0].removeAtIndex(index)
            }}
        
    }
    
    func isItemUsable(item: Item, checkCategoory: Bool) -> Bool {
        
        // Checks if a player can use the given item based on its restrictions
        
        let equipment = itemSlot[0]
        
        // Check item categories
        
        if checkCategoory {
            if item.category == "1 Hand" {
                var handcount = 0
                for card in equipment {
                    if card.category == "1 Hand" { handcount += 1 }
                    if card.category == "2 Hands" { handcount += 2 }
                }
                if handcount > 1 { return false }
            } else if item.category == "2 Hands" { for card in equipment { if card.category == "1 Hand" || card.category == "2 Hands" { return false }}}
            else { if item.category != "None" { for card in equipment { if card.category == item.category { return false }}}}
        }
        
        if item.usableBy != race?.physicalCard.stringValue && item.usableBy != classs?.physicalCard.stringValue
            && item.usableBy != "All" { return false }
        
        return true
    }
    
    func playerIsHuman() -> Bool { return ( playerNumber == 1 && !view.isAllAI() ) }

    
    
    
    // AI only methods
    
    // AI decisions
    
    func canHarm(difference: Int, player: Player) -> Bool {
        
        // If the combatant could win, use Monster Mods or 1 Use Items if you have them
        // Can also use Out To Lunches and Invisibility Potions
        
        
        // First check to see if a card (Monster Mod or 1 Use Item) could take a combat from the combatat having a higher combat strength
        // to the Monster having a higher level
        // If yes, move oon
        // If human, trigger popup allowing use of such a card
        // Else, If AI, combatant has a higher level, use Monster Modifier cards
        //       If AI, combatant has a higher level, and a Monster Mod card has not been used, and harmOthers is true for the player, use a single use item
        // (harmOthers refers to a global property concering AI strategy.  
        //  If false, players do not use 1 use items to harm others, leaving them instead to help themselves possibly in their own future combats)
        
        var couldHarm = false
        let combatMonster = view.getCombatMonster()
        let couldWinGame = player.level == 9 || (player.level == 8 && combatMonster.levelsGained == 2)
        var willUseMonsterMod = false
        var hadStopCard = false
        if difference >= 0 {
            for card in hand {
                if card is MonsterModifier {
                    hadStopCard = true
                    let monsterMod = card as! MonsterModifier
                    if difference - monsterMod.modifierAmount < 0 {
                        couldHarm = true
                        willUseMonsterMod = true
                    }
                }
                if card is SingleUseItem {
                    hadStopCard = true
                    let oneUseItem = card as! SingleUseItem
                    if difference - oneUseItem.eitherSideAmount < 0 {
                        couldHarm = true
                    }
                }
            }
        }
        var haveLunch = false
        var haveInvis = false
        
        var lunchIndex = -1
        var invisIndex = -1
        
        for (index, card) in hand.enumerate() { if card is OutToLunch {
            haveLunch = true
            hadStopCard = true
            lunchIndex = index
            }}
        for (index, card) in hand.enumerate() { if card is InvisibilityPotion {
            haveInvis = true
            hadStopCard = true
            invisIndex = index
            }}
        
        if couldWinGame && hadStopCard { couldHarm = true }
//        if playerIsHuman() && hadStopCard { couldHarm = true }
        if playerIsHuman() && couldHarm {
            view.askToHarm()
            return true
        }
        else if couldHarm {
            
            // AI GENERAL PRIORITY:  USE MONSTER MODS WHEN IT MAKES THE DIFFERENCE AND THE COMBATANT HAS A HIGHER LEVEL THAN THE AI PLAYER
            // AI GENERAL PRIORITY:  USE OUT TO LUNCH OR INVISIBILITY POTION IS ANOTHER WILL WIN
            

            if couldWinGame && haveLunch {
                view.discard(hand[lunchIndex])
                hand.removeAtIndex(lunchIndex)
                view.useOutToLunch(self)
                return true
            }
            else if couldWinGame && haveInvis {
                view.discard(hand[invisIndex])
                hand.removeAtIndex(invisIndex)
                view.useInvisibilityPotion(self)
                return true
            } else {
                if player.level > level {
                    if willUseMonsterMod {
                        for (index, card) in hand.enumerate() {
                            if card is MonsterModifier {
                                let monsterMod = card as! MonsterModifier
                                if couldWinGame {
                                    combatMonster.levelModifierAmount += monsterMod.modifierAmount
                                    combatMonster.rewardNumberModifierAmount += monsterMod.treasureEffect
                                    view.simpleAISendToCombat(index, player: self)
                                    break
                                }
                                else {
                                    if difference - monsterMod.modifierAmount < 0 {
                                        combatMonster.levelModifierAmount += monsterMod.modifierAmount
                                        combatMonster.rewardNumberModifierAmount += monsterMod.treasureEffect
                                        view.simpleAISendToCombat(index, player: self)
                                        break
                                    }
                                }
                                
                            }
                        }
                        // AI MULI PLAY COMPONENT: HARM OTHERS
                    } else if harmOthers || couldWinGame {
                        for (index, card) in hand.enumerate() {
                            if card is SingleUseItem {
                                let oneUseItem = card as! SingleUseItem
                                if couldWinGame {
                                    combatMonster.levelModifierAmount += oneUseItem.eitherSideAmount
                                    view.simpleAISendToCombat(index, player: self)
                                    break
                                }
                                else {
                                    if difference - oneUseItem.eitherSideAmount < 0 {
                                        combatMonster.levelModifierAmount += oneUseItem.eitherSideAmount
                                        view.simpleAISendToCombat(index, player: self)
                                        break
                                    }
                                }
                            }
                        }
                    }
                }
                
            }

        }
        return false
    }
    
    func willHelp(player: Player) -> Bool {
        
        // If player is human, ask for answer with method that calls a popup
        // Else, use logic based on player multi-Play-Style
        
        if playerIsHuman() { return view.humanWillHelp() }
        else {
            // AI MULTI PLAY COMPONENT:  WHEN TO HELP OTHERS
            if player.level == 9 { return false }
            let combatMonster = view.getCombatMonster()
            if player.level == 8 && combatMonster.levelsGained == 2 { return false }
            if player.level < 8 && race is Elf { return true }
            switch multiPlayStyle {
            case 1:
                return false
            case 2:
                if player.level >= level { return false }
            case 3:
                if player.level > 5 { return false }
            case 4:
                let randomRoll = Int(arc4random_uniform(2))
                if randomRoll == 1 { return false }
            default:break
            }
            return true
        }
    }
    
    func useWishingRing(curse: Curse) -> Bool {
        
        // Determines whether or not a Wishing Ring should be used to cancel a curse
        // AI GENERAL PRIORITY:  USE WISHING RING TO CANCEL A CURSE WHEN THE EFFECTS YOU, ALWAYS

        
        if curse is CurseOnLevels && level > 1 { return true }
        if curse is CurseOnItems {
            let curseItem = curse as! CurseOnItems
            for card in itemSlot[0] { if curseItem.curseType == card.category { return true }}
        }
        if curse is CurseOnRacesAndClasses {
            let curseRaceClass = curse as! CurseOnRacesAndClasses
            if curseRaceClass.curseType == "Race" && race != nil { return true }
            if curseRaceClass.curseType == "Class" && classs != nil { return true }
        }
        return false
    }
    
    func shouldLookForTrouble() -> Bool {
        
        // Determines whether or not to look for trouble
        
        var adjustmentPossible = 0
        
        for card in hand { if card is SingleUseItem {
            let cardSingleUse = card as! SingleUseItem
            adjustmentPossible += cardSingleUse.eitherSideAmount
        }}
        
        if classs is Warrior { adjustmentPossible += 1 }
        
        var monsterMinLevel = 100
        
        for card in hand {
            if card is Monster {
                let possibleMonster = card as! Monster
                var monsterLevel = possibleMonster.level
                if classs is Cleric { monsterLevel -= 5 }
                if  monsterMinLevel > monsterLevel {
                    monsterMinLevel = possibleMonster.level
                }
            }
        }
        
        // AI GENERAL PRIORITY:  LOOK FOR TROUBLE IF YOUR LOWEST MONSTER HAS A LEVEL BELOW YOUR COMBAT STRENGTH COMBINED WITH YOUR 1 USE ITEMS, -3


        
        if monsterMinLevel < ((adjustmentPossible + getEffectiveCombatStrength()) - 3 ) { return true }
        
        return false
    }
    
    func pickTroubleMonster() -> Monster {
        
         // Return the Monster with the lowest level
        
        var monsterMinLevel = 100
        var bestMonsterIndex = -1
        
        for (index, card) in hand.enumerate() {
            if card is Monster {
                let possibleMonster = card as! Monster
                var monsterLevel = possibleMonster.level
                if classs is Cleric { monsterLevel -= 5 }
                if  monsterMinLevel > monsterLevel {
                    monsterMinLevel = possibleMonster.level
                    bestMonsterIndex = index
                }
            }
        }
        let sendMonster = hand[bestMonsterIndex] as! Monster
        hand.removeAtIndex(bestMonsterIndex)
        
        return sendMonster
    }
    
    func shouldCharm(combatMonster: Monster) -> Bool {
        
        // Determines whether or not to charm a monster
        // AI GENERAL PRIORITY:  IF YOU ARE A WIZARD AND THE BAD STUFF OF A MONSTER WILL EFFECT YOU, CHARM THE MONSTER

        
        if combatMonster.badStuff is BadStuffOnLevels {
            let badLevel = combatMonster.badStuff as! BadStuffOnLevels
            if badLevel.levelEffect == 1 && !preventLevelOneLosses { return false }
            if level == 1 { return false }
        }
        return true
    }
    
    
    // AI combat decisions and logic
    
    func aICombat(skipHarm: Bool) {
        
        // Decide what choices to make in combat
        
        let combatMonster = view.getCombatMonster()
        var stopAction = false
        
        // If a round of letting other players harm the AI player has already occured, skip the round
        if !skipHarm { if combatMonster.levelAfterModifiers() < getEffectiveCombatStrength() { stopAction = view.letOthersHarmCombat() }}
        
        if !stopAction {
            
            // If defeat if possible, defeat the monster
            
            if combatMonster.levelAfterModifiers() < getEffectiveCombatStrength()  { view.defeatMonster() }
                
            else {
                
                // Find the maximum possible combat adjust given the Single Use Items in hand
                
                var adjustmentPossible = 0
                for card in hand { if card is SingleUseItem {
                    let cardSingleUse = card as! SingleUseItem
                    adjustmentPossible += cardSingleUse.eitherSideAmount
                    }}
                
                // If using Single Use Items can accomplish defeat, use them
                // Else if, ask all other players if they will help to defeat the monster
                // Else, check for Out For Lunches and Invisiblity Potions (use them if you have them, else try to escape)
                
                if combatMonster.levelAfterModifiers() < (adjustmentPossible + getEffectiveCombatStrength() ) {
                    for (index, card) in hand.enumerate().reverse() { if card is SingleUseItem {
                        if combatMonster.levelAfterModifiers() >= getEffectiveCombatStrength() {
                            let cardSingleUse = card as! SingleUseItem
                            combatMonster.levelModifierAmount -= cardSingleUse.eitherSideAmount
                            view.simpleAISendToCombat(index, player: self)
                        }}}
                    aICombat(false)
                } else {
                    var helpPlayer = Player()
                    for player in view.getListOfPlayersOrderedByLevelASC() {
                        
                        // Level must be below 9, cannot ask for help from a level 9 elf the other player must have a high enough
                        // combat strength to allow you to win, and you cannot ask for help being level 8 if the monster rewards 2 levels
                        
                        if level < 9 && ( player.playerNumber != playerNumber ) && !( player.level == 9 && player.race is Elf ) &&
                            !( combatMonster.levelAfterModifiers() >= ( getEffectiveCombatStrength() + player.getEffectiveCombatStrength() ) ) &&
                                !( combatMonster.levelsGained == 2 && level == 8) {
                            if player.willHelp(self) {
                                helpPlayer = player
                                break
                            }
                        }
                    }
                    
                    if helpPlayer.playerNumber != -1 {
                        view.addToGameLog(helpPlayer.playerName + " will help " + playerName)
                        view.defeatMonsterWithHelp(helpPlayer)
                    } else {
                        var haveLunch = false
                        var haveInvis = false
                        var useEscapeCard = true
                        
                        var lunchIndex = -1
                        var invisIndex = -1
                        
                        if combatMonster.badStuff is BadStuffOnLevels {
                            let badLevel = combatMonster.badStuff as! BadStuffOnLevels
                            if badLevel.levelEffect == 1 && !preventLevelOneLosses { useEscapeCard = false }
                        }
                        for (index, card) in hand.enumerate() { if card is OutToLunch {
                            haveLunch = true
                            lunchIndex = index
                            }}
                        for (index, card) in hand.enumerate() { if card is InvisibilityPotion {
                            haveInvis = true
                            invisIndex = index
                            }}
                        if useEscapeCard && haveLunch {
                            view.discard(hand[lunchIndex])
                            hand.removeAtIndex(lunchIndex)
                            view.useOutToLunch(self)
                        }
                        else if useEscapeCard && haveInvis {
                            view.discard(hand[invisIndex])
                            hand.removeAtIndex(invisIndex)
                            view.useInvisibilityPotion(self)
                        }
                        else { view.tryToEscape() }
                    }
                }
            }
        }
        
    }
    
    
    
    // AI methods for arraning cards at the begining and the end of a player's turn
    
    func arrangeCards() -> String {
        
        // First use all of your curses
        
        cursePass()
        
        
        // Arrange item cards optimally given the availible races and classes in a player has
        // Use any level up cards if you are not level 9
        
        var returnString = ""
        
        for (index, card) in hand.enumerate().reverse() { if card is LevelUpCard { if level < 9 {
            level += 1
            view.discard(hand[index])
            hand.removeAtIndex(index)
            returnString = returnString + playerName + " has used a Level Up card" + "\n\n"
            }}}
        
        
        // Put all cards in backpack, equip cards with no category
        
        for card in itemSlot[0] {
            itemSlot[1].append(card)
            itemSlot[0].removeAll()
        }
        for (index, card) in hand.enumerate().reverse() { if card is Item {
            let cardAsItem = card as! Item
            itemSlot[1].append(cardAsItem)
            hand.removeAtIndex(index)
            }}
        for (index, card) in itemSlot[1].enumerate().reverse() {
            if card.usableBy == "All" && card.category == "None" {
                itemSlot[0].append(card)
                itemSlot[1].removeAtIndex(index)
            }
        }
        
        
        // Collect all possible races and classes from the hand and from what is currently being used
        
        var raceOptions = [Race]()
        if race != nil { raceOptions.append(race!) }
        for card in hand { if card is Race {
            let raceCard = card as! Race
            raceOptions.append(raceCard)
            }}
        var classOptions = [Classs]()
        if classs != nil { classOptions.append(classs!) }
        for card in hand { if card is Classs {
            let classCard = card as! Classs
            classOptions.append(classCard)
            }}
        
        
        // If only one race or class is availible, and it is not being used, use that race or class
        
        if raceOptions.count == 1 { if race == nil { for (index, card) in hand.enumerate().reverse() { if card is Race {
            let raceCard = card as! Race
            race = raceCard
            returnString = returnString + newRace()
            hand.removeAtIndex(index)
            break
            }}}}
        if classOptions.count == 1 { if classs == nil { for (index, card) in hand.enumerate().reverse() { if card is Classs {
            let classCard = card as! Classs
            classs = classCard
            returnString = returnString + newClass()
            hand.removeAtIndex(index)
            break
            }}}}
        
        
        // Find the best possible combination of races and classes
        
        var maxScore = 0
        var bestRace = "None"
        var bestClass = "None"
        
        if raceOptions.count < 2 && classOptions.count < 2 {
            var racePos = "None"
            if race != nil { racePos = (race?.physicalCard.stringValue)! }
            var classPos = "None"
            if classs != nil { classPos = (classs?.physicalCard.stringValue)! }
            let tempScore = findArrangmentScore(racePos, classPos: classPos)
            if maxScore < tempScore {
                maxScore = tempScore
                bestRace = racePos
                bestClass = classPos
            }
            
        } else if raceOptions.count < 2 {
            var racePos = "None"
            if race != nil { racePos = (race?.physicalCard.stringValue)! }
            for classPos in classOptions {
                let tempScore = findArrangmentScore(racePos, classPos: classPos.physicalCard.stringValue)
                if maxScore < tempScore {
                    maxScore = tempScore
                    bestRace = racePos
                    bestClass = classPos.physicalCard.stringValue
                }
            }
        } else if classOptions.count < 2 {
            var classPos = "None"
            if classs != nil { classPos = (classs?.physicalCard.stringValue)! }
            for racePos in raceOptions {
                let tempScore = findArrangmentScore(racePos.physicalCard.stringValue, classPos: classPos)
                if maxScore < tempScore {
                    maxScore = tempScore
                    bestRace = racePos.physicalCard.stringValue
                    bestClass = classPos
                }
            }
        } else {
            for classPos in classOptions { for racePos in raceOptions {
                let tempScore = findArrangmentScore(racePos.physicalCard.stringValue, classPos: classPos.physicalCard.stringValue)
                if maxScore < tempScore {
                    maxScore = tempScore
                    bestRace = racePos.physicalCard.stringValue
                    bestClass = classPos.physicalCard.stringValue
                }
                }}
        }
        
        
        // Set race and class according to what was determined to be the best (yeild the highest combat strength with items in possesion)
        
        if bestRace != "None" && bestRace != race?.physicalCard.stringValue { for (index, card) in hand.enumerate() { if card is Race {
            if bestRace == card.physicalCard.stringValue {
                if race != nil { hand.append(race!) }
                let raceCard = card as! Race
                race = raceCard
                returnString = returnString + newRace()
                hand.removeAtIndex(index)
                break
            }}}
            
        }
        
        if bestClass != "None" && bestClass != classs?.physicalCard.stringValue { for (index, card) in hand.enumerate() { if card is Classs {
            if bestRace == card.physicalCard.stringValue {
                if classs != nil { hand.append(classs!) }
                let classCard = card as! Classs
                classs = classCard
                returnString = returnString + newClass()
                hand.removeAtIndex(index)
                break
            }}}
            
        }
        
        setCards()
        return returnString
    }
    
    func newRace() -> String { return playerName + " updated their race to: " + (race?.physicalCard.stringValue)! + "\n\n" }
    func newClass() -> String { return playerName + " updated their class to: " + (classs?.physicalCard.stringValue)! + "\n\n" }
    
    func setCards() {
        
        // After setting races and classes, equip the cards with the highest bonus for each category
        
        setMaxCategory("Headgear")
        setMaxCategory("Armor")
        setMaxCategory("Footgear")
        setMaxHand()
    }
    
    func setMaxCategory(category: String) {
        
        // Given a category, equip the item with the highest bonus
        
        var maxItem = 0
        var maxindex = -1
        for (index, item) in itemSlot[1].enumerate().reverse() { if item.category == category {
            if item.usableBy == "All" || item.usableBy == race?.physicalCard.stringValue || item.usableBy == classs?.physicalCard.stringValue {
                if maxItem < item.bonus {
                    maxItem = item.bonus
                    maxindex = index
                }}}}
        if maxindex > -1 {
            itemSlot[0].append(itemSlot[1][maxindex])
            itemSlot[1].removeAtIndex(maxindex)
        }
    }
    
    func setMaxHand() {
        
        // Equip the 2-hand item with the highest bonus, or two 1-hand items
        
        if use2hand {
            setMaxCategory("2 Hands")
        } else {
            for _ in 1...2 { setMaxCategory("1 Hand") }
        }
    }
    
    func findArrangmentScore(racePos: String, classPos: String) -> Int {
        
        // Given a potential race and class, find the highest possible combat strength
        
        var maxPotential = 0
        maxPotential += findMaxCategoryValue("Headgear", racePos: racePos, classPos: classPos)
        maxPotential += findMaxCategoryValue("Armor", racePos: racePos, classPos: classPos)
        maxPotential += findMaxCategoryValue("Footgear", racePos: racePos, classPos: classPos)
        maxPotential += findMaxHandValue(racePos, classPos: classPos)
        return maxPotential
    }
    
    func findMaxCategoryValue(category: String,racePos: String, classPos: String) -> Int {
        
        // Given a category, find the item with the highest bonus, return the bonus
        
        var maxItem = 0
        for item in itemSlot[1] { if item.category == category {
            if item.usableBy == "All" || item.usableBy == racePos || item.usableBy == classPos { if maxItem < item.bonus {
                maxItem = item.bonus
                }}}}
        return maxItem
    }
    
    func findMaxHandValue(racePos: String, classPos: String) -> Int {
        
        // Find the bonus given for using the 2-card item with the highest or bonus, or using the two 1-hand items with the highest bonus
        
        var max1hand = [Int]()
        var max2Hand = 0
        for item in itemSlot[1] { if item.category == "1 Hand" {
            if item.usableBy == "All" || item.usableBy == racePos || item.usableBy == classPos { max1hand.append(item.bonus) }}}
        var max1Handtotal = 0
        if max1hand.count < 3 { for num in max1hand { max1Handtotal += num }}
        else {
            max1Handtotal += max1hand.maxElement()!
            for (index, num) in max1hand.enumerate() { if num == max1hand.maxElement()! {
                max1hand.removeAtIndex(index)
                break
                }}
            max1Handtotal += max1hand.maxElement()!
        }
        for item in itemSlot[1] { if item.category == "2 Hands" {
            if item.usableBy == "All" || item.usableBy == racePos || item.usableBy == classPos { if max2Hand < item.bonus {
                max2Hand = item.bonus
                }}}}
        if max1Handtotal > max2Hand {
            use2hand = false
            return max1Handtotal
        }
        use2hand = true
        return max2Hand
    }
    
    func findBackpackValue() -> Int {
        
        // Return the value of all of the cards in the backpack to inform potential selling
        
        var totalValue = 0
        for item in itemSlot[1] { totalValue += item.value }
        if race is Halfling {
            var maxItemValue = 0
            for item in itemSlot[1] { if maxItemValue < maxItemValue { maxItemValue = item.value }}
            totalValue += maxItemValue
        }
        return totalValue
    }
    
    func findTotalValue() -> Int {
        
        // Return the value of all of the cards in the backpack to inform potential selling
        
        var totalValue = 0
        for item in itemSlot[1] { totalValue += item.value }
        for card in hand { totalValue += card.value }
        if race is Halfling {
            var maxItemValue = 0
            for item in itemSlot[1] { if maxItemValue < maxItemValue { maxItemValue = item.value }}
            for card in itemSlot[1] { if maxItemValue < maxItemValue { maxItemValue = card.value }}
            totalValue += maxItemValue
        }
        return totalValue
    }
    
    func arrangeAndEndTurn(game: Game) -> String {
        
        // Called at the end of a turn.  Selling method is called based on AI selling prefernce
        // Methods arrange item cards and possibly do some selling.  Cards are given to charity if neccesary
        
        var selltype = sellingStyle
        if sellingStyle == 0 { selltype = Int(arc4random_uniform(2)) }
        
        switch selltype {
        case 1: return neverSellBasic(game)
        case 2: return neverSellprioritzeRacesAndClasses(game)
        case 3: return sellReasoned(game)
        default: return sellAll(game)
        }
        
    }
    
    func neverSellBasic(game: Game) -> String {
        
        // Items get arranged optimally, but never sold
        
        let returnString = arrangeCards()
        
        basicCharity(game)
        
        return returnString
    }
    
    func neverSellprioritzeRacesAndClasses(game: Game) -> String {
        
        let returnString = arrangeCards()
        
        // Items get arranged optimally, but never sold.  Also, Race and Classes are kept in hand often
        // This leads to the maximum possible item card arrangments
        
        giveCardTypeToCharity(game, type: CurseOnLevels())
        giveCardTypeToCharity(game, type: CurseOnItems())
        giveCardTypeToCharity(game, type: CurseOnRacesAndClasses())
        giveCardTypeToCharity(game, type: MonsterModifier())
        giveCardTypeToCharity(game, type: Monster())
        giveCardTypeToCharity(game, type: SingleUseItem())
        
        for (index, card) in hand.enumerate().reverse() { if hand.count > getMaxHandCount() {
            game.charityCollection.append(card)
            hand.removeAtIndex(index)}}
        
        return returnString
    }
    
    func sellReasoned(game: Game) -> String {
        
        // Items get arranged optimally, then a reasoned selling of items in the backpack is done
        // This is the creators preferred method
        
        var returnString = arrangeCards()
        
        returnString = returnString + basicSell(game)
        
        basicCharity(game)
        
        return returnString
    }
    
    func sellAll(game: Game) -> String {
        
        // This is like a greedy algorithm.  Whatever can be sold to go up a level, is sold
        // Afterward, the few reamining item cards are arranged optimally
        
        var returnString = ""
        
        // This method works best when playing as a Halfling
        // Being that race is top prioirty
        
        if !(race is Halfling) { for (index, card) in hand.enumerate() { if card is Halfling {
            if race != nil { hand.append(race!)}
            race = Halfling()
            hand.removeAtIndex(index)
            returnString = returnString + newRace()
            break
            }}}
        
        
        // Place all item cards in backpack
        
        for card in itemSlot[0] {
            itemSlot[1].append(card)
            itemSlot[0].removeAll()
        }
        for (index, card) in hand.enumerate().reverse() { if card is Item {
            let cardAsItem = card as! Item
            itemSlot[1].append(cardAsItem)
            hand.removeAtIndex(index)
            }}
        
        
        // Find given all item cards and cards in hand, the number of levels that can be gained through sale
        
        var levelPotential = findTotalValue() / 1000
        let levelsUntilNine = 9 - level
        if levelPotential > levelsUntilNine { levelPotential = levelsUntilNine }
        
        
        var sellString = ""
        
        
        // If levels can be gained, sell
        
        if levelPotential > 0 {
            
            // First sell the most valueble item.  It counts as double if the player is a Halfling
            
            var maxInHand = false
            var saleTotal = 0
            var maxItemValue = 0
            var maxIndex = -1
            
            for (index, item) in itemSlot[1].enumerate().reverse() { if maxItemValue < item.value {
                maxItemValue = item.value
                maxIndex = index
                }}
            for (index, card) in hand.enumerate().reverse() { if maxItemValue < card.value {
                maxItemValue = card.value
                maxIndex = index
                maxInHand = true
                }}
            
            var maxCardString = ""
            
            if maxInHand {
                saleTotal += hand[maxIndex].value
                maxCardString = String(hand[maxIndex])
                game.deck[3].cards.append(hand[maxIndex])
                hand.removeAtIndex(maxIndex)
            }
            else  {
                saleTotal += itemSlot[1][maxIndex].value
                maxCardString = String(itemSlot[1][maxIndex])
                game.deck[3].cards.append(itemSlot[1][maxIndex])
                itemSlot[1].removeAtIndex(maxIndex)
            }
            
            if race is Halfling { saleTotal *= 2 }
            
            sellString = sellString + (playerName + " has sold " + maxCardString + " worth " +
                String(saleTotal) + "\n\n")
            
            while saleTotal < levelPotential * 1000 {
                
                // Sell remaining items, starting with the least valuable
                // Once all item cards all sold, move onto to other valuable cards in the hand
                
                var minItemValue = 2000
                var minIndex = -1
                if itemSlot[1].isEmpty{
                    for (index, card) in hand.enumerate().reverse() { if minItemValue > card.value && card.value > 0 {
                        minItemValue = card.value
                        minIndex = index
                        }}
                    if minItemValue != 2000 {
                        saleTotal += hand[minIndex].value
                        game.deck[3].cards.append(hand[minIndex])
                        sellString = sellString + (playerName + " has sold " + String(hand[minIndex]) + " worth " +
                            String(hand[minIndex].value) + "\n\n")
                        hand.removeAtIndex(minIndex)
                    }
                    
                } else{
                    for (index, item) in itemSlot[1].enumerate().reverse() { if minItemValue > item.value {
                        minItemValue = item.value
                        minIndex = index
                        }}
                    saleTotal += itemSlot[1][minIndex].value
                    game.deck[3].cards.append(itemSlot[1][minIndex])
                    sellString = sellString + (playerName + " has sold " + String(itemSlot[1][minIndex]) + " worth " +
                        String(itemSlot[1][minIndex].value) + "\n\n")
                    itemSlot[1].removeAtIndex(minIndex)
                }
            }
            
            // Gain levels from the sale
            
            for _ in 1...levelPotential {
                level += 1
                returnString = returnString + (playerName + " has gained a level" + "\n\n") + sellString
            }
        }
        
        basicCharity(game)
        
        return returnString + arrangeCards()
    }
    
    func basicCharity(game: Game) {
        
        // Default series of card preferences when giving to charity
        
        giveCardTypeToCharity(game, type: CurseOnLevels())
        giveCardTypeToCharity(game, type: CurseOnItems())
        giveCardTypeToCharity(game, type: CurseOnRacesAndClasses())
        giveCardTypeToCharity(game, type: MonsterModifier())
        giveCardTypeToCharity(game, type: Monster())
        giveCardTypeToCharity(game, type: Halfling())
        giveCardTypeToCharity(game, type: Elf())
        giveCardTypeToCharity(game, type: Wizard())
        giveCardTypeToCharity(game, type: Warrior())
        giveCardTypeToCharity(game, type: Dwarf())
        giveCardTypeToCharity(game, type: Cleric())
        
        for (index, card) in hand.enumerate().reverse() { if hand.count > getMaxHandCount() {
            game.charityCollection.append(card)
            hand.removeAtIndex(index)}}
    }
    
    func basicSell(game: Game) -> String {
        
        // If the total backpack value is over 999, sell cards to gain a level
        
        var returnString = ""
        
        if level < 9 {
            
            var sellString = ""
            
            if findBackpackValue() >= 1000 {
                
                // First sell the most valueble item.  It counts as double if the player is a Halfling
                
                var saleTotal = 0
                var maxItemValue = 0
                var maxIndex = -1
                
                for (index, item) in itemSlot[1].enumerate().reverse() { if maxItemValue < item.value {
                    maxItemValue = item.value
                    maxIndex = index
                    }}
                
                saleTotal += itemSlot[1][maxIndex].value
                game.deck[3].cards.append(itemSlot[1][maxIndex])
                
                if race is Halfling { saleTotal *= 2 }
                
                sellString = sellString + (playerName + " has sold " + String(itemSlot[1][maxIndex]) + " worth " +
                    String(saleTotal) + "\n\n")
                itemSlot[1].removeAtIndex(maxIndex)
                
                while saleTotal < 1000 {
                    
                    // Sell remaining items, starting with the least valuable until the total is at least 1000
                    
                    var minItemValue = 2000
                    var minIndex = -1
                    
                    for (index, item) in itemSlot[1].enumerate().reverse() { if minItemValue > item.value {
                        minItemValue = item.value
                        minIndex = index
                        }}
                    
                    saleTotal += itemSlot[1][minIndex].value
                    game.deck[3].cards.append(itemSlot[1][minIndex])
                    sellString = sellString + (playerName + " has sold " + String(itemSlot[1][minIndex]) + " worth " +
                        String(itemSlot[1][minIndex].value) + "\n\n")
                    itemSlot[1].removeAtIndex(minIndex)
                }
                
                
                // Gain a level from the sale ofat least 1000 gold pieces
                
                if saleTotal >= 1000 {
                    level += 1
                    returnString = returnString + (playerName + " has gained a level" + "\n\n") + sellString
                }
            }
        }
        
        return returnString
    }
    
    func giveCardTypeToCharity(game: Game, type: AnyObject!) {
        
        // Send cards to the charity to collection if they match the given class
        
        for (index, card) in hand.enumerate().reverse() { if object_getClass(card) == object_getClass(type) { if hand.count > getMaxHandCount() {
            if type is Monster {
                let potMonster = card as! Monster
                if potMonster.level >= getEffectiveCombatStrength() {
                    game.charityCollection.append(card)
                    hand.removeAtIndex(index)}
            } else {
                game.charityCollection.append(card)
                hand.removeAtIndex(index)}}}
        }
    }
    
    func cursePass() {
        
        // Uses all curses on the highest level player, if useful
        
        for (index, card) in hand.enumerate().reverse() {
            if card is CurseOnLevels {
                let curse = card as! CurseOnLevels
                curseLevelsBest(curse)
                hand.removeAtIndex(index)
            } else if card is CurseOnItems {
                let curse = card as! CurseOnItems
                curseItemsBest(curse)
                hand.removeAtIndex(index)
            } else if card is CurseOnRacesAndClasses {
                let curse = card as! CurseOnRacesAndClasses
                curseRaceClassBest(curse)
                hand.removeAtIndex(index)
            }
        }
    }
    
    func curseLevelsBest(curse: CurseOnLevels) {
        
        // If a Curse effects levels, get a list of players ordered by level in descending order
        // Remove yourself from the list
        // Remove players from the list who are level 1
        // If players remain, curse the one with the highest level
        
        var playerList = view.getListOfPlayersOrderedByLevelDSC()
        for (index, player) in playerList.enumerate().reverse() { if player.playerNumber == self.playerNumber { playerList.removeAtIndex(index) }}
        for (index, player) in playerList.enumerate().reverse() { if player.level == 1 { playerList.removeAtIndex(index) }}
        if !(playerList.isEmpty) { cursePlayer(curse, player: playerList[0]) }
    }
    
    func curseItemsBest(curse: CurseOnItems) {
        
        // If a Curse effects Items, get a list of players ordered by level in descending order
        // Remove yourself from the list
        // Remove players from the list who do not have the item that the curse effects
        // If players remain, curse the one with the highest level
        
        var playerList = view.getListOfPlayersOrderedByLevelDSC()
        for (index, player) in playerList.enumerate().reverse() { if player.playerNumber == self.playerNumber { playerList.removeAtIndex(index) }}
        for (index, player) in playerList.enumerate().reverse() {
            var hasItem = false
            for item in player.itemSlot[0] { if item.category == curse.curseType { hasItem = true }}
            if !hasItem { playerList.removeAtIndex(index)}
        }
        if !(playerList.isEmpty) { cursePlayer(curse, player: playerList[0]) }
    }
    
    func curseRaceClassBest(curse: CurseOnRacesAndClasses) {
        
        // If a Curse effects Races or Classes, get a list of players ordered by level in descending order
        // Remove yourself from the list
        // Remove players from the list who do not have Races or Classes (depending on which the curse effects)
        // If players remain, curse the one with the highest level
        
        var playerList = view.getListOfPlayersOrderedByLevelDSC()
        for (index, player) in playerList.enumerate().reverse() { if player.playerNumber == self.playerNumber { playerList.removeAtIndex(index) }}
        if curse.curseType == "Race" { for (index, player) in playerList.enumerate().reverse() { if player.race == nil { playerList.removeAtIndex(index) }}}
        else { for (index, player) in playerList.enumerate().reverse() { if player.classs == nil { playerList.removeAtIndex(index) }}}
        if !(playerList.isEmpty) { cursePlayer(curse, player: playerList[0]) }
    }
    
    func cursePlayer(curse: Curse, player: Player) {
        
        // Execute a curse
        
        view.addToGameLog(self.playerName + " would like to curse " + player.playerName + " with " + String(curse))
        view.cursePlayer(curse, player: player)
    }
    
}

