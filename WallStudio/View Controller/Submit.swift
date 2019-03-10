//
//  SubmitWallpaper.swift
//  WallStudio
//
//  Created by Greenfield
//  Copyright (c) 2017 Greenfield.com. All rights reserved.
//

import UIKit
import Parse
import MessageUI

class CatCell: UITableViewCell {
    @IBOutlet var catImage: UIImageView!
    @IBOutlet var catNameLabel: UILabel!
}

class SubmitWallpaper: UIViewController, UIAlertViewDelegate, UINavigationControllerDelegate {

    @IBOutlet private var containerScrollView: UIScrollView!
    @IBOutlet private var categoriesTableView: UITableView!
    @IBOutlet private var wallImage: UIImageView!
    @IBOutlet private var submitOutlet: UIButton!

    private var categoriesArray = [PFObject]()
    private var categorieName = ""
    private var imageURL = URL(string: "")

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Upload Wallpaper".uppercased()
        categorieName = ""

        // Back BarButton
        let backButton = UIButton(type: .custom)
        backButton.adjustsImageWhenHighlighted = false
        backButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        backButton.setTitle("BACK", for: UIControlState.normal)
        backButton.titleLabel?.font = UIFont(name: "Montserrat-Regular", size: 12)
        backButton.setTitleColor(UIColor.white, for: UIControlState.normal)

        categoriesTableView.layer.cornerRadius = 5
        submitOutlet.layer.cornerRadius = 5

        containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: submitOutlet.frame.origin.y + 280)

        queryCategories()
    }

    func queryCategories() {
        showHUD(with: "Sync Data...")

        let query = PFQuery(className: CATEGORIES_CLASS_NAME)
        query.findObjectsInBackground { [weak self] (objects, error) in
            guard let self = self else {
                return
            }
            if error == nil {
                self.categoriesArray = objects!
                self.hideHUD()
                self.categoriesTableView.reloadData()
            } else {
                self.showSimpleAlert(with: "\(error!.localizedDescription)")
                self.hideHUD()
            }
        }
    }

    // Choose Image
    @IBAction func chooseImageButtonPressed(_ sender: AnyObject) {

        let alert = UIAlertController(title: APP_NAME,
                                      message: "Select source",
                                      preferredStyle: .alert)


        let cameraAction = UIAlertAction(title: "Take a picture", style: .default, handler: { (action) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        })


        let libraryAction = UIAlertAction(title: "Pick from Library", style: .default, handler: { (action) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action) -> Void in })

        alert.addAction(cameraAction)
        alert.addAction(libraryAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

    // Submit
    @IBAction func submitButtonPressed(_ sender: AnyObject) {
        if categorieName == "" || wallImage.image == nil {
            self.showSimpleAlert(with: "Please select a Category and Upload a Wallpaper")
            hideHUD()

        } else {
            showHUD(with: "Please wait...")

            let wallClass = PFObject(className: WALLPAPERS_CLASS_NAME)
            wallClass[WALLPAPERS_CATEGORY] = categorieName
            wallClass[WALLPAPERS_IS_PENDING] = true

            if wallImage.image != nil {
                let imageData = UIImageJPEGRepresentation(wallImage.image!, 0.8)
                let imageFile = PFFileObject(name: "wallp.jpg", data: imageData!)
                wallClass[WALLPAPERS_IMAGE] = imageFile
            }

            wallClass.saveInBackground(block: { [weak self] (succ, error) in
                guard let self = self else {
                    return
                }
                if error == nil {
                    self.openMailController()
                    self.hideHUD()

                } else {
                    self.showSimpleAlert(with: "\(error!.localizedDescription)")
                    self.hideHUD()
                }
            })
        }
    }

    // Open iOS Mail Controller
    func openMailController() {
        let mailComposer: MFMailComposeViewController = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setToRecipients([SUBMIT_EMAIL])
        mailComposer.setSubject("New Wallpaper Submission")

        // HTML String
        mailComposer.setMessageBody("Hello,<br>please check out this wallpaper I'm uploading, hope you can publish it.<br>You can eventually reply to: <strong>\(PFUser.current()!.email!)</strong><br><br>Thank you.<br>", isHTML: true)

        // Attach Wallpaper
        let imageData = UIImageJPEGRepresentation(wallImage.image!, 0.5)
        mailComposer.addAttachmentData(imageData!, mimeType: "image/jpg", fileName: "wallpaper.jpg")

        if MFMailComposeViewController.canSendMail() {
            present(mailComposer, animated: true, completion: nil)
        } else {
            self.showSimpleAlert(with: "Your device cannot send emails. Please configure an email address into Settings -> Mail, Contacts, Calendars.")
        }
    }

    // Back Button
    @objc private func backButtonPressed(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }

}

// MARK: UITableViewDataSource

extension SubmitWallpaper: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CatCell", for: indexPath) as! CatCell

        var categorieClass = PFObject(className: CATEGORIES_CLASS_NAME)
        categorieClass = categoriesArray[indexPath.row]

        let imageFile = categorieClass[CATEGORIES_THUMB] as? PFFileObject
        imageFile?.getDataInBackground(block: { (data, error) in
            guard error == nil,
                let imageData = data else {
                    return
            }
            cell.catImage.image = UIImage(data: imageData)
        })

        cell.catImage.layer.cornerRadius = 10
        cell.catNameLabel.text = "  \(categorieClass[CATEGORIES_NAME]!)"

        return cell
    }
}

// MARK: UITableViewDelegate

extension SubmitWallpaper: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var categorieClass = PFObject(className: CATEGORIES_CLASS_NAME)
        categorieClass = categoriesArray[indexPath.row]

        categorieName = "\(categorieClass[CATEGORIES_NAME]!)"
    }

}

// MARK: UIImagePickerControllerDelegate

extension SubmitWallpaper: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            wallImage.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}

// MARK: MFMailComposeViewControllerDelegate

extension SubmitWallpaper: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        var outputMessage = ""
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            outputMessage = "Mail cancelled"
        case MFMailComposeResult.saved.rawValue:
            outputMessage = "Mail saved"
        case MFMailComposeResult.sent.rawValue:
            outputMessage = "Thanks for submitting your Wallpaper. Our Staff review it soon."
        case MFMailComposeResult.failed.rawValue:
            outputMessage = "Something went wrong with sending Mail, try again later."
        default: break }

        showSimpleAlert(with: outputMessage)
        dismiss(animated: false, completion: nil)
    }

}
