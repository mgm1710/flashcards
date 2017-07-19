//
//  FlashListViewController.swift
//  flashcards
//
//  Created by Mehul Mewada on 7/19/17.
//  Copyright © 2017 XYZ. All rights reserved.
//

import UIKit

class FlashListViewController: UIViewController {
    @IBOutlet weak var flashListView: UITableView!
    var wordList: [Word] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let db = DatabaseManager.sharedInstance
        self.wordList = db.getWordList()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension FlashListViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FlashListViewCell = tableView.dequeueReusableCell(withIdentifier: "flashListViewCellIdentifier", for: indexPath) as! FlashListViewCell
        cell.word = wordList[indexPath.row]
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1//sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.wordList.count// sections[section].count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension;
    }
}

class FlashListViewCell: UITableViewCell {
    var word: Word = Word() {
        didSet {
            self.wordLabel.text = word.word
            self.wordLabel.backgroundColor = UIColor.clear
            self.isFavouriteButton.setImage(UIImage(named:"star"), for: UIControlState.normal)
            if word.isFavourite {
                self.isFavouriteButton.setImage(UIImage(named:"star_selected"), for: UIControlState.normal)
            }
            self.meaningLabel.text = word.meaning
            self.meaningLabel.backgroundColor = UIColor.clear
        }
    }
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
    @IBOutlet weak var isFavouriteButton: UIButton!
    @IBAction func isFavouriteTapped(_ sender: Any) {
        let changedWord: Word = word
        changedWord.isFavourite = !word.isFavourite
        self.word = changedWord
        DatabaseManager.sharedInstance.updateFavouriteState(wordId: changedWord.identifier, updatedState: changedWord.isFavourite)
        
    }
}
