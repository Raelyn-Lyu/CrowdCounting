//
//  SelectImgViewController.swift
//  CrowdCounting
//
//  Created by Raelyn Lyu on 29/4/19.
//  Copyright © 2019 Raelyn Lyu. All rights reserved.
//

import UIKit
import PhotosUI
import YPImagePicker


class SelectImgViewcontroller: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    private var selectedImage: UIImage?


    
    var picker:YPImagePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
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
        config.onlySquareImagesFromCamera = true
        config.targetImageSize = .original
        config.usesFrontCamera = true
        config.showsFilters = true
        config.screens = [.library, .photo]
        config.hidesStatusBar = false
        config.usesFrontCamera = false
        
        config.showsCrop = .rectangle(ratio: (1/1))

        
        picker = YPImagePicker(configuration: config)
        
        picker.didFinishPicking { [picker] items, _ in
            if let photo = items.singlePhoto {
                self.imageView.image = photo.image
                self.selectedImage = photo.image
            }
            
            self.picker.dismiss(animated: true, completion: nil)
        }
        
    }
    
    //    override func viewWillAppear(_ animated: Bool) {
    //        self.imageView.image = #imageLiteral(resourceName: "tap-to-add")
    //    }
    
    
    

    @IBAction func upload(_ sender: Any) {
        
        self.selectedImage = imageView.image
        if let image = selectedImage{
            image.af_inflate()
            WebAPIHandler.shared.upload(image: image){ response in
                switch response.result{
                case .failure(let error):
                    print(error.localizedDescription)
                    UIFuncs.popUp(title: "Error", info: "Upload failed, \(error.localizedDescription)", type: UIFuncs.BlockPopType.warning , sender: self, callback: {})
                case .success(_):
                    UIFuncs.popUp(title: "Succ", info: "Post successfully.", type: .success , sender: self, callback: {})
                    self.imageView.image = #imageLiteral(resourceName: "tap-to-add")
                    self.selectedImage = nil
                    
                }
            }
        }else{
            UIFuncs.popUp(title: "Warning", info: "Please select an image first", type: .caution, sender: self, callback:{})
        }
    }
    
    
    
    @IBAction func imagePickerY(_ sender: Any) {
        
    }
    
}


extension SelectImgViewcontroller: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    
    
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

