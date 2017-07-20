//
//  FlashListViewController.swift
//  flashcards
//
//  Created by Mehul Mewada on 7/19/17.
//  Copyright © 2017 XYZ. All rights reserved.
//

import UIKit

class FavouriteListViewController: UIViewController {
    @IBOutlet weak var favouriteListView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var wordList: [Word] = []
    var searchedWordList: [Word] = []
    var searchActive : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
//        let db = DatabaseManager.sharedInstance
//        self.wordList = db.getFavouriteWordList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let db = DatabaseManager.sharedInstance
        self.wordList = db.getFavouriteWordList()
        self.favouriteListView.reloadData()
    }
}

extension FavouriteListViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        self.searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.searchedWordList = self.wordList.filter({ (word) -> Bool in
            let aWord: Word = word
            
            let range = (aWord.word as NSString).range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        
        if(self.searchedWordList.count == 0) {
            self.searchActive = false;
        } else {
            self.searchActive = true;
        }
        self.favouriteListView.reloadData()
    }
    
}

extension FavouriteListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FavouriteListViewCell = tableView.dequeueReusableCell(withIdentifier: "favouriteListViewCellIdentifier", for: indexPath) as! FavouriteListViewCell
        
        if self.searchActive {
            cell.word = self.searchedWordList[indexPath.row]
        } else {
            cell.word = self.wordList[indexPath.row]
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1//sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchActive {
            return self.searchedWordList.count
        } else {
            return self.wordList.count// sections[section].count
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension;
    }
}

class FavouriteListViewCell: UITableViewCell {
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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.meaningLabel.font = UIFont (name: "HelveticaNeue-UltraLight", size: 14)
        self.isFavouriteButton.isHidden = true
    }
    
}
