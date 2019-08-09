import UIKit
import Parchment

class TarihPageViewController: UIViewController{

    override func viewDidLoad() {
        super.viewDidLoad()
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
        let firstViewController = storyboard.instantiateViewController(withIdentifier: "Bugun") as! BugunViewController
        let thirdViewController = storyboard.instantiateViewController(withIdentifier: "takip") as! TakipViewController
        let fourthViewController = storyboard.instantiateViewController(withIdentifier: "sonGor") as! SonViewController
        let fifthViewController = storyboard.instantiateViewController(withIdentifier: "sorunsal") as! sorunsalViewController
    
        // Initialize a FixedPagingViewController and pass
        // in the view controllers.

        if status == false{
            let pagingViewController = FixedPagingViewController(viewControllers: [
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
        }
        self.navigationController?.navigationBar.barStyle = Theme.barStyle!
        self.navigationController?.navigationBar.barTintColor = Theme.navigationBarColor!
    }
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return Theme.statusBarStyle!
    }
}
