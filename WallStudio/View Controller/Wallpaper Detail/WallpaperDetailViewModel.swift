//
//  WallpaperDetailViewModel.swift
//  WallStudio
//
//  Created by Andrei Rybak on 3/3/19.
//  Copyright © 2019 GF. All rights reserved.
//

import Foundation
import UIKit
import Parse
import ReactiveSwift
import Result

protocol WallpaperDetailViewModelType {
    var wallpapers: [PFObject] { get }
    var selectedWallpaperIndex: Int { get set }
    var selectedWallpaperImage: SignalProducer<UIImage, NoError> { get }
    var numberOfLikes: Int { get }
    var currentTime: String { get }
    var currentDate: String { get }
}

class WallpaperDetailViewModel: WallpaperDetailViewModelType {

    init(wallpapers: [PFObject], selectedWallpaperIndex: Int) {
        self.wallpapers = wallpapers
        self.selectedWallpaperIndex = selectedWallpaperIndex
    }

    var wallpapers: [PFObject]

    var selectedWallpaperIndex: Int

    var selectedWallpaperImage: SignalProducer<UIImage, NoError> {
        return SignalProducer { [weak self] observer, _ in
            guard let self = self else { return }
            let selectedWallpaper = self.wallpapers[self.selectedWallpaperIndex]
            let imageFile = selectedWallpaper[WALLPAPERS_IMAGE] as? PFFileObject
            imageFile?.getDataInBackground(block: { (data, error) in
                guard error == nil,
                    let imageData = data,
                    let image = UIImage(data: imageData) else {
                        return
                }
                observer.send(value: image)
                observer.sendCompleted()
            })
        }
    }

    var numberOfLikes: Int {
        let selectedWallpaper = wallpapers[selectedWallpaperIndex]
        if selectedWallpaper[WALLPAPERS_LIKES] != nil {
            guard let likes = selectedWallpaper[WALLPAPERS_LIKES] as? Int else {
                return 0
            }
            return likes
        } else {
            return 0
        }
    }

    var currentTime: String {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        return "\(hour):\(minutes)"
    }

    var currentDate: String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "EEEE, MMMM d"
        let date = dateFormater.string(from: Date())
        return date
    }
}

