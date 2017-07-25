//
//  ViewController.swift
//  macOS
//
//  Created by Meniny on 2017-07-25.
//  Copyright © 2017年 Meniny. All rights reserved.
//

import Cocoa
import Imagery

class ViewController: NSViewController {
    
    @IBOutlet weak var imageView: NSImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let url = URL(string: "https://i.loli.net/2017/07/25/597765d9704f0.png") {
            
            let placeholder = NSImage(named: "placeholder")
            //let placeholder = #imageLiteral(resourceName: "placeholder")
            
            imageView.imagery.setImage(with: url,
                                       placeholder: placeholder,
                                       options: nil,
                                       progressBlock: nil,
                                       completionHandler: nil)
        }
    }


}

