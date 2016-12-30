//
//  Munchkin
//
//  Created by Henry Moyerman in summer 2016
//  Copyright © 2016 Henry Moyerman. All rights reserved.
//

import Cocoa
import AVKit
import AVFoundation

extension String { var length: Int { return characters.count }}

class ViewController: NSViewController {
    
    struct access { static var game = Game() }
    
    struct selections {
        
        static var selectedPlayer = Player()
        static var selectedCard = Card()
        static var selectedCardColumn = 2
        static var selectedCardSlot = 0
    }
    
    struct gUIElements {
        
        static let screenWidth:CGFloat = 1200
        static let screenHeight:CGFloat = 600
        static var playerInfoBox = [NSTextField]()
        static var cardBox = [NSTextField]()
        static var gameLogBox = NSTextView()
        static var gameLogBoxScroll = NSScrollView()
        static var selectedCardInfo = NSTextView()
        static var button = [NSButton]()
        static var playerInFocus = false
        static var showOutcome = false
        static var outcomeText = ""
        static var playerOneName = "Henry"
    }
    
    struct cancelAlerts {
        
        static var masterAlert = true
        static var arrangeBeg = true
        static var combat = true
        static var pickMonster = true
        static var arrangeEnd = true
        static var charity = true
        static var sell = true
        static var harm = true
    }
    
    struct aiTests {
        
        // THIS IS WHERE VARIABLES ARE SET FOR ALL AI GAMES AND TRIALS
        
        // =============================
        static var allAI = false
        static var numberOfTrials = 10000
        // =============================
        
        static var trialCounter = 0
        static var winningNumberOfTurns = [Int]()
        static var averageOtherPlayerLevels = [Double]()
        static var winnerType = [Int]()
        static var playerOccurance = [Int](count: 10, repeatedValue: 0)
    }

    

    override func viewDidLoad(){
        
        super.viewDidLoad()
        
        // Set up methods and alerts for the begining of the game
        
        createGUI()
        
        if !isAllAI() {
            NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0.01), target: self, selector: #selector(ViewController.startAlerts), userInfo: nil, repeats: false)
        } else { newGame() }
        
        
        
    }

    func startAlerts() {
        
        // Show alerts for when the app launches
        
//        tutorial()
        
        let alertsPopup: NSAlert = NSAlert()
        alertsPopup.messageText = "Would you like instructions along the way to help you with different parts of the game?"
        alertsPopup.addButtonWithTitle("No")
        alertsPopup.addButtonWithTitle("Yes")
        let runAlertsPopup = alertsPopup.runModal()
        if runAlertsPopup == NSAlertFirstButtonReturn { cancelAlerts.masterAlert = false }

        newGame()
    }
    
    func tutorial() {
        var text = "Welcome to Munchkin!"
        basicAlert(text)
        
        let firstPopup: NSAlert = NSAlert()
        firstPopup.messageText = "Would you like a short tutorial about the game interface?"
        firstPopup.addButtonWithTitle("No")
        firstPopup.addButtonWithTitle("Yes")
        let runFirstPopup = firstPopup.runModal()
        if runFirstPopup == NSAlertSecondButtonReturn {
            
            // Step by step walkthrough of the User Interface
            
            let tempHand = [
                LevelUpCard(title: "Potion of General Studliness"),
                Item(value: 6, bonus: 3, usableBy: "All", category: "Footgear", title: "Sneakers of Computer Science"),
                InvisibilityPotion(),
                SingleUseItem(value: 1, eitherSideAmount: 2, title: "Potion of Idiotic Bravery"),
                Monster(level: 1,  levelsGained: 1, rewardNumber: 1, undead: false, minPursueLevel: 1, badStuff: "1", title: "Course On Recursion"),
                MonsterModifier(modifierAmount: 10, treasureEffect: 2,  title: "Humongous +10 To Monster")
            ]
            
            let tempEquipment = [
                Item(value: 4, bonus: 3, usableBy: "Dwarf",       category: "Headgear", title: "Bad-Ass Bandana"),
                Item(value: 6, bonus: 3, usableBy: "All",         category: "2 Hands",  title: "Chainsaw of Bloody Dismemberment"),
                Item(value: 4, bonus: 3, usableBy: "Dwarf",       category: "Armor",    title: "Short Wide Armor"),
                Item(value: 6, bonus: 3, usableBy: "All",         category: "None",     title: "Really Impressive Title")
            ]
            
            let tempBackpack = [
                Item(value: 4, bonus: 3, usableBy: "Wizard",      category: "Headgear", title: "Pointy Hat of Power"),
                Item(value: 8, bonus: 5, usableBy: "Wizard",      category: "1 Hand",   title: "Staff of Napalm"),
                Item(value: 4, bonus: 3, usableBy: "Warrior",     category: "Footgear", title: "Flip Flops of Intensity")
            ]
            
            let cardRef = Card()
            let cardWidth = cardRef.physicalCard.frame.width
            let cardHeight = cardRef.physicalCard.frame.height
            let heightInterval:CGFloat = (1 / 6) * gUIElements.screenHeight
            let padding:CGFloat = 5
            let leftPadding:CGFloat = gUIElements.gameLogBox.frame.width + padding
            let cardWidthPlusPadding:CGFloat = cardRef.physicalCard.frame.width + padding
            
            for (index, card) in tempHand.enumerate() {
                view.addSubview(card.physicalCard)
                let xPos = CGFloat(leftPadding + (CGFloat(index) * cardWidthPlusPadding))
                card.physicalCard.frame = NSMakeRect(xPos, (0 * heightInterval) + padding, cardWidth, cardHeight)
                card.physicalCard.hidden = false
                card.physicalCard.backgroundColor = card.naturalColor
            }
            tempHand[1].physicalCard.backgroundColor = NSColor.grayColor()
            
            gUIElements.selectedCardInfo.backgroundColor = NSColor.yellowColor()
            gUIElements.selectedCardInfo.string = tempHand[1].getDescription()
            text = "To view card descriptions, click on the desired card and its description will appear on the left.  "
            basicAlert(text)
            
            
            for i in 5...8 { gUIElements.button[i].hidden = false }
            text = "All possible actions for that card will be represented by buttons in the bottom left corner.  "
            basicAlert(text)
            for i in 5...8 { gUIElements.button[i].hidden = true }
            gUIElements.selectedCardInfo.backgroundColor = NSColor.brownColor()
            gUIElements.selectedCardInfo.string = ""
            for card in tempHand { card.physicalCard.hidden = true }
            
            
            gUIElements.playerInfoBox[2].backgroundColor = NSColor.yellowColor()
            let tempPlayer = Player()
            tempPlayer.level = 7
            tempPlayer.combatStrength = 19
            gUIElements.playerInfoBox[2].stringValue = tempPlayer.getShortPlayerInfo()
            text = "To view more information about a player, click on their info box on the top of the window.  " + "\n\n"
            basicAlert(text)
            gUIElements.playerInfoBox[2].backgroundColor = NSColor(red: 0.6, green: 0.8, blue: 0.6, alpha: 1)
            gUIElements.playerInfoBox[2].stringValue = ""
            
            
            gUIElements.gameLogBox.backgroundColor = NSColor.yellowColor()
            gUIElements.gameLogBox.string = "Henry kicked open a door Revealing: \"Bigfoot\"" + "\n\n"
                + "Henry updated their race to: \"Dwarf\"" + "\n\n"
                + "Henry started turn *9*" + "\n\n"
                + "Henry" + "\n\n"
                + "Combat Strength: 19" + "\n\n"
                + "Level: 7" + "\n\n\n"
                + "===========" + "\n\n\n"
                + "Game log"
            text = "Information about what is happening and has happened in the game is available on the right in the Game Log.  " + "\n\n"
            basicAlert(text)
            gUIElements.gameLogBox.backgroundColor = NSColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1)
            gUIElements.gameLogBox.string = ""
            
            
            
            for (index, card) in tempEquipment.enumerate() {
                view.addSubview(card.physicalCard)
                let xPos = CGFloat(leftPadding + (CGFloat(index) * cardWidthPlusPadding))
                card.physicalCard.frame = NSMakeRect(xPos, ((2 - CGFloat(0)) * heightInterval) + padding, cardWidth, cardHeight)
                card.physicalCard.hidden = false
                card.physicalCard.backgroundColor = card.naturalColor
            }
            gUIElements.cardBox[1].backgroundColor = NSColor.yellowColor()
            text = "Equipped Items help you increase your combat strength.  "  + "\n\n"
            "Your combat strength is your level plus all of the bonuses from your equipped items"
            basicAlert(text)
            gUIElements.cardBox[1].backgroundColor = NSColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1)
            for card in tempEquipment { card.physicalCard.hidden = true }
            
            
            
            for (index, card) in tempBackpack.enumerate() {
                view.addSubview(card.physicalCard)
                let xPos = CGFloat(leftPadding + (CGFloat(index) * cardWidthPlusPadding))
                card.physicalCard.frame = NSMakeRect(xPos, ((2 - CGFloat(1)) * heightInterval) + padding, cardWidth, cardHeight)
                card.physicalCard.hidden = false
                card.physicalCard.backgroundColor = card.naturalColor
            }
            gUIElements.cardBox[2].backgroundColor = NSColor.yellowColor()
            text = "Your Backpack is a great place to store Items that are not equipped"
            basicAlert(text)
            gUIElements.cardBox[2].backgroundColor = NSColor(red: 0.8, green: 0.4, blue: 0.4, alpha: 1)
            for card in tempBackpack { card.physicalCard.hidden = true }
            
            
            
            text = "Game rules can be found in the menu bar above under \'File\'.  " + "\n\n"
                + "A new game can be started at any time from the menu bar under \'File\'.  " + "\n\n"
                + "For more information on Races and Classes, select \'Info\' in the menu bar.  " + "\n\n"
                + "Have fun, and good luck!!"
            basicAlert(text)
            
            
        }
    }



    // Setup methods

    func createGUI() {
        
        // Create and adjust grahpic boxes for card areas
        
        for i in 0...3 {
            var heightMult:CGFloat = 6
            if i == 0 { heightMult = 3 }
            
            let newTextBox = NSTextField(frame:
                NSMakeRect( ((2.5 / 12) * gUIElements.screenWidth), (gUIElements.screenHeight / 6) * CGFloat(3-i),
                    (7 / 12) * gUIElements.screenWidth, gUIElements.screenHeight / heightMult))
            
            newTextBox.alignment = NSRightTextAlignment
            textBoxAdjustAndAdd(newTextBox)
            gUIElements.cardBox.append(newTextBox)
        }
        
        
        // Create and adjust grahpic boxes for player information
        
        for i in 0...3 {
            let newTextBox = NSTextField(frame:
                NSMakeRect( ((1.75 / 12) * gUIElements.screenWidth * CGFloat(i)) + ((2.5 / 12) * gUIElements.screenWidth),
                    (5 / 6) * gUIElements.screenHeight,
                    (1.75 / 12) * gUIElements.screenWidth, (1 / 6) * gUIElements.screenHeight))
            
            textBoxAdjustAndAdd(newTextBox)
            if i % 2 == 0 { newTextBox.backgroundColor = NSColor(red: 0.6, green: 0.8, blue: 0.6, alpha: 1) }
            else {  newTextBox.backgroundColor = NSColor(red: 0.4, green: 0.6, blue: 0.4, alpha: 1) }
            newTextBox.font = NSFont(name: (newTextBox.font?.fontName)!, size: 16)
            gUIElements.playerInfoBox.append(newTextBox)
        }
        
        
        // Create and adjust grahpic boxes for other text boxes on sides
        
        gUIElements.selectedCardInfo = NSTextView(frame:
            NSMakeRect(0, 0, (2.5 / 12) * gUIElements.screenWidth, gUIElements.screenHeight))
        gUIElements.gameLogBox = NSTextView(frame:
            NSMakeRect( ((9.5 / 12) * gUIElements.screenWidth), 0,
                (2.5 / 12) * gUIElements.screenWidth, gUIElements.screenHeight))
        gUIElements.selectedCardInfo.editable = false
        gUIElements.selectedCardInfo.selectable = false
        gUIElements.gameLogBox.editable = false
//        gUIElements.gameLogBox.selectable = false
        gUIElements.selectedCardInfo.font = NSFont(name: (gUIElements.selectedCardInfo.font?.fontName)!, size: 18)
        gUIElements.gameLogBox.font = NSFont(name: (gUIElements.gameLogBox.font?.fontName)!, size: 18)
        gUIElements.selectedCardInfo.backgroundColor = NSColor.brownColor()
        gUIElements.gameLogBox.backgroundColor = NSColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1)
        gUIElements.selectedCardInfo.textContainerInset = NSMakeSize(15, 45)
        gUIElements.gameLogBox.textContainerInset = NSMakeSize(15, 45)
        view.addSubview(gUIElements.selectedCardInfo)

        
        // Allow game log to Scroll
        
        gUIElements.gameLogBoxScroll = NSScrollView(frame: gUIElements.gameLogBox.frame)
        view.addSubview(gUIElements.gameLogBoxScroll)
        gUIElements.gameLogBoxScroll.documentView = gUIElements.gameLogBox
        gUIElements.gameLogBoxScroll.hasVerticalScroller = true
        
        
        // Set colors and labels of card boxes
        
        gUIElements.cardBox[3].backgroundColor = NSColor(red: 0.6, green: 0.2, blue: 0.2, alpha: 1)
        gUIElements.cardBox[2].backgroundColor = NSColor(red: 0.8, green: 0.4, blue: 0.4, alpha: 1)
        gUIElements.cardBox[1].backgroundColor = NSColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1)
        gUIElements.cardBox[0].backgroundColor = NSColor(red: 0.2, green: 0.4, blue: 0.4, alpha: 1)
        
        gUIElements.cardBox[3].stringValue = "Hand"
        gUIElements.cardBox[2].stringValue = "Backpack"
        gUIElements.cardBox[1].stringValue = "Equipment"
        gUIElements.cardBox[0].stringValue = "Combat"
        
        
        // Create buttons
        
        let buttonPadding = 5
        let buttonWidth = Int(gUIElements.gameLogBox.frame.width) - (buttonPadding * 2)
        let buttonHeight = 20
        
        for _ in 0...11 {
            let button = NSButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight))
            button.target = self
            button.hidden = true
            button.action = #selector(ViewController.buttonAction(_:))
            gUIElements.button.append(button)
            self.view.addSubview(button)
        }
        
        
        // Set positions for buttons
        
        gUIElements.button[0].frame =
            CGRect(x: Int(gUIElements.gameLogBox.frame.width) + Int(gUIElements.cardBox[0].frame.width) + buttonPadding,
                   y: buttonPadding, width: buttonWidth - 15, height: buttonHeight)
        
        for i in 1...4 {
            gUIElements.button[i].frame = CGRect(
                x: (Int(gUIElements.gameLogBox.frame.width) + buttonPadding),
                y: (Int(gUIElements.screenHeight) - (Int(gUIElements.playerInfoBox[0].frame.height) +
                    (i * (buttonHeight + buttonPadding)) ) ),
                width: buttonWidth, height: buttonHeight)
        }
        
        for i in 5...8 {
            gUIElements.button[i].frame = CGRect(
                x: (buttonPadding),
                y: (buttonPadding +
                    ((8 - i) * (buttonHeight + buttonPadding)) ),
                width: buttonWidth, height: buttonHeight)
        }
        
        for i in 9...11 {
            gUIElements.button[i].frame = CGRect(
                x: (Int(gUIElements.gameLogBox.frame.width) + Int(gUIElements.cardBox[0].frame.width) - buttonWidth - buttonPadding),
                y: ( (Int(gUIElements.cardBox[3].frame.height) * 3) + buttonPadding +
                    ((11 - i) * (buttonHeight + buttonPadding)) ),
                width: buttonWidth, height: buttonHeight)
        }
        
        
        // Set titles for buttons
        
        gUIElements.button[0].title = "View Game Log"
        gUIElements.button[1].title = "Kick Open The Door"
