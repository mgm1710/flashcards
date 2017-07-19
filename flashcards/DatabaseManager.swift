//
//  DatabaseManager.swift
//  flashcards
//
//  Created by Mehul Mewada on 7/19/17.
//  Copyright © 2017 XYZ. All rights reserved.
//

import UIKit
import SQLite

class DatabaseManager {
    
    var db: Connection?
    
    static let sharedInstance : DatabaseManager = {
        let instance = DatabaseManager()
        return instance
    }()
    
    func copyDatabaseIfNeeded() {
        // Move database file from bundle to documents folder
        
        let fileManager = FileManager.default
        
        let documentsUrl = fileManager.urls(for: .documentDirectory,
                                            in: .userDomainMask)
        
        guard documentsUrl.count != 0 else {
            return // Could not find documents URL
        }
        
        let finalDatabaseURL = documentsUrl.first!.appendingPathComponent("db.sqlite")
        
        if !( (try? finalDatabaseURL.checkResourceIsReachable()) ?? false) {
            print("DB does not exist in documents folder")
            
            let documentsURL = Bundle.main.resourceURL?.appendingPathComponent("db.sqlite")
            
            do {
                try fileManager.copyItem(atPath: (documentsURL?.path)!, toPath: finalDatabaseURL.path)
            } catch let error as NSError {
                print("Couldn't copy file to final location! Error:\(error.description)")
            }
            
        } else {
            print("Database file found at path: \(finalDatabaseURL.path)")
        }
        
    }

    init() {
        do {
            
            copyDatabaseIfNeeded ()
            
            let fileManager = FileManager.default
            
            let documentsUrl = fileManager.urls(for: .documentDirectory,
                                                in: .userDomainMask)
            
            guard documentsUrl.count != 0 else {
                return // Could not find documents URL
            }
            
            let finalDatabaseURL = documentsUrl.first!.appendingPathComponent("db.sqlite")
            
            
            db = try Connection(finalDatabaseURL.absoluteString)
            
        } catch {
            print("Exception : File Read")
        }
    }
    
    func updateFavouriteState(wordId: Int, updatedState: Bool) {
        
//        let words = Table(Constants.TableName)
//        let id = Expression<Int64>(Constants.TableColumnId)
//        let isFavourite = Expression<Bool>(Constants.TableColumnIsFavourite)
//        let meaning = Expression<String>(Constants.TableColumnMeaning)
//
//        
//        let alice = words.filter(wordId == id)
//        try db.run(alice.update(isFavourite <- isFavourite.replace(0, with: updatedState)))
        do {
//            try db?.run(alice.update(isFavourite <- isFavourite.replace(false, with: false)))
            try db?.run("UPDATE grewl SET isfavourite = '\(updatedState ? "1":"0")' WHERE (id = \(wordId))")
//            UPDATE grewl SET isfavourite = 1 WHERE (id = 2)
        } catch {
            print("Exception : Databaase Update \(error)")
        }

    }
    
    func getWordList() -> [Word] {
        
        var wordList: [Word] = []
        
        let words = Table(Constants.TableName)
        let id = Expression<Int64>(Constants.TableColumnId)
        let word = Expression<String?>(Constants.TableColumnWord)
        let meaning = Expression<String>(Constants.TableColumnMeaning)
        let isFavourite = Expression<Bool>(Constants.TableColumnIsFavourite)
        
        do {
            guard let entries = try db?.prepare(words) else {
                return wordList
            }
            
            for entry in entries {
                let aWord: Word = Word()
                aWord.word = entry[word]!
                aWord.meaning = entry[meaning]
                aWord.isFavourite = entry[isFavourite]
                aWord.identifier = Int(entry[id])
                
                wordList.append(aWord)
            }
        } catch {
            
        }
        
        return wordList
    }
}
