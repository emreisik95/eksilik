//
//  FirstViewController.swift
//  Eksilik
//
//  Created by Emre Işık on 15.02.2019.
//  Copyright © 2019 Emre Isik. All rights reserved.
//

import UIKit
import Alamofire
import Kanna
import SwiftyJSON
import WhatsNew
import SwiftRater
import Toast_Swift
import Crashlytics
import Parchment

class FirstViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate, UITabBarControllerDelegate, UIViewControllerPreviewingDelegate, UISplitViewControllerDelegate{
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tabBarController?.tabBar.invalidateIntrinsicContentSize()
    }
    var ustbosluk = 0//UINavigationController().navigationBar.frame.height + 20
    var puntosecim = 15
    var filteredBaslikTableData = [String]()
    var filteredSuserTableData = [String]()
    var suserlar = [String]()
    var secim = false
    var test = ""
    var resultSearchController = UISearchController()
    let headers: HTTPHeaders = [ "X-Requested-With": "XMLHttpRequest",
                                 "Accept-Language": "tr-TR,tr;q=0.9,en-US;q=0.8,en;q=0.7,ru;q=0.6",
                                 "Accept-Encoding": "gzip, deflate, br"]
    let status = UserDefaults.standard.bool(forKey: "giris")
    let font = UserDefaults.standard.string(forKey: "secilenFont")
    var viewcim = (Bundle.main.loadNibNamed("başlık boş", owner: self, options: nil)![0]) as! UIView
    func updateSearchResults(for searchController: UISearchController) {
        let parameters: Parameters = ["q": "\(searchController.searchBar.text!)"]
        Alamofire.request("https://eksisozluk.com/autocomplete/query?", method: .get, parameters: parameters, headers: headers).responseJSON { response in
            guard let data = response.data else {
                return
            }
            let json = try? JSON(data: data)
            let name = json?.dictionaryObject
            let baslik = name!["Titles"]!
            let suser = name!["Nicks"]!
            self.basliklar = baslik as! [String]
            self.filteredBaslikTableData = self.basliklar
            self.suserlar = suser as! [String]
            self.filteredSuserTableData = self.suserlar
            self.baslikView?.reloadData()
        }
        if self.filteredSuserTableData.count == 0 && self.filteredBaslikTableData.count == 0 && resultSearchController.searchBar.text!.count<1{
            self.baslikView.addSubview(self.viewcim)
            self.baslikView.separatorStyle = .none
        }else if self.filteredBaslikTableData.count > 0 || filteredSuserTableData.count > 0 || resultSearchController.searchBar.text!.count < 2{
            self.viewcim.removeFromSuperview()
            self.baslikView.separatorStyle = .singleLine
            self.baslikView.tableFooterView = UIView()
        }
        if resultSearchController.isActive == false{
            self.viewcim.removeFromSuperview()
            refreshTableView()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        SwiftRater.check(host: self)
       puntosecim = UserDefaults.standard.integer(forKey: "secilenPunto")
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if WhatsNew.shouldPresent() {
            let whatsNew = WhatsNewViewController(items: [
                WhatsNewItem.text(title: "uygulama düzeninde değişiklik", subtitle: "artık gündem-bugün-tarihte bugün-sorunsallar-takip gibi başlıklara tek bir sayfadan ulaşabilirsiniz. ayarlar için ilk sayfada sol üstte bulunan butonu kullanabilirsiniz, mesajlara zil ikonuna basarak ulaşabilirsiniz."),
                WhatsNewItem.text(title: "entry ekran resmini paylaşma", subtitle: "entry'nin altındaki üç noktaya bastığınız zaman entry'nin görsel halini direkt olarak paylaşma imkanına sahipsiniz"),
                WhatsNewItem.text(title: "hata düzeltmeleri", subtitle: "elimden geldiğince her sürümde hata düzeltmelerini yapıyorum, lütfen gördüğünüz hatalar için benimle iletişime geçmekten çekinmeyin"),
                WhatsNewItem.text(title: "teşekkürler", subtitle: "uygulamayı her gün geliştirmeye çalışıyorum. eğer herhangi bir hatayla karşılaşırsanız ve istediğiniz ekstra bir özellik olursa lütfen sherlockun besinci sezonu'na mesaj gönderin.")
                ])
            whatsNew.titleText = "neler yeni?"
            whatsNew.titleColor = Theme.labelColor!
            whatsNew.itemSubtitleColor = Theme.labelColor!
            whatsNew.view.backgroundColor = Theme.backgroundColor!
            whatsNew.itemTitleColor = Theme.labelColor!
            whatsNew.buttonText = "aa tamam o zaman."
            whatsNew.buttonTextColor = .white
            whatsNew.buttonBackgroundColor = Theme.userColor!
            present(whatsNew, animated: true, completion: nil)
        }
    }
    @IBAction func clear(_ sender: Any) {
     UserDefaults.standard.removeObject(forKey: "LatestAppVersionPresented")
     UserDefaults.standard.synchronize()
     DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      exit(0)
      }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let yazi = resultSearchController.searchBar.text!
        if yazi.contains("#"){
            let vc =
                self.storyboard?.instantiateViewController(withIdentifier:
                    "entryGoruntule") as! EntryViewController
            let entryNo = yazi.replacingOccurrences(of: "#", with: "")
            vc.baslikLinki = "https://eksisozluk.com/entry/\(entryNo)"
            self.navigationController?.pushViewController(vc, animated: true)
            resultSearchController.isActive = false
            baslikView?.reloadData()
        }
        if yazi.contains("@"){
            let vc =
                self.storyboard?.instantiateViewController(withIdentifier:
                    "suserProfile") as! SuserViewController
            let suser = yazi.replacingOccurrences(of: "@", with: "")
            vc.asilLink = "https://eksisozluk.com/biri/\(suser)"
            self.navigationController?.pushViewController(vc, animated: true)
            resultSearchController.isActive = false
            baslikView?.reloadData()
        }
        let vc =
            self.storyboard?.instantiateViewController(withIdentifier:
                "entryGoruntule") as! EntryViewController
        let baslik = yazi.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]{} ").inverted)!
        vc.baslikLinki = "https://eksisozluk.com/\(baslik)"
        self.navigationController?.pushViewController(vc, animated: true)
        resultSearchController.isActive = false
        baslikView?.reloadData()
    }

    var basliklar = [String]()
    var entrySayisi = [String]()
    var linkler = [String]()
    var seciliLink = ""
    var baslik = ""
    var girisKontrolu = String()
    var gundemLink = "https://eksisozluk.com/basliklar/m/populer"
    var dahadaLink = ""
    var sayfaSayisi = "5"
    var aktifSayfa = "2"
    var sayfa: Int = 2
    
    @IBOutlet weak var baslikView: UITableView!
    
    var refreshView: RefreshView!
    
    var tableViewRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = .clear
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        
        return refreshControl
    }()

    var titles: [String] = []


    override func viewDidLoad() {
        super.viewDidLoad()

       let tabBar = tabBarController?.tabBar
        tabBar?.installBlurEffect()
            self.siteyeBaglan()
        self.view.backgroundColor = Theme.backgroundColor
        self.navigationController?.navigationBar.installBlurEffect()
        self.navigationItem.rightBarButtonItem?.tintColor = Theme.titleColor
        self.navigationItem.leftBarButtonItem?.tintColor = Theme.titleColor
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchBar.barStyle = Theme.barStyle ?? .black
            controller.searchBar.tintColor = Theme.entryButton
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            self.definesPresentationContext = true
            controller.hidesNavigationBarDuringPresentation = false
            controller.searchBar.setValue("vazgeç", forKey: "cancelButtonText")
            controller.searchBar.sizeToFit()
            controller.searchBar.placeholder = "başlık, @yazar veya #entry ara..."
            UILabel.appearance(whenContainedInInstancesOf: [UISearchBar.self]).font = UIFont.systemFont(ofSize: CGFloat(puntosecim))
            controller.searchBar.keyboardAppearance = Theme.keyboardColor ?? .dark
            controller.searchBar.delegate = self
            self.baslikView.tableHeaderView = controller.searchBar
            self.baslikView.backgroundView = UIView()
            let tbHeight = self.tabBarController?.tabBar.frame.height ?? 0
            let adjustForTabbarInsets: UIEdgeInsets = UIEdgeInsets(top:0, left: 0, bottom: tbHeight + 95, right: 0)
            self.baslikView.contentInset = adjustForTabbarInsets
            self.baslikView.scrollIndicatorInsets = adjustForTabbarInsets
            return controller
        })()
        
        prepareUI()
        self.navigationController?.navigationBar.barStyle = Theme.barStyle!
        self.navigationController?.navigationBar.barTintColor = Theme.navigationBarColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Theme.titleColor!]
        
        self.navigationItem.rightBarButtonItem?.tintColor = Theme.entryButton
        self.navigationItem.leftBarButtonItem?.tintColor = Theme.entryButton
        self.tabBarController?.tabBar.unselectedItemTintColor = .gray
        self.tabBarController?.tabBar.tintColor = Theme.tabBarColor
        self.tabBarController?.delegate = self
        baslikView.separatorStyle = .singleLine
        baslikView.separatorColor = Theme.separatorColor
        baslikView.delegate = self
        baslikView.dataSource = self
        baslikView.backgroundColor = Theme.backgroundColor
        if status == true{
            navigationItem.rightBarButtonItem = nil
            navigationItem.leftBarButtonItem = nil
        }
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: baslikView)
        }
    self.baslikView.setContentOffset(CGPoint(x: 0, y: self.resultSearchController.searchBar.frame.height), animated: true)
    }
    override var previewActionItems: [UIPreviewActionItem]{
        let pw1 = UIPreviewAction.init(title: "paylaş", style: .default) { (UIPreviewAction, UIViewController) in
            print("puh")
        }
        return [pw1]
    }
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = baslikView.indexPathForRow(at: location), let cell = baslikView.cellForRow(at: indexPath){
            let popVC = storyboard?.instantiateViewController(withIdentifier: "entryGoruntule") as! EntryViewController
           popVC.baslikLinki = linkler[indexPath.row]
            seciliLink = linkler[indexPath.row]
            previewingContext.sourceRect = cell.frame
           let vc = UINavigationController(rootViewController: popVC)
            vc.navigationBar.barStyle = Theme.barStyle!
            vc.navigationBar.barTintColor = Theme.navigationBarColor
           return vc
        }else{
            return nil
        }
        }
    
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        let popVC = storyboard?.instantiateViewController(withIdentifier: "entryGoruntule") as! EntryViewController
        popVC.baslikLinki = seciliLink
        navigationController?.pushViewController(popVC, animated: true)
    }
    
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "entryVC"{
            let entryVC = segue.destination as! EntryViewController
            entryVC.baslikLinki = "https://eksisozluk.com/\(self.seciliLink)"
            entryVC.baslik = self.baslik
            entryVC.extendedLayoutIncludesOpaqueBars = secim
            entryVC.secim = self.secim
        }
    }


    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 0 {
          /*  CustomLoader.instance.showLoaderView()
            siteyeBaglan()
            self.baslikView.beginUpdates()
            self.baslikView.setContentOffset(CGPoint(x: 0, y: -baslikView.contentInset.top), animated: true)
            self.baslikView.endUpdates()*/
        }
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
    
    private func loadData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(20)) {
            self.baslikView?.reloadData()
        }
    }
    @objc func refreshTableView() {
        siteyeBaglan()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableViewRefreshControl.endRefreshing()
        }
    }
     func prepareUI() {
        baslikView.refreshControl = tableViewRefreshControl
        getRefereshView()
    }
    func getRefereshView() {
        if let objOfRefreshView = Bundle.main.loadNibNamed("RefreshView", owner: self, options: nil)?.first as? RefreshView {
            // Initializing the 'refreshView'
            refreshView = objOfRefreshView
            // Giving the frame as per 'tableViewRefreshControl'
            refreshView.frame = baslikView.refreshControl!.frame
            refreshView.startAnimation()
            // Adding the 'refreshView' to 'tableViewRefreshControl'
            tableViewRefreshControl.addSubview(refreshView)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (resultSearchController.isActive){
            if indexPath.section == 0{
                let vc =
                    self.storyboard?.instantiateViewController(withIdentifier:
                        "entryGoruntule") as! EntryViewController
                var link = filteredBaslikTableData[indexPath.row] 
                link = link.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]{} ").inverted)!
                vc.baslikLinki = link
                vc.extendedLayoutIncludesOpaqueBars = false
                self.navigationController?.pushViewController(vc, animated: true)
                resultSearchController.isActive = false
                
            }
            if indexPath.section == 1{
                let vc =
                    self.storyboard?.instantiateViewController(withIdentifier:
                        "suserProfile") as! SuserViewController
                var link = filteredSuserTableData[indexPath.row]
                link = link.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]{} ").inverted)!
                vc.biriLink = "/biri/\(link)"
                self.navigationController?.pushViewController(vc, animated: true)
                resultSearchController.isActive = false
            }
            baslikView?.reloadData()
        }else{
        seciliLink = linkler[indexPath.row]
        baslik = basliklar[indexPath.row]
        baslikView?.reloadData()
        }
        performSegue(withIdentifier: "entryVC", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
        }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (resultSearchController.isActive){
            return 2
        }
        return 1
    }
    
    private var finishedLoadingInitialTableCells = false

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if resultSearchController.isActive == false{
        if self.aktifSayfa == self.sayfaSayisi{
        }else{
        let lastData = self.basliklar.count - 1
        if indexPath.row == lastData {
            CustomLoader.instance.showLoaderView()
            self.dahadaLink = "\(gundemLink)?p=\(sayfa)"
            basliklariGetir()
            cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
            UIView.animate(withDuration: 0.3, animations: {
             cell.layer.transform = CATransform3DMakeScale(1.05,1.05,1)
            },completion: { finished in
                UIView.animate(withDuration: 0.1, animations: {
              cell.layer.transform = CATransform3DMakeScale(1,1,1)
                })
            })
            sayfa = sayfa+1
        }
    }
        
        
        var lastInitialDisplayableCell = false
        
        //change flag as soon as last displayable cell is being loaded (which will mean table has initially loaded)
        if basliklar.count > 0 && !finishedLoadingInitialTableCells {
            if let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows,
                let lastIndexPath = indexPathsForVisibleRows.last, lastIndexPath.row == indexPath.row {
                lastInitialDisplayableCell = true
            }
        }
        
        if !finishedLoadingInitialTableCells {
            
            if lastInitialDisplayableCell {
                finishedLoadingInitialTableCells = true
            }
            
            //animates the cell as it is being displayed for the first time
            cell.transform = CGAffineTransform(translationX: 0, y: baslikView.rowHeight/2)
            cell.alpha = 0
            
            UIView.animate(withDuration: 0.3, delay: 0.05*Double(indexPath.row), options: [.curveEaseInOut], animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
                cell.alpha = 1
            }, completion: nil)
        }
        }
    }
    
    var style = ToastStyle()

    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let closeAction = UIContextualAction(style: .normal, title:  "başlığı engelle", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.style.backgroundColor = Theme.userColor!
            self.style.titleColor = .white
            tableView.beginUpdates()
            Theme.wordList.append(self.basliklar[indexPath.row])
            self.view.makeToast("\(self.basliklar[indexPath.row]) başlığı başarıyla engellendi", duration: 3.0, position: .center, style: self.style)
            DispatchQueue.main.asyncAfter(deadline: .now() + (1), execute: {
                UserDefaults.standard.set(Theme.wordList, forKey: "engellenenler")
                UserDefaults.standard.synchronize()
                self.siteyeBaglan()
            })
            
            tableView.endUpdates()
            success(true)
        })
        closeAction.backgroundColor = Theme.userColor
        
        return UISwipeActionsConfiguration(actions: [closeAction])
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        return UISwipeActionsConfiguration()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  (resultSearchController.isActive) {
            if section == 0{
                return filteredBaslikTableData.count
            }
            if section == 1{
                return filteredSuserTableData.count
            }
        }
            return basliklar.count
        }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (resultSearchController.isActive) {
            if indexPath.section == 0{
                let Baslikcell = tableView.dequeueReusableCell(withIdentifier: "sonuc") as! sonucTableViewCell
                Baslikcell.sonucAdiLabel.text = filteredBaslikTableData[indexPath.row]
                Baslikcell.sonucAdiLabel.font = UIFont(name: font ?? "Helvetica", size: CGFloat(puntosecim))
                Baslikcell.sonucAdiLabel.textColor = Theme.labelColor
                Baslikcell.backgroundColor = Theme.backgroundColor
                return Baslikcell
            }
            if indexPath.section == 1{
                let kisiCell = tableView.dequeueReusableCell(withIdentifier: "kisisonuc") as! kisisonucTableViewCell
                kisiCell.kisiSonucLabel.text = filteredSuserTableData[indexPath.row]
                kisiCell.kisiSonucLabel.font = UIFont(name: font ?? "Helvetica", size: CGFloat(puntosecim))
                kisiCell.backgroundColor = Theme.backgroundColor
                kisiCell.kisiSonucLabel.textColor = Theme.labelColor
                return kisiCell
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BaslikViewCell

        if indexPath.row % 2 == 0{
        cell.backgroundColor = Theme.cellFirstColor
        }else{
        cell.backgroundColor = Theme.cellSecondColor
        }
        let bgColorView = UIView()
        bgColorView.backgroundColor = Theme.cellFirstColor
        cell.selectedBackgroundView = bgColorView
        cell.entrySayisiLabel.text = entrySayisi[indexPath.row]
        cell.baslikLabel.text = basliklar[indexPath.row]
        cell.baslikLabel.font = UIFont(name: font ?? "Helvetica-Light", size: CGFloat(puntosecim))
        cell.baslikLabel.textColor = Theme.labelColor
        cell.baslikLabel.tintColor = Theme.labelColor
        cell.entrySayisiLabel.tintColor = Theme.entrySayiColor
        cell.entrySayisiLabel.font = UIFont(name: font ?? "Helvetica-Light", size: CGFloat(puntosecim))
        cell.entrySayisiLabel.textColor = Theme.entrySayiColor
        return cell
    }

    func basliklariGetir() -> Void {
        Alamofire.request(dahadaLink).responseString {
            response in
            if let html = response.result.value{
                self.girisKontrol(html: html)
                self.sayfaSayisiGetir(html: html)
               // self.baslikentrysayisiGetir(html: html)
                self.baslikGetir(html: html)
               // self.baslikLink(html: html)
                self.baslikView?.reloadData()
            }
            if response.result.isSuccess == false{
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    let alert = UIAlertController(title: "başlıklar gelmedi", message: "ama her an burda olabilir, gerçi olmayabilir de", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "tamam", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
            }
                CustomLoader.instance.hideLoaderView()
        }
    }
    

    
    func siteyeBaglan() -> Void {
        Alamofire.request(gundemLink).responseString {
            response in
            if let html = response.result.value{
                if self.status == true{
                    self.olayKontrol(html: html)
                    self.mesajKontrol(html: html)
                    self.kullaniciAdiGetir(html: html)
                }
                self.girisKontrol(html: html)
                self.basliklar = [String]()
                self.linkler = [String]()
                self.entrySayisi = [String]()
                self.aktifSayfa = "1"
                self.sayfa = 2
                self.sayfaSayisiGetir(html: html)
                self.baslikGetir(html: html)
                CustomLoader.instance.hideLoaderView()

            }
            if response.result.isSuccess == false{
                CustomLoader.instance.hideLoaderView()
                let alert = UIAlertController(title: "başlıklar gelmedi", message: "ama her an burda olabilir, gerçi olmayabilir de", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "tamam", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
        }
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 10
        
        manager.request(gundemLink)
            .responseString {
                response in
                switch (response.result) {
                case .success: break // succes path
                case .failure(let error):
                    if error._code == NSURLErrorTimedOut {
                        let alert = UIAlertController(title: "başlıklar gelmedi", message: "ama her an burda olabilir, gerçi olmayabilir de", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "tamam", style: .cancel, handler: nil))
                        self.present(alert, animated: true)                    }
                }
        }
            self.baslikView?.reloadData()
        self.baslikView?.setContentOffset(.zero, animated: true)
    }
    
    func kullaniciAdiGetir(html: String) -> Void {
        var k = [String]()
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("li[class^=not-mobile] a"){
                k.append(basliklar["title"] ?? "emre")
            }
        }
        if k.count == 0{
            cikis()
        }else{
        UserDefaults.standard.set(k[0], forKey: "kullaniciAdi")
        print(k[0])
        }
    }
    
    
    func baslikentrysayisiGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for entrySayisi in doc.css("ul[class^=topic-list partial mobile] li a"){
                let entryNo = entrySayisi.at_css("small")
                if entryNo?.content == nil{
                    self.entrySayisi.append("")
                }else{
                    self.entrySayisi.append((entryNo?.content)!)

                }
                self.baslikView?.reloadData()
            }
    }
}
    
    func baslikGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("ul[class^=topic-list partial mobile] li a"){
                if Theme.wordList.contains(where: {basliklar.text!.contains($0) }){

                }else{
                    let entryNo = basliklar.at_css("small")
                    self.entrySayisi.append(entryNo?.text ?? "")
                    var small = basliklar.at_css("small")
                    small?.content = ""
                    self.basliklar.append(basliklar.text!)
                    self.linkler.append(basliklar["href"]!)
                }
            }
                self.baslikView?.reloadData()
        }
    }

    
    func cikart(){
        UserDefaults.standard.set(false, forKey: "giris")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "basla") as! UITabBarController
        vc.viewControllers?.removeLast()
        TarihPageViewController().viewDidLoad()
        UIApplication.shared.keyWindow?.rootViewController = vc
    }

    func girisKontrol(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("a[id^=top-login-link]"){
                if status == true{
                if basliklar.text!.count>0{
                    self.cikart()
                }
                }
            }
        }
    }
    
    
    func sayfaSayisiGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for sayfa in doc.css("div[class^=pager]"){
                let simdiki = sayfa["data-currentpage"]
                let toplam = sayfa["data-pagecount"]
                self.sayfaSayisi = toplam!
                self.aktifSayfa = simdiki!
            }
        }
    }
    func olayKontrol(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for sayfa in doc.css("li[class^=tracked mobile-only] a"){
                let olayTuru = sayfa.className!
                if olayTuru == "new-update"{
                    DispatchQueue.main.async(execute: {
                        self.tabBarController?.tabBar.items?[2].badgeValue = "olay"
                        self.tabBarController?.tabBar.items?[2].badgeColor = Theme.userColor                    })
                }else{
                    self.tabBarController?.tabBar.items?[2].badgeValue = nil
                }
            }
        }
    }
    func mesajKontrol(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for sayfa in doc.css("li[class^=messages mobile-only] a svg"){
                let olayTuru = sayfa.className!
                    if olayTuru.contains("green"){
                        tabBarController?.tabBar.items?[2].badgeValue = "mesaj"
                        tabBarController?.tabBar.items?[2].badgeColor = Theme.userColor
                    }else{
                        tabBarController?.tabBar.items?[2].badgeValue = nil
                }
            }
        }
    }


}


