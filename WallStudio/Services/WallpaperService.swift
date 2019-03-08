//
//  WallpaperService.swift
//  WallStudio
//
//  Created by Andrei Rybak on 3/8/19.
//  Copyright © 2019 GF. All rights reserved.
//

import Foundation
import Parse

typealias WallpaperServiceCompletion = (_ success: Bool, _ error: Error?) -> ()
typealias WallpaperServiceDownloadImageCompletion = (_ image: UIImage?, _ error: Error?) -> ()

protocol WallpaperServiceType {
    func getImage(for wall: PFObject, completion: @escaping WallpaperServiceDownloadImageCompletion)
    func usersWhoFavorite(wallpaper wall: PFObject) -> [String]
    func usersWhoLiked(wallpaper wall: PFObject) -> [String]
    func likes(for wall: PFObject) -> Int
    func like(wallpaper wall: PFObject, with userId: String, completion: WallpaperServiceCompletion?)
    func dislike(wallpaper wall: PFObject, with userId: String, completion: WallpaperServiceCompletion?)
    func addToFavorites(wallpaper wall: PFObject, with userId: String, completion: WallpaperServiceCompletion?)
    func removeFromFavorits(wallpaper wall: PFObject, with userId: String, completion: WallpaperServiceCompletion?)
    func report(wallpaper wall: PFObject, completion: WallpaperServiceCompletion?)
}

class WallpaperService: WallpaperServiceType {

    func getImage(for wall: PFObject, completion: @escaping WallpaperServiceDownloadImageCompletion) {
        guard let imageFile = wall[WALLPAPERS_IMAGE] as? PFFileObject else {
            completion(nil, nil)
            return
        }
        imageFile.getDataInBackground(block: { (data, error) in
            guard error == nil,
                let imageData = data,
                let image = UIImage(data: imageData) else {
                    completion(nil, error)
                    return
            }
            completion(image, error)
        })
    }

    func usersWhoLiked(wallpaper wall: PFObject) -> [String] {
        guard let usersWhoLiked = wall[WALLPAPERS_LIKED_BY] as? [String] else {
            return []
        }
        return usersWhoLiked
    }

    func usersWhoFavorite(wallpaper wall: PFObject) -> [String] {
        guard let usersWhoFavorite = wall[WALLPAPERS_FAVORITED_BY] as? [String] else {
            return []
        }
        return usersWhoFavorite
    }

    func likes(for wall: PFObject) -> Int {
        if wall[WALLPAPERS_LIKES] != nil {
            guard let likes = wall[WALLPAPERS_LIKES] as? Int else {
                return 0
            }
            return likes
        } else {
            return 0
        }
    }

    func like(wallpaper wall: PFObject, with userId: String, completion: WallpaperServiceCompletion?) {
        var likedBy = usersWhoLiked(wallpaper: wall)
        likedBy.append(userId)
        wall.incrementKey(WALLPAPERS_LIKES, byAmount: 1)
        wall[WALLPAPERS_LIKED_BY] = likedBy
        wall.saveInBackground { (success, error) in
            completion?(success, error)
        }
    }

    func dislike(wallpaper wall: PFObject, with userId: String, completion: WallpaperServiceCompletion?) {
        var likedBy = usersWhoLiked(wallpaper: wall)
        likedBy = likedBy.filter { $0 != userId }
        wall.incrementKey(WALLPAPERS_LIKES, byAmount: -1)
        wall[WALLPAPERS_LIKED_BY] = likedBy
        wall.saveInBackground(block: { (success, error) in
            completion?(success, error)
        })
    }

    func addToFavorites(wallpaper wall: PFObject, with userId: String, completion: WallpaperServiceCompletion?) {
        var favoriteBy = usersWhoFavorite(wallpaper: wall)
        favoriteBy.append(userId)
        wall[WALLPAPERS_FAVORITED_BY] = favoriteBy
        wall.saveInBackground { (success, error) in
            completion?(success, error)
        }
    }

    func removeFromFavorits(wallpaper wall: PFObject, with userId: String, completion: WallpaperServiceCompletion?) {
        var favoriteBy = usersWhoFavorite(wallpaper: wall)
        favoriteBy = favoriteBy.filter { $0 != userId }
        wall[WALLPAPERS_FAVORITED_BY] = favoriteBy
        wall.saveInBackground { (success, error) in
            completion?(success, error)
        }
    }

    func report(wallpaper wall: PFObject, completion: WallpaperServiceCompletion?) {
        wall[WALLPAPERS_IS_PENDING] = true
        wall[WALLPAPERS_REPORT_MESSAGE] = "Reported as Inappropriate"
        wall.saveInBackground(block: { (success, error) in
            completion?(success, error)
        })
    }
}
