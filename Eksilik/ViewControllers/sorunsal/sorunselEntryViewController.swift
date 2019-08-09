//
//  sorunselEntryViewController.swift
//  Eksilik
//
//  Created by Emre Işık on 24.04.2019.
//  Copyright © 2019 Emre Isik. All rights reserved.
//

import UIKit
import Alamofire
import Kanna
import SafariServices

class sorunselEntryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, SFSafariViewControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIViewControllerPreviewingDelegate{
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        return UIViewController()
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
    }
    
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
            vc.extendedLayoutIncludesOpaqueBars = false
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
        vc.extendedLayoutIncludesOpaqueBars = false
        self.navigationController?.pushViewController(vc, animated: true)
        resultSearchController.isActive = false
        
    }
    
    var viewcim = (Bundle.main.loadNibNamed("başlık boş", owner: self, options: nil)![0]) as! UIView
    
    var anlam = [String]()
    var soru = [NSAttributedString]()
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
    var pager = 1
    var takipNo = ""
    var takip = false
    var authorId = [String]()
    var eID = ""
    var duzenleLinki = ""
    var baslikKontrolLink = [String]()
    var anlamAyrimi = [String]()
    var durumText = ""
    
    
    @IBAction func suserButton(_ sender: UIButton) {
        if let indexPath = entryView.indexPath(forItem: sender) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier:
                "suserProfile") as! SuserViewController
            var kadi = userName[indexPath.row]
            kadi = kadi.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
            vc.biriLink = "/biri/\(kadi)"
            vc.extendedLayoutIncludesOpaqueBars = false
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    private let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var durumLabel: UILabel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return Theme.statusBarStyle!
    }

    
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
            barAccessory = UIToolbar(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 304, width: typePickerView.frame.size.width, height: 44))
            barAccessory.barStyle = Theme.barStyle!
            barAccessory.barTintColor = Theme.userColor
            let flexiblespace = UIBarButtonItem(barButtonSystemItem:.flexibleSpace , target: nil, action: nil)
            let btnDone = UIBarButtonItem(title: "tamam", style: .done, target: self, action: #selector(tamam(_:)))
            btnDone.tintColor = .white
            barAccessory.items = [flexiblespace,btnDone]
            self.view.addSubview(barAccessory)
        }
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
        alert.addAction(UIAlertAction(title: "mesaj gönder", style: .default, handler: { (UIAlertAction) in
            CustomLoader.instance.showLoaderView()
            self.performSegue(withIdentifier: "mesajAt", sender: nil)
        }))
        alert.addAction(UIAlertAction(title: "vazgeç", style: .cancel, handler: { (UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }))
        alert.view.tintColor = Theme.userColor
        alert.view.layer.cornerRadius = 25
        alert.view.layer.borderColor = Theme.userColor?.cgColor
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
        self.durumView.backgroundColor = Theme.backgroundColor
        
    }
    
    func scrollToTop() {
        
        DispatchQueue.main.async {
            if self.soru.count>1{
                let indexPath = IndexPath(row: 0, section: 0)
                self.entryView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.installBlurEffect()
        puntosecim = UserDefaults.standard.integer(forKey: "secilenPunto")
        navigationController?.navigationBar.barStyle = Theme.barStyle ?? .default
        prepareUI()
        siteyeBaglan()
        durumLabel.text = durumText
        durumLabel.lineBreakMode = .byWordWrapping
        durumLabel.numberOfLines = 0
        sayfaView.backgroundColor = Theme.cellFirstColor
        
        entryView.tableFooterView = UIView()
        ilkSayfa.imageView?.image = ilkSayfa.imageView?.image!.withRenderingMode(.alwaysTemplate)
        sukelaButonu.imageView?.image = sukelaButonu.imageView?.image!.withRenderingMode(.alwaysTemplate)

        takipButonu.tintColor = Theme.labelColor
        sukelaButonu.tintColor = Theme.labelColor
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
        self.typePickerView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 260, width: UIScreen.main.bounds.width, height: 220)
        entryView.separatorStyle = .singleLine
        entryView.separatorColor = Theme.separatorColor
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.tableViewRefreshControl.endRefreshing()
        }
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
    
    @IBAction func yorumSukela(_ sender: UIButton) {
        if let indexPath = entryView.indexPath(forItem: sender) {
            let cell = entryView.cellForRow(at: indexPath)! as? CevapViewCell
            let yorum = self.yorumEksiOy[indexPath.row]
            let parameters: Parameters = [
                "owner": "\(self.yorumOwner[indexPath.row])",
                "Id": "\(yorumID[indexPath.row])",
                "rate": "1"]
            if sukela[indexPath.row] == false{
                Alamofire.request("https://eksisozluk.com/yorum/vote",method: .post, parameters: parameters, headers: headers).responseJSON { response in
                    print(response.result.debugDescription)
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
            let cell = entryView.cellForRow(at: indexPath)! as? CevapViewCell
            let yorum = self.yorumArtiOy[indexPath.row]
            let parameters: Parameters = [
                "owner": "\(self.yorumOwner[indexPath.row])",
                "Id": "\(yorumID[indexPath.row])",
                "rate": "-1"]
            if sukela[indexPath.row] == false{
                Alamofire.request("https://eksisozluk.com/yorum/vote",method: .post, parameters: parameters, headers: headers).responseJSON { response in
                    print(response.result.debugDescription)
                    if response.result.isSuccess{
                        let artir = Int(yorum)!+1
                       // cell?.sukelaSayi.text = "\(artir)"
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
                      //  cell?.sukelaSayi.text = "\(yorum)"
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
        let ben = self.kullaniciAdi[0].addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        let alert = UIAlertController(title: "sıralama şekli", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "yeniden eskiye", style: .default, handler: { (UIAlertAction) in
            CustomLoader.instance.showLoaderView()
            
            self.soru = [NSAttributedString]()
            self.favoriler = [NSAttributedString]()
            self.linkler = [String]()
            self.favoriSayisi = [Int]()
            self.userName = [String]()
            self.tarihler = [String]()
            self.fav = [Bool]()
            self.sayfaSayisi = ""
            self.aktifSayfa = ""
            self.baslikLinki = "\(self.tumuLink)?a=mnew"
            self.siteyeBaglan()
            self.durumLabel.text = "yeniden eskiye"
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "şükela modu", style: .default, handler: { (UIAlertAction) in
            CustomLoader.instance.showLoaderView()
            
            self.soru = [NSAttributedString]()
            self.favoriler = [NSAttributedString]()
            self.linkler = [String]()
            self.favoriSayisi = [Int]()
            self.userName = [String]()
            self.tarihler = [String]()
            self.fav = [Bool]()
            self.sayfaSayisi = ""
            self.aktifSayfa = ""
            self.baslikLinki = "\(self.tumuLink)?a=mnice"
            self.siteyeBaglan()
            self.durumLabel.text = "şükela modu"
            
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "hiçbiri", style: .cancel, handler: nil))
        alert.view.tintColor = Theme.userColor
        alert.view.layer.cornerRadius = 25
        alert.view.layer.borderColor = Theme.userColor?.cgColor
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
            viewController.extendedLayoutIncludesOpaqueBars = secim
            navigationController?.pushViewController(viewController, animated: true)
        }
        else{
            let controller = SFSafariViewController(url: URL)
            controller.preferredBarTintColor = Theme.navigationBarColor
            controller.preferredControlTintColor = Theme.userColor
            self.present(controller, animated: true, completion: nil)
            controller.delegate = self
            func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
                controller.dismiss(animated: true, completion: nil)
            }
            print(URL)
        }
        return false
    }
    
    @IBOutlet var durumView: UIView!
    
    @IBOutlet var sayfaView: UIView!
    
    @IBOutlet var sukelaButonu: UIButton!
    
    @IBOutlet var takipButonu: UIButton!
    
    
    @IBOutlet weak var entryView: UITableView!
    /* Otomatik tablo hücre yüksekliği  */
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    /* Otomatik tablo hücre yüksekliği  */
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.baslikKontrolu.isEmpty == false{
            let view = UIView()
            let blurEffect = Theme.blurEffect!
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(blurEffectView)
            view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30)
            view.layer.masksToBounds = false
            view.layer.shadowColor = Theme.userColor?.cgColor
            view.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
            view.layer.shadowOpacity = 1.0
            view.layer.shadowRadius = 0.0
            let tumuButton = UIButton()
            tumuButton.setTitle(self.baslikKontrolu[0], for: .normal)
            tumuButton.setTitleColor(Theme.userColor, for: .normal)
            tumuButton.titleLabel?.font = UIFont(name: "Helvetica", size: 15)
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
            tumuButton.titleLabel?.font = UIFont(name: "Helvetica", size: 15)
            tumuButton.frame = view.bounds
            tumuButton.addTarget(self, action: #selector(footerButton(sender:)), for: UIControl.Event.touchUpInside)
            view.addSubview(tumuButton)
            let topBorder = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1))
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
            return 30
        }else{
            return 0
        }
    }
    /* Tablo getir  */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return soru.count
    }
    var yorum = [Bool]()
    var cevaplar = [NSAttributedString]()
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if yorum[indexPath.row] == false{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cevap", for: indexPath) as! CevapViewCell
            cell.entryView.attributedText = soru[indexPath.row]
            cell.entryView.textColor = Theme.labelColor
            cell.entryView.tintColor = Theme.linkColor
            cell.userName.setTitle(userName[indexPath.row], for: .normal)
            cell.userName.setTitleColor(Theme.userColor, for: .normal)
            cell.selectionStyle = .none
          cell.tarihLabel.text = tarihler[indexPath.row]
            cell.tarihLabel.textColor = Theme.tarihColor
            cell.kotuleSayi.text = rate
            cell.kotuleSayi.textColor = Theme.tarihColor!
            cell.backgroundColor = Theme.yorumColor!
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "soru", for: indexPath) as! SoruViewCell
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
            cell.selectionStyle = .none
            cell.entryView.attributedText = soru[indexPath.row]
            cell.entryView.textColor = Theme.labelColor
            cell.entryView.tintColor = Theme.linkColor
           cell.tarihLabel.text = tarihler[indexPath.row]
            cell.userName.setTitle(userName[indexPath.row], for: .normal)
            cell.userName.setTitleColor(Theme.userColor, for: .normal)
            cell.sukelaSayi.text = yorumArtiOy[indexPath.row - 1]
            cell.kotuleSayi.text = yorumEksiOy[indexPath.row - 1]
            //  if userName[indexPath.row] == self.kullaniciAdi[0]{
          //      cell.sukela.isHidden = true
          //      cell.kotule.isHidden = true
          //  }
            
            cell.tarihLabel.textColor = Theme.tarihColor
            let sukelaImg = UIImage(named: "şükela")
            cell.sukela.setImage(sukelaImg, for: .normal)
            return cell
        }
        //  return UITableViewCell()
        
    }
    private var finishedLoadingInitialTableCells = false
    
    
    /* Tablo getir  */
    
    /* başlığa bağlan verileri çek  */
    
    func siteyeBaglan() -> Void {
        baslikLinki = baslikLinki.replacingOccurrences(of: "https://eksisozluk.com", with: "")
        baslikLinki = baslikLinki.replacingOccurrences(of: "/sorunsal/", with: "")
        Alamofire.request("https://eksisozluk.com//sorunsal/\(baslikLinki)", method: .get, headers: headers).responseString {
            response in
            if let html = response.result.value{
                self.yorum = [Bool]()
                self.yorumArtiOy = [String]()
                self.yorumEksiOy = [String]()
                self.i = 0
                self.yorumlar = NSAttributedString()
                self.soru = [NSAttributedString]()
                self.favoriler = [NSAttributedString]()
                self.linkler = [String]()
                self.favoriSayisi = [Int]()
                self.userName = [String]()
                self.tarihler = [String]()
                self.fav = [Bool]()
                self.yildizlar = [String]()
                self.yildizsayisi = Int()
                self.baslikKontrolu = [String]()
                self.baslikKontrolLink = [String]()
                self.favoriGetir(html: html)
                self.cevapGetir(html: html)
                self.kullanici(html: html)
                self.BaslikGetir(html: html)
                self.BasliklinkiGetir(html: html)
                self.sayfaSayisiGetir(html: html)
                self.girisKontrol(html: html)
                self.baslikKontrol(html: html)
                self.favoriSayisiGetir(html: html)
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
                    repeat{
                        self.pager = self.pager + 1
                        self.array.append("\(self.pager)")
                    }while self.pager < Int(self.sayfaSayisi)!
                }
                
                CustomLoader.instance.hideLoaderView()
                if self.soru.count == 0 {
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
                    self.navigationItem.rightBarButtonItem = nil
                
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + (0.5), execute: {
                        if response.result.isSuccess{
                            if let image = UIImage(named: "favlandı") {
                                sender.setImage(image, for: .normal)
                                self.fav[indexPath.row] = true
                                self.favoriSayisi[indexPath.row] = self.favoriSayisi[indexPath.row]+1
                                self.entryView.reloadRows(at: [indexPath], with: .none)
                            }
                        }
                    })
                }
            }
            
            /***************************/
            
            if fav[indexPath.row] == true{
                if let image = UIImage(named: "favlandı") {
                    sender.setImage(image, for: .normal)
                }
                Alamofire.request("https://eksisozluk.com/entry/favlama",method: .post, parameters: parameters, headers: headers).responseJSON { response in
                    DispatchQueue.main.asyncAfter(deadline: .now() + (0.5), execute: {
                        if response.result.isSuccess{
                            if let image = UIImage(named: "favlanmadı") {
                                sender.setImage(image, for: .normal)
                                self.fav[indexPath.row] = false
                                self.favoriSayisi[indexPath.row] = self.favoriSayisi[indexPath.row]-1
                                self.entryView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                            }
                        }
                    })
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + (0.5), execute: {
                            if let image = UIImage(named: "kötülendi") {
                                sender.setImage(image, for: .normal)
                            }
                        })
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
                    self.takipButonu.backgroundColor = Theme.userColor
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
            ac.view.tintColor = Theme.userColor
            ac.view.layer.cornerRadius = 25
            ac.view.layer.borderColor = Theme.userColor?.cgColor
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
                    self.takipButonu.backgroundColor = Theme.userColor
                    self.takipButonu.layer.cornerRadius = 10
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
                    tabBarController?.tabBar.items?[2].badgeValue = "mesaj"
                    tabBarController?.tabBar.items?[2].badgeColor = Theme.userColor
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
                    tabBarController?.tabBar.items?[2].badgeValue = "olay"
                    tabBarController?.tabBar.items?[2].badgeColor = Theme.userColor
                }else{
                    tabBarController?.tabBar.items?[2].badgeValue = nil
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
    var i = 0
    var rate = ""
    func entryleriGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for entryIcerik in doc.css("div[class^=content]"){
                let yorum = entryIcerik.parent?.at_css("div[class^=comment-content]")
                var entry = entryIcerik.toHTML
                let e = entryIcerik.parent?.parent?.parent
                let test = e?.at_css("li")
                if test!["data-rate"] != nil{
                rate = test!["data-rate"]!
                }

                if self.tema == 0 || self.tema == 2{
                    entry?.append(contentsOf: "<style>body{ font-size:\(puntosecim)px; font-family:\(font!), sans-serif} mark{background-color:#616161;}a{text-decoration:none}</style>")
                }else{
                    entry?.append(contentsOf: "<style>body{ font-size:\(puntosecim)px; font-family:\(font!), sans-serif} mark{background-color:#ffff9e;}a{text-decoration:none}</style>")
                }
                let goruntule = entry?.html2AttributedString
                if i == 0{
                    self.yorum.append(false)
                    i = i + 1
                }else{
                self.yorum.append(true)
                }
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
                soru.append(attributedString)
                if yorum?.toHTML != nil && yorum?.toHTML?.html2String != "\n"{
                    var yoruml = yorum?.toHTML
                    let user = yorum?.parent
                    yoruml?.append(contentsOf: "<style>body{ font-size:\(puntosecim)px; font-family:\(font!), sans-serif} mark{background-color:#616161;}a{text-decoration:none}</style>")
                    yorumlar = (yoruml?.html2AttributedString)!
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
                    self.cevaplar.append(yorumlar)
                }
            }
        }
    }
    func cevapGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for baslikAdi in doc.css("ul[id^=matter-answer-list] li"){

                let artiOy = baslikAdi["data-upvote-count"] ?? "0"
                yorumArtiOy.append(artiOy)
                let eksiOy = baslikAdi["data-downvote-count"] ?? "0"
                yorumEksiOy.append(eksiOy)
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
                tumuLink = "\(dataSlug!)--\(dataId!)"
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
            for suser in doc.css("a[class^=entry-author]"){
                userName.append(suser.text!)
            }
        }
    }
    func tarihGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for tarih in doc.css("a[class^=matter-date permalink]"){
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
                if self.baslikLinki.contains("%20") || self.baslikLinki.contains("%C3%B6") || self.baslikLinki.contains("%C3%BC") || self.baslikLinki.contains("%C4%B1") || self.baslikLinki.contains("%C4%9F") || self.baslikLinki.contains("day") || self.baslikLinki.contains("?a=find") || self.baslikLinki.contains("?a=search") || self.baslikLinki.contains("focusto"){
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

class SoruViewCell: UITableViewCell{
    
    @IBOutlet weak var userName: UIButton!
    
    @IBOutlet weak var entryView: UITextView!
    
    @IBOutlet weak var tarihLabel: UILabel!
    
    @IBOutlet weak var sukela: UIButton!
    
    @IBOutlet weak var kotule: UIButton!
    
    @IBOutlet weak var kotuleSayi: UILabel!
    
    @IBOutlet weak var sukelaSayi: UILabel!
}
class CevapViewCell: UITableViewCell{
    
    
    @IBOutlet weak var userName: UIButton!
    
    @IBOutlet weak var entryView: UITextView!
    
    @IBOutlet weak var tarihLabel: UILabel!
    
    @IBOutlet weak var sukela: UIButton!
    
    @IBOutlet weak var kotule: UIButton!
    
    @IBOutlet weak var kotuleSayi: UILabel!
    
}
