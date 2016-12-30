//
//  Munchkin
//
//  Created by Henry Moyerman in summer 2016
//  Copyright © 2016 Henry Moyerman. All rights reserved.
//

import Foundation

class Game : NSObject {
    
    var deck = [Deck]()
    var player = [Player]()
    var board = [Card]()
    var charityCollection = [Card]()
    var playerTurn = 0
    var numberOfPlayers = 4
    var turnCounter = 0
    var sellingTotal = -100
    var combatInProgress = false
    var lookingForTrouble = false
    var humanCanHarm = false
    var endTurnPossible = false
    var sellItem = false
    var gameWon = false
    var log:String
    var view:ViewController

    init(view: ViewController) {
        
        self.view = view
        
        // Inital welcome information and instructions
        
        log = "Game log" + "\n\n"
        
        super.init()
        
        turnCounter = numberOfPlayers
        
        createCardsAndDecks()
    }
    
    convenience override init() { self.init(view:ViewController()) }    
    
    
    func getCurrentPlayer() -> Player { return player[playerTurn] }
    
    func setPlayerNamesAndDealCards() {
        
        // Load new players
        
        for i in 1...4 {
            let newPlayer = Player(playerNumber: (i), view: view)
            player.append(newPlayer)
        }
        
        // Set the names of all players
        
        setRandomPlayerNames()
        player[0].playerName = "Henry"
        for i in 0...3 { newCardsForPlayer(player[i]) }
    }
    
    func setRandomPlayerNames() {
        
        // Pick three random names from this name bank
        
        var nameNumber = [Int]()
        for _ in 1...3 { nameNumber.append(Int(arc4random_uniform(25))) }
        while nameNumber[0] == nameNumber[1] { nameNumber[1] = Int(arc4random_uniform(25)) }
        while nameNumber[0] == nameNumber[2] || nameNumber[1] == nameNumber[2] { nameNumber[2] = Int(arc4random_uniform(25)) }
        let nameList = [
            
            "Frank",
            "Liz",
            "Audrey",
            "Bobby",
            "Emmet",
            "Abe",
            "Will",
            "Heather",
            "Eric",
            "Shelly",
            
            "Bev",
            "Paul",
            "Adam",
            "Daisy",
            "Sam",
            "Kylo",
            "Luke",
            "George",
            "David",
            "Conor",
            
            "Lia",
            "Zebulon",
            "Louis",
            "Mitch",
            "Emily"
        ]
        for (index, number) in nameNumber.enumerate() { player[index + 1].playerName  = nameList[number]}
    }
    
    func removeAllCards() {
        
        // Hides any cards on the board and any cards belonging to player 1; used to start a new game
        
        if !player.isEmpty {
            for card in board { card.physicalCard.hidden = true }
            for card in player[0].hand { card.physicalCard.hidden = true }
            for slot in player[0].itemSlot { for card in slot { card.physicalCard.hidden = true }}
        }
    }
    
    func checkDecks(){
        
        // Check if any non discard decks are empty, if so put discards into main deck and shuffle
        
        for var i in 0...1 {
            if i == 1 { i = 2 }
            for (index, card) in deck[i + 1].cards.enumerate().reverse() { if card.physicalCard.stringValue == "" { deck[i + 1].cards.removeAtIndex(index) }}
            if deck[i].cards.isEmpty {
                for card in deck[i + 1].cards { deck[i].cards.append(card) }
                deck[i + 1].cards.removeAll()
                deck[i].shuffleDeck()
                if i == 0 {
                    
                    // Normalize all Monster cards if refilling the Door deck
                    
                    for card in deck[i].cards { if card is Monster {
                        let monsterCard = card as! Monster
                        monsterCard.normalizeMonster()
                        }}
                }
            }
        }
    }
    
