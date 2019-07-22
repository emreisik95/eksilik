//
//  EntryViewController.swift
//  Eksilik
//
//  Created by Emre Işık on 15.02.2019.
//  Copyright © 2019 Emre Isik. All rights reserved.
//

import UIKit
import Alamofire
import Kanna
import SafariServices
import Toast_Swift

class EntryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, SFSafariViewControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        var yazi = resultSearchController.searchBar.text!
        if yazi.contains("@"){
            let vc =
                self.storyboard?.instantiateViewController(withIdentifier:
                    "entryGoruntule") as! EntryViewController
            yazi = yazi.replacingOccurrences(of: "@", with: "")
            let baslik = yazi.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
            vc.baslikLinki = "\(baslikLinki)?a=search&author=\(baslik)"
            self.navigationController?.pushViewController(vc, animated: true)
            resultSearchController.isActive = false
        }
        let vc =
            self.storyboard?.instantiateViewController(withIdentifier:
                "entryGoruntule") as! EntryViewController
        let baslik = yazi.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]{} ").inverted)!
       baslikLinki = baslikLinki.replacingOccurrences(of: "?a=popular", with: "")
       baslikLinki = baslikLinki.replacingOccurrences(of: "?a=popular&p=\(self.aktifSayfa)", with: "")

        vc.baslikLinki = "\(baslikLinki)?a=find&keywords=\(baslik)"
        self.navigationController?.pushViewController(vc, animated: true)
        resultSearchController.isActive = false
        
    }
    
        var viewcim = (Bundle.main.loadNibNamed("başlık boş", owner: self, options: nil)![0]) as! UIView
    
    var anlam = [String]()
    var entryler = [NSAttributedString]()
    var favoriler = [NSAttributedString]()
    var linkler = [String]()
    var favoriSayisi = [Int]()
    var baslikLinki = String()
    var userName = [String]()
    var tarihler = [String]()
    var yildizlar = [String]()
    var kullaniciAdi = [String]()
    let headers: HTTPHeaders = [ "X-Requested-With": "XMLHttpRequest",
                                 "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1",
                                 "Accept-Language": "tr-TR,tr;q=0.9,en-US;q=0.8,en;q=0.7,ru;q=0.6",
                                 "Accept-Encoding": "gzip, deflate, br"]
    var fav = [Bool]()
    var baslikKontrolu = [String]()
    var girisKontrolu = ""
    var sayfaSayisi = ""
    var aktifSayfa = ""
    var sukela = [Bool]()
    var kotule = [Bool]()
    var asilLink = ""
    var baslik = ""
    var gidenBaslik = ""
    var yildizsayisi: Int = 0
    var secim = Bool()
    let status = UserDefaults.standard.bool(forKey: "giris")
    var array = [String]()
    var secti = Int()
    var barAccessory = UIToolbar()
    let font = UserDefaults.standard.string(forKey: "secilenFont")
    let tema = UserDefaults.standard.integer(forKey: "secilenTema")
    let safari = UserDefaults.standard.bool(forKey: "link")
    let entryGizle = UserDefaults.standard.bool(forKey: "gizle")
    var pager = 1
    var takipNo = ""
    var takip = false
    var authorId = [String]()
    var eID = ""
    var duzenleLinki = ""
    var baslikKontrolLink = [String]()
    var anlamAyrimi = [String]()


    @IBAction func suserButton(_ sender: UIButton) {
        if let indexPath = entryView.indexPath(forItem: sender) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier:
                "suserProfile") as! SuserViewController
            var kadi = userName[indexPath.row]
            kadi = kadi.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
            vc.biriLink = "/biri/\(kadi)"
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    private let refreshControl = UIRefreshControl()
    
    
    @IBAction func favoributton(_ sender: UIButton) {
        if let indexPath = entryView.indexPath(forItem: sender) {
            self.eID = linkler[indexPath.row]
            performSegue(withIdentifier: "favorileyen", sender: nil)
        }
    }
    
    
    @IBOutlet weak var sayfaButonu: UIButton!
    
    @IBAction func sayfaButton(_ sender: Any) {
        if sayfaSayisi.isEmpty == false{
        typePickerView.isHidden = false
        self.view.addSubview(typePickerView)
        barAccessory = UIToolbar(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 324, width: typePickerView.frame.size.width, height: 44))
        barAccessory.barStyle = Theme.barStyle!
        barAccessory.barTintColor = Theme.entryButton
      /*  let textfield = UITextField(frame: CGRect(x: 5, y: 5, width: 55, height: 10))
            textfield.backgroundColor = .white
            textfield.textColor = .black
            textfield.placeholder = "\(aktifSayfa) / \(sayfaSayisi)"
            textfield.keyboardType = .numberPad
            textfield.keyboardAppearance = Theme.keyboardColor!
            textfield.becomeFirstResponder()
        let textfieldBarButton = UIBarButtonItem.init(customView: textfield)*/
        let vazgec = UIBarButtonItem(title: "vazgeç", style: .done, target: self, action: #selector(vazgec(_:)))
        let flexiblespace = UIBarButtonItem(barButtonSystemItem:.flexibleSpace , target: nil, action: nil)
        let btnDone = UIBarButtonItem(title: "tamam", style: .done, target: self, action: #selector(tamam(_:)))
        btnDone.tintColor = .white
        vazgec.tintColor = .white
        barAccessory.items = [vazgec,flexiblespace,btnDone]
        self.view.addSubview(barAccessory)
        }
    }
    
    @IBAction func vazgec(_ sender: Any) {
        self.barAccessory.isHidden = true
        self.typePickerView.isHidden = true
    }
    
    @IBAction func tamam(_ sender: Any) {
        CustomLoader.instance.showLoaderView()
        typePickerView.isHidden = true
        barAccessory.isHidden = true
        if baslikLinki.contains("popular") || baslikLinki.contains("nice") || baslikLinki.contains("find") || baslikLinki.contains("search") || baslikLinki.contains("eksiseyler") || baslikLinki.contains("caylaklar") || baslikLinki.contains("day") || baslikLinki.contains("latest") || baslikLinki.contains("tracked") || baslikLinki.contains("focus"){
            baslikLinki = baslikLinki.replacingOccurrences(of: "&p=\(aktifSayfa)", with: "")
            baslikLinki.append("&p=\(secti)")
        }
        else{
            baslikLinki = baslikLinki.replacingOccurrences(of: "?p=\(aktifSayfa)", with: "")
            baslikLinki.append("?p=\(secti)")
        }
        self.entryView.isScrollEnabled = false
        let co = self.entryView.contentOffset
        self.entryView.setContentOffset(co, animated: false)
        secti = Int()
        DispatchQueue.main.async {
            self.siteyeBaglan()
            self.entryView.beginUpdates()
            self.entryView.setContentOffset(.zero, animated: false)
            self.entryView.endUpdates()
            self.entryView.isScrollEnabled = true
        }
    }

    @IBAction func sonrakiSayfa(_ sender: Any) {
        CustomLoader.instance.showLoaderView()

        let sayfa = Int(aktifSayfa)!
        if baslikLinki.contains("popular") || baslikLinki.contains("nice") || baslikLinki.contains("find") || baslikLinki.contains("search") || baslikLinki.contains("eksiseyler") || baslikLinki.contains("caylaklar") || baslikLinki.contains("day") || baslikLinki.contains("latest") || baslikLinki.contains("tracked") || baslikLinki.contains("focus"){
           baslikLinki = baslikLinki.replacingOccurrences(of: "&p=\(sayfa)", with: "")
            baslikLinki.append("&p=\(sayfa+1)")
        }
        else{
            baslikLinki = baslikLinki.replacingOccurrences(of: "?p=\(sayfa)", with: "")
            baslikLinki.append("?p=\(sayfa+1)")
        }
        self.entryView.isScrollEnabled = false
        let co = self.entryView.contentOffset
        self.entryView.setContentOffset(co, animated: false)
        DispatchQueue.main.async {
            self.siteyeBaglan()
            self.entryView.beginUpdates()
            self.entryView.setContentOffset(.zero, animated: false)
            self.entryView.endUpdates()
            self.entryView.isScrollEnabled = true
        }
    }
    @IBOutlet weak var sonrakiSayfaButonu: UIButton!
    
    @IBOutlet weak var sonSayfaButonu: UIButton!
    @IBAction func sonSayfa(_ sender: Any) {
        CustomLoader.instance.showLoaderView()
        if baslikLinki.contains("popular") || baslikLinki.contains("nice") || baslikLinki.contains("find") || baslikLinki.contains("search") || baslikLinki.contains("eksiseyler") || baslikLinki.contains("caylaklar") || baslikLinki.contains("day") || baslikLinki.contains("latest") || baslikLinki.contains("tracked") || baslikLinki.contains("focus"){
            baslikLinki = baslikLinki.replacingOccurrences(of: "&p=\(aktifSayfa)", with: "")
            baslikLinki.append("&p=\(sayfaSayisi)")
        }
        else{
            baslikLinki = baslikLinki.replacingOccurrences(of: "?p=\(aktifSayfa)", with: "")
            baslikLinki.append("?p=\(sayfaSayisi)")
        }
        self.entryView.isScrollEnabled = false
        let co = self.entryView.contentOffset
        self.entryView.setContentOffset(co, animated: false)
        DispatchQueue.main.async {
            self.siteyeBaglan()
            self.entryView.beginUpdates()
            self.entryView.setContentOffset(.zero, animated: false)
            self.entryView.endUpdates()
            self.entryView.isScrollEnabled = true
        }
    }
 
    @IBOutlet weak var ilkSayfa: UIButton!
    @IBAction func ilkSayfaButonu(_ sender: Any) {
        CustomLoader.instance.showLoaderView()
        if baslikLinki.contains("popular") || baslikLinki.contains("nice") || baslikLinki.contains("find") || baslikLinki.contains("search") || baslikLinki.contains("eksiseyler") || baslikLinki.contains("caylaklar") || baslikLinki.contains("day") || baslikLinki.contains("latest") || baslikLinki.contains("tracked") || baslikLinki.contains("focus"){
            baslikLinki = baslikLinki.replacingOccurrences(of: "&p=\(aktifSayfa)", with: "")
            baslikLinki.append("&p=1")
        }
        else{
            baslikLinki = baslikLinki.replacingOccurrences(of: "?p=\(aktifSayfa)", with: "")
            baslikLinki.append("?p=1")
        }
        self.entryView.isScrollEnabled = false
        let co = self.entryView.contentOffset
        self.entryView.setContentOffset(co, animated: false)
        DispatchQueue.main.async {
            self.siteyeBaglan()
            self.entryView.beginUpdates()
            self.entryView.setContentOffset(.zero, animated: false)
            self.entryView.endUpdates()
            self.entryView.isScrollEnabled = true
        }
    }
    
    
    
    @IBOutlet weak var oncekiSayfaButonu: UIButton!
    @IBAction func oncekiSayfa(_ sender: Any) {
        CustomLoader.instance.showLoaderView()
        let sayfa = Int(aktifSayfa)!
        if baslikLinki.contains("popular") || baslikLinki.contains("nice") || baslikLinki.contains("find") || baslikLinki.contains("search") || baslikLinki.contains("eksiseyler") || baslikLinki.contains("caylaklar") || baslikLinki.contains("day") || baslikLinki.contains("latest") || baslikLinki.contains("focus"){
            baslikLinki = baslikLinki.replacingOccurrences(of: "&p=\(sayfa)", with: "")
            baslikLinki.append("&p=\(sayfa-1)")
        }
        else{
            baslikLinki = baslikLinki.replacingOccurrences(of: "?p=\(sayfa)", with: "")
            baslikLinki.append("?p=\(sayfa-1)")
        }
        self.entryView.isScrollEnabled = false
        let co = self.entryView.contentOffset
        self.entryView.setContentOffset(co, animated: false)
        DispatchQueue.main.async {
            self.siteyeBaglan()
            self.entryView.beginUpdates()
            self.entryView.setContentOffset(.zero, animated: false)
            self.entryView.endUpdates()
            self.entryView.isScrollEnabled = true
        }
    }
    

    @IBOutlet weak var entryYazButton: UIBarButtonItem!

    var resultSearchController = UISearchController()
    
    var indexP = IndexPath()
    @IBAction func digerButton(_ sender: UIButton) {
        
        if let indexPath = entryView.indexPath(forItem: sender) {
            self.indexP = indexPath
        }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if self.girisKontrolu.isEmpty{
        }else{
        alert.addAction(UIAlertAction(title: "mesaj gönder", style: .default, handler: { (UIAlertAction) in
            CustomLoader.instance.showLoaderView()
            self.performSegue(withIdentifier: "mesajAt", sender: nil)
        }))
        }
        alert.addAction(UIAlertAction(title: "entry'i kopyala", style: .default, handler: { (UIAlertAction) in
            UIPasteboard.general.string = self.entryler[self.indexP.row].string
            self.view.makeToast("entry başarıyla kopyalandı")
        }))
        alert.addAction(UIAlertAction(title: "vazgeç", style: .cancel, handler: { (UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }))
        alert.view.tintColor = Theme.entryButton
        alert.view.layer.cornerRadius = 25
        alert.view.layer.borderColor = Theme.entryButton?.cgColor
        alert.view.layer.borderWidth = 0
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad)
        {
            alert.popoverPresentationController!.sourceView = self.view
            alert.popoverPresentationController!.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 1.25, width: 1.0, height: 1.0)
            
        }
        self.present(alert,animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    func scrollToTop() {
        
        DispatchQueue.main.async {
            if self.entryler.count>1{
            let indexPath = IndexPath(row: 0, section: 0)
            self.entryView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
    }
    
    @IBOutlet weak var durumLabel: UILabel!
    @IBOutlet weak var durumView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        puntosecim = UserDefaults.standard.integer(forKey: "secilenPunto")

        self.navigationController?.navigationBar.barStyle = Theme.barStyle!
        self.navigationController?.navigationBar.barTintColor = Theme.navigationBarColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Theme.titleColor!]
        tabBarController?.tabBar.installBlurEffect()
        self.navigationController?.navigationBar.installBlurEffect()

        self.navigationItem.rightBarButtonItem?.tintColor = Theme.titleColor
        self.navigationItem.leftBarButtonItem?.tintColor = Theme.titleColor
        
        if status == false{
            if #available(iOS 11.0, *) {
//                NSLayoutConstraint(item: view.safeAreaLayoutGuide, attribute: .trailing, relatedBy: .equal, toItem: takipButonu, attribute: .trailing, multiplier: 1, constant: -20).isActive = true
            } else {
                // Fallback on earlier versions
            }
        }
        prepareUI()
        siteyeBaglan()
        durumLabel.text = "gündem entryleri"
        durumLabel.adjustsFontSizeToFitWidth = true
        durumLabel.textColor = Theme.entryColor
        let durumBlurView  = UIVisualEffectView(effect: Theme.altBarStyle!)
        durumView.isUserInteractionEnabled = true
        durumBlurView.frame = durumView.bounds
        durumBlurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        durumView.addSubview(durumBlurView)
        durumBlurView.layer.zPosition = -1
        durumBlurView.isUserInteractionEnabled = false
        self.view.backgroundColor = Theme.backgroundColor
        durumView.isUserInteractionEnabled = true
        entryView.tableFooterView = UIView()
        ilkSayfa.imageView?.image = ilkSayfa.imageView?.image!.withRenderingMode(.alwaysTemplate)
        paylasButonu.imageView?.image = paylasButonu.imageView?.image!.withRenderingMode(.alwaysTemplate)
        sukelaButonu.imageView?.image = sukelaButonu.imageView?.image!.withRenderingMode(.alwaysTemplate)
        secenekButonu.imageView?.image = secenekButonu.imageView?.image!.withRenderingMode(.alwaysTemplate)
        secenekButonu.tintColor = Theme.labelColor
        takipButonu.tintColor = Theme.labelColor
        sukelaButonu.tintColor = Theme.labelColor
        paylasButonu.tintColor = Theme.labelColor
        oncekiSayfaButonu.tintColor = Theme.labelColor
        sayfaButonu.setTitleColor(Theme.labelColor, for: .normal)
        sonrakiSayfaButonu.tintColor = Theme.labelColor
        sonSayfaButonu.tintColor = Theme.labelColor
        ilkSayfa.tintColor = Theme.labelColor
        durumLabel.textColor = Theme.linkColor
        sayfaButonu.titleLabel?.adjustsFontSizeToFitWidth = true
        CustomLoader.instance.showLoaderView()
        entryView.delegate = self
        entryView.dataSource = self
        entryView.backgroundColor = Theme.backgroundColor
        entryView.alwaysBounceVertical = false
       // baslikLinki = baslikLinki.replacingOccurrences(of: "https://eksisozluk.com/", with: "")
        self.navigationController?.navigationBar.tintColor = Theme.titleColor
        self.typePickerView.dataSource = self
        self.typePickerView.delegate = self
        self.typePickerView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 280, width: UIScreen.main.bounds.width, height: 220)
        entryView.separatorStyle = .singleLine
        entryView.separatorColor = Theme.separatorColor
        let nvHeight = navigationController?.navigationBar.frame.height ?? 0
        let tbHeight = self.tabBarController?.tabBar.frame.height ?? 0
        let adjustForTabbarInsets: UIEdgeInsets = UIEdgeInsets(top:  nvHeight+14 , left: 0, bottom: tbHeight + 84, right: 0)
        self.entryView.contentInset = adjustForTabbarInsets
        self.entryView.scrollIndicatorInsets = adjustForTabbarInsets
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchBar.barStyle = Theme.barStyle!
            controller.searchBar.tintColor = .white
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            self.definesPresentationContext = true
            controller.hidesNavigationBarDuringPresentation = false
            controller.searchBar.setValue("vazgeç", forKey: "cancelButtonText")
            controller.searchBar.sizeToFit()
            controller.searchBar.placeholder = "kelime ya da @yazar ara"
            controller.searchBar.keyboardAppearance = .dark
            controller.searchBar.delegate = self
            if status{
                self.entryView.tableHeaderView = controller.searchBar
            }
            self.entryView.backgroundView = UIView()
            return controller
        })()
        let point = CGPoint(x: 0, y:(self.navigationController?.navigationBar.frame.size.height)! + 12)
        entryView.setContentOffset(point, animated: true)
        if status == false{
            takipButonu.isHidden = true
        }
    }
    
    
    var refreshView: RefreshView!
    
    var tableViewRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = .clear
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        return refreshControl
    }()
    
    
    private func loadData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(20)) {
            self.entryView.reloadData()
        }
    }
    @objc func refreshTableView() {
        CustomLoader.instance.showLoaderView()
        siteyeBaglan()
        self.tableViewRefreshControl.endRefreshing()
    }
    func prepareUI() {
        // Adding 'tableViewRefreshControl' to tableView
        entryView.refreshControl = tableViewRefreshControl
        // Getting the nib from bundle
        getRefereshView()
    }
    func getRefereshView() {
        if let objOfRefreshView = Bundle.main.loadNibNamed("RefreshView", owner: self, options: nil)?.first as? RefreshView {
            // Initializing the 'refreshView'
            refreshView = objOfRefreshView
            // Giving the frame as per 'tableViewRefreshControl'
            refreshView.frame = tableViewRefreshControl.frame
            // Adding the 'refreshView' to 'tableViewRefreshControl'
            tableViewRefreshControl.addSubview(refreshView)
        }
    }
    var gizlendi = [Bool]()
 
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
           if entryGizle == true{
        let closeAction = UIContextualAction(style: .normal, title:  "gizle", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            tableView.beginUpdates()
            if self.gizlendi[indexPath.row] == false{
            self.gizlendi[indexPath.row] = true
            }else{
                self.gizlendi[indexPath.row] = false
            }
            tableView.endUpdates()
            print("küçültüldü")
            success(true)
        })
        closeAction.image = UIImage(named: "tick")
        closeAction.backgroundColor = Theme.entryButton
        
        return UISwipeActionsConfiguration(actions: [closeAction])
           }else{
            return nil
        }
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

       let cell = tableView.cellForRow(at: indexPath) as! entryViewTableCell
        
        if cell.userButton.titleLabel?.text == kullaniciAdi[0]{
        self.duzenleLinki = "https://eksisozluk.com/entry/duzelt/\(self.linkler[indexPath.row])"
            let duzenle = UITableViewRowAction(style: .normal, title: "entry'i düzenle") { (UITableViewRowAction, indexPath) in
                self.duzenleLinki = self.linkler[indexPath.row]
                self.performSegue(withIdentifier: "duzenle", sender: nil)
            }
            let sil = UITableViewRowAction(style: .destructive, title: "entry'i sil") { (action, indexPath) in
                let alert = UIAlertController(title: nil, message: "#\(self.linkler[indexPath.row]) numaralı entry silinsin mi?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "aynen", style: .default, handler: { (UIAlertAction) in
                    let header: HTTPHeaders = [ "X-Requested-With": "XMLHttpRequest"]
                    let parameters: Parameters = ["Id": "\(self.linkler[indexPath.row])"]
                    Alamofire.request("https://eksisozluk.com/entry/sil", method: .post, parameters: parameters, headers: header).responseJSON { response in
                        if response.response?.statusCode == 200{
                            let alerti = UIAlertController(title: nil, message: "#\(self.linkler[indexPath.row]) numaralı entry'niz başarıyla silindi!", preferredStyle: .alert)
                            alerti.addAction(UIKit.UIAlertAction(title:"tamam", style: .cancel, handler: { (UIAlertAction)in
                                self.dismiss(animated: true, completion: nil)
                            }))
                            alerti.view.tintColor = Theme.entryButton!
                            self.present(alerti, animated: true, completion: nil)
                            self.entryler.remove(at: indexPath.row)
                            self.fav.remove(at: indexPath.row)
                            self.authorId.remove(at: indexPath.row)
                            self.favoriler.remove(at: indexPath.row)
                            self.favoriSayisi.remove(at: indexPath.row)
                            self.kotule.remove(at: indexPath.row)
                            self.sukela.remove(at: indexPath.row)
                            self.tarihler.remove(at: indexPath.row)
                            self.userName.remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .fade)
                        }else if response.response?.statusCode == 429{
                            let alerti = UIAlertController(title: nil, message: "#\(self.linkler[indexPath.row]) numaralı entry'niz ekşi sözlük'ün entry silme limiti yüzünden silinemedi. 2 dakika içinde tekrar deneyin.", preferredStyle: .alert)
                            alerti.addAction(UIKit.UIAlertAction(title:"tamam", style: .cancel, handler: { (UIAlertAction)in
                                self.dismiss(animated: true, completion: nil)
                            }))
                            alerti.view.tintColor = Theme.entryButton!
                            self.present(alerti, animated: true, completion: nil)
                        }else{
                            let alerti = UIAlertController(title: nil, message: "#\(self.linkler[indexPath.row]) numaralı entry'niz silinemedi. \nhata kodu: \(String(describing: response.response?.statusCode))", preferredStyle: .alert)
                            alerti.addAction(UIKit.UIAlertAction(title:"tamam", style: .cancel, handler: { (UIAlertAction)in
                                self.dismiss(animated: true, completion: nil)
                            }))
                            alerti.view.tintColor = Theme.entryButton!
                            self.present(alerti, animated: true, completion: nil)
                        }
                    }
                }))
                alert.addAction(UIAlertAction(title: "yoo", style: .cancel, handler: { (UIAlertAction)in
                    self.dismiss(animated: true, completion: nil)
                }))
                alert.view.tintColor = Theme.entryButton
                self.present(alert, animated: true, completion: nil)
            }
            duzenle.backgroundColor = Theme.entryButton
            sil.backgroundColor = .red
            return [duzenle, sil]
        }else{
        let engelle = UITableViewRowAction(style: .normal, title: "engelle") { (UITableViewRowAction, indexPath) in
            let alert = UIAlertController(title: nil, message: "\(self.userName[indexPath.row]) kişisi engellensin mi?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "aynen", style: .default, handler: { (UIAlertAction) in
                
                let parameters: Parameters = ["Id": "\(self.authorId[indexPath.row])",
                    "r": "m"]
                Alamofire.request("https://eksisozluk.com/userrelation/addrelation",method: .post, parameters: parameters, headers: self.headers).responseJSON { response in
                    if response.result.isSuccess{
                        let alerti = UIAlertController(title: nil, message: "\(self.userName[indexPath.row]) kişisi başarıyla engellendi!", preferredStyle: .alert)
                        alerti.addAction(UIKit.UIAlertAction(title:"tamam", style: .cancel, handler: { (UIAlertAction)in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        alerti.view.tintColor = Theme.entryButton!
                        self.present(alerti, animated: true, completion: nil)
                        self.entryler.remove(at: indexPath.row)
                        self.fav.remove(at: indexPath.row)
                        self.authorId.remove(at: indexPath.row)
                        self.favoriler.remove(at: indexPath.row)
                        self.favoriSayisi.remove(at: indexPath.row)
                        self.kotule.remove(at: indexPath.row)
                        self.sukela.remove(at: indexPath.row)
                        self.tarihler.remove(at: indexPath.row)
                        self.userName.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        
                    }
                }
                
            }))
            alert.addAction(UIAlertAction(title: "yoo", style: .cancel, handler: { (UIAlertAction)in
                self.dismiss(animated: true, completion: nil)
            }))
            alert.view.tintColor = Theme.entryButton
            self.present(alert, animated: true, completion: nil)
        }
        engelle.backgroundColor = Theme.entryButton
        return [engelle]
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    
    var typePickerView: UIPickerView = UIPickerView()

    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let myTitle = NSAttributedString(string: array[row], attributes: [NSAttributedString.Key.foregroundColor: Theme.userColor!])
        pickerView.backgroundColor = Theme.backgroundColor
        return myTitle
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.secti = row+1
        print(self.secti)
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return array.count
    }

    @IBAction func baslikPaylas(_ sender: Any) {
        let items = ["\(baslik) \nhttps://eksisozluk.com/entry/\(baslikLinki)"]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad)
        {
            ac.popoverPresentationController!.sourceView = self.view
            ac.popoverPresentationController!.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 1.25, width: 1.0, height: 1.0)
            
        }
        self.present(ac, animated: true)
    }
 
    
    @IBAction func secenekButton(_ sender: Any) {
        let ben = self.kullaniciAdi[0].addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "tümü", style: .default, handler: { (UIAlertAction) in
            CustomLoader.instance.showLoaderView()
            
            self.entryler = [NSAttributedString]()
            self.favoriler = [NSAttributedString]()
            self.linkler = [String]()
            self.favoriSayisi = [Int]()
            self.userName = [String]()
            self.tarihler = [String]()
            self.fav = [Bool]()
            self.baslikLinki = "\(self.tumuLink)"
            self.durumLabel.text = "tüm entryler"
            self.siteyeBaglan()
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "ekşi şeyler'de", style: .default, handler: { (UIAlertAction) in
            CustomLoader.instance.showLoaderView()
            
            self.entryler = [NSAttributedString]()
            self.favoriler = [NSAttributedString]()
            self.linkler = [String]()
            self.favoriSayisi = [Int]()
            self.userName = [String]()
            self.tarihler = [String]()
            self.fav = [Bool]()
            self.baslikLinki = "\(self.tumuLink)?a=eksiseyler"
            self.siteyeBaglan()
            self.dismiss(animated: true, completion: nil)
            self.durumLabel.text = "ekşi şeyler"
        }))
        if self.girisKontrolu.isEmpty{
            
        }else{
        alert.addAction(UIAlertAction(title: "linkler", style: .default, handler: { (UIAlertAction) in
            CustomLoader.instance.showLoaderView()
            
            self.entryler = [NSAttributedString]()
            self.favoriler = [NSAttributedString]()
            self.linkler = [String]()
            self.favoriSayisi = [Int]()
            self.userName = [String]()
            self.tarihler = [String]()
            self.fav = [Bool]()
            self.baslikLinki = "\(self.tumuLink)?a=find&keywords=http%3a%2f%2f"
            self.siteyeBaglan()
            self.dismiss(animated: true, completion: nil)
            self.durumLabel.text = "linkler"
            
        }))
        }
        if self.girisKontrolu.isEmpty{
            
        }else{
            alert.addAction(UIAlertAction(title: "benimkiler", style: .default, handler: { (UIAlertAction) in
                CustomLoader.instance.showLoaderView()
                
                self.entryler = [NSAttributedString]()
                self.favoriler = [NSAttributedString]()
                self.linkler = [String]()
                self.favoriSayisi = [Int]()
                self.userName = [String]()
                self.tarihler = [String]()
                self.fav = [Bool]()
                self.baslikLinki = "\(self.tumuLink)?a=search&author=\(ben)"
                self.siteyeBaglan()
                self.dismiss(animated: true, completion: nil)
                self.durumLabel.text = "benimkiler"
            }))}

        if self.girisKontrolu.isEmpty{
            
        }else{
        alert.addAction(UIAlertAction(title: "takip ettiklerim", style: .default, handler: { (UIAlertAction) in
            CustomLoader.instance.showLoaderView()
            
            self.entryler = [NSAttributedString]()
            self.favoriler = [NSAttributedString]()
            self.linkler = [String]()
            self.favoriSayisi = [Int]()
            self.userName = [String]()
            self.tarihler = [String]()
            self.fav = [Bool]()
            self.baslikLinki = "\(self.tumuLink)?a=buddy"
            self.siteyeBaglan()
            self.dismiss(animated: true, completion: nil)
            self.durumLabel.text = "takip ettiklerim"
        }))}
        if self.girisKontrolu.isEmpty{
            
        }else{
        alert.addAction(UIAlertAction(title: "bugün", style: .default, handler: { (UIAlertAction) in
            CustomLoader.instance.showLoaderView()
            
            self.entryler = [NSAttributedString]()
            self.favoriler = [NSAttributedString]()
            self.linkler = [String]()
            self.favoriSayisi = [Int]()
            self.userName = [String]()
            self.tarihler = [String]()
            self.fav = [Bool]()
            
            let date = Date()
            let calendar = Calendar.current
            
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            let gun = String(format: "%02d", day)
            let ay = String(format: "%02d", month)
            self.baslikLinki = "\(self.tumuLink)?day=\(year)-\(ay)-\(gun)"
            self.siteyeBaglan()
            self.dismiss(animated: true, completion: nil)
            self.durumLabel.text = "bugün"
        }))
        }
        alert.addAction(UIAlertAction(title: "hiçbiri", style: .cancel, handler: nil))
        alert.view.tintColor = Theme.entryButton
        alert.view.layer.cornerRadius = 25
        alert.view.layer.borderColor = Theme.entryButton?.cgColor
        alert.view.layer.borderWidth = 0
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad)
        {
            alert.popoverPresentationController!.sourceView = self.view
            alert.popoverPresentationController!.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 1.25, width: 1.0, height: 1.0)
            
        }
        self.present(alert, animated: true, completion: nil)
 
    }
    
 
    @IBAction func yorumSukela(_ sender: UIButton) {
        if let indexPath = entryView.indexPath(forItem: sender) {
        let cell = entryView.cellForRow(at: indexPath)! as? YorumViewCell
            let yorum = self.yorumEksiOy[indexPath.row]
            let parameters: Parameters = [
                "owner": "\(self.yorumOwner[indexPath.row])",
                "Id": "\(yorumID[indexPath.row])",
                "rate": "1"]
            if sukela[indexPath.row] == false{
                Alamofire.request("https://eksisozluk.com/yorum/vote",method: .post, parameters: parameters, headers: headers).responseJSON { response in
                    if response.result.isSuccess{
                        let artir = Int(yorum)!+1
                        cell?.kotuleSayi.text = "\(artir)"
                        if let image = UIImage(named: "şükelalandı") {
                            cell?.sukela.setImage(image, for: .normal)
                        }
                        self.sukela[indexPath.row] = true
                    }
                }
            }
            if sukela[indexPath.row] == true{
                Alamofire.request("https://eksisozluk.com/yorum/vote",method: .post, parameters: parameters, headers: headers).responseJSON { response in
                    if response.result.isSuccess{
                        cell?.kotuleSayi.text = "\(yorum)"
                        if let image = UIImage(named: "şükela") {
                            cell?.sukela.setImage(image, for: .normal)
                        }
                        self.sukela[indexPath.row] = false
                    }
                }
            }
        }
    }
    
    @IBAction func yorumKotule(_ sender: UIButton) {
        
        if let indexPath = entryView.indexPath(forItem: sender) {
            let cell = entryView.cellForRow(at: indexPath)! as? YorumViewCell
            let yorum = self.yorumArtiOy[indexPath.row]
            let parameters: Parameters = [
                "owner": "\(self.yorumOwner[indexPath.row])",
                "Id": "\(yorumID[indexPath.row])",
                "rate": "-1"]
            if sukela[indexPath.row] == false{
                Alamofire.request("https://eksisozluk.com/yorum/vote",method: .post, parameters: parameters, headers: headers).responseJSON { response in
                    if response.result.isSuccess{
                        let artir = Int(yorum)!+1
                        cell?.sukelaSayi.text = "\(artir)"
                        if let image = UIImage(named: "kötülendi") {
                            cell?.kotule.setImage(image, for: .normal)
                        }
                        self.sukela[indexPath.row] = true
                    }
                }
            }
            if sukela[indexPath.row] == true{
                Alamofire.request("https://eksisozluk.com/yorum/vote",method: .post, parameters: parameters, headers: headers).responseJSON { response in
                    if response.result.isSuccess{
                        cell?.sukelaSayi.text = "\(yorum)"
                        if let image = UIImage(named: "kötüle") {
                            cell?.kotule.setImage(image, for: .normal)
                        }
                        self.sukela[indexPath.row] = false
                    }
                }
            }
        }
        
    }
    

    @IBAction func sukelaButton(_ sender: Any) {
        DispatchQueue.main.async{
                    let ben = self.kullaniciAdi[0].addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        }
        let alert = UIAlertController(title: "şükela modu", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "bugün", style: .default, handler: { (UIAlertAction) in
            CustomLoader.instance.showLoaderView()
            
            self.entryler = [NSAttributedString]()
            self.favoriler = [NSAttributedString]()
            self.linkler = [String]()
            self.favoriSayisi = [Int]()
            self.userName = [String]()
            self.tarihler = [String]()
            self.fav = [Bool]()
            self.sayfaSayisi = ""
            self.aktifSayfa = ""
            self.baslikLinki = "\(self.tumuLink)?a=dailynice"
            self.siteyeBaglan()
            self.durumLabel.text = "şükela bugün"
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "tümü", style: .default, handler: { (UIAlertAction) in
            CustomLoader.instance.showLoaderView()
            
            self.entryler = [NSAttributedString]()
            self.favoriler = [NSAttributedString]()
            self.linkler = [String]()
            self.favoriSayisi = [Int]()
            self.userName = [String]()
            self.tarihler = [String]()
            self.fav = [Bool]()
            self.sayfaSayisi = ""
            self.aktifSayfa = ""
            self.baslikLinki = "\(self.tumuLink)?a=nice"
            self.siteyeBaglan()
            self.durumLabel.text = "şükela tümü"
            
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "hiçbiri", style: .cancel, handler: nil))
        alert.view.tintColor = Theme.entryButton
        alert.view.layer.cornerRadius = 25
        alert.view.layer.borderColor = Theme.entryButton?.cgColor
        alert.view.layer.borderWidth = 0
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad)
        {
            alert.popoverPresentationController!.sourceView = self.view
            alert.popoverPresentationController!.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 1.25, width: 1.0, height: 1.0)
            
        }

        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "entryGir"{
            let entryVC = segue.destination as! EntryYazViewController
            entryVC.baslikLinki = "https://eksisozluk.com\(self.baslikLinki)"
            entryVC.Title = baslik
        }
        if segue.identifier == "favorileyen"{
            let favoriVC = segue.destination as! favorileyenViewController
            let entryId = self.eID
            favoriVC.entryId = entryId
        }
        if segue.identifier == "duzenle"{
            let vc = segue.destination as! DuzenleViewController
            vc.Title = self.baslik
            vc.baslikLinki = self.baslikLinki
            vc.entryNo = self.duzenleLinki
        }
        if segue.identifier == "mesajAt"{
                let vc = segue.destination as! mesajYazViewController
                vc.baslikLinki = self.baslikLinki
                vc.yazarAdi = userName[indexP.row]
            vc.mesajAdi = "(#\(linkler[indexP.row])) "
            vc.cevap = false
        }
    }
    
   
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let link = URL.absoluteString
        let url = URL
        if (link.contains("applewebdata://")){
            var url = URLComponents(string: link)!
            url.host = ""
            var asil: String = ""
            asil = url.string!
           self.asilLink = asil.replacingOccurrences(of: "applewebdata://", with: "", options: .literal, range: nil)
            let viewController = storyboard?.instantiateViewController(withIdentifier: "entryGoruntule") as! EntryViewController
            CustomLoader.instance.showLoaderView()
            viewController.baslikLinki = "\(self.asilLink)"
            navigationController?.pushViewController(viewController, animated: true)
        }
        else if safari == true{
            if (link.contains("twitter")) && (link.contains("status")){
                let appURL = NSURL(string: "twitter://status?id=\(url.lastPathComponent)")!
                if UIApplication.shared.canOpenURL(appURL as URL) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(appURL as URL, options: [:], completionHandler: nil)
                    }
                }
            }else if(link.contains("twitter") && link.contains("status") == false){
                let appURL = NSURL(string: "twitter://user?screen_name=\(url.lastPathComponent)")!
                if UIApplication.shared.canOpenURL(appURL as URL) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(appURL as URL, options: [:], completionHandler: nil)
                    }
                }
            }else{
                
            let controller = SFSafariViewController(url: URL)
            controller.preferredBarTintColor = Theme.backgroundColor
            controller.preferredControlTintColor = Theme.entryButton
            controller.dismissButtonStyle = .close
            self.present(controller, animated: true, completion: nil)
            controller.delegate = self
            func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
                controller.dismiss(animated: true, completion: nil)
            }
            }
        }else{
            UIApplication.shared.open(URL)
        }
        return false
    }
    
    

    @IBOutlet var secenekButonu: UIButton!
    
    @IBOutlet var paylasButonu: UIButton!
    
    @IBOutlet var sukelaButonu: UIButton!
    
    @IBOutlet var takipButonu: UIButton!
    
    
    @IBOutlet weak var entryView: UITableView!
    /* Otomatik tablo hücre yüksekliği  */

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if gizlendi[indexPath.row] == false{
            return UITableView.automaticDimension
        }else{
            return 150
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if gizlendi[indexPath.row] == false{
            return UITableView.automaticDimension
        }else{
            return 150
        }
        
    }
    /* Otomatik tablo hücre yüksekliği  */
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            if self.baslikKontrolu.isEmpty == false{
        let view = UIView()
        let blurEffect = Theme.altBarStyle!
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30)
        view.layer.masksToBounds = false
        view.layer.shadowColor = Theme.userColor?.cgColor
        view.layer.shadowOffset = CGSize(width: 0.0, height: 0.3)
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = 0.0
        let tumuButton = UIButton()
        tumuButton.setTitle(self.baslikKontrolu[0], for: .normal)
        tumuButton.setTitleColor(Theme.userColor, for: .normal)
                tumuButton.titleLabel?.font = UIFont(name: font!, size: CGFloat(puntosecim))
        tumuButton.frame = view.bounds
        tumuButton.addTarget(self, action: #selector(self.headerButton(sender:)), for: UIControl.Event.touchUpInside)
        view.addSubview(tumuButton)
            return view
        }
            return UIView()
    }
   @objc func headerButton(sender:UIButton!) {
       self.baslikLinki = baslikKontrolLink[0]
        CustomLoader.instance.showLoaderView()
        self.siteyeBaglan()
    self.entryView.beginUpdates()
    self.entryView.setContentOffset(.zero, animated: false)
    self.entryView.endUpdates()
    }

    @objc func footerButton(sender:UIButton!) {
        self.baslikLinki = baslikKontrolLink[1]
        CustomLoader.instance.showLoaderView()
        self.siteyeBaglan()
        self.entryView.beginUpdates()
        self.entryView.setContentOffset(.zero, animated: false)
        self.entryView.endUpdates()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if baslikKontrolu.isEmpty == false{
            return 30
        }else{
            return 0
        }    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if baslikKontrolu.count > 1{
            let view = UIView()
            let blurEffect = Theme.blurEffect!
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(blurEffectView)
            view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30)
            let tumuButton = UIButton()
            tumuButton.setTitle(self.baslikKontrolu[1], for: .normal)
            tumuButton.setTitleColor(Theme.userColor, for: .normal)
            tumuButton.titleLabel?.font = UIFont(name: font!, size: CGFloat(puntosecim))
            tumuButton.frame = view.bounds
            tumuButton.addTarget(self, action: #selector(footerButton(sender:)), for: UIControl.Event.touchUpInside)
            view.addSubview(tumuButton)
            let topBorder = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0.3))
            topBorder.backgroundColor = Theme.userColor!
            view.addSubview(topBorder)
            view.layer.masksToBounds = false
            return view
        }else{
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if baslikKontrolu.isEmpty == false{
        return 0
        }else{
            return 0
        }
    }
    /* Tablo getir  */

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entryler.count
    }
    var yorum = [Bool]()
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if yorum[indexPath.row] == false{
        let cell = tableView.dequeueReusableCell(withIdentifier: "yorum", for: indexPath) as! YorumViewCell
            cell.entryView.attributedText = entryler[indexPath.row]
            cell.tarihLabel.text = tarihler[indexPath.row]
            cell.userName.setTitle(self.konukAdi, for: .normal)
            cell.entryView.textColor = Theme.labelColor
            cell.entryView.tintColor = Theme.linkColor
            cell.userName.setTitleColor(Theme.userColor, for: .normal)
            cell.tarihLabel.textColor = Theme.tarihColor
            cell.sukelaSayi.text = yorumArtiOy[indexPath.row]
            cell.kotuleSayi.text = yorumEksiOy[indexPath.row]
            cell.sukelaSayi.textColor = Theme.tarihColor!
            cell.kotuleSayi.textColor = Theme.tarihColor!
            cell.backgroundColor = Theme.yorumColor!
            return cell
        }else{
        let cell = tableView.dequeueReusableCell(withIdentifier: "entry", for: indexPath) as! entryViewTableCell
        
        if girisKontrolu.isEmpty{
            cell.favoriButonu.isEnabled = false
        }
        if indexPath.row % 2 == 0{
            cell.backgroundColor = Theme.cellFirstColor
            let bgColorView = UIView()
            bgColorView.backgroundColor = Theme.cellFirstColor
            cell.selectedBackgroundView = bgColorView
        }else{
            cell.backgroundColor = Theme.cellSecondColor
            let bgColorView = UIView()
            bgColorView.backgroundColor = Theme.cellSecondColor
            cell.selectedBackgroundView = bgColorView
        }
        if anlam.isEmpty == false{
        }
        else{
        }
        cell.selectionStyle = .none
        cell.entryText.attributedText = self.entryler[indexPath.row]
        cell.favoriButton.setTitle("\(self.favoriSayisi[indexPath.row]) fav", for: .normal)
        cell.entryNoLabel.text = "#\(self.linkler[indexPath.row])"
        cell.tarihLabel.text = self.tarihler[indexPath.row]
        cell.userButton.setTitle(self.userName[indexPath.row], for: .normal)
                if self.userName[indexPath.row] == self.kullaniciAdi[0]{
        print(self.kullaniciAdi[0])
        cell.kotule.isHidden = true
        cell.sukela.isHidden = true
        NSLayoutConstraint(item: cell.entryPaylas, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: cell.sukela, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 25).isActive = true
        NSLayoutConstraint(item: cell.sukela, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: .equal, toItem: cell.favoriButton, attribute: .trailing, multiplier: 1.0, constant: 8).isActive = true
        }
        
        cell.entryText.textColor = Theme.labelColor
        cell.entryText.tintColor = Theme.linkColor
        cell.userButton.setTitleColor(Theme.userColor, for: .normal)
        cell.tarihLabel.textColor = Theme.tarihColor
        cell.entryPaylas.tintColor = Theme.entryButton
        cell.entryDaha.tintColor = Theme.entryButton
        let sukelaImg = UIImage(named: "şükela")
        cell.sukela.setImage(sukelaImg, for: .normal)

                if self.fav[indexPath.row] == false{
            if let image = UIImage(named: "favlanmadı") {
                cell.favoriButonu.setImage(image, for: .normal)
                cell.favoriButonu.tintColor = .gray
            }
        }
        else{
            if let image = UIImage(named: "favlandı") {
                cell.favoriButonu.setImage(image, for: .normal)
            }
        }
            
        return cell
        }
      //  return UITableViewCell()
        
    }
    
    func eksiseyler() {
        let alert = UIAlertController(title: "yok ki", message: "bu başlıkta ekşi şeyler'e ait pek bir şey yok.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "geri döneyim madem", style: .default, handler: { (UIAlertAction) in
            CustomLoader.instance.showLoaderView()
            
            self.anlam = [String]()
            self.entryler = [NSAttributedString]()
            self.favoriler = [NSAttributedString]()
            self.linkler = [String]()
            self.favoriSayisi = [Int]()
            self.userName = [String]()
            self.tarihler = [String]()
            self.yildizlar = [String]()
            self.kullaniciAdi = [String]()
            self.fav = [Bool]()
            self.baslikKontrolu = [String]()
            self.sukela = [Bool]()
            self.kotule = [Bool]()
            self.yildizsayisi = 0
            self.secim = Bool()
            self.array = [String]()
            self.secti = Int()
            self.barAccessory = UIToolbar()
            self.takipNo = ""
            self.authorId = [String]()
            self.eID = ""
            self.duzenleLinki = ""
            self.baslikKontrolLink = [String]()
            self.anlamAyrimi = [String]()
            if self.baslikLinki.contains("?a=eksiseyler"){
                self.baslikLinki = self.baslikLinki.replacingOccurrences(of: "?a=eksiseyler", with: "?a=popular", options: .literal, range: nil)
                self.durumLabel.text = "bugünün entryleri"
            }else if self.baslikLinki.contains("?a=dailynice"){
                self.baslikLinki = self.baslikLinki.replacingOccurrences(of: "?a=dailynice", with: "", options: .literal, range: nil)
                self.durumLabel.text = "tüm entryler"
            }else if self.baslikLinki.contains("?a=nice"){
                self.baslikLinki = self.baslikLinki.replacingOccurrences(of: "?a=nice", with: "", options: .literal, range: nil)
                self.durumLabel.text = "tüm entryler"
            }
            self.siteyeBaglan()
            self.dismiss(animated: true, completion: nil)
        }))
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad)
        {
            alert.popoverPresentationController!.sourceView = self.view
            alert.popoverPresentationController!.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 1.25, width: 1.0, height: 1.0)
            
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func linkYok() {
        let alert = UIAlertController(title: "yok ki", message: "bu başlıkta link bulamadık.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "geri döneyim madem", style: .default, handler: { (UIAlertAction) in
            CustomLoader.instance.showLoaderView()
            
            self.anlam = [String]()
            self.entryler = [NSAttributedString]()
            self.favoriler = [NSAttributedString]()
            self.linkler = [String]()
            self.favoriSayisi = [Int]()
            self.userName = [String]()
            self.tarihler = [String]()
            self.yildizlar = [String]()
            self.kullaniciAdi = [String]()
            self.fav = [Bool]()
            self.baslikKontrolu = [String]()
            self.sukela = [Bool]()
            self.kotule = [Bool]()
            self.yildizsayisi = 0
            self.secim = Bool()
            self.array = [String]()
            self.secti = Int()
            self.barAccessory = UIToolbar()
            self.takipNo = ""
            self.authorId = [String]()
            self.eID = ""
            self.duzenleLinki = ""
            self.baslikKontrolLink = [String]()
            self.anlamAyrimi = [String]()
            if self.baslikLinki.contains("?a=find&keywords=http%3a%2f%2f"){
                self.baslikLinki = self.baslikLinki.replacingOccurrences(of: "?a=find&keywords=http%3a%2f%2f", with: "?a=popular", options: .literal, range: nil)
                self.durumLabel.text = "bugünün entryleri"
            }
            self.siteyeBaglan()
            self.dismiss(animated: true, completion: nil)
        }))
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad)
        {
            alert.popoverPresentationController!.sourceView = self.view
            alert.popoverPresentationController!.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 1.25, width: 1.0, height: 1.0)
            
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func takipettiklerim() {
        let alert = UIAlertController(title: "yok ki", message: "takip ettikleriniz bu başlığa uğramamış.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "geri döneyim madem", style: .default, handler: { (UIAlertAction) in
            CustomLoader.instance.showLoaderView()
            
            self.anlam = [String]()
            self.entryler = [NSAttributedString]()
            self.favoriler = [NSAttributedString]()
            self.linkler = [String]()
            self.favoriSayisi = [Int]()
            self.userName = [String]()
            self.tarihler = [String]()
            self.yildizlar = [String]()
            self.kullaniciAdi = [String]()
            self.fav = [Bool]()
            self.baslikKontrolu = [String]()
            self.sukela = [Bool]()
            self.kotule = [Bool]()
            self.yildizsayisi = 0
            self.secim = Bool()
            self.array = [String]()
            self.secti = Int()
            self.barAccessory = UIToolbar()
            self.takipNo = ""
            self.authorId = [String]()
            self.eID = ""
            self.duzenleLinki = ""
            self.baslikKontrolLink = [String]()
            self.anlamAyrimi = [String]()
            if self.baslikLinki.contains("?a=buddy"){
                self.baslikLinki = self.baslikLinki.replacingOccurrences(of: "?a=buddy", with: "?a=popular", options: .literal, range: nil)
                self.durumLabel.text = "bugünün entryleri"
            }
            self.siteyeBaglan()
            self.dismiss(animated: true, completion: nil)
        }))
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad)
        {
            alert.popoverPresentationController!.sourceView = self.view
            alert.popoverPresentationController!.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 1.25, width: 1.0, height: 1.0)
            
        }
        self.present(alert, animated: true, completion: nil)
    }
    private var finishedLoadingInitialTableCells = false
    

    /* Tablo getir  */
    
    /* başlığa bağlan verileri çek  */

    func siteyeBaglan() -> Void {
        baslikLinki = baslikLinki.replacingOccurrences(of: "https://eksisozluk.com/", with: "")
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            CustomLoader.instance.hideLoaderView()
        }
        Alamofire.request("https://eksisozluk.com/\(baslikLinki)", method: .get, headers: headers).responseString {
            response in
            if let html = response.result.value{
                self.anlam = [String]()
                self.linkler = [String]()
                self.tarihler = [String]()
                self.yildizlar = [String]()
                self.kullaniciAdi = [String]()
                self.fav = [Bool]()
                self.baslikKontrolu = [String]()
                self.sukela = [Bool]()
                self.kotule = [Bool]()
                self.yildizsayisi = 0
                self.secim = Bool()
                self.array = [String]()
                self.secti = Int()
                self.barAccessory = UIToolbar()
                self.takipNo = ""
                self.authorId = [String]()
                self.eID = ""
                self.duzenleLinki = ""
                self.baslikKontrolLink = [String]()
                self.anlamAyrimi = [String]()
                self.pager = 1
                self.favoriler = [NSAttributedString]()
                self.favoriGetir(html: html)
                self.userName = [String]()
                self.kullanici(html: html)
                self.BaslikGetir(html: html)
                self.BasliklinkiGetir(html: html)
                self.sayfaSayisiGetir(html: html)
                self.girisKontrol(html: html)
                self.baslikKontrol(html: html)
                self.favoriSayisi = [Int]()
                self.favoriSayisiGetir(html: html)
                self.entryler = [NSAttributedString]()
                self.entryleriGetir(html: html)
                self.suserGetir(html: html)
                self.tarihGetir(html: html)
                if self.status == true{
                    self.olayKontrol(html: html)
                    self.mesajKontrol(html: html)
                    self.takipKontrol(html: html)
                }
                self.entryView.reloadData()
                self.scrollToTop()


                if self.sayfaSayisi.isEmpty == false{
                    while self.pager<Int(self.sayfaSayisi)!{
                        self.pager += 1
                        self.array.append("\(self.pager)")
                    }

                }
                
                if self.entryler.count == 0 {
                    self.entryView.addSubview(self.viewcim)
                    self.entryView.separatorStyle = .none
                }else{
                    self.viewcim.removeFromSuperview()
                    self.entryView.separatorStyle = .singleLine
                }
                if self.aktifSayfa == self.sayfaSayisi{
                    self.sonrakiSayfaButonu.isEnabled = false
                    self.sonSayfaButonu.isEnabled = false
                }else{
                    self.sonSayfaButonu.isEnabled = true
                    self.sonrakiSayfaButonu.isEnabled = true
                }
                
                if self.aktifSayfa == "1" || self.aktifSayfa == ""{
                    self.ilkSayfa.isEnabled = false
                    self.oncekiSayfaButonu.isEnabled = false
                }else{
                    self.ilkSayfa.isEnabled = true
                    self.oncekiSayfaButonu.isEnabled = true
                }
                if self.girisKontrolu.isEmpty{
                    self.navigationItem.rightBarButtonItem = nil
                }
            }
        }
    }
    /* başlığa bağlan verileri çek  */

    
    
    func girisKontrol(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("li[class^=buddy mobile-only] a"){
                girisKontrolu = basliklar["href"]!
            }
        }
    }
    
    
    /* hücrenin indexpath verisini getir  */

    func getIndexPathFor(view: UIView, tableView: UITableView) -> IndexPath? {
        let point = entryView.convert(view.bounds.origin, from: view)
        let indexPath = entryView.indexPathForRow(at: point)
        return indexPath
    }
    
    /* hücrenin indexpath verisini getir  */

    /* favori ayarları  */

    @IBAction func favorileButton(_ sender: UIButton) {
        if let indexPath = entryView.indexPath(forItem: sender) {
            let parameters: Parameters = ["entryId": "\(linkler[indexPath.row])"]
            /***************************/
        if fav[indexPath.row] == false{
            Alamofire.request("https://eksisozluk.com/entry/favla",method: .post, parameters: parameters, headers: headers).responseJSON { response in
                if response.result.isSuccess{
                    if let image = UIImage(named: "favlandı") {
                        sender.setImage(image, for: .normal)
                        self.fav[indexPath.row] = true
                      self.favoriSayisi[indexPath.row] = self.favoriSayisi[indexPath.row]+1
                        self.entryView.reloadRows(at: [indexPath], with: .none)
                }
            }
        }
    }
            
            /***************************/
            
        if fav[indexPath.row] == true{
            if let image = UIImage(named: "favlandı") {
                sender.setImage(image, for: .normal)
            }
            Alamofire.request("https://eksisozluk.com/entry/favlama",method: .post, parameters: parameters, headers: headers).responseJSON { response in
                    if response.result.isSuccess{
                        if let image = UIImage(named: "favlanmadı") {
                            sender.setImage(image, for: .normal)
                            self.fav[indexPath.row] = false
                            self.favoriSayisi[indexPath.row] = self.favoriSayisi[indexPath.row]-1
                            self.entryView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                        }
                    }
            }
        }
    }
}
    
    /* favori ayarları  */
    
    
    @IBAction func kotule(_ sender: UIButton) {
        if let indexPath = entryView.indexPath(forItem: sender) {
            let parameters: Parameters = [
                "Id": "\(linkler[indexPath.row])",
                "rate": "-1"]
            if kotule[indexPath.row] == true{
                Alamofire.request("https://eksisozluk.com/entry/removevote",method: .post, parameters: parameters, headers: headers).responseJSON { response in
                    if response.result.isSuccess{
                            if let image = UIImage(named: "kötüle") {
                                sender.setImage(image, for: .normal)
                            }
                    }
                }
            }
            if kotule[indexPath.row] == false{
                Alamofire.request("https://eksisozluk.com/entry/vote",method: .post, parameters: parameters, headers: headers).responseJSON { response in
                    if response.result.isSuccess{
                            if let image = UIImage(named: "kötülendi") {
                                sender.setImage(image, for: .normal)
                            }
                    }
                }
                kotule[indexPath.row] = true
            }
        }
    }
    
    @IBAction func sukela(_ sender: UIButton) {
        if let indexPath = entryView.indexPath(forItem: sender) {
            let parameters: Parameters = [
                "Id": "\(linkler[indexPath.row])",
                "rate": "1"]
            if sukela[indexPath.row] == true{
                Alamofire.request("https://eksisozluk.com/entry/removevote",method: .post, parameters: parameters, headers: headers).responseJSON { response in
                    if response.result.isSuccess{
                        if let image = UIImage(named: "şükela") {
                            sender.setImage(image, for: .normal)
                        }
                    }
                }
            }
            if sukela[indexPath.row] == false{
                Alamofire.request("https://eksisozluk.com/entry/vote",method: .post, parameters: parameters, headers: headers).responseJSON { response in
                    if response.result.isSuccess{
                        if let image = UIImage(named: "şükelalandı") {
                            sender.setImage(image, for: .normal)
                        }
                    }
                }
                sukela[indexPath.row] = true
            }
    }
}
    
    @IBAction func takipButton(_ sender: Any) {
        if self.takip == false{
            Alamofire.request("https://eksisozluk.com/baslik/takip-et/\(takipNo)",method: .post, headers: headers).responseJSON { response in
                if response.response?.statusCode == 200{
                    self.takipButonu.backgroundColor = Theme.entryButton
                    self.takipButonu.layer.cornerRadius = 10
                    self.takip = true
                }
            }
        }else{
            Alamofire.request("https://eksisozluk.com/baslik/takip-etme/\(takipNo)",method: .post, headers: headers).responseJSON { response in
                if response.response?.statusCode == 200{
                    self.takipButonu.backgroundColor = .clear
                    self.takipButonu.layer.cornerRadius = 10
                    self.takip = false
                }
            }
        }
    }
   
    
    @IBAction func paylasButton(sender: UIButton) {
        if let indexPath = entryView.indexPath(forItem: sender) {
            let items = ["https://eksisozluk.com/entry/\(linkler[indexPath.row])"]
            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            ac.view.tintColor = Theme.entryButton
            ac.view.layer.cornerRadius = 25
            ac.view.layer.borderColor = Theme.entryButton?.cgColor
            ac.view.layer.borderWidth = 0
            if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad)
            {
                ac.popoverPresentationController!.sourceView = self.view
                ac.popoverPresentationController!.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 1.2, width: 1.0, height: 1.0)
                
            }
            self.present(ac, animated: true)
        }
    }
    
    /* tablo içeriklerini çek  */
    
    func takipKontrol(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for sayfa in doc.css("a[id^=track-topic-link]"){
                let olayTuru = sayfa["data-tracked"]
                if olayTuru == "1"{
               //     self.takipButonu.backgroundColor = Theme.entryButton
                 //   self.takipButonu.layer.cornerRadius = 10
                    self.takip = true
                }
                
            }
        }
    }
    
    func mesajKontrol(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for sayfa in doc.css("li[class^=messages mobile-only] a svg"){
                let olayTuru = sayfa.className!
                if olayTuru.contains("green"){
                    tabBarController?.tabBar.items?.last!.badgeValue = "mesaj"
                    tabBarController?.tabBar.items?.last!.badgeColor = Theme.entryButton
                }else{
                    tabBarController?.tabBar.items?.last!.badgeValue = nil
                }
            }
        }
    }
    func olayKontrol(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for sayfa in doc.css("li[class^=tracked mobile-only] a svg"){
                let olayTuru = sayfa.className!
                if olayTuru.contains("green"){
                    tabBarController?.tabBar.items?[3].badgeValue = "olay"
                    tabBarController?.tabBar.items?[3].badgeColor = Theme.entryButton
                }else{
                    tabBarController?.tabBar.items?[3].badgeValue = nil
                }
            }
        }
    }
    var yorumlar = NSAttributedString()
    var konukAdi = ""
    var yorumArtiOy = [String]()
    var yorumEksiOy = [String]()
    var yorumID = [String]()
    var yorumOwner = [String]()
    var puntosecim = 15
    func entryleriGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for entryIcerik in doc.css("div[class^=content]"){
                gizlendi.append(false)
                let yorum = entryIcerik.parent?.at_css("div[class^=comment-content]")
                var entry = entryIcerik.toHTML
                if self.tema == 0 || self.tema == 2{
                    entry?.append(contentsOf: "<style>body{ font-size:\(puntosecim)px; font-family:\(font!), sans-serif} mark{background-color:#616161;}a{text-decoration:none}</style>")
                }else{
                entry?.append(contentsOf: "<style>body{ font-size:\(puntosecim)px; font-family:\(font!), sans-serif} mark{background-color:#ffff9e;}a{text-decoration:none}</style>")
                }
                let goruntule = entry?.html2AttributedString
                self.yorum.append(true)
                let attributedString = NSMutableAttributedString(attributedString: goruntule!)
                kotule.append(false)
                sukela.append(false)
                let yldz = doc.css("div[class^=content] sup a")
                for yil in yldz{
                    let yldz = yil["data-query"]
                    yildizlar.append(yldz!)
                }
                
                attributedString.enumerateAttribute(.link, in: NSRange(location: 0, length: attributedString.length), options: [.reverse]) { (attribute, range, pointee) in

                    if let link = attribute as? URL, link.absoluteString.hasPrefix("http") {
                        let replacement = NSMutableAttributedString(attributedString: attributedString.attributedSubstring(from: range))
                        replacement.replaceCharacters(in: NSRange(location: replacement.length, length: 0), with: "⤳")
                        let newLink = link.absoluteString
                        replacement.addAttribute(.link, value: newLink, range: NSRange(location: 0, length: replacement.length))
                        attributedString.replaceCharacters(in: range, with: replacement)
                    }
                }
                attributedString.enumerateAttribute(.link, in: NSRange(location: 0, length: attributedString.length), options: .init()) { (attribute, range, pointee) in
                    if let link = attribute as? URL, link.absoluteString.hasPrefix("applewebdata"){
                        if range.length == 1 && yildizlar.count>0{
                            let replacement = NSMutableAttributedString(attributedString: attributedString.attributedSubstring(from: range))
                            replacement.replaceCharacters(in: NSRange(location: replacement.length, length: 0), with: ": \(yildizlar[yildizsayisi])")
                            yildizsayisi = yildizsayisi+1
                            let newLink = link.absoluteString
                            replacement.addAttribute(.link, value: newLink, range: NSRange(location: 0, length: replacement.length))
                            attributedString.replaceCharacters(in: range, with: replacement)
                        }
                    }
                }
                self.yorumEksiOy.append("")
                self.yorumArtiOy.append("")
                self.yorumID.append("")
                self.yorumOwner.append("")
                entryler.append(attributedString)
                if yorum?.toHTML != nil && yorum?.toHTML?.html2String != "\n"{
                    var yoruml = yorum?.toHTML
                    let user = yorum?.parent
                    yoruml?.append(contentsOf: "<style>body{ font-size:\(puntosecim)px; font-family:\(font!), sans-serif} mark{background-color:#616161;}a{text-decoration:none}</style>")
                    yorumlar = (yoruml?.html2AttributedString)!
/*                    self.fav.append(false)
                    self.favoriSayisi.append(0)
                    self.linkler.append("")
                    self.tarihler.append("")*/
                    self.konukAdi = user!["data-author"]!
                    let kotuleSayi = user!["data-up-vote-count"]!
                    let sukelaSayi = user!["data-down-vote-count"]!
                    let Id = user!["data-comment-id"]!
                    let owner = user!["data-author-id"]!
                    self.sukela.append(false)
                    self.yorumOwner.append(owner)
                    self.yorumID.append(Id)
                    self.yorumArtiOy.append(sukelaSayi)
                    self.yorumEksiOy.append(kotuleSayi)
                    self.yorum.append(false)
                    self.gizlendi.append(false)
                    self.entryler.append(yorumlar)
                }
            }
        }
    }
    var tumuLink = String()
    func BaslikGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for baslikAdi in doc.css("h1[id^=title]"){
                let baslik = baslikAdi["data-title"]
                let baslikTakipNo = baslikAdi["data-id"]
                let dataSlug = baslikAdi["data-slug"]
                let dataId = baslikAdi["data-id"]
                if (dataSlug != nil){
                tumuLink = "\(dataSlug!)--\(dataId!)"
                }
                print(tumuLink)
                self.takipNo = baslikTakipNo ?? "0"
                self.title = baslik ?? "bulunamadı"
                let tlabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
                tlabel.text = self.title
                tlabel.textColor = Theme.titleColor
                tlabel.textAlignment = .center;
                tlabel.lineBreakMode = .byWordWrapping
                tlabel.numberOfLines = 2
                tlabel.adjustsFontSizeToFitWidth = true
                self.navigationItem.titleView = tlabel
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    CustomLoader.instance.hideLoaderView()
                }
            }
        }
    }
    
    func favoriSayisiGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for entrySayisi in doc.css("ul[id^=entry-item-list] li"){
                let favoriSayi = entrySayisi["data-favorite-count"] ?? "0"
                let favoriKontrol = entrySayisi["data-isfavorite"] ?? "false"
                let userId = entrySayisi["data-author-id"] ?? "0"
                self.authorId.append(userId)
                self.fav.append(Bool(favoriKontrol) ?? false)
                self.favoriSayisi.append(Int(favoriSayi)!)
            }
        }
    }

    
    func suserGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for suser in doc.css("ul[id^=entry-item-list] li"){
                let suserName = suser["data-author"]
                userName.append(suserName!)
            }
        }
    }
    func tarihGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for tarih in doc.css("a[class^=entry-date permalink]"){
                let linkler = tarih["href"]
                let link = linkler?.replacingOccurrences(of: "/entry/", with: "", options: .literal, range: nil)
                self.linkler.append(link!)
                let tarihler = tarih.text
                self.tarihler.append(tarihler!)
            }
        }
    }

    func BasliklinkiGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("h1 a"){
                let kanalLinki = basliklar["href"]
                if self.baslikLinki.contains("%20") || self.baslikLinki.contains("%C3%B6") || self.baslikLinki.contains("%C3%BC") || self.baslikLinki.contains("%C4%B1") || self.baslikLinki.contains("%C4%9F") || self.baslikLinki.contains("day") || self.baslikLinki.contains("?a=find") || self.baslikLinki.contains("?a=search") || self.baslikLinki.contains("focusto") || self.baslikLinki.contains("?q="){
                self.baslikLinki = kanalLinki!
                }
            }
        }
    }
    
   func sayfaSayisiGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            array.append("\(pager)")
            for sayfa in doc.css("div[class^=pager]"){
                let simdiki = sayfa["data-currentpage"]
                let toplam = sayfa["data-pagecount"]
                self.sayfaSayisi = toplam!
                self.aktifSayfa = simdiki!
                sayfaButonu.setTitle("\(self.aktifSayfa) / \(sayfaSayisi)", for: .normal)
            }
        }
    }
  
    func favoriGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for favori in doc.css("[class^=feedback]"){
                let favoriler = favori.toHTML
                self.favoriler.append((favoriler?.html2AttributedString)!)
            }
        }
    }
    
    func kullanici(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for kullanici in doc.css("nav[id^=top-navigation]"){
                var pullanici = kullanici.at_css("li[class^=not-mobile] a")
                let k = pullanici?["title"]
                self.kullaniciAdi.append(k ?? "ben")
            }
        }
    }

    

    /* tablo içeriklerini çek  */
    func baslikKontrol(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("a[class^=showall more-data]"){
                baslikKontrolu.append(basliklar.text!)
                baslikKontrolLink.append(basliklar["href"]!)
            }
            for basliklar in doc.css("div[id^=disambiguations]"){
                self.anlam.append(basliklar.text!)
            }
        }
    }

}


