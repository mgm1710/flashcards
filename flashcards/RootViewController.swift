//
//  RootViewController.swift
//  flashcards
//
//  Created by Mehul Mewada on 8/8/17.
//  Copyright © 2017 XYZ. All rights reserved.
//

import UIKit
import XLPagerTabStrip

enum WordLearningState: Int {
    case New = 0, Learning, Learnt
}

protocol RootSearchDelegate {
    func rootSearchBar(_ rootSearchBar: UISearchBar, textDidChange rootSearchText: String)
    func rootSearchBarTextDidEndEditing(_ rootSearchBar: UISearchBar)
    func rootSearchBarCancelButtonClicked(_ rootSearchBar: UISearchBar)
    func rootSearchBarSearchButtonClicked(_ rootSearchBar: UISearchBar)
    func rootDidSwipeToVisibility()
}

class RootViewController: ButtonBarPagerTabStripViewController {

    lazy var searchBar = UISearchBar(frame: CGRect.zero)
    var rootSearchDelegate:RootSearchDelegate?
    let purpleInspireColor = UIColor(red:0.13, green:0.03, blue:0.25, alpha:1.0)

    
    override func viewDidLoad() {
        
        self.navigationController?.hidesBarsOnSwipe = true
        
        self.setupSearchbar()
        self.setupTabbarItems()

        super.viewDidLoad()
    }
    
    func setupSearchbar() {
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
    }
    
    func setupTabbarItems() {
        // change selected bar color
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = purpleInspireColor
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .black
            newCell?.label.textColor = self?.purpleInspireColor
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                print("in index change progressive : \((self?.currentIndex)!) and progress is : \(progressPercentage)")
            }
            

            let vc: UIViewController = (self?.viewControllers[(self?.currentIndex)!])!

            self?.searchBar.text = ""
            self?.searchBar.resignFirstResponder()
            self?.rootSearchDelegate?.rootDidSwipeToVisibility()
            if let currentVC = vc as? RootSearchDelegate {
                self?.rootSearchDelegate = currentVC
                print("current vc does confirm the rootsearchdelegate protocol: \(vc.description)")
            } else {
                print("current vc does not confirm the rootsearchdelegate protocol")
            }
        }
    }
    
    override public func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child_1 : FlashListViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FlashListViewController") as! FlashListViewController
        child_1.wordLearningState = WordLearningState.New

        let child_2 : FlashListViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FlashListViewController") as! FlashListViewController
        child_2.wordLearningState = WordLearningState.Learning

        let child_3 : FlashListViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FlashListViewController") as! FlashListViewController
        child_3.wordLearningState = WordLearningState.Learnt

        //        let child_2 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FavouriteListViewController")
        return [child_1, child_2, child_3]
    }
    
    
    func hideKeyboard() {
        self.searchBar.resignFirstResponder()
        self.view.endEditing(true)
    }
    
}

extension RootViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("item searched : \(searchText)" )
        self.rootSearchDelegate?.rootSearchBar(searchBar, textDidChange: searchText)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.rootSearchDelegate?.rootSearchBarTextDidEndEditing(searchBar)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.rootSearchDelegate?.rootSearchBarCancelButtonClicked(searchBar)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.rootSearchDelegate?.rootSearchBarSearchButtonClicked(searchBar)
        self.hideKeyboard()
    }
}
