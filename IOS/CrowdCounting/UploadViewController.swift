//
//  UploadViewController.swift
//  CrowdCounting
//
//  Created by Raelyn Lyu on 29/4/19.
//  Copyright © 2019 Raelyn Lyu. All rights reserved.
//

import Foundation
import UIKit
import PhotosUI
import YPImagePicker
import FirebaseDatabase


class UploadViewController: UIViewController,UITextFieldDelegate {
    
//    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var Upload: UIButton!
    @IBOutlet weak var CheckResult: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    var window: UIWindow?
    
    var currentLocation:(address:String,lati:CLLocationDegrees?,logi:CLLocationDegrees?) = (address:"N/A",lati:nil,logi:nil){
        didSet{
            print(currentLocation)
        }
    }
    
    private var selectedImage: UIImage?
    var returnImg = String()
    var number = String()
    
    let locationManager = CLLocationManager()
    var picker:YPImagePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if checkLocationPermission(){
            self.getLocationAsyn()
        }
//        print(self.currentLocation)
        CheckResult.isHidden = true
        // add tap gesture for image view to allow select image
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.showActionSheet))
        
        // add it to the image view;
        imageView.addGestureRecognizer(tapGesture)
        // make sure imageView can be interacted with by user
        imageView.isUserInteractionEnabled = true
        
        // 3rd photo library
        var config = YPImagePickerConfiguration()
        config.library.mediaType = .photoAndVideo
        config.library.onlySquare  = false
        config.onlySquareImagesFromCamera = false
        config.targetImageSize = .original
        config.usesFrontCamera = true
        config.showsFilters = false
        config.screens = [.library, .photo]
        config.hidesStatusBar = false
        config.usesFrontCamera = false
        
       // config.showsCrop = //.rectangle(ratio: (1/1))
        
        
        picker = YPImagePicker(configuration: config)
        
        picker.didFinishPicking { [picker] items, _ in
            if let photo = items.singlePhoto {
                self.imageView.image = photo.image
                self.selectedImage = photo.image
            }
            
            self.picker.dismiss(animated: true, completion: nil)
        }
        
    }
    public func checkLocationPermission() -> Bool{
        let authorizationStatus = CLLocationManager.authorizationStatus()
        switch authorizationStatus{
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            return true
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            return true
        case .restricted:
            return false
        case .denied:
            UIFuncs.popUp(title: "Opps", info: "This app does not have the permission to get your location information, please go to settings=>privacy to grant permission", type: .caution, sender: self, callback: {})
            return false
        }
        
        return false
    }
    
    //    override func viewWillAppear(_ animated: Bool) {
    //        self.imageView.image = #imageLiteral(resourceName: "tap-to-add")
    //    }
    
    
    @IBAction func upload(_ sender: Any) {
        self.selectedImage = imageView.image
        if let image = selectedImage{
            image.af_inflate()
            WebAPIHandler.shared.upload(photo: image){ response in
                switch response.result{
                case .failure(let error):
                    print(error.localizedDescription)
                    UIFuncs.popUp(title: "Error", info: "Upload failed, \(error.localizedDescription)", type: UIFuncs.BlockPopType.warning , sender: self, callback: {})
                case .success(_):
                    UIFuncs.popUp(title: "Succ", info: "Post successfully.", type: .success , sender: self, callback: {
                        //self.imageView.image = #imageLiteral(resourceName: "tap-to-add")
                        self.selectedImage = nil
                        let test = response.result.value
                        let JSON = test as! NSDictionary
                        self.returnImg = JSON["msg"] as! String
                        let total = JSON["sum"] as! Int
                        self.number = "Total:" + String(total)
                        
                        let loginView = ResultViewController()
                        loginView.returnImg = self.returnImg
                        self.Upload.isHidden = true
                        self.CheckResult.isHidden = false
                        print(self.currentLocation.address)
                        let ref = Database.database().reference()
                        let millisecond = Date().milliStamp
                        let lat = Double(self.currentLocation.lati ?? 0.0)
                        let logi = Double(self.currentLocation.logi ?? 0.0)
                        ref.child("records").child(millisecond).setValue(["Address":self.currentLocation.address,
                                                                           "Lat":lat,"Logi":logi,"Num":total])

                    })
                    
                    
                    
                }
            }
        }else{
            UIFuncs.popUp(title: "Warning", info: "Please select an image first", type: .caution, sender: self, callback:{})
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seeResult" {
        
            let commentTVC = segue.destination as! ResultViewController
            commentTVC.returnImg = self.returnImg
            commentTVC.totalPpl = self.number
            self.imageView.image = UIImage(named:"tap-to-add")
            
        }
    }
    
    @IBAction func imagePickerY(_ sender: Any) {
        
    }
    
}

