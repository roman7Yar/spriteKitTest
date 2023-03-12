//
//  UserDefaultsManager.swift
//  spriteKitTest
//
//  Created by Roman Yarmoliuk on 02.01.2023.
//

import Foundation

class UserDefaultsManager {
    private init() {
        UserDefaults.standard.register(defaults: ["score" : 0])
    }
    private let scoreKey = "score"
    
    static let shared = UserDefaultsManager()
    
    
    func getScore() -> (Int) {
        UserDefaults.standard.integer(forKey: scoreKey)
    }
    
    func setScore(value: Int) {
        UserDefaults.standard.set(value, forKey: scoreKey)
    }
    

}