//        gUIElements.button[2].title = "Trade"
        gUIElements.button[3].title = "Sell"
        gUIElements.button[4].title = "End Turn"
        gUIElements.button[5].title = "Use In This Combat"
        gUIElements.button[6].title = "Move to Equipment"
        gUIElements.button[7].title = "Move to Backpack"
        gUIElements.button[8].title = "Give to Charity"
        gUIElements.button[9].title = "Ask For Help"
        gUIElements.button[10].title = "Try to Escape"
        gUIElements.button[11].title = "Defeat The Monster"
    }
    
    func textBoxAdjustAndAdd(currentTextField: NSTextField) -> NSTextField {
        
        currentTextField.editable = false
        currentTextField.selectable = false
        currentTextField.bordered = false
        view.addSubview(currentTextField)
        return currentTextField
    }
    
    func newGame() {
        
        access.game.removeAllCards()
        access.game = Game(view: self)
        
        // Add all cards to view
        
        for card in access.game.deck[0].cards { view.addSubview(card.physicalCard) }
        for card in access.game.deck[2].cards { view.addSubview(card.physicalCard) }
        
        // Normalize selections and buttons
        
        for button in gUIElements.button { button.hidden = true }
        
        access.game.setPlayerNamesAndDealCards()
        selections.selectedCard = access.game.player[0].hand[0]
        selections.selectedPlayer = access.game.player[0]
        selections.selectedCardColumn = 2
        selections.selectedCardSlot = 0
        
        // Ask the user for their name
        
        if humanTurn() {
            var username = getStringFromUser("Please Enter Your Name\n(Up to 11 Characters)", defaultValue: gUIElements.playerOneName)
            let letters = NSCharacterSet.letterCharacterSet()
            
            for (index, uni) in username.unicodeScalars.enumerate().reverse() {
                if !letters.longCharacterIsMember(uni.value) {
                    let newIndex = username.startIndex.advancedBy(index)
                    username.removeAtIndex(newIndex)
                }
            }
            
            if username.length > 11 {
                let indexEndOfText = username.startIndex.advancedBy(11)
                username = username.substringToIndex(indexEndOfText)
            }
            access.game.player[0].playerName = username
            gUIElements.playerOneName = username
        }
        
        for i in 1...3 { if access.game.player[0].playerName == access.game.player[i].playerName { access.game.player[i].playerName = "Ole" }}
        updateGraphics()
        
        // Good spot for adding test code to alter games
        
//        let newCards = [
//            OutToLunch(), OutToLunch(), OutToLunch(),
//            Monster(level: 1,  levelsGained: 1, rewardNumber: 1, undead: false, minPursueLevel: 1, badStuff: "1",     title: "Potted Plant"),
//            Monster(level: 1,  levelsGained: 1, rewardNumber: 1, undead: false, minPursueLevel: 1, badStuff: "1",     title: "Potted Plant"),
//            Monster(level: 1,  levelsGained: 1, rewardNumber: 1, undead: false, minPursueLevel: 1, badStuff: "1",     title: "Potted Plant"),
//            SingleUseItem(value: 1, eitherSideAmount: 2, title: "Potion of Idiotic Bravery"),
//            SingleUseItem(value: 1, eitherSideAmount: 2, title: "Potion of Idiotic Bravery"),
//            SingleUseItem(value: 1, eitherSideAmount: 2, title: "Potion of Idiotic Bravery")
//        ]
//        for card in newCards { view.addSubview(card.physicalCard)}
//        access.game.player[0].hand.removeAll()
//        for i in 0...2 { access.game.player[i].hand.append(newCards[i]) }
//        for i in 3...5 { access.game.deck[0].cards.append(newCards[i]) }
//        for i in 6...8 { access.game.player[0].hand.append(newCards[i]) }
//
//        access.game.player[3].level = 9
//        access.game.player[3].combatStrength = 9
//        
//        access.game.playerTurn = 3
        
        // Start Game

        
        startTurn()
    }
    
    func getStringFromUser(title: String, defaultValue: String) -> String {
        let msg = NSAlert()
        msg.addButtonWithTitle("OK")
        msg.messageText = title
        
        let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        txt.stringValue = defaultValue
        
        msg.accessoryView = txt
        let response: NSModalResponse = msg.runModal()
        
        if (response == NSAlertFirstButtonReturn) {
            return txt.stringValue
        } else {
            return ""
        }
    }
    
    
    
    // Button and Menu methods
    
    func buttonAction(sender: NSButton!) {
        
        // Method for all buttons
        
        switch (sender){
        case(gUIElements.button[0]):
            backToGameLog()
        case(gUIElements.button[1]):
            kickOpenDoor()
//        case(gUIElements.button[2]):
//            trade()
        case(gUIElements.button[3]):
            if sender.title == "Sell" { sellItems() }
            else { doneSelling() }
        case(gUIElements.button[4]):
            endTurn()
        case(gUIElements.button[5]):
            moveToOtherPressed()
        case(gUIElements.button[6]):
            moveItem(0)
        case(gUIElements.button[7]):
            moveItem(1)
        case(gUIElements.button[8]):
            if sender.title == "Give to Charity" { sendCardToCharity() }
            else { sellSelectedItem() }
        case(gUIElements.button[9]):
            askForHelp()
        case(gUIElements.button[10]):
            tryToEscape()
        case(gUIElements.button[11]):
            defeatMonster()
        default:
            print("Button Error")
        }
    }
    
    func moveToOtherPressed() {
        
        // Moves non-items to various locations
        
        switch (selections.selectedCard){
        case(is Race):
            setRaceOrClass()
        case(is Classs):
            setRaceOrClass()
        case(is Monster):
            troubleMonsterPicked()
        case(is LevelUpCard):
            access.game.player[0].level += 1
            access.game.checkCombatStrengthForAll()
            removeSelectedCard(true)
            addToGameLog(currentPlayerName() + " has used a Level Up card")
        case(is Curse):
            let curseCard = selections.selectedCard as! Curse
            curseSomeone(curseCard)
        case(is OutToLunch):
            gUIElements.showOutcome = false
            useOutToLunch(access.game.player[0])
        case(is InvisibilityPotion):
            gUIElements.showOutcome = false
            useInvisibilityPotion(access.game.player[0])
        default: // For Monster Modifiers and Single Use Items
            sendToCombat()
        }

        updateGraphics()
    }
    
    func setRaceOrClass() {
        
        // Sets Races or Class of a player
        
        if selections.selectedCard is Race {
            if access.game.player[0].race != nil {
                access.game.player[0].hand.append(access.game.player[0].race!)
            }
            access.game.player[0].race = (selections.selectedCard as! Race)
            addToGameLog(currentPlayerName() + " updated their race to: " + String(selections.selectedCard))
        } else {
            if access.game.player[0].classs != nil {
                access.game.player[0].hand.append(access.game.player[0].classs!)
            }
            access.game.player[0].classs = (selections.selectedCard as! Classs)
            addToGameLog(currentPlayerName() + " updated their class to: " + String(selections.selectedCard))
        }
        removeSelectedCard(false)
        access.game.checkEquipmentForAll()
    }
    
    func sendToCombat() {
        
        // Various procedures for sending a card into combat
        
        let combatMonster = getCombatMonster()
        
        access.game.board.append(selections.selectedCard)
        if selections.selectedCard is MonsterModifier {
            let monsterMod = selections.selectedCard as! MonsterModifier
            combatMonster.levelModifierAmount += monsterMod.modifierAmount
            combatMonster.rewardNumberModifierAmount += monsterMod.treasureEffect
            
        } else { // Single Use Item
            let oneUseItem = selections.selectedCard as! SingleUseItem
            if humanTurn() { combatMonster.levelModifierAmount -= oneUseItem.eitherSideAmount }
            else { combatMonster.levelModifierAmount += oneUseItem.eitherSideAmount }
        }
        addToGameLog(access.game.player[0].playerName + " used " + String(selections.selectedCard) + " in combat")
        removeSelectedCard(false)
        selections.selectedCardSlot = access.game.board.count - 1
        
        combatLog()
        if !humanTurn() {
            letOnlyAIHarm()
            if access.game.combatInProgress { currentPlayer().aICombat(false) }
        }
        else { if combatMonster.levelAfterModifiers() < currentPlayer().getEffectiveCombatStrength() { letOthersHarmCombat() }}
    }
    
    func moveItem(id: Int) {
        
        // Dictates the movement of Item cards betwen the hand, backpack, and equipment

        if id == 2 { access.game.player[0].hand.append(selections.selectedCard) }
        else { access.game.player[0].itemSlot[id].append(selections.selectedCard as! Item) }
        
        if selections.selectedCardColumn == 2 { access.game.player[0].hand.removeAtIndex(selections.selectedCardSlot) }
        else { access.game.player[0].itemSlot[selections.selectedCardColumn].removeAtIndex(selections.selectedCardSlot) }
        
        if id == 2 { selections.selectedCardSlot = access.game.player[0].hand.count - 1 }
        else {  selections.selectedCardSlot = access.game.player[0].itemSlot[id].count - 1 }
        
        selections.selectedCardColumn = id

        access.game.checkCombatStrengthForAll()
        if access.game.combatInProgress { combatLog() }
        updateGraphics()
    }
    
    func menuItemPressed(sender: AnyObject) {
        
        // Provides information on races and clasees selected from the menu
        
        let item = sender as! NSMenuItem
        let id = item.tag
        var alertText = ""
        
        switch (id) {
        case (2):
            newGameFromMenu()
        case (3):
            if let pdfURL = NSBundle.mainBundle().URLForResource("Rules", withExtension: "pdf") { NSWorkspace.sharedWorkspace().openURL(pdfURL) }
        case (4):
            if let pdfURL = NSBundle.mainBundle().URLForResource("Tutorial", withExtension: "pdf") { NSWorkspace.sharedWorkspace().openURL(pdfURL) }
        case (7):
            alertText = Dwarf().getDescription()
        case (8):
            alertText = Elf().getDescription()
        case (9):
            alertText = Halfling().getDescription()
        case (11):
            alertText = Cleric().getDescription()
        case (13):
            alertText = Warrior().getDescription()
        case (14):
            alertText = Wizard().getDescription()
        default:
            print(id)
        }
        
        if id > 4 {
            gUIElements.playerInFocus = false
            replacegameLogBox(alertText)
        }
    }
    
    func newGameFromMenu() {
        
        // If 'New Game' is selected from the menu, gives the user the option to start a new game
        
        let newGamePopup: NSAlert = NSAlert()
        normalScroll()
        newGamePopup.messageText = "Are you sure you want to start a new game?"
        newGamePopup.addButtonWithTitle("Yes")
        newGamePopup.addButtonWithTitle("No")
        let runnewGamePopup = newGamePopup.runModal()
        if runnewGamePopup == NSAlertFirstButtonReturn { newGame() }
    }
    
    
    
    // Graphic updates
    
    func updateGraphics() {
        
        // Update player top bar info, selected player, and card information
        
        for (index, box) in gUIElements.playerInfoBox.enumerate() { box.stringValue = access.game.player[index].getShortPlayerInfo() }
        if gUIElements.button[0].hidden { gUIElements.gameLogBox.string = access.game.log }
        gUIElements.selectedCardInfo.string = selections.selectedCard.getDescription()
        
        for i in 0...3 {
            if i % 2 == 0 { gUIElements.playerInfoBox[i].backgroundColor = NSColor(red: 0.6, green: 0.8, blue: 0.6, alpha: 1) }
            else { gUIElements.playerInfoBox[i].backgroundColor = NSColor(red: 0.4, green: 0.6, blue: 0.4, alpha: 1) }
        }
        gUIElements.playerInfoBox[currentPlayer().playerNumber - 1].backgroundColor =  NSColor(red: 0.9, green: 0.9, blue: 0.1, alpha: 1)

        
        // Update Player 1 hand, backpack, and equipment
        

        let cardRef = Card()
        let cardWidth = cardRef.physicalCard.frame.width
        let cardHeight = cardRef.physicalCard.frame.height
        let heightInterval:CGFloat = (1 / 6) * gUIElements.screenHeight
        let padding:CGFloat = 5
        let leftPadding:CGFloat = gUIElements.gameLogBox.frame.width + padding
        let cardWidthPlusPadding:CGFloat = cardRef.physicalCard.frame.width + padding
        
        for (index, card) in access.game.board.enumerate() {
            let xPos = CGFloat(leftPadding + (CGFloat(index) * cardWidthPlusPadding))
            card.physicalCard.frame = NSMakeRect(xPos, (4 * heightInterval) + padding, cardWidth, cardHeight)
            card.physicalCard.hidden = false
            card.physicalCard.backgroundColor = card.naturalColor
        }
        
        if !isAllAI() {
            for i in 0...1 {
                for (index, card) in access.game.player[0].itemSlot[i].enumerate() {
                    let xPos = CGFloat(leftPadding + (CGFloat(index) * cardWidthPlusPadding))
                    card.physicalCard.frame = NSMakeRect(xPos, ((2 - CGFloat(i)) * heightInterval) + padding, cardWidth, cardHeight)
                    card.physicalCard.hidden = false
                    card.physicalCard.backgroundColor = card.naturalColor
                }
            }
            
            for (index, card) in access.game.player[0].hand.enumerate() {
                if index < 10 {
                    let xPos = CGFloat(leftPadding + (CGFloat(index) * cardWidthPlusPadding))
                    card.physicalCard.frame = NSMakeRect(xPos, (0 * heightInterval) + padding, cardWidth, cardHeight)
                    card.physicalCard.hidden = false
                    card.physicalCard.backgroundColor = card.naturalColor
                } else { card.physicalCard.hidden = true }
            }
            
            
            // Update color of cards, including seleced card
            
            let newColor = NSColor.grayColor()
            
            if selections.selectedCardSlot > -1 {
                if selections.selectedCardColumn == -1 { access.game.board[selections.selectedCardSlot].physicalCard.backgroundColor = newColor }
                else if selections.selectedCardColumn == 2 { access.game.player[0].hand[selections.selectedCardSlot].physicalCard.backgroundColor = newColor }
                else { access.game.player[0].itemSlot[selections.selectedCardColumn][selections.selectedCardSlot].physicalCard.backgroundColor = newColor }
            }
        }
        
        // Hide Other Cards
        
        for deck in access.game.deck { for card in deck.cards { card.physicalCard.hidden = true }}
        for player in access.game.player {
            if player.race != nil { player.race?.physicalCard.hidden = true }
            if player.classs != nil { player.classs?.physicalCard.hidden = true }
            if player.playerNumber != 1 {
                for slot in player.itemSlot { for item in slot { item.physicalCard.hidden = true }}
                for card in player.hand { card.physicalCard.hidden = true }
            }
        }
        
        

        

        
        
        // Update all buttons to reflect possible actions at current place in a turn
        
        if access.game.humanCanHarm {
            if selections.selectedCard is MonsterModifier || selections.selectedCard is SingleUseItem ||
            selections.selectedCard is OutToLunch || selections.selectedCard is InvisibilityPotion
            { onlyShowOtherButtonForCard() }
            else { hideAllButtonsForCard() }
        }
        
        if humanTurn() {
            
            // Update buttons to relfect possible actions of selected card
            
            var freezeOptions = false
            if access.game.combatInProgress || access.game.lookingForTrouble { freezeOptions = true }
            
            switch (selections.selectedCard) {
            case (is Race):
                if freezeOptions { hideAllButtonsForCard() }
                else { onlyShowOtherButtonForCard() }
                if currentPlayer().race != nil { if selections.selectedCard.sameTitle(currentPlayer().race!) { hideAllButtonsForCard() }}
            case (is Classs):
                if freezeOptions { hideAllButtonsForCard() }
                else { onlyShowOtherButtonForCard() }
                if currentPlayer().classs != nil { if selections.selectedCard.sameTitle(currentPlayer().classs!) { hideAllButtonsForCard() }}
            case (is LevelUpCard):
                if freezeOptions || access.game.player[0].level == 9 { hideAllButtonsForCard() }
                else { onlyShowOtherButtonForCard() }
            case (is Monster):
                let handMonster = selections.selectedCard as! Monster
                
                if access.game.lookingForTrouble && handMonster.minPursueLevel <= currentPlayer().level { onlyShowOtherButtonForCard() }
                else { hideAllButtonsForCard() }
            case (is Curse):
                if freezeOptions { hideAllButtonsForCard() }
                else { onlyShowOtherButtonForCard() }
                if access.game.numberOfPlayers == 1 { hideAllButtonsForCard() }
            case (is WishingRing):
                hideAllButtonsForCard()
            case (is Item):
                if freezeOptions { hideAllButtonsForCard() }
                else {
                    gUIElements.button[5].hidden = true
                    gUIElements.button[6].hidden = false
                    gUIElements.button[7].hidden = false
                    
                    if selections.selectedCardColumn == 0 { gUIElements.button[6].hidden = true }
                    else if selections.selectedCardColumn == 1 { gUIElements.button[7].hidden = true }
                    else if selections.selectedCardColumn == 2 { gUIElements.button[8].hidden = true }
                    if !currentPlayer().isItemUsable((selections.selectedCard as! Item), checkCategoory: true ) { gUIElements.button[6].hidden = true }
                }
                

            default: // Monster Modifiers, Single Use Items, OutToLunchs, and InvisibilityPotions
                if access.game.combatInProgress { onlyShowOtherButtonForCard() }
                else { hideAllButtonsForCard() }
            }
            
            // Shows end turn button if number of cards in player's hand is small enough, else it allows for cards to be given to charity
            
            if access.game.endTurnPossible {
                if access.game.player[0].hand.count <= access.game.player[0].getMaxHandCount() { gUIElements.button[4].hidden = false }
                else { gUIElements.button[4].hidden = true
                    if !(selections.selectedCard is Item) && !(selections.selectedCard is LevelUpCard && !(selections.selectedCard is Curse)) {
                        gUIElements.button[8].hidden = false }
                    if access.game.player[0].level == 9 && selections.selectedCard is LevelUpCard { gUIElements.button[8].hidden = false }
                }
            }
            
            
            // Shows sell buttons if selling is in progress
            
            if access.game.sellItem {
                if (selections.selectedCard is Item) || (selections.selectedCard is SingleUseItem)  ||
                    (selections.selectedCard is OutToLunch) || (selections.selectedCard is InvisibilityPotion) ||
                    (selections.selectedCard is WishingRing)
                { gUIElements.button[8].hidden = false }
            }
            
            
            // Shows defeat button if combat is in progress and combatant can win
            
            if access.game.combatInProgress {
                let combatMonster = getCombatMonster()
                if combatMonster.levelAfterModifiers() < currentPlayer().getEffectiveCombatStrength() {
                    gUIElements.button[9].hidden = true
                    gUIElements.button[10].hidden = true
                    gUIElements.button[11].hidden = false
                }
                else {
                    gUIElements.button[9].hidden = false
                    gUIElements.button[10].hidden = false
                    gUIElements.button[11].hidden = true
                }
            }
            
            

            // Prevent selling items for final level
            
            if access.game.player[0].level == 9 { gUIElements.button[3].hidden = true }
            
            
            // Updates player info in side view if in focus
            
            if gUIElements.playerInFocus { gUIElements.gameLogBox.string = selections.selectedPlayer.getFullPlayerInfo() }
            
            
            // Hides 'Ask For Help' if the game in in one player mode or a player is level 9
            if access.game.numberOfPlayers == 1 || currentPlayer().level == 9 { gUIElements.button[9].hidden = true }
            
            
            // Trade is no longer being supported
            
            gUIElements.button[2].hidden = true
        }
        
        if selections.selectedCardSlot == -1 || selections.selectedCardColumn == -1 { hideAllButtonsForCard() }
        
        // Hides all buttons if the game has been won (meaning it is over)
        
        if access.game.gameWon { hideAllButtons() }
    }
    
    func onlyShowOtherButtonForCard() {
        
        // Only show the 'Move to Other' button
        
        gUIElements.button[5].title = selections.selectedCard.otherButtonTitle
        gUIElements.button[5].hidden = false
        for i in 6...8 { gUIElements.button[i].hidden = true }
    }
    
    func hideAllButtonsForCard() { for i in 5...8 { gUIElements.button[i].hidden = true } }
    
    func hideAllButtons() { for i in 1...11 { gUIElements.button[i].hidden = true }}
    
    
    override func mouseDown(theEvent: NSEvent) {
        
        let mouseLoc = CGPoint(x: NSEvent.mouseLocation().x, y: NSEvent.mouseLocation().y)
        
        
        // Update selected player information if a player box is clicked on
        
        for (index, box) in gUIElements.playerInfoBox.enumerate() {
            if (CGRectContainsPoint(box.accessibilityFrame(), mouseLoc)) {
                selections.selectedPlayer = access.game.player[index]
                showPlayerInfo()
            }
        }
        
        
        // Update selected card information if a card is clicked on
        
        for (index, card) in access.game.board.enumerate() {
            if (CGRectContainsPoint(card.physicalCard.accessibilityFrame(), mouseLoc)) {
                selections.selectedCard = card
                selections.selectedCardColumn = -1
                selections.selectedCardSlot = index
            }
        }
        
        for i in 0...1 {
            for (index, card) in access.game.player[0].itemSlot[i].enumerate() {
                if (CGRectContainsPoint(card.physicalCard.accessibilityFrame(), mouseLoc)) {
                    selections.selectedCard = card
                    selections.selectedCardColumn = i
                    selections.selectedCardSlot = index
                }
            }
        }
        
        for (index, card) in access.game.player[0].hand.enumerate() {
            if (CGRectContainsPoint(card.physicalCard.accessibilityFrame(), mouseLoc)) {
                selections.selectedCard = card
                selections.selectedCardColumn = 2
                selections.selectedCardSlot = index
            }
        }
        
        updateGraphics()
    }
    
    func replacegameLogBox(text: String) {
        
        // Reaplce the Game Log with other text
        
        gUIElements.gameLogBox.string = text
        gUIElements.button[0].hidden = false
        updateGraphics()
    }
    
    func backToGameLog() {
        
        // Return the Game Log to its normal state
        
        gUIElements.gameLogBox.string = access.game.log
        gUIElements.button[0].hidden = true
        gUIElements.playerInFocus = false
        updateGraphics()
    }
    
    func showPlayerInfo() {
        
        // Show selected player information
        
        gUIElements.playerInFocus = true
        replacegameLogBox(selections.selectedPlayer.getFullPlayerInfo())
    }
    
    
    
    // Other functions
    
    func rollDi() -> Int { return Int(arc4random_uniform(6)) + 1 }
    
    func isAllAI() -> Bool { if aiTests.allAI { return true }; return false }
    
    func getCombatMonster() -> Monster { if !access.game.board.isEmpty { return access.game.board[0] as! Monster } else { return Monster() }}
    
    func currentPlayerName() -> String { return currentPlayer().playerName }
    
    func currentPlayer() -> Player { return access.game.getCurrentPlayer() }
    
    func humanTurn() -> Bool { if !isAllAI() { return currentPlayer().playerNumber == 1 }; return false }
    
    func normalScroll() {
        if !gUIElements.button[0].hidden { backToGameLog() }
        gUIElements.gameLogBoxScroll.contentView.scrollPoint(NSPoint(x: 0, y: 0))
    }
    
    func getListOfPlayersOrderedByLevelASC() -> [Player] {
        let playerList = access.game.player
        let sortedList = playerList.sort({ $0.level < $1.level })
        return sortedList
    }
    
    func getListOfPlayersOrderedByLevelDSC() -> [Player] {
        let playerList = access.game.player
        let sortedList = playerList.sort({ $0.level > $1.level })
        return sortedList
    }
    
    func basicAlert(text: String) {
        let myPopup: NSAlert = NSAlert()
        normalScroll()
        myPopup.messageText = text
        myPopup.alertStyle = NSAlertStyle.WarningAlertStyle
        myPopup.addButtonWithTitle("OK")
        myPopup.runModal()
    }
    
    
    func explainAlert(text: String, cnclAlrt: Bool) -> Bool {
        
        // Explains a part of the game
        // Alerts are only shown if the alerts are turned on from the master or still on for the individual type
        // If the player does not want to see the message again, they can indicate this preference
        
        if cancelAlerts.masterAlert && cnclAlrt {
            let lookForTroublePopup: NSAlert = NSAlert()
            normalScroll()
            lookForTroublePopup.messageText = text
            lookForTroublePopup.addButtonWithTitle("OK")
            lookForTroublePopup.addButtonWithTitle("Don't show this message again")
            let runLookForTroublePopup = lookForTroublePopup.runModal()
            if runLookForTroublePopup == NSAlertSecondButtonReturn { return false }
            else { return true }
        }
        else { return false }
    }
    
    func addToGameLog(text: String) {
        
        if gUIElements.showOutcome { gUIElements.outcomeText = gUIElements.outcomeText + "\n\n" + text }
        access.game.log = text + "\n\n" + access.game.log
        updateGraphics()
    }
    
    func combatLog() {
        
        // Logs to current fighting level of the monster and the combat strength of the combatant
        
        let combatMonster = getCombatMonster()
        addToGameLog(String(combatMonster) + " is fighting at level " + String(combatMonster.levelAfterModifiers())
        + "\n" + "--------" + "\n" +
        currentPlayerName() + " has a Combat Strength of " + String(currentPlayer().combatStrength) )
    }
    
    func discard(card: Card) {
        
        // Sends a card to the proper discard deck, deping on whether the card is a door card or a treasure card
        
        if card.doorCard { access.game.deck[1].cards.append(card) }
        else { access.game.deck[3].cards.append(card) }
//        updateGraphics()
    }
    
    func removeSelectedCard(shouldDiscard: Bool) {
        
        // Removes the selected card from its current location
        
        if selections.selectedCardColumn == 2 {
            if shouldDiscard { discard(access.game.player[0].hand[selections.selectedCardSlot]) }
            access.game.player[0].hand.removeAtIndex(selections.selectedCardSlot)
        }
        else {
            if shouldDiscard { discard(access.game.player[0].itemSlot[selections.selectedCardColumn][selections.selectedCardSlot]) }
            access.game.player[0].itemSlot[selections.selectedCardColumn].removeAtIndex(selections.selectedCardSlot)
        }
        selections.selectedCardColumn = -1
        selections.selectedCardSlot = -1
        updateGraphics()
    }
    
    func useInvisibilityPotion(player: Player) {
        
        // Executes the funcions for 'Invisibility Potion':
        
        addToGameLog(player.playerName + " used " + String(InvisibilityPotion()))
        if player.playerIsHuman() { removeSelectedCard(true) }
        clearBoard()
    }
    
    func useOutToLunch(player: Player) {
        
        // Executes the funcions for 'Out To Lunch':
        // Removing the monster in combat and giving the player 2 treasure
        
        for _ in 1...2 {
            player.hand.append(access.game.deck[2].cards.last!)
            access.game.deck[2].cards.removeLast()
            access.game.checkDecks()
        }
        addToGameLog(player.playerName + " used " + String(OutToLunch()) )
        if player.playerIsHuman() { removeSelectedCard(true) }
        clearBoard()
    }
    
    
    
    // Game logic sequence methods
    
    func startTurn() {
        
        addToGameLog("\n\n===========\n\n")
        addToGameLog(currentPlayer().getShortPlayerInfo())
        addToGameLog(currentPlayerName() + " started turn *" + String(access.game.turnCounter / 4) + "*")
        access.game.turnCounter += 1

        if humanTurn() {
            hideAllButtons()
            let text = "Your turn has started.  You may now arrange the cards in your Hand, Equipment, and Backpack.  After clicking on a card, the description will appear on the left and give all options for that card."
            cancelAlerts.arrangeBeg = explainAlert(text, cnclAlrt: cancelAlerts.arrangeBeg)
            gUIElements.button[1].hidden = false
            if access.game.player[0].hand.isEmpty { selections.selectedCard = Card() }
            else { selections.selectedCard = access.game.player[0].hand[0] }
            updateGraphics()
        } else {
            addToGameLog( currentPlayer().arrangeCards() )
            access.game.checkCombatStrengthForAll()
            kickOpenDoor()
        }
    }
    
    func kickOpenDoor() {
        
        
        // Deal top Deck card into Combat Area
        
        let newCard = (access.game.deck[0].cards.last!)
        access.game.deck[0].cards.removeLast()
        access.game.checkDecks()
        selections.selectedCard = newCard
        
        
        gUIElements.button[1].hidden = true
        selections.selectedCardColumn = -1
        selections.selectedCardSlot = -1
        updateGraphics()
        
        

        addToGameLog(currentPlayerName() + " kicked open a door" + "\n" +
            "Revealing: " + String(newCard))
        
        
        // Different cases based on what door card is dealt
        
        if newCard is Monster {
            
            let combatMonster = newCard as! Monster
            
            if combatMonster.minPursueLevel > currentPlayer().level {
                addToGameLog(String(combatMonster) + " will not pursure " + currentPlayerName() )
                clearBoard()
            } else {
                access.game.board.append(newCard)
                combat()
            }
            

            
        } else if newCard is Curse {
            
            cursePlayer(newCard as! Curse, player: currentPlayer())
            
            access.game.deck[1].cards.append(newCard)
            updateGraphics()
            postDoorNoMonster()
            
        } else {
            
            // Place the card in the players hand
            
            addToGameLog(String(newCard) + " has been placed in the hand of " + currentPlayerName())
            currentPlayer().hand.append(newCard)
            updateGraphics()
            postDoorNoMonster()
        }
    }
    
    func curseSomeone(curse: Curse) {
        
        // Select a player to curse
        
        let playerIndex = playerSelect("Who would you like to curse?")
        removeSelectedCard(true)
        
        addToGameLog(currentPlayerName() + " would like to curse " + access.game.player[playerIndex].playerName + " with " + String(curse))
        cursePlayer(curse, player: access.game.player[playerIndex])

    }
    
    func playerSelect(text: String) -> Int {
        
        // Create a popup with other players for selection
        
        let playerSelectPopup: NSAlert = NSAlert()
        normalScroll()
        playerSelectPopup.messageText = text
        for i in (1...3).reverse() { playerSelectPopup.addButtonWithTitle(access.game.player[i].playerName) }
        let runPlayerSelectPopup = playerSelectPopup.runModal()
        if runPlayerSelectPopup == NSAlertFirstButtonReturn { return 3 }
        else if runPlayerSelectPopup == NSAlertSecondButtonReturn { return 2 }
        else { return 1 }
    }
    
    func cursePlayer(curse: Curse, player: Player) {
        
        // Given a player, curse them
        // If that player has a Wishing Ring, allow them to use it to prevent the curse
        
        var playerHasWishingRing = false
        for card in player.hand { if card is WishingRing { playerHasWishingRing = true }}
        if playerHasWishingRing {
            if !(isAllAI()) && player.playerNumber == 1 {
                let cursePopup: NSAlert = NSAlert()
                normalScroll()
                cursePopup.messageText = "Would you like to use your Wishing Ring to cancel this Curse?"
                cursePopup.addButtonWithTitle("Yes")
                cursePopup.addButtonWithTitle("No")
                let runCursePopup = cursePopup.runModal()
                if runCursePopup == NSAlertFirstButtonReturn { removeWishingRing(player) }
                else {
                    basicAlert("You have been cursed with: " + String(curse))
                    executeCurse(curse, player: player)
                }
            } else {
                if player.useWishingRing(curse) { removeWishingRing(player) }
                else { executeCurse(curse, player: player) }
            }
        } else {
            if !(isAllAI()) && player.playerNumber == 1 { basicAlert("You have been cursed with: " + String(curse)) }
            executeCurse(curse, player: player) }
    }
    
    func removeWishingRing(player: Player) {
        
        // Removes the wishing ring from a player's hand, preventing a curse
        
        addToGameLog( player.playerName + " has cancelled the curse with their " + String(WishingRing()) )
        for (index, card) in player.hand.enumerate() { if card is WishingRing {
            discard(card)
            player.hand.removeAtIndex(index)
            break
            }}
        selections.selectedCardSlot = -1
        updateGraphics()
    }
    
    func executeCurse(curse: Curse, player: Player) {
        
        // Executes a given curse on a given player
        
        addToGameLog(player.playerName + " has been cursed!")
        discard(curse.execute(player))
        access.game.checkEquipmentForAll()
    }
    
    func combat() {
        
        // Start a combat (fight with a monster)
        
        if !isAllAI() {
            selections.selectedCard = access.game.board[0]
            selections.selectedCardColumn = -1
            selections.selectedCardSlot = 0
        }

        access.game.combatInProgress = true
        let combatMonster = getCombatMonster()
        if combatMonster.undead && currentPlayer().classs is Cleric { combatMonster.levelModifierAmount -= 5 }
        combatLog()
        updateGraphics()
        if humanTurn(){
            let text = "You are now you are engaged in combat with a Monster.  "
            + "To win the combat, your combat strength must be above the Monster’s level.  "
            + "Warriors win in ties.  "
            + "You can use cards from your hand to try to hurt the Monster and defeat the Monster.  "
            + "You can also ask other players for help.  "
            + "Other players may put cards on the board during the combat to strengthen the Monster.  "
            + "If defeat is possible, the option will appear on the board."
            cancelAlerts.combat = explainAlert(text, cnclAlrt: cancelAlerts.combat)
            for i in 9...10 { gUIElements.button[i].hidden = false }
            letOthersHarmCombat()
            updateGraphics()
        }
        else { currentPlayer().aICombat(false) }
    }
    
    func letOthersHarmCombat() -> Bool {
        
        // Randomly go thorugh players and allow them to harm the combatant
        
        var playerList = access.game.player
        for (index, player) in playerList.enumerate().reverse() { if player.playerNumber == currentPlayer().playerNumber { playerList.removeAtIndex(index) }}
        playerList.shuffleInPlace()
        let combatMonster = getCombatMonster()
        let difference = currentPlayer().getEffectiveCombatStrength() - (combatMonster.levelAfterModifiers() + 1)
        var huamnStopMethod = false
        for player in playerList {
            if access.game.combatInProgress && !huamnStopMethod {
                huamnStopMethod = player.canHarm(difference, player: currentPlayer())
                if huamnStopMethod { return true }
            }
        }
        return false
    }
    
    func askToHarm() {
        
        // Create popup to ask whether or not a player would like to use a card in hand to harm the combatant
        
        updateGraphics()
        let harmPopup: NSAlert = NSAlert()
        normalScroll()
        harmPopup.messageText = "Would you like to use a card against " + currentPlayerName() + " in their current combat?"
        harmPopup.addButtonWithTitle("Yes")
        harmPopup.addButtonWithTitle("No")
        let runHarmPopup = harmPopup.runModal()
        if runHarmPopup == NSAlertFirstButtonReturn {
            access.game.humanCanHarm = true
            gUIElements.showOutcome = true
            updateGraphics()
            let text = "Pick a card from your hand to send into combat"
            cancelAlerts.harm = explainAlert(text, cnclAlrt: cancelAlerts.harm)
        } else {
            letOnlyAIHarm()
            if access.game.combatInProgress { currentPlayer().aICombat(true) }
        }
    }
    
    func letOnlyAIHarm() {
        var playerList = access.game.player
        playerList.removeAtIndex(0)
        for (index, player) in playerList.enumerate().reverse() {
            if player.playerNumber == currentPlayer().playerNumber { playerList.removeAtIndex(index) }
            if player.playerNumber == 1 { playerList.removeAtIndex(index) }
        }
        let combatMonster = getCombatMonster()
        let difference = currentPlayer().getEffectiveCombatStrength() - (combatMonster.levelAfterModifiers() + 1)
        for player in playerList { if access.game.combatInProgress { player.canHarm(difference, player: currentPlayer()) }}
    }
    
    func defeatMonster() {
        
        if access.game.combatInProgress {
            // Adjust levels, give treasure, and clear the board
            
            let combatMonster = getCombatMonster()
            addToGameLog(String(combatMonster) + " has been defeated")
            
            
            let levelGain = combatMonster.levelsGained
            currentPlayer().level += levelGain
            addToGameLog("Levels gained: " + String(levelGain))
            
            let treasureGain = combatMonster.rewardAfterModifiers()
            for _ in 1...treasureGain {
                currentPlayer().hand.append(access.game.deck[2].cards.last!)
                access.game.deck[2].cards.removeLast()
                access.game.checkDecks()
            }
            addToGameLog(currentPlayerName() + " has received " + String(treasureGain) + " treasure")
            
            access.game.checkCombatStrengthForAll()
            updateGraphics()
            clearBoard()
        } else { print("error") }

    }
    
    func defeatMonsterWithHelp(helperPlayer: Player) {
        
        // Adjust levels, give treasure, and clear the board

        if helperPlayer.race is Elf {
            helperPlayer.level += 1
            addToGameLog(helperPlayer.playerName + " went up a level for helping and being an Elf")
        }
        
        let combatMonster = getCombatMonster()
        addToGameLog(String(combatMonster) + " has been defeated")
        
        
        let levelGain = combatMonster.levelsGained
        currentPlayer().level += levelGain
        addToGameLog("Levels gained: " + String(levelGain))
        
        let treasureGain = combatMonster.rewardAfterModifiers()
        var mainTreasure = 0
        var helperTreasure = 0
        
        // The helper gets half of the treasure, and gets the extra if there is an odd number of treasure
        
        for i in 1...treasureGain {
            if i % 2 == 1 {
                helperPlayer.hand.append(access.game.deck[2].cards.last!)
                helperTreasure += 1
            } else {
                currentPlayer().hand.append(access.game.deck[2].cards.last!)
                mainTreasure += 1
            }
            access.game.deck[2].cards.removeLast()
            access.game.checkDecks()
        }
        addToGameLog(currentPlayerName() + " has received " + String(mainTreasure) + " treasure")
        addToGameLog(helperPlayer.playerName + " has received " + String(helperTreasure) + " treasure")
        
        access.game.checkCombatStrengthForAll()
        updateGraphics()
        clearBoard()
        
    }
    
    func postDoorNoMonster() {
        
        // If there was no monster or curse, give the player the option to Loot The Room
        // Check to see if the current player has a monster to that would fight the player
        // If so, give the option to Look For Touble
        
        var hadMonster = false
        for card in access.game.player[0].hand { if card is Monster {
            let cardMonster = card as! Monster
            if currentPlayer().level >= cardMonster.minPursueLevel { hadMonster = true }
        }}
        updateGraphics()

        if humanTurn() {
            let postMonsterPopup: NSAlert = NSAlert()
            normalScroll()
            postMonsterPopup.messageText = "What would you like to do next?"
            postMonsterPopup.addButtonWithTitle("Loot the Room")
            if hadMonster { postMonsterPopup.addButtonWithTitle("Look For Trouble") }
            let runPostMonsterPopup = postMonsterPopup.runModal()
            if runPostMonsterPopup == NSAlertFirstButtonReturn { lootTheRoom() }
            else { lookForTrouble() }
        } else {
            if hadMonster {
                if currentPlayer().shouldLookForTrouble() { lookForTrouble() }
                else { lootTheRoom() }
            } else { lootTheRoom() }
        }

    }
    
    func lootTheRoom() {
        
        // Put the top door card into the player's hand
        
        currentPlayer().hand.append(access.game.deck[0].cards.last!)
        access.game.deck[0].cards.removeLast()
        access.game.checkDecks()
        if humanTurn() {
            selections.selectedCard = access.game.player[0].hand[access.game.player[0].hand.count - 1]
            selections.selectedCardColumn = 2
            selections.selectedCardSlot = access.game.player[0].hand.count - 1
        }

        addToGameLog(currentPlayerName() + " looted the room" + "\n" +
            "Receiving: " + String(currentPlayer().hand.last!))
        
        updateGraphics()
        clearBoard()
    }
    
    func lookForTrouble() {
        
        // Enables the player to pick a monster from their hand to fight
        
        addToGameLog(currentPlayerName() + " has decided to look For trouble")

        if !humanTurn() {
            access.game.board.append(currentPlayer().pickTroubleMonster())
            troubleMonsterPicked()
        }
        else {
            access.game.lookingForTrouble = true
            let text = "Pick a Monster from your hand to fight"
            cancelAlerts.pickMonster = explainAlert(text, cnclAlrt: cancelAlerts.pickMonster)
        }
    }
    
    func troubleMonsterPicked() {
        
        // Set combat in motion after a players has pick a monster from their hand when looking for trouble
        
        if humanTurn() { access.game.board.append(selections.selectedCard) }
        addToGameLog(currentPlayerName() + " will fight " + String(access.game.board[0]) + " from their hand")
        if humanTurn() {
            removeSelectedCard(false)
            access.game.lookingForTrouble = false
        }
        combat()
    }
    
    func tryToEscape() {
        
        // If the player is a Wizard with more than 3 cards in their hand, they have the option to charm the monster
        // Otherwise, the player automatically runs away
        
        let canCharm = currentPlayer().classs is Wizard && currentPlayer().hand.count > 2
        if !canCharm { runAway() }
        else {
            if humanTurn() {
                let escapePopup: NSAlert = NSAlert()
                normalScroll()
                escapePopup.messageText = "How would you like to try to escape?"
                escapePopup.addButtonWithTitle("Run Away")
                escapePopup.addButtonWithTitle("Charm the Monster")
                let runEscapePopup = escapePopup.runModal()
                if runEscapePopup == NSAlertFirstButtonReturn { runAway() }
                else { charmTheMonster() }
            } else {
                if currentPlayer().shouldCharm(getCombatMonster()) { charmTheMonster() }
                else { runAway() }
            }
        }
    }
    
    func charmTheMonster() {
        
        // Charming means discarding all cards in the players hand
        // The player then gains treasure from the monster and the combat ends
        
        let combatMonster = getCombatMonster()
        addToGameLog(currentPlayerName() + " charmed " + String(combatMonster) )

        for card in currentPlayer().hand { discard(card) }
        currentPlayer().hand.removeAll()
        
        let treasureGain = combatMonster.rewardAfterModifiers()
        for _ in 1...treasureGain {
            currentPlayer().hand.append(access.game.deck[2].cards.last!)
            access.game.deck[2].cards.removeLast()
            access.game.checkDecks()
        }
        
        clearBoard()
    }
    
    func runAway() {
        
        // Roll the di to try to run away
        // Rolls above 4 allow the player to escape
        // Otherwise, the Monster's bad stuff takes effect
        
        gUIElements.button[10].hidden = true
        let combatMonster = getCombatMonster()
        
        let card = access.game.board[0]
        if humanTurn(){ selections.selectedCard = card }
        let diResult = rollDi()
        
        addToGameLog(currentPlayerName() + " rolled a " + String(diResult))
        
        if diResult < 5 {
            addToGameLog(currentPlayerName() + " failed to run away from " + String(card))
            let toDiscard = combatMonster.badStuff.execute(currentPlayer())
            for card in toDiscard { discard(card) }
            if combatMonster.badStuff is BadStuffDeath { access.game.newCardsForPlayer(currentPlayer()) }
            addToGameLog(currentPlayerName() + combatMonster.badStuff.badStuffPastAction)
            access.game.checkCombatStrengthForAll()
        }
        else { addToGameLog(currentPlayerName() + " ran away from " + String(card) + " successfully") }
            
        clearBoard()
    }

    func clearBoard() {
        
        // Clear the board and end the combat mode
        
        access.game.combatInProgress = false
        access.game.humanCanHarm = false
        if gUIElements.showOutcome{
            gUIElements.outcomeText = "OUTCOME OF THAT COMBAT:" + "\n\n" + gUIElements.outcomeText
            basicAlert(gUIElements.outcomeText)
        }
        gUIElements.showOutcome = false
        gUIElements.outcomeText = ""
        selections.selectedCardSlot = -1
        addToGameLog("The board was cleared")

        
        // Empty Game Board
        
        for card in access.game.board { discard(card) }
        access.game.board.removeAll()
        updateGraphics()
        
        var gamewon = false
        for player in access.game.player { if player.level >= 10 { gamewon = true }}
        
        if gamewon { gameWon() }
        else {
            if humanTurn() {
                selections.selectedCardSlot = -1
                for i in 2...3 { gUIElements.button[i].hidden = false }
                for i in 9...11 { gUIElements.button[i].hidden = true }
                access.game.endTurnPossible = true
                updateGraphics()
                
                
                if access.game.player[0].hand.count > access.game.player[0].getMaxHandCount() {
                    let text = "You have too many cards in hand. "
                        + "You must sell and/or give cards to charirty before you can end your turn."
                    cancelAlerts.charity = explainAlert(text, cnclAlrt: cancelAlerts.charity)
                }
            } else {
                addToGameLog( currentPlayer().arrangeAndEndTurn(access.game) )
                access.game.checkCombatStrengthForAll()
                endTurn()
            }
        }
    }
    
    func sellItems() {
        
        // Change board to selling mode
        
        gUIElements.button[3].title = "Finish Selling"
        gUIElements.button[8].title = "Sell This Item"
        access.game.endTurnPossible = false
        access.game.sellItem = true
        gUIElements.button[2].hidden = true
        gUIElements.button[4].hidden = true
        updateGraphics()
        let text = "Select cards that you want to sell by clicking on them, then pressing \'Sell\'.  "
        + "For every 1000 gold pieces, you will go up one level.  "
        + "If you are a Halfling, the first item you sell will be worth double.  "
        + "You cannot sell to reach level 10.  "
        + "You are are finished, press \'Finish Selling\'."
        cancelAlerts.sell = explainAlert(text, cnclAlrt: cancelAlerts.sell)
    }
    
    func sellSelectedItem() {
        
        // Sells the selected item, checks if the total is over 1000, and if so increases the player level
        // Halflings get to sell their first card each round for double value
        
        var cardValue = selections.selectedCard.value
        
        if access.game.sellingTotal == -100 {
            if currentPlayer().race is Halfling { cardValue *= 2 }
            access.game.sellingTotal = 0
        }
        
        access.game.sellingTotal += cardValue
        addToGameLog(currentPlayerName() + " has sold " + String(selections.selectedCard) + " worth " + String(cardValue))
        
        if access.game.sellingTotal >= 1000 {
            access.game.player[0].level += 1
            access.game.sellingTotal -= 1000
            addToGameLog(currentPlayerName() + " has gained a level")
        }
        
//        access.game.deck[3].cards.append(selections.selectedCard)
        removeSelectedCard(true)
        
        access.game.checkCombatStrengthForAll()
        updateGraphics()
        if access.game.player[0].level == 9 { doneSelling() }
    }
    
    func doneSelling() {
        
        // Ends the selling mode, normalizes the board
        
        gUIElements.button[3].title = "Sell"
        gUIElements.button[8].title = "Give to Charity"
        access.game.endTurnPossible = true
        access.game.sellItem = false
        gUIElements.button[2].hidden = false
        gUIElements.button[4].hidden = false
        updateGraphics()
    }
    
    func charity() {
        
        // Distribute cards to all of the players having the lowest level
        // If that is only the current player, discard all charity collection cards instead
        
        var minLevel = 10
        for player in access.game.player { if minLevel > player.level { minLevel = player.level }}
        var lowPlayers = [Player]()
        for player in access.game.player { if minLevel == player.level { if player.playerNumber != currentPlayer().playerNumber {
            lowPlayers.append(player) }}}
        
        if lowPlayers.isEmpty {
            for card in access.game.charityCollection {
                discard(card)
            }
            access.game.charityCollection.removeAll()
        } else { while !(access.game.charityCollection.isEmpty) { for player in lowPlayers { if !(access.game.charityCollection.isEmpty) {
                    player.hand.append(access.game.charityCollection.last!)
                    access.game.charityCollection.removeLast()
        }}}}

    }
    
    func sendCardToCharity() {
        
        // Sends a card to the chairty collection
        
        selections.selectedCard.physicalCard.hidden = true
        removeSelectedCard(false)
        access.game.charityCollection.append(selections.selectedCard)
        updateGraphics()
    }
    
    func endTurn() {
        
        // Triggered by a button, ends a player's turn
        
        access.game.sellingTotal = -100
        access.game.endTurnPossible = false
        charity()
        for i in 2...4 { gUIElements.button[i].hidden = true }
        addToGameLog(currentPlayer().getShortPlayerInfo())
        addToGameLog(currentPlayerName() + " ended their turn")
        access.game.playerTurn = (access.game.playerTurn + 1) % access.game.numberOfPlayers
        startTurn()
    }
    
    func askForHelp() {
        
        // Let a human player select a player to ask for help
        // That player cannot help if they are level 9 and an elf
        // Also the player must make the difference between winning and losing the combat
        // The AI player then decides whether or not to help
        
        let index = playerSelect("Who would you like to ask for help?")
        let playerHelp = access.game.player[index]
        let combatMonster = getCombatMonster()
        if playerHelp.level == 9 && playerHelp.race is Elf {
            basicAlert(playerHelp.playerName + " cannot help you, they are a Level 9 Elf")
        } else if combatMonster.levelAfterModifiers() >= ( currentPlayer().getEffectiveCombatStrength() + playerHelp.getEffectiveCombatStrength() ) {
            basicAlert(playerHelp.playerName + " and your combined combat strengths are not enough to defeat this Monster")
        } else {
            if playerHelp.willHelp(currentPlayer()) {
                addToGameLog(playerHelp.playerName + " will help " + currentPlayerName())
                defeatMonsterWithHelp(playerHelp)
            }
            else { addToGameLog(playerHelp.playerName + " will not help " + currentPlayerName()) }
        }
    }
    
    func humanWillHelp() -> Bool {
        
        // If a Human player is asked for help, create popup to ask for answer
        
        let helpPopup: NSAlert = NSAlert()
        normalScroll()
        helpPopup.messageText = "Would you like to help " + currentPlayerName() + " win their combat?"
        helpPopup.addButtonWithTitle("Yes")
        helpPopup.addButtonWithTitle("No")
        let runHelpPopup = helpPopup.runModal()
        if runHelpPopup == NSAlertFirstButtonReturn {
            gUIElements.showOutcome = false
            return true
        }
        else { return false }
    }
    
    func gameWon() {
        
        // Check to see if a plyer has won
        
        for player in access.game.player { if player.level >= 10 {
            addToGameLog(player.playerName + " has won the game!!!")
            access.game.gameWon = true
            updateGraphics()
            if !isAllAI() {
                if humanTurn() { print("Human won in " + String(access.game.turnCounter / access.game.numberOfPlayers) + " turns") }
                else { print("AI won in " + String(access.game.turnCounter / access.game.numberOfPlayers) + " turns") }
                var winText = player.playerName + " has won the game!!!"
                if humanTurn() { winText = "You have won the game!!!"}
                basicAlert(winText)
                let newGamePopup: NSAlert = NSAlert()
                normalScroll()
                newGamePopup.messageText = "Would you like to play again?"
                newGamePopup.addButtonWithTitle("Yes")
                newGamePopup.addButtonWithTitle("No")
                let runGamePopup = newGamePopup.runModal()
                if runGamePopup == NSAlertFirstButtonReturn { newGame() }
            } else { print("Game won in " + String(access.game.turnCounter / access.game.numberOfPlayers) + " turns") }

            if aiTests.numberOfTrials > 1 && isAllAI() { aiTrials() }
            break
            }
        }
    }
    
    
    
    // AI trial methods
    
    func aiTrials() {
        
        // Called after a game is won if multiple simultaneous ai trials are running
        // If the desired number of trials has not been reached, start a new game
        // Else, print statistics on the trials
        
        let winNumOfTurns = (access.game.turnCounter / access.game.numberOfPlayers)
        aiTests.winningNumberOfTurns.append(winNumOfTurns)
        
        var totalOtherLevels = 0
        for player in access.game.player { if player.level < 10 { totalOtherLevels += player.level }}
        let avgOtherLevels = Double(totalOtherLevels) / 3.0
        aiTests.averageOtherPlayerLevels.append(avgOtherLevels)
        
        aiTests.winnerType.append(currentPlayer().getMultiPlayStyle())
        
        for player in access.game.player { aiTests.playerOccurance[player.getMultiPlayStyle()] += 1}
        
        aiTests.trialCounter += 1
        if aiTests.trialCounter == aiTests.numberOfTrials {
            print("\n\n")
            var aiWinnerArrays = [[Int]()]
            var aiOtherLevelsArrays = [[Double]()]
            for _ in 1...9 {
                aiWinnerArrays.append([Int]())
                aiOtherLevelsArrays.append([Double]())
            }
            for (index, num) in aiTests.winnerType.enumerate() {
                aiWinnerArrays[num].append(aiTests.winningNumberOfTurns[index])
                aiOtherLevelsArrays[num].append(aiTests.averageOtherPlayerLevels[index])
            }
            for (index, list) in aiWinnerArrays.enumerate() {
                print(translateMultiName(index))
                if list.isEmpty { print("Never Won") }
                else {
                    var percentWin = Double(list.count) / Double(aiTests.playerOccurance[index]) * 10000
                    percentWin = round(percentWin) / 10000
                    print("Won: " + String(percentWin) + "% of the time")
                    
                    let turnTotals = list.reduce(0, combine: +)
                    var averageNumberOfTurns = ( Double(turnTotals) / Double(list.count) ) * 100
                    averageNumberOfTurns = round(averageNumberOfTurns) / 100
                    print("Average: " + String(averageNumberOfTurns))
                    
                    let minNumberOfTurns = list.minElement()!
                    let maxNumberOfTurns = list.maxElement()!
                    print("Minimum: " + String(minNumberOfTurns))
                    print("Maximum: " + String(maxNumberOfTurns))
                    
                    let otherTurnsTotals = aiOtherLevelsArrays[index].reduce(0, combine: +)
                    var averageOtherNumberOfTurns = ( otherTurnsTotals / Double(list.count) ) * 100
                    averageOtherNumberOfTurns = round(averageOtherNumberOfTurns) / 100
                    print("Average Level of Other Players: " + String(averageOtherNumberOfTurns))
                    print()
                }

            }
            

            aiTests.trialCounter = 0
            aiTests.winningNumberOfTurns.removeAll()
            aiTests.winnerType.removeAll()
            for i in 0...9 { aiTests.playerOccurance[i] = 0}

        } else {
            if aiTests.trialCounter % 10 == 0 {
                NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0.01), target: self, selector: #selector(ViewController.newGame), userInfo: nil, repeats: false) }
            else { newGame() }
        }
    }
    
    func translateMultiName(style: Int) -> String {
        
        // Returns a descriptive name of playing style given the int representing multi play style for an AI players
        
        var varStyle = style
        var harmStyle = "never harming others."
        if varStyle > 4 {
            harmStyle = "harming others when logical"
            varStyle -= 5
        }
        var mode = ""
        switch varStyle {
        case 0:
            mode = "Always help"
        case 1:
            mode = "Never help"
        case 2:
            mode = "Only help players with lower levels"
        case 3:
            mode = "Only help those with levels under 6"
        default:
            mode = "Random"
        }
        return "Multi-Player Style: " + mode + " while " + harmStyle
    }
    
    
    
    
    // AI methods
    
    func simpleAISendToCombat(index: Int, player: Player) {
        
        // Sends a card from an AI player to the board for combat
        
        access.game.board.append(player.hand[index])
        addToGameLog(player.playerName + " used " + String(player.hand[index]) + " in combat")
        combatLog()
        player.hand.removeAtIndex(index)
        updateGraphics()
    }

}