/* tablo hücresi tanımla  */

class entryViewTableCell: UITableViewCell{
    @IBOutlet weak var entryText: UITextView!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var tarihLabel: UILabel!
    @IBOutlet weak var favoriButton: UIButton!
    @IBOutlet weak var favoriButonu: UIButton!
    @IBOutlet weak var sukela: UIButton!
    @IBOutlet weak var entryNoLabel: UILabel!
    @IBOutlet weak var kotule: UIButton!
    
    @IBOutlet var entryPaylas: UIButton!
    
    @IBOutlet var entryDaha: UIButton!
}
/* tablo hücresi tanımla  */


/* gelen datayı anlamlandır  */

extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension String {
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}
/* gelen datayı anlamlandır  */
extension UITableView {
    func indexPath(forItem: AnyObject) -> IndexPath? {
        let itemPosition: CGPoint = forItem.convert(CGPoint.zero, to: self)
        return self.indexPathForRow(at: itemPosition)
    }}

extension NSAttributedString {
    func stringWithString(stringToReplace: String, replacedWithString newStringPart: String) -> NSMutableAttributedString
    {
        let mutableAttributedString = mutableCopy() as! NSMutableAttributedString
        let mutableString = mutableAttributedString.mutableString
        while mutableString.contains(stringToReplace) {
            let rangeOfStringToBeReplaced = mutableString.range(of: stringToReplace)
            mutableAttributedString.replaceCharacters(in: rangeOfStringToBeReplaced, with: newStringPart)
        }
        return mutableAttributedString
    }
}

