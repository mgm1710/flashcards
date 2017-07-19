//
//  Models.swift
//  flashcards
//
//  Created by Mehul Mewada on 7/19/17.
//  Copyright © 2017 XYZ. All rights reserved.
//

import Foundation

class Word {
    var word: String
    var meaning: String
    var isFavourite: Bool
    var identifier: Int
    
    init() {
        word = ""
        meaning = ""
        isFavourite = false
        identifier = -1
    }
}
