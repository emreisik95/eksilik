//
//  BenViewController.swift
//  Eksilik
//
//  Created by Emre Işık on 29.03.2019.
//  Copyright © 2019 Emre Isik. All rights reserved.
//

import UIKit
import Alamofire
import Kanna
import SafariServices
import ReadMoreTextView

class BenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, SFSafariViewControllerDelegate, UITextViewDelegate, UIViewControllerPreviewingDelegate{

    var kullaniciAdi = [String]()
    var biriLink = String()
    var sonIstatistik = String()
    var tarih = String()
    var baslik = String()
    var basliklar = [String]()
    var entryNo = [String]()
    var deneme = [String]()
    let headers: HTTPHeaders = [ "X-Requested-With": "XMLHttpRequest"]
    var seciliLink = String()
    var linkler = [String]()
    var array = ["son entryleri", "en beğenilenleri", "favori entryleri", "en çok favorilenenleri", "son oylananları", "bu hafta dikkat çekenleri"]
    var oneCikanLink = String()
    var secti = Int()
    var barAccessory = UIToolbar()
    var gundemLink = ["son-entryleri","en-begenilenleri","favori-entryleri","favorilenen-entryleri", "son-oylananlari","bu-hafta-dikkat-cekenleri"]
    var secilenLink = "son-entryleri"
    var asilLink = ""
    let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction(sender:)))
    var girisKontrolu = String()
    let font = UserDefaults.standard.string(forKey: "secilenFont")
    var puntosecim = 15
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        let vc =
            self.storyboard?.instantiateViewController(withIdentifier:
                "entryGoruntule") as! EntryViewController
        var link = oneCikanBaslik.text!
        link = link.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]{} ").inverted)!
        vc.baslikLinki = link
        vc.extendedLayoutIncludesOpaqueBars = false
        self.navigationController?.pushViewController(vc, animated: true)    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return array.count
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let myTitle = NSAttributedString(string: array[row], attributes: [NSAttributedString.Key.foregroundColor: Theme.userColor!])
        pickerView.backgroundColor = Theme.backgroundColor
        return myTitle
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        secti = row
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return basliklar.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "birientry") as! benViewCell
        if indexPath.row % 2 == 0{
            cell.backgroundColor = Theme.cellFirstColor
        }
        if indexPath.row % 2 == 1{
            cell.backgroundColor = Theme.cellSecondColor
        }
        DispatchQueue.main.async{
            cell.baslikLabel.text = self.basliklar[indexPath.row]
            cell.entryNoLabel.text = self.entryNo[indexPath.row]
        }
            cell.baslikLabel.textColor = Theme.labelColor
        cell.baslikLabel.font = UIFont(name: self.font ?? "Helvetica-Light", size: CGFloat(puntosecim))
            cell.entryNoLabel.textColor = Theme.tarihColor
            cell.entryNoLabel.font = UIFont(name: self.font ?? "Helvetica-Light", size: 10)
            cell.baslikLabel.adjustsFontSizeToFitWidth = true
            cell.entryNoLabel.adjustsFontSizeToFitWidth = true
        return cell
    }

    
    
    @IBOutlet var istatistikLabel: UILabel!
    
    @IBOutlet var oneCikanBaslik: UILabel!
    
    @IBOutlet var oneCikanEntry: UITextView!
    
    @IBOutlet var oneCikanTarih: UILabel!
    
    
    @IBOutlet var entryList: UITableView!
    
    @IBAction func secenekButton(_ sender: Any) {
        pickerView.isHidden = false
        self.view.addSubview(pickerView)
        barAccessory = UIToolbar(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 320, width: pickerView.frame.size.width, height: 44))
        barAccessory.barStyle = Theme.barStyle!
        barAccessory.barTintColor = Theme.userColor
        let vazgec = UIBarButtonItem(title: "vazgeç", style: .done, target: self, action: #selector(vazgec(_:)))
        let flexiblespace = UIBarButtonItem(barButtonSystemItem:.flexibleSpace , target: nil, action: nil)
        let btnDone = UIBarButtonItem(title: "tamam", style: .done, target: self, action: #selector(tamam(_:)))
        btnDone.tintColor = .white
        vazgec.tintColor = .white
        barAccessory.items = [vazgec,flexiblespace,btnDone]
        self.view.addSubview(barAccessory)

    }
    @IBAction func vazgec(_ sender: Any) {
        pickerView.isHidden = true
        barAccessory.isHidden = true
    }
    @IBAction func tamam(_ sender: Any) {
        pickerView.isHidden = true
        barAccessory.isHidden = true
        CustomLoader.instance.showLoaderView()
        secilenLink = gundemLink[secti]
        secenekButonu.setTitle(array[secti], for: .normal)
        self.linkler = [String]()
        okImage.isHidden = true
        baslikCek()
    }
    
    @IBOutlet var secenekButonu: UIButton!
    @IBOutlet var okImage: UIImageView!

    
    override func viewWillAppear(_ animated: Bool) {
        prepareUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CustomLoader.instance.showLoaderView()
        entryList.contentInset = UIEdgeInsets(top: 5, left: 0, bottom:40, right: 0);
        self.oneCikanEntry.alpha = 0
        self.oneCikanTarih.alpha = 0
        self.istatistikLabel.alpha = 0
        self.oneCikanBaslik.alpha = 0
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(biriBaslik(_:)))
        self.navigationController?.navigationBar.addGestureRecognizer(tapGestureRecognizer)
        puntosecim = UserDefaults.standard.integer(forKey: "secilenPunto")
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: entryList)
        }
        kullaniciAdiOgren()
        self.navigationController?.navigationBar.barStyle = Theme.barStyle!
        self.navigationController?.navigationBar.installBlurEffect()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Theme.titleColor!]
        tabBarController?.tabBar.installBlurEffect()

        self.oneCikanBaslik.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(linkeGit)))
        self.oneCikanEntry.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(linkeGit)))
        
        self.navigationItem.rightBarButtonItem?.tintColor = Theme.titleColor
        self.navigationItem.leftBarButtonItem?.tintColor = Theme.titleColor
        entryList.separatorColor = Theme.separatorColor
        entryList.delegate = self
        entryList.dataSource = self
        entryList.backgroundColor = Theme.backgroundColor
        entryList.tableFooterView = UIView()
        self.view.backgroundColor = Theme.backgroundColor
        oneCikanEntry.tintColor = Theme.linkColor
        oneCikanEntry.delegate = self
        oneCikanTarih.textColor = Theme.tarihColor
        oneCikanBaslik.textColor = Theme.linkColor
        oneCikanBaslik.addGestureRecognizer(tap)
        self.oneCikanBaslik.numberOfLines = 0
        self.oneCikanBaslik.lineBreakMode = .byWordWrapping
        self.oneCikanBaslik.font = UIFont(name: font ?? "Helvetica-Light", size: 17)
        secenekButonu.backgroundColor = Theme.entryButton
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.pickerView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 320, width: UIScreen.main.bounds.width, height: 320)
        secti = 0
    }
    
    private var finishedLoadingInitialTableCells = false
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        var lastInitialDisplayableCell = false
        
        //change flag as soon as last displayable cell is being loaded (which will mean table has initially loaded)
        if entryNo.count > 0 && !finishedLoadingInitialTableCells {
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
            cell.transform = CGAffineTransform(translationX: 0, y: entryList.rowHeight/2)
            cell.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0.05*Double(indexPath.row), options: [.curveEaseInOut], animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
                cell.alpha = 1
            }, completion: nil)
        }
    }
    
    
    @objc func linkeGit(){
        let vc =
            self.storyboard?.instantiateViewController(withIdentifier:
                "entryGoruntule") as! EntryViewController
        vc.baslikLinki = oneCikanLink
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func biriBaslik(_ sth: AnyObject){
        let vc =
            self.storyboard?.instantiateViewController(withIdentifier:
                "entryGoruntule") as! EntryViewController
        vc.baslikLinki = self.kullaniciAdi[0].addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        self.navigationController?.pushViewController(vc, animated: true)
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
            self.entryList.reloadData()
        }
    }
    @objc func refreshTableView() {
        CustomLoader.instance.showLoaderView()
        kullaniciAdiOgren()
        self.bilgiCek()
        self.baslikCek()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.tableViewRefreshControl.endRefreshing()
        }
    }
    @available(iOS 10.0, *)
    func prepareUI() {
        // Adding 'tableViewRefreshControl' to tableView
        entryList.refreshControl = tableViewRefreshControl
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
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = entryList.indexPathForRow(at: location), let cell = entryList.cellForRow(at: indexPath){
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

    
    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let link = URL.absoluteString
        let url = URL
        if (link.contains("applewebdata://")){
            var url = URLComponents(string: link)!
            url.host = ""
            url.path = ""
            var asil: String = ""
            asil = url.string!
            self.asilLink = asil.replacingOccurrences(of: "applewebdata://", with: "", options: .literal, range: nil)
            let viewController = storyboard?.instantiateViewController(withIdentifier: "entryGoruntule") as! EntryViewController
            CustomLoader.instance.showLoaderView()
            viewController.baslikLinki = "\(self.asilLink)"
            navigationController?.pushViewController(viewController, animated: true)
        }
        else{
            let controller = SFSafariViewController(url: URL)
            controller.preferredBarTintColor = UIColor.black
            controller.preferredControlTintColor = UIColor.white
            self.present(controller, animated: true, completion: nil)
            controller.delegate = self
            func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
                controller.dismiss(animated: true, completion: nil)
            }
        }
        return false
    }
    
    var pickerView: UIPickerView = UIPickerView()

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        seciliLink = linkler[indexPath.row]
        baslik = basliklar[indexPath.row]
        performSegue(withIdentifier: "entryVC", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "entryVC"{
            let entryVC = segue.destination as! EntryViewController
            entryVC.baslikLinki = "https://eksisozluk.com/\(self.seciliLink)"
            entryVC.baslik = self.baslik
            entryVC.extendedLayoutIncludesOpaqueBars = false
        }
    }
    func kullaniciAdiOgren() -> Void {
        Alamofire.request("https://eksisozluk.com/basliklar/m/populer").responseString {
            response in
            if let html = response.result.value{
                self.tarih = String()
                self.baslik = String()
                self.deneme = [String]()
                self.seciliLink = String()
                self.girisKontrolu = String()
                self.sonIstatistik = ""
                self.kullanici(html: html)
                self.olayKontrol(html: html)
                self.mesajKontrol(html: html)
                self.bilgiCek()
                self.baslikCek()
            }
            }
        }
    
    func mesajKontrol(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for sayfa in doc.css("li[class^=messages mobile-only] a svg"){
                let olayTuru = sayfa.className!
                if olayTuru.contains("green"){
                    tabBarController?.tabBar.items?.last!.badgeValue = "mesaj"
                    tabBarController?.tabBar.items?.last!.badgeColor = Theme.userColor
                }else{
                    tabBarController?.tabBar.items?.last!.badgeValue = ""
                    tabBarController?.tabBar.items?.last!.badgeColor = .clear
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
                    tabBarController?.tabBar.items?[3].badgeColor = Theme.userColor
                }else{
                    tabBarController?.tabBar.items?[3].badgeValue = nil
                }
            }
        }
    }
    
