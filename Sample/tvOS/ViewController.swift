//
//  ViewController.swift
//  tvOS
//
//  Created by Meniny on 2017-07-25.
//  Copyright © 2017年 Meniny. All rights reserved.
//

import UIKit
import Imagery

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = URL(string: "https://i.loli.net/2017/07/25/597765d9704f0.png") {
            
            let placeholder = UIImage(named: "placeholder")
            //let placeholder = #imageLiteral(resourceName: "placeholder")
            
            imageView.imagery.setImage(with: url,
                                       placeholder: placeholder,
                                       options: nil,
                                       progressBlock: nil,
                                       completionHandler: nil)
        }
    }


}

