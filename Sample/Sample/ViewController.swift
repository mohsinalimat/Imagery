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
            
            button.imagery.setBackgroundImage(with: url, for: .normal, placeholder: nil)
            
            imageView.imagery.setImage(with: url,
                                       placeholder: placeholder,
                                       options: nil,
                                       progressBlock: nil,
                                       completionHandler: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        ImageryCache.clearMemoryCache()
//        ImageryCache.clearDiskCache()
//        ImageryCache.cleanExpiredDiskCache()
//        ImageryCache.clearDiskCache {
//            // code
//        }
//        ImageryCache.cleanExpiredDiskCache {
//            // code
//        }
//
//        ImageryCache.default.clearMemoryCache()
//        ImageryCache.default.clearDiskCache()
//        ImageryCache.default.cleanExpiredDiskCache()
//        ImageryCache.default.clearDiskCache {
//            // code
//        }
//        ImageryCache.default.cleanExpiredDiskCache { 
//            // code
//        }
    }

}

