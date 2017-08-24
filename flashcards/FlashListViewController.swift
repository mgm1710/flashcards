//
//  FlashListViewController.swift
//  flashcards
//
//  Created by Mehul Mewada on 7/19/17.
//  Copyright © 2017 XYZ. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class FlashListViewController: UIViewController {
    @IBOutlet weak var flashListView: UITableView!
    var wordList: [Word] = []
    var searchedWordList: [Word] = []
    var searchActive : Bool = false
    var wordLearningState: WordLearningState = WordLearningState.New
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let db = DatabaseManager.sharedInstance
        self.wordList = db.getWordList(forWordLearningState: self.wordLearningState)
        self.automaticallyAdjustsScrollViewInsets = false
        self.flashListView.tableFooterView = UIView()
    }
}

extension FlashListViewController: RootSearchDelegate {
    
    func rootDidSwipeToVisibility() {
        self.searchActive = false;
        self.flashListView.reloadData()
    }
    
    func rootSearchBar(_ rootSearchBar: UISearchBar, textDidChange rootSearchText: String) {
        self.searchActive = true;
        self.searchedWordList = self.wordList.filter({ (word) -> Bool in
            let aWord: Word = word
            
            let range = (aWord.word as NSString).range(of: rootSearchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        
        if(self.searchedWordList.count == 0) {
            self.searchActive = false;
        } else {
            self.searchActive = true;
        }
        self.flashListView.reloadData()
    }
    
    func rootSearchBarTextDidEndEditing(_ rootSearchBar: UISearchBar) {
        self.searchActive = false;
    }
    
    func rootSearchBarCancelButtonClicked(_ rootSearchBar: UISearchBar) {
        self.searchActive = false;
    }
    
    func rootSearchBarSearchButtonClicked(_ rootSearchBar: UISearchBar) {
        self.searchActive = false;
    }
}

extension FlashListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FlashListViewCell = tableView.dequeueReusableCell(withIdentifier: "flashListViewCellIdentifier", for: indexPath) as! FlashListViewCell
        
        if self.searchActive {
            cell.word = self.searchedWordList[indexPath.row]
        } else {
//            let aWord: Word = self.wordList[indexPath.row]
//            if case self.wordLearningState = aWord.wordLearningState {
                cell.word = self.wordList[indexPath.row]
//            }
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

extension FlashListViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        switch self.wordLearningState {
        case WordLearningState.New:
            return IndicatorInfo(title: "All")
        case WordLearningState.Learning:
            return IndicatorInfo(title: "Learning")
        case WordLearningState.Learnt:
            return IndicatorInfo(title: "Learnt")
        }
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
            switch word.wordLearningState {
                case WordLearningState.New:
                    self.isFavouriteButton.setImage(UIImage(named:"learning"), for: UIControlState.normal)
                    break
                case WordLearningState.Learning:
                    self.isFavouriteButton.setImage(UIImage(named:"learnt"), for: UIControlState.normal)
                    break
                case WordLearningState.Learnt:
                    self.isFavouriteButton.setImage(UIImage(named:"learning"), for: UIControlState.normal)
                    break
            }
            self.meaningLabel.text = word.meaning
            self.meaningLabel.backgroundColor = UIColor.clear
        }
    }
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
    @IBOutlet weak var isFavouriteButton: UIButton!
    
    @IBAction func actionButtonTapped (_ sender: Any) {
        let changedWord: Word = word
        changedWord.isFavourite = !word.isFavourite
        self.word = changedWord
        DatabaseManager.sharedInstance.updateFavouriteState(wordId: changedWord.identifier, updatedState: changedWord.isFavourite)
    }
    
    @IBAction func isFavouriteTapped(_ sender: Any) {
        let changedWord: Word = word
        
        if case changedWord.wordLearningState = WordLearningState.New {
            changedWord.wordLearningState = WordLearningState.Learning
        } else if case changedWord.wordLearningState = WordLearningState.Learning {
            changedWord.wordLearningState = WordLearningState.Learnt
        } else if case changedWord.wordLearningState = WordLearningState.Learnt {
            changedWord.wordLearningState = WordLearningState.Learning
        }
        
        self.word = changedWord
        DatabaseManager.sharedInstance.updateWordLearningState(wordId: changedWord.identifier, toState: changedWord.wordLearningState)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.meaningLabel.font = UIFont (name: "HelveticaNeue-UltraLight", size: 14)
    }
    
}