class BaslikViewCell: UITableViewCell{
    
    @IBOutlet weak var baslikLabel: UILabel!

    @IBOutlet weak var entrySayisiLabel: UILabel!
}

class tabBarController: UITabBarController {
    
    override func viewDidLayoutSubviews() {
        let visualEffectView = UIVisualEffectView(effect: Theme.blurEffect!)
        visualEffectView.frame = self.view.bounds
        let window = UIApplication.shared.keyWindow ?? UIApplication.shared.windows[0]
        window.subviews[0].addSubview(visualEffectView)
    }
}
extension UINavigationBar {
    func installBlurEffect() {
        
        isTranslucent = true
        setBackgroundImage(UIImage(), for: .default)
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
        var blurFrame = bounds
        blurFrame.size.height += statusBarHeight
        blurFrame.origin.y -= statusBarHeight
        let blurView  = UIVisualEffectView(effect: Theme.blurEffect)
        blurView.isUserInteractionEnabled = false
        blurView.frame = blurFrame
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(blurView)
        blurView.layer.zPosition = -1
    }
}
extension UITabBar {
    func installBlurEffect() {
        isTranslucent = true
        backgroundImage = UIImage()
        let blurFrame = bounds
        let blurView  = UIVisualEffectView(effect: Theme.blurEffect)
        blurView.isUserInteractionEnabled = false
        blurView.frame = blurFrame
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurView)
        blurView.layer.zPosition = -1
    }
}