extension String {
    func indices(of occurrence: String) -> [Int] {
        var indices = [Int]()
        var position = startIndex
        while let range = range(of: occurrence, range: position..<endIndex) {
            let i = distance(from: startIndex,
                             to: range.lowerBound)
            indices.append(i)
            let offset = occurrence.distance(from: occurrence.startIndex,
                                             to: occurrence.endIndex) - 1
            guard let after = index(range.lowerBound,
                                    offsetBy: offset,
                                    limitedBy: endIndex) else {
                                        break
            }
            position = index(after: after)
        }
        return indices
    }
}

extension String {
    func ranges(of searchString: String) -> [Range<String.Index>] {
        let _indices = indices(of: searchString)
        let count = searchString.count
        return _indices.map({ index(startIndex, offsetBy: $0)..<index(startIndex, offsetBy: $0+count) })
    }
}
public extension NSRange {
    private init(string: String, lowerBound: String.Index, upperBound: String.Index) {
        let utf16 = string.utf16
        
        let lowerBound = lowerBound.samePosition(in: utf16)
        let location = utf16.distance(from: utf16.startIndex, to: lowerBound!)
        let length = utf16.distance(from: lowerBound!, to: upperBound.samePosition(in: utf16)!)
        
        self.init(location: location, length: length)
    }
    
    init(range: Range<String.Index>, in string: String) {
        self.init(string: string, lowerBound: range.lowerBound, upperBound: range.upperBound)
    }
    
    init(range: ClosedRange<String.Index>, in string: String) {
        self.init(string: string, lowerBound: range.lowerBound, upperBound: range.upperBound)
    }
}

extension URL {
    var parameters: [String: String] {
        var parameters = [String: String]()
        if let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false),
            let queryItems = urlComponents.queryItems {
            for queryItem in queryItems where queryItem.value != nil {
                parameters[queryItem.name] = queryItem.value
            }
        }
        return parameters
    }
}


class YorumViewCell: UITableViewCell{
    
    @IBOutlet weak var userName: UIButton!
    
    @IBOutlet weak var entryView: UITextView!
    
    @IBOutlet weak var tarihLabel: UILabel!
    
    @IBOutlet weak var sukela: UIButton!
    
    @IBOutlet weak var kotule: UIButton!
    
    @IBOutlet weak var kotuleSayi: UILabel!
    
    @IBOutlet weak var sukelaSayi: UILabel!
    
    
}
