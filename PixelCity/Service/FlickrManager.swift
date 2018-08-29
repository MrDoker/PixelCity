//
//  FlickrManager.swift
//  PixelCity
//
//  Created by DokeR on 29.08.2018.
//  Copyright © 2018 DokeR. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

class FlickrManager {
    static let instance = FlickrManager()
    
    var imageUrlArray = [String]()
    
    func flickrURL(apiKey: String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int) -> String{
        return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=km&per_page=\(number)&format=json&nojsoncallback=1"
    }
    
    func retriveUrls(forAnnotation annotation: DroppablePin, handler: @escaping (_ success: Bool)->()) {
        imageUrlArray.removeAll()
        
        let url = flickrURL(apiKey: apiKey, withAnnotation: annotation, andNumberOfPhotos: 40)
        
        Alamofire.request(url).responseJSON { (response) in
            print(response)
        }
    }
}