func kullanici(html: String) -> Void {
    if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
        for kullanici in doc.css("nav[id^=top-navigation]"){
            var pullanici = kullanici.at_css("li[class^=not-mobile] a")
            let k = pullanici?["title"]
                let link = pullanici?["href"]
                self.biriLink = link!
                self.kullaniciAdi.append(k ?? "ben")
            let tlabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
            tlabel.text = kullaniciAdi[0]
            tlabel.textColor = Theme.titleColor
            tlabel.textAlignment = .center;
            tlabel.lineBreakMode = .byWordWrapping
            tlabel.numberOfLines = 2
            tlabel.adjustsFontSizeToFitWidth = true
            self.navigationItem.titleView = tlabel
        }
    }
}
    
    func bilgiCek() -> Void {
        Alamofire.request("https://eksisozluk.com/\(biriLink)").responseString {
            response in
            if let html = response.result.value{
                self.sonIstatistik = String()
                self.entryleriGetir(html: html)
                self.kullaniciBilgi(html: html)
                self.oneCikan(html: html)
                self.girisKontrol(html: html)
            }
        }
    }
    
    func baslikCek() -> Void {
        
       var kadi = biriLink

        kadi = kadi.replacingOccurrences(of: "/biri/", with: "")
        Alamofire.request("https://eksisozluk.com/basliklar/istatistik/\(kadi)/\(secilenLink)").responseString {
            response in
            if let html = response.result.value{
                self.basliklar(html: html)
                CustomLoader.instance.hideLoaderView()
            }
        }
    }

    
    
    func kullaniciBilgi(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for kullaniciBilgi in doc.css("ul[id^=user-entry-stats] li"){
                let k =  kullaniciBilgi.content
              //  k = k!.replacingOccurrences(of: " ", with: "")
                self.sonIstatistik.append("• \(k!.html2String)   •")
                self.sonIstatistik.removeLast()
                self.istatistikLabel.text = sonIstatistik
            }
        }
    }
    
    
    func basliklar(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            self.basliklar = [String]()
            self.entryNo = [String]()
            for basliklar in doc.css("section[id^=content-body] ul li a"){
                var small = basliklar.at_css("span[class^=detail with-parentheses]")
                self.entryNo.append((small?.text!)!)
                small?.content = ""
                let k =  basliklar.content
                self.basliklar.append("\(k!.html2String)")
                linkler.append(basliklar["href"]!)
            }
            self.entryList.reloadData()
        }
    }

    
    func oneCikan(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for kullaniciBilgi in doc.css("blockquote[id^=quote-entry]"){
                let b =  kullaniciBilgi.at_css("h2")
                let t =  kullaniciBilgi.at_css("footer")
                let ba = b?.toHTML
                let ta = t?.toHTML
                let l = kullaniciBilgi.at_css("footer a")
                self.oneCikanLink = l!["href"]!
                self.baslik = ba!.html2String
                self.tarih = ta!.html2String
                self.oneCikanTarih.text = tarih
                self.oneCikanBaslik.text = baslik
            }
        }
    }
    
    func girisKontrol(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("li[class^=buddy mobile-only] a"){
                girisKontrolu = basliklar["href"]!
                    if girisKontrolu.isEmpty{
                        self.cikis()
                }
            }
        }
    }
    
    func cikis(){
        Alamofire.request("https://www.eksisozluk.com/terk").responseString {
            response in
            if response.result.isSuccess{
                UserDefaults.standard.set(false, forKey: "giris")
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "basla") as! UITabBarController
                vc.viewControllers?.removeLast()
                vc.viewControllers?.remove(at: 3)
                TarihPageViewController().viewDidLoad()
                UIApplication.shared.keyWindow?.rootViewController = vc
            }
        }
    }
    
    func entryleriGetir(html: String) -> Void {
        UIView.animate(withDuration: 1, delay: 0, options: .curveLinear, animations: {
            self.oneCikanEntry.alpha = 1
            self.oneCikanTarih.alpha = 1
            self.istatistikLabel.alpha = 1
            self.oneCikanBaslik.alpha = 1
            
        }, completion: { finished in
            print("Animation completed")
        })
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            let k = doc.css("p")
            for caylak in k{
                var e = caylak.toHTML
                e?.append(contentsOf: "<style>body{font-weight:200; font-size:15px; font-family:'\(font ?? "Helvetica-Light")', sans-serif} a{text-decoration:none} #read-all{display:none;}</style>")
                self.oneCikanEntry.attributedText = e?.html2AttributedString
                self.oneCikanEntry.textColor = Theme.labelColor
            }
            for entryIcerik in doc.css("div[class^=content]"){
                var entry = entryIcerik.toHTML
                entry?.append(contentsOf: "<style>body{font-weight:200; font-size:15px; font-family:'\(font ?? "Helvetica-Light")', sans-serif} a{text-decoration:none} #read-all{display:none;}</style>")
                let goruntule = entry?.html2AttributedString
                self.deneme.append(entry!.html2String)
                let attributedString = NSMutableAttributedString(attributedString: goruntule!)
                attributedString.enumerateAttribute(.link, in: NSRange(location: 0, length: attributedString.length), options: [.reverse]) { (attribute, range, pointee) in
                    if let link = attribute as? URL, link.absoluteString.hasPrefix("http") {
                        let replacement = NSMutableAttributedString(attributedString: attributedString.attributedSubstring(from: range))
                        replacement.replaceCharacters(in: NSRange(location: replacement.length, length: 0), with: "⤳")
                        let newLink = link.absoluteString
                        replacement.addAttribute(.link, value: newLink, range: NSRange(location: 0, length: replacement.length))
                        attributedString.replaceCharacters(in: range, with: replacement)
                    }
                }
                self.oneCikanEntry.attributedText = attributedString
                self.oneCikanEntry.textColor = Theme.labelColor
        }
    }

}

}
class benViewCell:UITableViewCell{
  
    @IBOutlet var baslikLabel: UILabel!
    
    @IBOutlet var entryNoLabel: UILabel!
    
    
}
