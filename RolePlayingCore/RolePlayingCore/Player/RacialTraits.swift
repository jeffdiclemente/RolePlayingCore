//
//  RacialTraits.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 11/12/16.
//  Copyright © 2016-2017 Brian Arnold. All rights reserved.
//

import Foundation

extension Trait {
    
    public static let abilityScores = "ability scores"
    
    public static let minimumAge = "minimum age"
    
    public static let lifespan = "lifespan"
    
    public static let baseHeight = "base height"
    
    public static let heightModifier = "height modifier"
    
    public static let baseWeight = "base weight"
    
    public static let weightModifier = "weight modifier"
    
    public static let speed = "speed"

    public static let darkVision = "darkvision"
    
}

public struct RacialTraits {
    
    public var name: String
    
    public var plural: String
    
    public var aliases = [String]()
    
    public var descriptiveTraits = [String: Any]()
    
    public var abilityScoreIncrease: Ability.Scores
    
    public var minimumAge: Int
    
    public var lifespan: Int
    
    public var alignment: Alignment?
    
    public enum Size {
        case small
        case medium
        case large
    }
    
    public var size: Size {
        let size: Size
        
        let heightInFeet = baseHeight.converted(to: .feet)
        switch heightInFeet.value {
        case 0..<4:
            size = .small
        case 4..<7:
            size = .medium
        default:
            size = .large
        }
        
        return size
    }
    
    public var baseHeight: Height
    
    public var heightModifier: Dice
    
    public var baseWeight: Weight
    
    public var weightModifier: Dice?
    
    public var darkVision: Int
    
    public var speed: Int
    
    public var hitPointsBonus: Int
    
    public var subraces = [RacialTraits]()
    
    // TODO: weapons, armor, skills, etc.

    /// Creates race traits from dictionary traits.
    ///
    /// - parameter traits: a dictionary of traits with the following keys and values:
    ///   - "name": required string
    ///   - "plural": required string
    ///   - "minimum age": required integer
    ///   - "lifespan": required integer
    ///   - "base height": required height string or number
    ///   - "height modifier": required dice string
    ///   - "baseWeight": required weight string or number
    ///   - "weight modifier": optional dice string
    ///   - "speed": required integer
    ///   - "aliases": optional alternative names
    ///   - "ability score increase": optional array of ability string names
    ///   - "alignment": optional string alignment name
    ///   - "darkvision": optional integer
    ///   - "hit points": optional hit point bonus integer
    ///
    /// - returns: `RacialTraits` instance, or nil if there are any missing required traits.
    public init?(from traits: [String: Any]) {
        // Required traits
        guard let name = traits[Trait.name] as? String else { Trait.logMissing(Trait.name); return nil }
        guard let plural = traits[Trait.plural] as? String else { Trait.logMissing(Trait.plural); return nil }
        guard let minimumAge = traits[Trait.minimumAge] as? Int else { Trait.logMissing(Trait.minimumAge); return nil }
        guard let lifespan = traits[Trait.lifespan] as? Int else { Trait.logMissing(Trait.lifespan); return nil }
        guard let baseHeight = height(from: traits[Trait.baseHeight]) else { Trait.logMissing(Trait.baseHeight); return nil }
        guard let heightString = traits[Trait.heightModifier] as? String, let heightModifier = dice(from: heightString) else { Trait.logMissing(Trait.heightModifier); return nil }
        guard let baseWeight = weight(from: traits[Trait.baseWeight]) else { Trait.logMissing(Trait.baseWeight); return nil }
        guard let speed = traits[Trait.speed] as? Int else { Trait.logMissing(Trait.speed); return nil }
        
        // Optional traits
        let aliases = traits[Trait.aliases] as? [String]
        
        let abilityScoreIncrease = Ability.Scores(from: traits[Trait.abilityScores]) ?? Ability.Scores()
        
        let alignment: Alignment?
        if let alignmentTrait = traits[Trait.alignment] as? String {
            alignment = Alignment(from: alignmentTrait)
        } else {
            alignment = nil
        }
        
        let weightModifier: Dice?
        if let weightModifierString = traits[Trait.weightModifier] as? String {
            weightModifier = dice(from: weightModifierString)
        } else {
            weightModifier = nil
        }
        
        let darkVision = traits[Trait.darkVision] as? Int ?? 0
        
        let hitPointsBonus = traits[Trait.hitPoints] as? Int ?? 0
        
        // TODO: weapons, armor, skills, etc.
        
        // All is well, set the properties:
        self.name = name
        self.plural = plural
        if aliases != nil {
            self.aliases = aliases!
        }
        self.minimumAge = minimumAge
        self.lifespan = lifespan
        self.baseHeight = baseHeight
        self.baseWeight = baseWeight
        self.heightModifier = heightModifier
        self.weightModifier = weightModifier
        self.speed = speed
        self.abilityScoreIncrease = abilityScoreIncrease
        self.alignment = alignment
        self.darkVision = darkVision
        self.hitPointsBonus = hitPointsBonus
    }
    
    /// Creates a sub-race from a parent race and overridden traits.
    public init(from traits: [String: Any], parent: RacialTraits) {
        // Initialize from parent traits
        self = parent
        
        // Override traits specified by the subrace
        if let name = traits[Trait.name] as? String {
            self.name = name
        }
        if let plural = traits[Trait.plural] as? String {
            self.plural = plural
        }
        if let aliases = traits[Trait.aliases] as? [String] {
            self.aliases += aliases
        }
        
        if let minimumAge = traits[Trait.minimumAge] as? Int {
            self.minimumAge = minimumAge
        }
        if let lifespan = traits[Trait.lifespan] as? Int {
            self.lifespan = lifespan
        }
        
        if let baseHeight = height(from: traits[Trait.baseHeight]) {
            self.baseHeight = baseHeight
        }
        if let baseWeight = weight(from: traits[Trait.baseWeight]) {
            self.baseWeight = baseWeight
        }
        
        if let heightModifier = traits[Trait.heightModifier] as? String {
            self.heightModifier = dice(from: heightModifier)!
        }
        if let weightModifier = traits[Trait.weightModifier] as? String {
            self.weightModifier = dice(from: weightModifier)
        }
        
        if let speed = traits[Trait.speed] as? Int {
            self.speed = speed
        }
        
        if let scores = Ability.Scores(from: traits[Trait.abilityScores]) {
            self.abilityScoreIncrease = self.abilityScoreIncrease + scores
        }
        
        if let alignmentTrait = traits[Trait.alignment] as? String {
            alignment = Alignment(from: alignmentTrait)
        }
        
        if let darkVision = traits[Trait.darkVision] as? Int {
            self.darkVision = darkVision
        }
        
        if let hitPointsBonus = traits[Trait.hitPoints] as? Int {
            self.hitPointsBonus = hitPointsBonus
        }
    }
    
}