    func newCardsForPlayer(recipientPlayer: Player) {
        
        // Deal four door cards and four treasure cards to the player
        
        for _ in 1...4 {
            recipientPlayer.hand.append(deck[0].cards.last!)
            recipientPlayer.hand.append(deck[2].cards.last!)
            deck[0].cards.removeLast()
            deck[2].cards.removeLast()
            checkDecks()
        }
    }
    
    func checkEquipmentForAll() { for player in self.player { player.checkEquipment() }; checkCombatStrengthForAll() }
    
    func checkCombatStrengthForAll() { for player in self.player { player.checkCombatStrength() }}
    
    

    func curseFactory(curseFactoryType: String) -> Curse {
        
        if curseFactoryType == "1" || curseFactoryType == "2" { return CurseOnLevels(levelEffect: Int(curseFactoryType)!) }
        else if curseFactoryType == "Race" || curseFactoryType == "Class" { return CurseOnRacesAndClasses(curseType: curseFactoryType) }
        else { return CurseOnItems(curseType: curseFactoryType) }
    }
    
    
    
    func createCardsAndDecks() {
        
        // Create decks
        // Deck Reference:  Door Deck, Discards, Treasure Deck, Discards
        
        for i in 1...4 {
            var doorDeck = true
            var discard = false
            if i > 2 { doorDeck = false }
            if i % 2 == 0 { discard = true }
            let newDeck = Deck(doordeck: doorDeck, discard: discard)
            self.deck.append(newDeck)
        }
        
        
        // Load door deck
        
        self.deck[0].cards = [
            
            Dwarf(), Elf(), Halfling(), Cleric(), Warrior(), Wizard(),
            Dwarf(), Elf(), Halfling(), Cleric(), Warrior(), Wizard(),
            Dwarf(), Elf(), Halfling(), Cleric(), Warrior(), Wizard(),
            
            Monster(level: 1,  levelsGained: 1, rewardNumber: 1, undead: false, minPursueLevel: 1, badStuff: "1",     title: "Maul Rat"),
            Monster(level: 1,  levelsGained: 1, rewardNumber: 1, undead: false, minPursueLevel: 1, badStuff: "1",     title: "Potted Plant"),
            Monster(level: 1,  levelsGained: 1, rewardNumber: 1, undead: false, minPursueLevel: 1, badStuff: "1",     title: "Lame Goblin"),
            Monster(level: 1,  levelsGained: 1, rewardNumber: 1, undead: false, minPursueLevel: 1, badStuff: "1",     title: "Crabs"),
            Monster(level: 1,  levelsGained: 1, rewardNumber: 1, undead: false, minPursueLevel: 1, badStuff: "1",     title: "Drooling Slime"),
            Monster(level: 1,  levelsGained: 1, rewardNumber: 1, undead: false, minPursueLevel: 1, badStuff: "1",     title: "Course On Recursion"),
            Monster(level: 2,  levelsGained: 1, rewardNumber: 1, undead: false, minPursueLevel: 1, badStuff: "1",     title: "Gelatinous Octahedron"),
            Monster(level: 2,  levelsGained: 1, rewardNumber: 1, undead: false, minPursueLevel: 1, badStuff: "2",     title: "Pit Bull"),
            Monster(level: 2,  levelsGained: 1, rewardNumber: 1, undead: false, minPursueLevel: 1, badStuff: "1",     title: "Large Angry Chicken"),
            Monster(level: 2,  levelsGained: 1, rewardNumber: 1, undead: true,  minPursueLevel: 1, badStuff: "2",     title: "Mr. Bones"),
            Monster(level: 2,  levelsGained: 1, rewardNumber: 1, undead: false, minPursueLevel: 1, badStuff: "2",     title: "Flying Frogs"),
            Monster(level: 4,  levelsGained: 1, rewardNumber: 2, undead: false, minPursueLevel: 1, badStuff: "2",     title: "Leprechaun"),
            Monster(level: 4,  levelsGained: 1, rewardNumber: 2, undead: false, minPursueLevel: 1, badStuff: "2",     title: "Snails On Speed"),
            Monster(level: 4,  levelsGained: 1, rewardNumber: 2, undead: false, minPursueLevel: 1, badStuff: "2",     title: "Harpies"),
            Monster(level: 6,  levelsGained: 1, rewardNumber: 2, undead: true,  minPursueLevel: 1, badStuff: "2",     title: "Undead Horse"),
            Monster(level: 6,  levelsGained: 1, rewardNumber: 2, undead: false, minPursueLevel: 1, badStuff: "2",     title: "Shrieking Geek"),
            Monster(level: 6,  levelsGained: 1, rewardNumber: 2, undead: false, minPursueLevel: 1, badStuff: "2",     title: "Lawyers"),
            Monster(level: 6,  levelsGained: 1, rewardNumber: 2, undead: false, minPursueLevel: 1, badStuff: "hand",  title: "Platycore"),
            Monster(level: 6,  levelsGained: 1, rewardNumber: 2, undead: false, minPursueLevel: 1, badStuff: "hand",  title: "Pukachu"),
            Monster(level: 8,  levelsGained: 1, rewardNumber: 2, undead: false, minPursueLevel: 1, badStuff: "hand",  title: "Face Sucker"),
            Monster(level: 8,  levelsGained: 1, rewardNumber: 2, undead: false, minPursueLevel: 1, badStuff: "3",     title: "Gazebo"),
            Monster(level: 8,  levelsGained: 1, rewardNumber: 2, undead: false, minPursueLevel: 1, badStuff: "1",     title: "Ghoulfiends"),
            Monster(level: 10, levelsGained: 1, rewardNumber: 3, undead: false, minPursueLevel: 1, badStuff: "3",     title: "Floating Nose"),
            Monster(level: 10, levelsGained: 1, rewardNumber: 3, undead: false, minPursueLevel: 1, badStuff: "3",     title: "Net Troll"),
            Monster(level: 10, levelsGained: 1, rewardNumber: 3, undead: true,  minPursueLevel: 1, badStuff: "3",     title: "Internet Troll"),
            Monster(level: 10, levelsGained: 1, rewardNumber: 3, undead: false, minPursueLevel: 1, badStuff: "hand",  title: "3,872 Orcs"),
            Monster(level: 12, levelsGained: 1, rewardNumber: 3, undead: false, minPursueLevel: 1, badStuff: "3",     title: "Bigfoot"),
            Monster(level: 12, levelsGained: 1, rewardNumber: 3, undead: false, minPursueLevel: 1, badStuff: "3",     title: "Tongue Demon"),
            Monster(level: 12, levelsGained: 1, rewardNumber: 3, undead: false, minPursueLevel: 1, badStuff: "3",     title: "Wannabe Vampire"),
            Monster(level: 14, levelsGained: 1, rewardNumber: 4, undead: false, minPursueLevel: 1, badStuff: "death", title: "Stoned Golem"),
            Monster(level: 14, levelsGained: 1, rewardNumber: 4, undead: false, minPursueLevel: 1, badStuff: "death", title: "Insurance Salesman"),
            Monster(level: 14, levelsGained: 1, rewardNumber: 4, undead: false, minPursueLevel: 1, badStuff: "death", title: "Unspeakably Awful Indescribable Horor"),
            Monster(level: 16, levelsGained: 2, rewardNumber: 4, undead: false, minPursueLevel: 1, badStuff: "death", title: "Hippogriff"),
            Monster(level: 16, levelsGained: 2, rewardNumber: 4, undead: true,  minPursueLevel: 3, badStuff: "death", title: "Wight Brothers"),
            Monster(level: 16, levelsGained: 2, rewardNumber: 4, undead: true,  minPursueLevel: 3, badStuff: "death", title: "King Tut"),
            Monster(level: 18, levelsGained: 2, rewardNumber: 4, undead: false, minPursueLevel: 4, badStuff: "death", title: "Squidzilla"),
            Monster(level: 18, levelsGained: 2, rewardNumber: 5, undead: false, minPursueLevel: 4, badStuff: "death", title: "Bullrog"),
            Monster(level: 18, levelsGained: 2, rewardNumber: 5, undead: false, minPursueLevel: 5, badStuff: "death", title: "Plutonium Dragon"),
            
            MonsterModifier(modifierAmount: 5,  treasureEffect: 1,  title: "Intelligent +5 To Monster"),
            MonsterModifier(modifierAmount: 5,  treasureEffect: 1,  title: "Enraged +5 To Monster"),
            MonsterModifier(modifierAmount: 10, treasureEffect: 2,  title: "Humongous +10 To Monster"),
            MonsterModifier(modifierAmount: 10, treasureEffect: 2,  title: "Ancient +10 To Monster"),
            
            curseFactory("1"),
            curseFactory("1"),
            curseFactory("2"),
            curseFactory("Headgear"),
            curseFactory("Armor"),
            curseFactory("Footgear"),
            curseFactory("Race"),
            curseFactory("Class"),
            curseFactory("1"),
            curseFactory("1"),
            curseFactory("2"),
            curseFactory("Headgear"),
            curseFactory("Armor"),
            curseFactory("Footgear"),
            curseFactory("Race"),
            curseFactory("Class"),
        ]
        
        
        // Load treasure deck
        
        self.deck[2].cards = [
            
            Item(value: 2, bonus: 1, usableBy: "All",         category: "Headgear", title: "Helm of Courage"),
            Item(value: 4, bonus: 3, usableBy: "Dwarf",       category: "Headgear", title: "Bad-Ass Bandana"),
            Item(value: 4, bonus: 3, usableBy: "Wizard",      category: "Headgear", title: "Pointy Hat of Power"),
            Item(value: 6, bonus: 3, usableBy: "Elf",         category: "Headgear", title: "Horny Helmet"),
            Item(value: 4, bonus: 2, usableBy: "All",         category: "1 Hand",   title: "Bucker of Swashing"),
            Item(value: 4, bonus: 2, usableBy: "All",         category: "1 Hand",   title: "Sneaky Bastard Sword"),
            Item(value: 4, bonus: 3, usableBy: "Cleric",      category: "1 Hand",   title: "Cheese Grater of Peace"),
            Item(value: 4, bonus: 3, usableBy: "Halfling",    category: "1 Hand",   title: "Dagger of Treachery"),
            Item(value: 6, bonus: 3, usableBy: "Elf",         category: "1 Hand",   title: "Rapier of Unfairness"),
            Item(value: 6, bonus: 4, usableBy: "Dwarf",       category: "1 Hand",   title: "Hammer of Kneecapping"),
            Item(value: 6, bonus: 4, usableBy: "Cleric",      category: "1 Hand",   title: "Mace of Sharpness"),
            Item(value: 8, bonus: 5, usableBy: "Wizard",      category: "1 Hand",   title: "Staff of Napalm"),
            Item(value: 6, bonus: 4, usableBy: "Warrior",     category: "1 Hand",   title: "Shield of Ubiquity"),
            Item(value: 2, bonus: 1, usableBy: "All",         category: "2 Hands",  title: "Eleven-Foot Pole"),
            Item(value: 6, bonus: 3, usableBy: "All",         category: "2 Hands",  title: "Huge Rock"),
            Item(value: 6, bonus: 3, usableBy: "All",         category: "2 Hands",  title: "Chainsaw of Bloody Dismemberment"),
            Item(value: 6, bonus: 4, usableBy: "Elf",         category: "2 Hands",  title: "Bow With Ribbons"),
            Item(value: 6, bonus: 4, usableBy: "Halfling",    category: "2 Hands",  title: "Swiss Army Polearm"),
            Item(value: 2, bonus: 1, usableBy: "All",         category: "Armor",    title: "Slimy Armor"),
            Item(value: 2, bonus: 1, usableBy: "All",         category: "Armor",    title: "Leather Armor"),
            Item(value: 4, bonus: 2, usableBy: "All",         category: "Armor",    title: "Flaming Armor"),
            Item(value: 4, bonus: 3, usableBy: "Dwarf",       category: "Armor",    title: "Short Wide Armor"),
            Item(value: 6, bonus: 3, usableBy: "Warrior",     category: "Armor",    title: "Mithril Armor"),
            Item(value: 4, bonus: 2, usableBy: "All",         category: "Footgear", title: "Boots of Butt-Kicking"),
            Item(value: 4, bonus: 3, usableBy: "Warrior",     category: "Footgear", title: "Flip Flops of Intensity"),
            Item(value: 6, bonus: 3, usableBy: "All",         category: "Footgear", title: "Sneakers of Computer Science"),
            Item(value: 6, bonus: 3, usableBy: "Dwarf",       category: "Footgear", title: "Z-Coils of Height"),
            Item(value: 2, bonus: 1, usableBy: "All",         category: "None",     title: "Spiky Knees"),
            Item(value: 4, bonus: 2, usableBy: "Cleric",      category: "None",     title: "Singing and Dancing Sword"),
            Item(value: 6, bonus: 3, usableBy: "All",         category: "None",     title: "Really Impressive Title"),
            Item(value: 6, bonus: 3, usableBy: "Wizard",      category: "None",     title: "Pantyhose of Giant Strength"),
            Item(value: 4, bonus: 3, usableBy: "Halfling",    category: "None",     title: "Limburger and Anchovy Sandwich"),
            Item(value: 6, bonus: 4, usableBy: "Elf",         category: "None",     title: "Cloak of Obscurity"),
            Item(value: 4, bonus: 3, usableBy: "Halfling",    category: "None",     title: "Stepladder"),
            
            SingleUseItem(value: 1, eitherSideAmount: 2, title: "Potion of Idiotic Bravery"),
            SingleUseItem(value: 1, eitherSideAmount: 2, title: "Sleep Potion"),
            SingleUseItem(value: 2, eitherSideAmount: 2, title: "Nasty-Tasting Sports Drink"),
            SingleUseItem(value: 1, eitherSideAmount: 2, title: "Potion of Halitosis"),
            SingleUseItem(value: 1, eitherSideAmount: 2, title: "Yuppie Water"),
            SingleUseItem(value: 1, eitherSideAmount: 3, title: "Flaming Poison Potion"),
            SingleUseItem(value: 1, eitherSideAmount: 3, title: "Cotion of Ponfusion"),
            SingleUseItem(value: 1, eitherSideAmount: 3, title: "Freezing Explosive Potion"),
            SingleUseItem(value: 2, eitherSideAmount: 5, title: "Electric Radioactive Acid Potion"),
            SingleUseItem(value: 2, eitherSideAmount: 5, title: "Magic Missile"),
            SingleUseItem(value: 2, eitherSideAmount: 5, title: "Pretty Balloons"),
            
            LevelUpCard(title: "Boil an Anthill"),
            LevelUpCard(title: "Potion of General Studliness"),
            LevelUpCard(title: "Convenient Addition Error"),
            LevelUpCard(title: "Bribe GM With Food"),
            LevelUpCard(title: "Invoke Obscure Rules"),
            LevelUpCard(title: "1,000 Gold Pieces"),
            LevelUpCard(title: "The Software Engineer Endorses You"),
            LevelUpCard(title: "Gain a Master's Degree in CS"),
            
            OutToLunch(), InvisibilityPotion(), WishingRing(),
            OutToLunch(), InvisibilityPotion(), WishingRing(),
            OutToLunch(), InvisibilityPotion(), WishingRing(),
        ]
        
        
        self.deck[0].shuffleDeck()
        self.deck[2].shuffleDeck()
    }
}