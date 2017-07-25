//
//  ViewController.swift
//  Sample
//
//  Created by Meniny on 2017-07-25.
//  Copyright © 2017年 Meniny. All rights reserved.
//

import UIKit
import Imagery

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let url = URL(string: "https://i.loli.net/2017/07/25/597765d9704f0.png") {
        
            let placeholder = UIImage(named: "placeholder")
            //let placeholder = #imageLiteral(resourceName: "placeholder")
            
            button.tintColor = .clear
            
            button.imagery.setBackgroundImage(with: url, for: .normal)
            
            imageView.imagery.setImage(with: url,
                                       placeholder: placeholder,
                                       options: nil,
                                       progressBlock: nil,
                                       completionHandler: nil)
        }
    }

}

