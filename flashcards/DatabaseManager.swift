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
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
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
            let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
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
        do {
            try db?.run("UPDATE \(Constants.TableName) SET \(Constants.TableColumnIsFavourite) = '\(updatedState ? "1":"0")' WHERE (\(Constants.TableColumnId) = \(wordId))")
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
            print("Exception : Word List Reading Error \(error)")
        }
        return wordList
    }
    
    func getFavouriteWordList() -> [Word] {
        
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
                if(aWord.isFavourite) {
                    wordList.append(aWord)
                }
            }
        } catch {
            print("Exception : Word List Reading Error \(error)")
        }
        return wordList
    }

}
