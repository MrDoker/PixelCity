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
    
    var imageToDisplay: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = imageToDisplay
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }
    
    @objc func dismissVC() {
        dismiss(animated: true, completion: nil)
    }

}
