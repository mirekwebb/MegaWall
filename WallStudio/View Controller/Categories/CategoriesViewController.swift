//
//  CategoriesViewController.swift
//  WallStudio
//
//  Created by Andrei Rybak on 2/27/19.
//  Copyright © 2019 GF. All rights reserved.
//

import UIKit
import Parse

class CategoriesViewController: UIViewController {

    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var categoriesTableView: UITableView!
    
    private var categoriesArray = [PFObject]()

    override func viewDidLoad() {
        super.viewDidLoad()

        categoriesTableView.register(UINib(nibName: "CategoriesTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoriesTableViewCell")

        queryCategories()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    private func setupNavigationBar() {
        navigationController?.isNavigationBarHidden = false

        title = "Browse".uppercased()

        let backButton = UIBarButtonItem(title: "BACK", style: .plain, target: self, action: #selector(backButtonPressed(_:)))
        backButton.tintColor = .white
        navigationItem.leftBarButtonItem = backButton

        let refreshButton = UIBarButtonItem(title: "REFRESH", style: .plain, target: self, action: #selector(refreshButtonPressed(_:)))
        refreshButton.tintColor = .white
        navigationItem.rightBarButtonItem = refreshButton
    }

    private func queryCategories() {
        showHUD(with: "Loading...")

        let query = PFQuery(className: CATEGORIES_CLASS_NAME)

        // Search
        if searchBar.text != "" {
            let searchStr = searchBar.text!.capitalized
            query.whereKey(CATEGORIES_NAME, contains: searchStr)
        }

        query.findObjectsInBackground { [weak self] (objects, error) in
            guard let self = self else {
                return
            }

            if error == nil {
                self.categoriesArray = objects!
                self.categoriesTableView.reloadData()
                self.hideHUD()
            } else {
                self.hideHUD()
                self.showSimpleAlert(with: "\(error!.localizedDescription)")
            }
        }
    }

    // Back Button
    @objc private func backButtonPressed(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }

    // Refresh Button
    @objc private func refreshButtonPressed(_ sender: AnyObject) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false

        queryCategories()
    }

}

// MARK: UITableViewDataSource

extension CategoriesViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoriesTableViewCell", for: indexPath) as! CategoriesTableViewCell

        let catClass = categoriesArray[indexPath.row]

        let imageFile = catClass[CATEGORIES_THUMB] as? PFFileObject

        imageFile?.getDataInBackground(block: { (data, error) in
            guard error == nil,
                let imageData = data else {
                    return
            }
            cell.update(image: UIImage(data: imageData))
        })

        let categoriesTableCellViewModel = CategoriesTableCellViewModel(posterImage: nil, title: "\(catClass[CATEGORIES_NAME]!)")
        cell.configure(with: categoriesTableCellViewModel)

        return cell
    }

}

// MARK: UITableViewDelegate

extension CategoriesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }

    // Show Wallpapers
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        view.endEditing(true)

        var categoriesClass = PFObject(className: CATEGORIES_CLASS_NAME)
        categoriesClass = categoriesArray[indexPath.row]

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let wallGridViewController = storyboard.instantiateViewController(withIdentifier: "WallGrid") as! WallGrid
        wallGridViewController.categoryName = "\(categoriesClass[CATEGORIES_NAME]!)"
        wallGridViewController.isFavorites = false
        navigationController?.pushViewController(wallGridViewController, animated: true)
    }
}

// MARK: UISearchBarDelegate

extension CategoriesViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        queryCategories()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        queryCategories()
    }
}