extension Date {
    
    /// seconds
    var timeStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return "\(timeStamp)"
    }
    
    /// milli-seconds
    var milliStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        return "\(millisecond)"
    }
}

extension UploadViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var newImage: UIImage
        
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }
        let originalCIImage = CIImage(data: newImage.pngData()!)
        
        self.imageView.image = UIImage(ciImage:originalCIImage!)
        
        // do something interesting here!
        self.selectedImage = newImage
        self.imageView.image = newImage
        
        dismiss(animated: true)
    }
    
    
    func camera()
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.modalPresentationStyle = .popover
            myPickerController.sourceType = .camera
            myPickerController.allowsEditing = true
            
            self.present(myPickerController, animated: true, completion: nil)
        }
        
    }
    
    func photoLibrary()
    {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .photoLibrary
            myPickerController.allowsEditing = true
            self.present(myPickerController, animated: true, completion: nil)
        }
    }
    
    func checkPhotoPermission(hanler: @escaping () -> Void) {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            // Access is already granted by user
            hanler()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (newStatus) in
                if newStatus == PHAuthorizationStatus.authorized {
                    // Access is granted by user
                    hanler()
                }
            }
        default:
            print("Error: no access to photo album.")
        }
    }
    
    @objc func showActionSheet() {
        
        present(picker, animated: true, completion: nil)
    }
}


extension UploadViewController:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse{
            self.getLocationAsyn()
        }
    }
    
    func getCoordinate() -> (lati:CLLocationDegrees?,logi:CLLocationDegrees?){
        
        var lati:CLLocationDegrees?
        var logi:CLLocationDegrees?
        if let currentLocation = locationManager.location?.coordinate{
            lati = currentLocation.latitude
            logi = currentLocation.longitude
        }
        
        return (lati, logi)
        
    }
    
    func getLocationAsyn(){
        
        let coordinate = getCoordinate()
    
        var address: String = ""
        
        guard let lati = coordinate.lati, let logi = coordinate.logi else{
            print(22222)
            currentLocation.address = address
            currentLocation = (address:address,lati:nil,logi:nil)
            return
        }
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: lati, longitude: logi)
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            if let e = error{
                print("Reverse geocoder failed with error" + e.localizedDescription)
                self.currentLocation = (address:address,lati:nil,logi:nil)
                return
            }
            guard let placeMark = placemarks?[0] else{
                print("Problem with the data received from geocoder")
                self.currentLocation = (address:address,lati:nil,logi:nil)
                return
            }
            
            // Address dictionary
            //print(placeMark.addressDictionary ?? "")
            
            // Location name
            if let locationName = placeMark.name {
                address += "\(locationName),"
            }
            
            //            // Street address
            //            if let street = placeMark.thoroughfare {
            //                address += "\(street),"
            //            }
            
            // City
            if let city = placeMark.locality { // city
                address += "\(city),"
            }
            
            // Country
            if let country = placeMark.country{
                address += "\(country)"
            }
            
            self.currentLocation = (address:address,lati:lati,logi:logi)
            
        })
        
    }
}


