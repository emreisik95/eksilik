//
//  PuhViewController.swift
//  Eksilik
//
//  Created by Emre Işık on 21.03.2019.
//  Copyright © 2019 Emre Isik. All rights reserved.
//

import UIKit

class GundemViewController: PagerController, PagerDataSource{
    
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor(red: 38.0/255, green: 38.0/255, blue: 38/255, alpha: 1)
        super.viewDidLoad()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    
}
