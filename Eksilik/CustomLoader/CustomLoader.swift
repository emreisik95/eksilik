//
//  CustomLoader.swift
//  APIDemo
//
//  Created by SHUBHAM AGARWAL on 26/04/18.
//  Copyright © 2018 SHUBHAM AGARWAL. All rights reserved.
//

import UIKit

class CustomLoader: UIView {
    
    static let instance = CustomLoader()
    
    var viewColor: UIColor = .black
    var setAlpha: CGFloat = 0.3
    var gifName: String = ""
    
    lazy var transparentView: UIView = {
        let transparentView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        transparentView.backgroundColor = viewColor.withAlphaComponent(setAlpha)
        transparentView.isUserInteractionEnabled = false
        return transparentView
    }()
    
    lazy var gifImage: UIImageView = {
        var gifImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        gifImage.contentMode = .scaleAspectFit
        gifImage.center = transparentView.center
        gifImage.isUserInteractionEnabled = false
        gifImage.layer.shadowOffset = .zero
        gifImage.layer.shadowColor = UIColor.init(red: 235/255, green: 255/255, blue: 125/255, alpha: 1.0).cgColor
        gifImage.layer.shadowRadius = 10
        gifImage.layer.shadowOpacity = 0.7
        gifImage.layer.shadowPath = UIImage(named: "demo")?.accessibilityPath?.cgPath
        gifImage.loadGif(name: gifName)
        return gifImage
    }()
    
    func showLoaderView() {
        self.addSubview(self.transparentView)
        self.transparentView.addSubview(self.gifImage)
        self.transparentView.bringSubviewToFront(self.gifImage)
        UIApplication.shared.keyWindow?.addSubview(transparentView)
        let edgePan = UISwipeGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        edgePan.direction = .right
        
        self.addGestureRecognizer(edgePan)
        
    }
    @objc func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
            CustomLoader.instance.hideLoaderView()
        }
    }

    
    func hideLoaderView() {
        self.transparentView.removeFromSuperview()
    }
    
}
