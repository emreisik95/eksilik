import UIKit
import Parchment

class MesajViewController: UIViewController, UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        print(location)
        return UIViewController()
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
    }
    
    
    @IBAction func geriButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Load each of the view controllers you want to embed
        // from the storyboard.
        tabBarController?.tabBar.installBlurEffect()
        let status = UserDefaults.standard.bool(forKey: "giris")
        self.navigationController?.navigationBar.installBlurEffect()
        navigationItem.rightBarButtonItem?.tintColor = Theme.titleColor!
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let firstViewController = storyboard.instantiateViewController(withIdentifier: "mesaj") as! olayViewController
        let secondViewController = storyboard.instantiateViewController(withIdentifier: "mesaj") as! mesajlListeViewController
        
        
        // Initialize a FixedPagingViewController and pass
        // in the view controllers.
        

            let pagingViewController = FixedPagingViewController(viewControllers: [
                firstViewController,
                secondViewController
                ])
            pagingViewController.textColor = Theme.labelColor!
            pagingViewController.backgroundColor = Theme.navigationBarColor!
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

