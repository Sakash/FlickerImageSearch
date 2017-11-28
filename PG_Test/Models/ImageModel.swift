//
//  ImageModel.swift
//  PG_Test
//
//  Created by Sakshi Jain on 25/11/17.
//  Copyright © 2017 Sakshi. All rights reserved.
//

import UIKit

class ImageModel: NSObject
{
    var thumbnail : UIImage?
    var largeImageURL : URL?
    let photoID : String
    let farm : Int
    let server : String
    let secret : String
    
    init (photoID:String,farm:Int, server:String, secret:String) {
        self.photoID = photoID
        self.farm = farm
        self.server = server
        self.secret = secret
        
        if let url =  URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret).jpg") {
            self.largeImageURL = url
        }
        else
        {
            self.largeImageURL = nil
        }
    }
    
    func ImageURL() -> URL? {
        if let url =  URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret).jpg") {
            return url
        }
        return nil
    }
}

class ImageModelCollection: NSObject
{
    var imgArray: NSMutableArray = NSMutableArray()
    
    init(json:NSDictionary) {
        
        let photoArray : NSArray = json.value(forKey: "photo") as! NSArray
        for photoObject in photoArray
        {
            guard let photoID : String = (photoObject as AnyObject).value(forKey: "id") as? String,
                let farm : Int = (photoObject as AnyObject)["farm"] as? Int ,
                let server : String = (photoObject as AnyObject)["server"] as? String ,
                let secret : String = (photoObject as AnyObject)["secret"] as? String else {
                    break
            }
            let image = ImageModel(photoID: photoID, farm: farm, server: server, secret: secret)
            self.imgArray.add(image)
        }
    }
}
