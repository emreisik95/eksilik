//
//  gundemController.swift
//  Eksilik
//
//  Created by Emre Işık on 2.08.2019.
//  Copyright © 2019 Emre Isik. All rights reserved.
//

import UIKit
import Parchment
import Alamofire

class GundemPageViewController: UIViewController, UITabBarControllerDelegate, UISplitViewControllerDelegate{
    let status = UserDefaults.standard.bool(forKey: "giris")

    @IBOutlet weak var girisButton: UIBarButtonItem!
    let sv = UISplitViewController()
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return false
    }    
    override func viewDidLoad() {
        super.viewDidLoad()
        sv.delegate = self
        sv.preferredDisplayMode = .primaryOverlay
        if  status == false && tabBarController?.tabBar.items?.count ?? 2 > 3{
            cikis()
        }
        loadView()
        self.tabBarController?.tabBar.isTranslucent = false
        self.tabBarController?.tabBar.unselectedItemTintColor = .gray
        self.tabBarController?.tabBar.tintColor = Theme.tabBarColor
        self.tabBarController?.delegate = self
        if status == true{
            self.navigationItem.rightBarButtonItem = nil
        }
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Theme.titleColor!]
        self.navigationController?.navigationBar.tintColor = Theme.tabBarColor
        // Load each of the view controllers you want to embed
        // from the storyboard.
        tabBarController?.tabBar.installBlurEffect()
        self.navigationController?.navigationBar.installBlurEffect()
        let value = UserDefaults.standard.integer(forKey: "secilenTema")
        if value == 0 || value == 2 {
            view.backgroundColor = Theme.backgroundColor
        }else{
            view.backgroundColor = .white
        }
        let status = UserDefaults.standard.bool(forKey: "giris")
        //  navigationController?.navigationBar.installBlurEffect()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondViewController = storyboard.instantiateViewController(withIdentifier: "tarihteBugun") as! tBugunViewController
        let gundemViewControll = storyboard.instantiateViewController(withIdentifier: "baslikGor") as! FirstViewController
        let firstViewController = storyboard.instantiateViewController(withIdentifier: "Bugun") as! BugunViewController
        let thirdViewController = storyboard.instantiateViewController(withIdentifier: "takip") as! TakipViewController
        let fourthViewController = storyboard.instantiateViewController(withIdentifier: "sonGor") as! SonViewController
        let fifthViewController = storyboard.instantiateViewController(withIdentifier: "sorunsal") as! sorunsalViewController
        
        // Initialize a FixedPagingViewController and pass
        // in the view controllers.
        
        if status == false{
            let pagingViewController = FixedPagingViewController(viewControllers: [
                gundemViewControll,
                firstViewController,
                secondViewController,
                fifthViewController
                ])
            pagingViewController.textColor = Theme.labelColor!
            pagingViewController.backgroundColor = Theme.backgroundColor!
            pagingViewController.selectedBackgroundColor = Theme.backgroundColor!
            pagingViewController.selectedTextColor = Theme.labelColor!
            pagingViewController.indicatorColor = Theme.userColor!
            pagingViewController.borderColor = Theme.userColor!
            pagingViewController.menuHorizontalAlignment = .center
            
            // Make sure you add the PagingViewController as a child view
            // controller and contrain it to the edges of the view.
            addChild(pagingViewController)
            view.addSubview(pagingViewController.view)
            view.constrainToEdges(pagingViewController.view)
            pagingViewController.didMove(toParent: self)
        }else{
            let pagingViewController = FixedPagingViewController(viewControllers: [
                gundemViewControll,
                firstViewController,
                secondViewController,
                fifthViewController,
                thirdViewController,
                fourthViewController
                ])
            pagingViewController.textColor = Theme.menuColor!
            pagingViewController.backgroundColor = Theme.backgroundColor!
            pagingViewController.selectedBackgroundColor = Theme.backgroundColor!
            pagingViewController.selectedTextColor = Theme.labelColor!
            pagingViewController.indicatorColor = Theme.userColor!
            pagingViewController.borderColor = Theme.userColor!
            pagingViewController.menuHorizontalAlignment = .center
            
            // Make sure you add the PagingViewController as a child view
            // controller and contrain it to the edges of the view.
            addChild(pagingViewController)
            view.addSubview(pagingViewController.view)
            view.constrainToEdges(pagingViewController.view)
            pagingViewController.didMove(toParent: self)
            pagingViewController.contentInteraction = .scrolling
        }
        self.navigationController?.navigationBar.barStyle = Theme.barStyle!
        self.navigationController?.navigationBar.barTintColor = Theme.navigationBarColor!
    }
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return Theme.statusBarStyle!
    }

    
    @objc func cikis(){
        Alamofire.request("https://www.eksisozluk.com/terk").responseString {
            response in
            if response.result.isSuccess{
                UserDefaults.standard.set(false, forKey: "giris")
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "basla") as! UITabBarController
                vc.viewControllers?.removeLast()
                vc.viewControllers?.remove(at: 2)
                TarihPageViewController().viewDidLoad()
                UIApplication.shared.keyWindow?.rootViewController = vc
            }
        }
    }
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print(tabBarController.selectedIndex)
        if tabBarController.selectedIndex == 0{
            CustomLoader.instance.showLoaderView()
            let vc = FirstViewController()
            vc.siteyeBaglan()
        }
    }
    
}

class CustomPagingView : PagingView {
    override func setupConstraints() {
        pageView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            pageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            pageView.topAnchor.constraint(equalTo: collectionView.topAnchor),
            pageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: options.menuItemSize.height),
            ])
    }
}

class CustomPagingViewController : FixedPagingViewController {
    override func loadView() {
        view = CustomPagingView(
            options: options,
            collectionView: collectionView,
            pageView: pageViewController.view)
    }
}
