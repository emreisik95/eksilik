//
//  AppDelegate.swift
//  Eksilik
//
//  Created by Emre Işık on 15.02.2019.
//  Copyright © 2019 Emre Isik. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications
import SwiftRater

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CAAnimationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //Açılış animasyonu
        // Override point for customization after application launch.
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.backgroundColor = UIColor(red: 104/255, green: 156/255, blue: 56/255, alpha: 1)
        self.window!.makeKeyAndVisible()
        
        // rootViewController from StoryBoard
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController = mainStoryboard.instantiateViewController(withIdentifier: "basla") as! UITabBarController
        self.window!.rootViewController = navigationController
        
        // logo mask
        navigationController.view.layer.mask = CALayer()
        navigationController.view.layer.mask?.contents = UIImage(named: "elogo")!.cgImage
        navigationController.view.layer.mask?.bounds = CGRect(x: 0, y: 0, width: 360, height: 360)
        navigationController.view.layer.mask?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        navigationController.view.layer.mask?.position = CGPoint(x: navigationController.view.frame.width / 2, y: navigationController.view.frame.height / 2)
        
        // logo mask background view
        let maskBgView = UIView(frame: navigationController.view.frame)
        maskBgView.backgroundColor = UIColor.white
        navigationController.view.addSubview(maskBgView)
        navigationController.view.bringSubviewToFront(maskBgView)
        
        // logo mask animation
        let transformAnimation = CAKeyframeAnimation(keyPath: "bounds")
        transformAnimation.delegate = self
        transformAnimation.duration = 1
        transformAnimation.beginTime = CACurrentMediaTime() + 1 //add delay of 1 second
        let initalBounds = NSValue(cgRect: (navigationController.view.layer.mask?.bounds)!)
        let secondBounds = NSValue(cgRect: CGRect(x: 0, y: 0, width: 50, height: 50))
        let finalBounds = NSValue(cgRect: CGRect(x: 0, y: 0, width: 5000, height: 5000))
        transformAnimation.values = [initalBounds, secondBounds, finalBounds]
        transformAnimation.keyTimes = [0, 0.5, 1]
        transformAnimation.timingFunctions = [CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut), CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)]
        transformAnimation.isRemovedOnCompletion = false
        transformAnimation.fillMode = CAMediaTimingFillMode.forwards
        navigationController.view.layer.mask?.add(transformAnimation, forKey: "maskAnimation")
        
        // logo mask background view animation
        UIView.animate(withDuration: 0.1,
                       delay: 1.35,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: {
                        maskBgView.alpha = 0.0
        },
                       completion: { finished in
                        maskBgView.removeFromSuperview()
        })
        
        // root view animation
        UIView.animate(withDuration: 0.25,
                       delay: 1.3,
                       options: [],
                       animations: {
                        self.window!.rootViewController!.view.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        },
                       completion: { finished in
                        UIView.animate(withDuration: 0.3,
                                       delay: 0.0,
                                       options: UIView.AnimationOptions.curveEaseInOut,
                                       animations: {
                                        self.window!.rootViewController!.view.transform = .identity
                        },
                                       completion: nil)
        })
        
        
        //açılış animasyonu
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -1000, vertical: 0), for:UIBarMetrics.default)
        Theme.defaultTheme()

        FirebaseApp.configure()
        
        SwiftRater.daysUntilPrompt = 7
        SwiftRater.usesUntilPrompt = 10
        SwiftRater.significantUsesUntilPrompt = 3
        SwiftRater.daysBeforeReminding = 2
        SwiftRater.showLaterButton = true
        SwiftRater.debugMode = false
        SwiftRater.alertTitle = "uygulamayı beğendiniz mi?"
        SwiftRater.alertMessage = "eğer beğendiyseniz app store'da oy vermeyi unutmayın"
        SwiftRater.alertCancelTitle = "yoo"
        SwiftRater.alertRateTitle = "aynen"
        SwiftRater.alertRateLaterTitle = "sonra bakarız"
        SwiftRater.appLaunched()
        
        UserDefaults.standard.register(defaults: [
            "giris": false,
            "secilenTema": 1,
            "secilenFont": "Helvetica-Light",
            "secilenPunto": 15,
            "link": true,
            "gizle": true
            ])

        let value = UserDefaults.standard.integer(forKey: "secilenTema")
        let tema: Int = value
        if tema == 0{
            Theme.defaultTheme()
        }
        if tema == 1{
            Theme.gunduzTheme()
        }
        if tema == 2{
            Theme.klasikTheme()
            UINavigationBar.appearance().isTranslucent = true
        }
        if tema == 3{
            Theme.pembeTheme()
        }
        
        UINavigationBar.appearance().backgroundColor = Theme.navigationBarColor
        UINavigationBar.appearance().isTranslucent = false

        let vc = FirstViewController()
        let status = UserDefaults.standard.bool(forKey: "giris")
        if status == false{
                vc.tabBarController?.viewControllers?.remove(at:4)
        }
        if status == true{
            vc.navigationItem.rightBarButtonItem = nil
        }
        if let tabController = self.window?.rootViewController as? UITabBarController, var viewControllers = tabController.viewControllers {
            
            let isLoggedIn = status
            
            if  isLoggedIn == false {
                viewControllers.remove(at: 3)
                viewControllers.removeLast()
                tabController.viewControllers = viewControllers
                self.window?.rootViewController = tabController
            }            
        }
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}

