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
import SwiftyJSON

class FlickrManager {
    static let instance = FlickrManager()
    
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
    
    private func flickrURL(apiKey: String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int) -> String{
        return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=km&per_page=\(number)&format=json&nojsoncallback=1"
    }
    
    
    func retriveUrls(forAnnotation annotation: DroppablePin, handler: @escaping (_ success: Bool)->()) {
        imageUrlArray.removeAll()
        imageArray.removeAll()
        
        let url = flickrURL(apiKey: apiKey, withAnnotation: annotation, andNumberOfPhotos: 40)
        
        Alamofire.request(url).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.data else { return }
                do{
                    if let json = try JSON(data: data).dictionaryObject {
                        
                        let photosJSON = JSON(json["photos"] as Any)
                        let photosJsonArray = JSON(photosJSON["photo"]).array
                        for photo in photosJsonArray! {
                            let farm = photo["farm"].int
                            let server = photo["server"].string
                            let id = photo["id"].string
                            let secret = photo["secret"].string
                            
                            let postURL = "https://farm\(farm!).staticflickr.com/\(server!)/\(id!)_\(secret!)_h_d.jpg"
                            self.imageUrlArray.append(postURL)
                        }
                        handler(true)
                    }
                } catch {
                    print(error)
                    handler(false)
                }
            } else {
                handler(false)
                debugPrint(response.result.error as Any)
            }
        }
    }
    
    func retrieveImages(label: UILabel,handeler: @escaping (_ success:Bool)->()) {
        for imageURL in imageUrlArray {
            Alamofire.request(imageURL).responseImage { (response) in
                guard let image = response.result.value else  {return}
                self.imageArray.append(image)
                label.text = "\(self.imageArray.count)/\(self.imageUrlArray.count) IMAGES DOWNLOADED"
                
                if self.imageArray.count == self.imageUrlArray.count {
                    handeler(true)
                }
            }
        }
    }
    
    func cancelAllSessions() {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach({ $0.cancel() })
            downloadData.forEach({ $0.cancel() })
        }
    }
    
}








