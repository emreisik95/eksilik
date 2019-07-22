//
//  SecondViewController.swift
//  Eksilik
//
//  Created by Emre Işık on 15.02.2019.
//  Copyright © 2019 Emre Isik. All rights reserved.
//

import UIKit
import WebKit


class SecondViewController: UIViewController, UIWebViewDelegate {
    
 
    @IBOutlet weak var webView: UIWebView!
    
    var girisURL: URL = URL(string: "https://eksisozluk.com")!
    var hataURL: URL = URL(string: "https://eksisozluk.com/giris")!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self
        self.navigationController?.navigationBar.installBlurEffect()
        tabBarController?.tabBar.installBlurEffect()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadWebView()
    }
    
    func loadWebView()  {
        webView.loadRequest(URLRequest(url: URL(string: "https://eksisozluk.com/giris")!))
    }
    func restartApplication () {
        let viewController = FirstViewController()
        let navCtrl = UINavigationController(rootViewController: viewController)
        
        guard
            let window = UIApplication.shared.keyWindow,
            let rootViewController = window.rootViewController
            else {
                return
        }
        
        navCtrl.view.frame = rootViewController.view.frame
        navCtrl.view.layoutIfNeeded()
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = navCtrl
        })
        
    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        print("request: \(request.description)")
        if request.description == "https://eksisozluk.com/"{
            //do close window magic here!!
            print("url matches...")
            stopLoading()
            return false
        }
        return true
    }
    
    func stopLoading() {
        webView.removeFromSuperview()
        self.moveToVC()
    }
    
    func moveToVC()  {
        print("Write code where you want to go in app")
        if var controllers = tabBarController?.viewControllers {
            let tabItem = UITabBarItem(title: "", image: UIImage(named: "ben"), selectedImage: UIImage(named: "ben"))
            tabItem.imageInsets = .init(top: 6, left: 0, bottom: -6, right: 0)
            let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ben") as! UINavigationController
            vc.tabBarItem = tabItem
            controllers.append(vc) // or insert at index up to you
            tabBarController?.setViewControllers(controllers, animated: true)
            TarihPageViewController().viewDidLoad()
            FirstViewController().viewWillAppear(true)
            UserDefaults.standard.set(true, forKey: "giris")
            UserDefaults.standard.synchronize()
        }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "basla") as! UITabBarController
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
}


