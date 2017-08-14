//
//  ViewController.swift
//  LiveEncode
//
//  Created by neulion on 8/9/17.
//  Copyright © 2017 NeuLion. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var avCapture:NLAVCapure?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        avCapture = NLAVCapure();
        avCapture?.startCapture()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let layer = avCapture?.getPreviewLayer(){
            layer.frame = self.view.bounds
            layer.borderColor =  UIColor.red.cgColor
            layer.borderWidth = 1
            self.view.layer.addSublayer(layer)
        }
        
    }


}

