//
//  DetailsViewController.swift
//  MemeMe
//
//  Created by Ischuk Alexander on 16.05.2020.
//  Copyright © 2020 Ischuk Alexander. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView?.image = image
    }
}
