//
//  PopImageVC.swift
//  PixelCity
//
//  Created by DokeR on 30.08.2018.
//  Copyright © 2018 DokeR. All rights reserved.
//

import UIKit

class PopImageVC: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descBgView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionlabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postedDateLabel: UILabel!
    
    var imageToDisplay: UIImage!
    var photo: Photo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = imageToDisplay
        titleLabel.text = photo.title
        descriptionlabel.text = photo.description
        if let intTime = Int(photo.dateUpload) {
            let date = NSDate(timeIntervalSince1970: TimeInterval(intTime))
            let newFormatter = DateFormatter()
            newFormatter.dateFormat = "MMM d, yyyy - HH:mm"
            dateLabel.text = newFormatter.string(from: date as Date)
        }
        
        
        descBgView.frame.size.height = dateLabel.frame.origin.y + dateLabel.frame.height + 8
        view.layoutSubviews()

        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }
    
    @objc func dismissVC() {
        dismiss(animated: true, completion: nil)
    }

}
