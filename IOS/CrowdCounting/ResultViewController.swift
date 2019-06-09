//
//  ResultViewController.swift
//  CrowdCounting
//
//  Created by Raelyn Lyu on 3/5/19.
//  Copyright © 2019 Raelyn Lyu. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage
class ResultViewController: UIViewController {
    
    
    
    @IBAction func restart(_ sender: Any) {
        let imageData = resultView.image!.pngData()
        let compresedImage = UIImage(data: imageData!)
        UIImageWriteToSavedPhotosAlbum(compresedImage!, nil, nil, nil)
        
        let alert = UIAlertController(title: "Saved", message: "Your image has been saved", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    @IBOutlet weak var resultView: UIImageView!
    @IBOutlet weak var lable: UILabel!
    var returnImg: String = "dsfd"
    var totalPpl: String = "dsfd"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.returnImg)
        let res = WebAPIUrls.fetchURL + self.returnImg
        let url = URL(string: res)!
        print(self.totalPpl)
        resultView.af_setImage(withURL: url)
        self.lable.text = self.totalPpl
        
        
    }
    
    
}
