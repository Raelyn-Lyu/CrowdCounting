//
//  ViewController.swift
//  CrowdCounting
//
//  Created by Raelyn Lyu on 28/4/19.
//  Copyright © 2019 Raelyn Lyu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var StartButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        UIFuncs.setBorder(layer: StartButton.layer, width: 1, cornerRadius: 8, color: #colorLiteral(red: 0, green: 0.6196078431, blue: 0.7058823529, alpha: 1))
    }


}

