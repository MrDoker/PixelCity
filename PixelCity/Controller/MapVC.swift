//
//  ViewController.swift
//  PixelCity
//
//  Created by DokeR on 29.08.2018.
//  Copyright © 2018 DokeR. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
    
    var locationManager = CLLocationManager()
    let authorizationStatus =  CLLocationManager.authorizationStatus()
    let regionRadius = 1000.0
    
    var spinner: UIActivityIndicatorView?
    var progressLabel: UILabel?
    var collectionView: UICollectionView?
    var flowLayot = UICollectionViewFlowLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        addDoubleTap()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayot)
        collectionView?.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.9529411765, blue: 0.9529411765, alpha: 1)
        registerForPreviewing(with: self, sourceView: collectionView!)
        pullUpView.addSubview(collectionView!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        configureLocationService()
    }
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPinOnMap(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    func addSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    
    func animateViewUp() {
        pullUpViewHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func animateViewDown() {
        pullUpViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        FlickrManager.instance.cancelAllSessions()
    }
    
    func addSpinner() {
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: pullUpView.frame.width/2 - (spinner?.frame.width)!/2, y: 130)
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        spinner?.isHidden = false
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    
    func addProgressLabel() {
        if progressLabel != nil {
            progressLabel?.removeFromSuperview()
        }
        progressLabel = UILabel()
        progressLabel?.frame = CGRect(x: pullUpView.frame.width/2 - 125, y: 155, width: 250, height: 40)
        progressLabel?.font = UIFont(name: "Avenir Next", size: 18)
        progressLabel?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        progressLabel?.textAlignment = .center
        collectionView?.addSubview(progressLabel!)
    }
    
    
    
    @IBAction func centerMapViewBtnPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "presentPopImageVC" {
            let popVC = segue.destination as? PopImageVC
            popVC?.imageToDisplay = FlickrManager.instance.imageArray[sender as! Int]
        }
    }
}

extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9254901961, green: 0.6745098039, blue: 0.168627451, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius*2, regionRadius*2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func dropPinOnMap(sender: UITapGestureRecognizer) {
        mapView.removeAnnotations(mapView.annotations)
        
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        print("--------------")
        print(touchCoordinate)
        
        let annotation = DroppablePin(coordinate: touchCoordinate, identifer: "droppablePin")
        mapView.addAnnotation(annotation)
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius*2, regionRadius*2)
        mapView.setRegion(coordinateRegion, animated: true)
        
        animateViewUp()
        addSwipe()
        addSpinner()
        addProgressLabel()
        FlickrManager.instance.cancelAllSessions()
        collectionView?.reloadData()
        
        FlickrManager.instance.retriveUrls(forAnnotation: annotation) { (success) in
            if success {
                FlickrManager.instance.retrieveImages(label: self.progressLabel!, handeler: { (success) in
                    if success {
                        self.spinner?.removeFromSuperview()
                        self.progressLabel?.removeFromSuperview()
                        self.collectionView?.reloadData()
                    }
                })
            }
        }
    }
}

extension MapVC: CLLocationManagerDelegate {
    func configureLocationService() {
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else if authorizationStatus == .denied {
            let alert = UIAlertController(title: "App can find your location(", message: "You need to allow the app to use location in Setting", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Lets go and do this", style: .default, handler: { (_) in
                if let url = URL(string:UIApplicationOpenSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
}

extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FlickrManager.instance.imageArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCollectionViewCell {
            let imageView = UIImageView(image: FlickrManager.instance.imageArray[indexPath.row])
            imageView.contentMode = .scaleAspectFill
            cell.addSubview(imageView)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "presentPopImageVC", sender: indexPath.row)
    }
}

extension MapVC: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView?.indexPathForItem(at: location), let cell = collectionView?.cellForItem(at: indexPath) else { return nil}
        
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "popVC") as? PopImageVC else { return nil}
        popVC.imageToDisplay = FlickrManager.instance.imageArray[indexPath.row]
        previewingContext.sourceRect = cell.contentView.frame
        return popVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    
}







