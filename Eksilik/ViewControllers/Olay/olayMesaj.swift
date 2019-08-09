import UIKit
import Parchment

class OlayMesajPageViewController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Load each of the view controllers you want to embed
        // from the storyboard.
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Theme.titleColor!]
        self.navigationController?.navigationBar.tintColor = Theme.userColor
        tabBarController?.tabBar.installBlurEffect()
        self.navigationController?.navigationBar.installBlurEffect()
        let value = UserDefaults.standard.integer(forKey: "secilenTema")
        if value == 0 || value == 2 {
            view.backgroundColor = Theme.backgroundColor
        }else{
            view.backgroundColor = .white
        }
        //  navigationController?.navigationBar.installBlurEffect()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let firstViewController = storyboard.instantiateViewController(withIdentifier: "olay") as! olayViewController
                let secondViewController = storyboard.instantiateViewController(withIdentifier: "mesaj") as! mesajlListeViewController
        
        // Initialize a FixedPagingViewController and pass
        // in the view controllers.

            let pagingViewController = FixedPagingViewController(viewControllers: [
                firstViewController,
                secondViewController
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
        self.navigationController?.navigationBar.barStyle = Theme.barStyle!
        self.navigationController?.navigationBar.barTintColor = Theme.navigationBarColor!
    }
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return Theme.statusBarStyle!
    }
}


