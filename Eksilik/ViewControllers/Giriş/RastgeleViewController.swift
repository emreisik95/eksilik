//
//  RastgeleViewController.swift
//  Eksilik
//
//  Created by Emre Işık on 24.04.2019.
//  Copyright © 2019 Emre Isik. All rights reserved.
//

import UIKit
import Kanna
import Alamofire
import SafariServices


class RastgeleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate, UITextViewDelegate {
    
    
    var viewcim = (Bundle.main.loadNibNamed("başlık boş", owner: self, options: nil)![0]) as! UIView
    
    var anlam = [String]()
    var entryler = [NSAttributedString]()
    var favoriler = [NSAttributedString]()
    var linkler = [String]()
    var favoriSayisi = [Int]()
    var baslikLinki = [String]()
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
    var basliklar = [String]()
    
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
    
    
    
    @IBAction func favoributton(_ sender: UIButton) {
        if let indexPath = entryView.indexPath(forItem: sender) {
            self.eID = linkler[indexPath.row]
            performSegue(withIdentifier: "favorileyen", sender: nil)
        }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        puntosecim = UserDefaults.standard.integer(forKey: "secilenPunto")
        prepareUI()
        siteyeBaglan()
        self.navigationController?.navigationBar.installBlurEffect()
        tabBarController?.tabBar.installBlurEffect()
        let adjustForTabbarInsets: UIEdgeInsets = UIEdgeInsets(top: (navigationController?.navigationBar.frame.height)! - 24, left: 0, bottom: self.tabBarController!.tabBar.frame.height + 95, right: 0)
        entryView.contentInset = adjustForTabbarInsets
        entryView.scrollIndicatorInsets = adjustForTabbarInsets
        entryView.tableFooterView = UIView()
        self.navigationItem.title = "rastgele şükela entryler"
        CustomLoader.instance.showLoaderView()
        entryView.delegate = self
        entryView.dataSource = self
        entryView.backgroundColor = Theme.backgroundColor
        entryView.alwaysBounceVertical = false
        self.navigationController?.navigationBar.tintColor = Theme.titleColor
        entryView.separatorStyle = .singleLine
        entryView.separatorColor = Theme.separatorColor
        let point = CGPoint(x: 0, y:(self.navigationController?.navigationBar.frame.size.height)! + 12)
        entryView.setContentOffset(point, animated: true)

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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "favorileyen"{
            let favoriVC = segue.destination as! favorileyenViewController
            let entryId = self.eID
            favoriVC.entryId = entryId
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
        }
        return false
    }
    
    @IBOutlet weak var entryView: UITableView!
    /* Otomatik tablo hücre yüksekliği  */
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    /* Otomatik tablo hücre yüksekliği  */
    /* Tablo getir  */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entryler.count
    }
    var yorum = [Bool]()
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! randomCell
            if self.girisKontrolu.isEmpty{
                cell.favorileButton.isEnabled = false
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
            cell.selectionStyle = .none
            cell.entryText.delegate = self
            cell.entryText.attributedText = self.entryler[indexPath.row]
            cell.favoriButton.setTitle("\(self.favoriSayisi[indexPath.row]) favori", for: .normal)
            cell.favoriButton.setTitleColor(.gray, for: .normal)
            cell.tarihLabel.text = self.tarihler[indexPath.row]
            cell.kullaniciButton.setTitle(self.userName[indexPath.row], for: .normal)
            
            if self.userName[indexPath.row] == self.kullaniciAdi[0]{
                cell.sukelaButton.isHidden = true
                cell.kotuleButton.isHidden = true
            }
            
            cell.baslikLabel.setTitle(self.basliklar[indexPath.row], for: .normal)
        cell.baslikLabel.titleLabel?.numberOfLines = 0; 
        cell.baslikLabel.titleLabel?.lineBreakMode = .byWordWrapping;
        cell.baslikLabel.titleLabel?.textAlignment = .center
            cell.baslikLabel.setTitleColor(Theme.userColor, for: .normal)
            cell.entryText.textColor = Theme.labelColor
            cell.entryText.tintColor = Theme.linkColor
            cell.kullaniciButton.setTitleColor(Theme.userColor, for: .normal)
            cell.tarihLabel.textColor = Theme.tarihColor
            cell.paylasButton.tintColor = Theme.entryButton
            let sukelaImg = UIImage(named: "şükela")
            cell.sukelaButton.setImage(sukelaImg, for: .normal)
            
            if self.fav[indexPath.row] == false{
                if let image = UIImage(named: "favlanmadı") {
                    cell.favorileButton.setImage(image, for: .normal)
                    cell.favorileButton.tintColor = .gray
                }
            }
            else{
                if let image = UIImage(named: "favlandı") {
                    cell.favorileButton.setImage(image, for: .normal)
                }
        }

            return cell
        }
        //  return UITableViewCell()
    
    private var finishedLoadingInitialTableCells = false
    
    
    /* Tablo getir  */
    
    /* başlığa bağlan verileri çek  */
    
    func siteyeBaglan() -> Void {
        Alamofire.request("https://eksisozluk.com/", method: .get, headers: headers).responseString {
            response in
            if let html = response.result.value{
                self.yorum = [Bool]()
                self.yorumlar = NSAttributedString()
                self.entryler = [NSAttributedString]()
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
                self.basliklar = [String]()
                self.baslikGetir(html: html)
                self.favoriGetir(html: html)
                self.kullanici(html: html)
                self.girisKontrol(html: html)
                self.baslikKontrol(html: html)
                self.favoriSayisiGetir(html: html)
                self.entryleriGetir(html: html)
                self.suserGetir(html: html)
                self.tarihGetir(html: html)
                if self.status == true{
                    self.olayKontrol(html: html)
                    self.mesajKontrol(html: html)
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
                if self.entryler.count == 0 {
                    self.entryView.addSubview(self.viewcim)
                    self.entryView.separatorStyle = .none
                }else{
                    self.viewcim.removeFromSuperview()
                    self.entryView.separatorStyle = .singleLine
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
    
    
    @IBAction func baslikButonu(_ sender: UIButton) {
        if let indexPath = entryView.indexPath(forItem: sender) {
            let viewController = storyboard?.instantiateViewController(withIdentifier: "entryGoruntule") as! EntryViewController
            CustomLoader.instance.showLoaderView()
            viewController.baslikLinki = "\(self.baslikLinki[indexPath.row])"
            navigationController?.pushViewController(viewController, animated: true)
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
    func entryleriGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for entryIcerik in doc.css("div[class^=content]"){
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
                    self.entryler.append(yorumlar)
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

    func baslikGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for entrySayisi in doc.css("h1[id^=title]"){
                let dataSlug = entrySayisi["data-slug"]
                let dataId = entrySayisi["data-id"]
                self.baslikLinki.append("\(dataSlug!)--\(dataId!)")
                self.basliklar.append(entrySayisi["data-title"]!)
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


class randomCell:UITableViewCell{
    
    @IBOutlet weak var entryText: UITextView!
    
    @IBOutlet weak var kullaniciButton: UIButton!
    
    @IBOutlet weak var tarihLabel: UILabel!
    
    @IBOutlet weak var favoriButton: UIButton!
    
    @IBOutlet weak var favorileButton: UIButton!
    
    @IBOutlet weak var sukelaButton: UIButton!
    
    @IBOutlet weak var kotuleButton: UIButton!
    
    @IBOutlet weak var paylasButton: UIButton!
    
    @IBOutlet weak var baslikLabel: UIButton!
    
    
}
