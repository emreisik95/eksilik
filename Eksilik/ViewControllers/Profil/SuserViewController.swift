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

class SuserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, SFSafariViewControllerDelegate, UITextViewDelegate, UIViewControllerPreviewingDelegate {
    
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
    var secti = Int()
    var barAccessory = UIToolbar()
    var gundemLink = ["son-entryleri","en-begenilenleri","favori-entryleri","favorilenen-entryleri", "son-oylananlari","bu-hafta-dikkat-cekenleri"]
    var secilenLink = "son-entryleri"
    var asilLink = ""
    var oneCikanLink = String()
    let font = UserDefaults.standard.string(forKey: "secilenFont")
    var puntosecim = 15
    var takip = String()
    var engel = String()
    var baslikEngel = String()
    
    var followLink = String()
    var unfollowLink = String()
    var blockLink = String()
    var unblockLink = String()
    var blockTitleLink = String()
    var unblockTitleLink = String()
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return array.count
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let myTitle = NSAttributedString(string: array[row], attributes: [NSAttributedString.Key.foregroundColor: Theme.labelColor!])
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "birientry") as! suserViewCell
        if indexPath.row % 2 == 0{
            cell.backgroundColor = Theme.cellFirstColor
        }
        else{
            cell.backgroundColor = Theme.cellSecondColor
        }
        cell.baslikLabel.text = basliklar[indexPath.row]
        cell.baslikLabel.font = UIFont(name: font!, size: CGFloat(puntosecim))
        cell.baslikLabel.lineBreakMode = .byWordWrapping
        cell.baslikLabel.numberOfLines = 0
        cell.baslikLabel.textColor = Theme.labelColor
        cell.entryNoLabel.text = entryNo[indexPath.row]
        cell.entryNoLabel.font = UIFont(name: font!, size: 10)
        cell.entryNoLabel.adjustsFontSizeToFitWidth = true
        return cell
    }

    
    @IBAction func suserMore(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if durum.count <= 1 {
            alert.addAction(UIAlertAction(title: (durum[0] ? cikarBaslik[0] : ekleBaslik[0]), style: .default, handler: { (UIAlertAction) in
            Alamofire.request("https://eksisozluk.com/\(self.durum[0] ? self.cikarLink[0]: self.kisiLinkler[0])",method: .post, headers: self.headers).responseString {
                response in
                if response.result.isSuccess == true{
                    self.view.makeToast("\(self.durum[0] ? self.cikarBaslik[0] : self.ekleBaslik[0]) işlemi çok da güzel oldu")
                    self.bilgiCek()
                    self.entryList.reloadData()
                }
            }
            }))
        }else if durum.count>1{
            alert.addAction(UIAlertAction(title: (durum[0] ? cikarBaslik[0] : ekleBaslik[0]), style: .default, handler: { (UIAlertAction) in
                Alamofire.request("https://eksisozluk.com/\(self.durum[0] ? self.cikarLink[0]: self.kisiLinkler[0])",method: .post, headers: self.headers).responseString {
                    response in
                    if response.result.isSuccess == true{
                        self.view.makeToast("\(self.durum[0] ? self.cikarBaslik[0] : self.ekleBaslik[0]) işlemi çok da güzel oldu")
                        self.bilgiCek()
                        self.entryList.reloadData()
                    }
                }
            }))
        alert.addAction(UIAlertAction(title: (durum[1] ? cikarBaslik[1] : ekleBaslik[1]), style: .default, handler: { (UIAlertAction) in
            Alamofire.request("https://eksisozluk.com/\(self.durum[1] ? self.cikarLink[1]: self.kisiLinkler[1])",method: .post, headers: self.headers).responseString {
                response in
                if response.result.isSuccess == true{
                    self.view.makeToast("\(self.durum[1] ? self.cikarBaslik[1] : self.ekleBaslik[1]) işlemi çok da güzel oldu")
                    self.bilgiCek()
                    self.entryList.reloadData()
                }
            }
        }))
            if durum.count>2{
        alert.addAction(UIAlertAction(title: (durum[2] ? cikarBaslik[2] : ekleBaslik[2]), style: .default, handler: { (UIAlertAction) in
                Alamofire.request("https://eksisozluk.com/\(self.durum[2] ? self.cikarLink[2]: self.kisiLinkler[2])",method: .post, headers: self.headers).responseString {
                    response in
                    if response.result.isSuccess == true{
                        self.view.makeToast("\(self.durum[2] ? self.cikarBaslik[2] : self.ekleBaslik[2]) işlemi çok da güzel oldu")
                        self.bilgiCek()
                        self.entryList.reloadData()
                    }
                }
            }))
            }
        }
        alert.addAction(UIAlertAction(title: "vazgeç", style: .cancel, handler: { (UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        alert.view.tintColor = Theme.entryButton
        alert.view.layer.cornerRadius = 25
        alert.view.layer.borderColor = Theme.entryButton?.cgColor
        alert.view.layer.borderWidth = 0
        
        self.present(alert, animated: true)
    }
    
    @IBOutlet var istatistikLabel: UILabel!

    @IBOutlet var oneCikanBaslik: UILabel!

    @IBOutlet var oneCikanEntry: UITextView!

    @IBOutlet var oneCikanTarih: UILabel!
    
    @IBOutlet var secenekButonu: UIButton!
    
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
        okImage.isHidden = true
        baslikCek()
    }
    
    @IBOutlet var okImage: UIImageView!
    let status = UserDefaults.standard.bool(forKey: "giris")

    

    override func viewDidLoad() {
        super.viewDidLoad()
        CustomLoader.instance.showLoaderView()
        self.oneCikanEntry.alpha = 0
        self.oneCikanTarih.alpha = 0
        self.istatistikLabel.alpha = 0
        self.oneCikanBaslik.alpha = 0
        self.navigationController?.hidesBottomBarWhenPushed = true
        self.navigationController?.navigationBar.installBlurEffect()
        puntosecim = UserDefaults.standard.integer(forKey: "secilenPunto")
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(biriBaslik(_:)))
        self.navigationController?.navigationBar.addGestureRecognizer(tapGestureRecognizer)
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: entryList)
        }
        
        if status == false{
            self.navigationController?.navigationItem.rightBarButtonItem = nil
        }
        self.oneCikanBaslik.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(linkeGit)))
        self.oneCikanEntry.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(linkeGit)))
        
        tabBarController?.tabBar.installBlurEffect()
        self.bilgiCek()
        self.baslikCek()
        self.navigationController?.navigationBar.barStyle = Theme.barStyle!
        self.navigationController?.navigationBar.barTintColor = Theme.navigationBarColor
        self.view.backgroundColor = Theme.backgroundColor
        entryList.delegate = self
        entryList.dataSource = self
        entryList.backgroundColor = Theme.backgroundColor
        entryList.separatorColor = Theme.separatorColor
        entryList.tableFooterView = UIView()
        oneCikanEntry.delegate = self
        oneCikanEntry.tintColor = Theme.userColor
        secenekButonu.backgroundColor = Theme.userColor
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.pickerView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 320, width: UIScreen.main.bounds.width, height: 320)
        self.pickerView.backgroundColor = Theme.backgroundColor!
        self.barAccessory.backgroundColor = Theme.userColor
        self.barAccessory.isHidden = true
        secti = 0
        DispatchQueue.main.async {
            print(self.kullaniciAdi)
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
        let cleanedText = self.kullaniciAdi.filter { !" \n\t\r".characters.contains($0) }
        vc.baslikLinki = cleanedText[0].addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        print(cleanedText)
        self.navigationController?.pushViewController(vc, animated: true)
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

    func bilgiCek() -> Void {
        Alamofire.request("https://eksisozluk.com/\(biriLink)").responseString {
            response in
            if let html = response.result.value{
                self.kullaniciAdi(html: html)
                self.kullaniciBilgi(html: html)
                self.oneCikan(html: html)
                self.entryleriGetir(html: html)
                self.olayKontrol(html: html)
                self.mesajKontrol(html: html)
                if (self.status){
                self.suserKontrol(html: html)
                }
                CustomLoader.instance.hideLoaderView()
            }
        }
    }
    
    func baslikCek() -> Void {
        
        var kadi = biriLink
        kadi = kadi.replacingOccurrences(of: "/biri/", with: "")
        seciliLink = String()
        sonIstatistik = String()
        tarih = String()
        baslik = String()
        basliklar = [String]()
        entryNo = [String]()
        deneme = [String]()
        linkler = [String]()
        Alamofire.request("https://eksisozluk.com/basliklar/istatistik/\(kadi)/\(secilenLink)").responseString {
            response in
            if let html = response.result.value{
                self.basliklar(html: html)
                CustomLoader.instance.hideLoaderView()
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
                    tabBarController?.tabBar.items?.last!.badgeValue = nil
                }
            }
        }
    }
    var engelli = String()
    var baslikEngelli = String()
    var durum = [Bool]()
    var kisiLinkler = [String]()
    var cikarLink = [String]()
    var ekleBaslik = [String]()
    var cikarBaslik = [String]()
    func suserKontrol(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
             durum = [Bool]()
             kisiLinkler = [String]()
             cikarLink = [String]()
             ekleBaslik = [String]()
             cikarBaslik = [String]()
            for sayfa in doc.css("div[class^=sub-title-menu profile-buttons] a"){
                ekleBaslik.append(sayfa["data-add-caption"] ?? "nil")
                cikarBaslik.append(sayfa["data-remove-caption"] ?? "nil")
                durum.append((sayfa["data-added"]?.boolValue()) ?? false)
                kisiLinkler.append(sayfa["data-add-url"] ?? "nil")
                cikarLink.append(sayfa["data-remove-url"] ?? "nil")
            }
            baslik.removeLast()
            durum.removeLast()
            kisiLinkler.removeLast()
            cikarLink.removeLast()
        }
        print(durum)
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
    
    func kullaniciBilgi(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            if sonIstatistik.count == 0{
            for kullaniciBilgi in doc.css("ul[id^=user-entry-stats] li"){
                let k =  kullaniciBilgi.content
                //  k = k!.replacingOccurrences(of: " ", with: "")
                self.sonIstatistik.append("• \(k!.html2String)   •")
                self.sonIstatistik.removeLast()
                self.istatistikLabel.text = sonIstatistik
                }
            }
        }
    }
    
    func kullaniciAdi(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for kullaniciBilgi in doc.css("h1[data-nick] a"){
                let tlabel = UILabel(frame: CGRect(x: 0, y: -20, width: 200, height: 60))
                print(kullaniciBilgi.text!)
                self.kullaniciAdi.append(kullaniciBilgi.text!)
                tlabel.text = kullaniciBilgi.text!
                tlabel.textColor = Theme.titleColor
                tlabel.textAlignment = .center;
                tlabel.lineBreakMode = .byWordWrapping
                tlabel.numberOfLines = 2
                tlabel.adjustsFontSizeToFitWidth = true
                self.navigationItem.titleView = tlabel
            }
        }
    }
    
    
    func basliklar(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
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
                let l = kullaniciBilgi.at_css("footer a")
                self.oneCikanLink = l!["href"]!
                let ba = b?.toHTML ?? ""
                let ta = t?.toHTML ?? ""
                self.baslik = ba.html2String
                self.tarih = ta.html2String
                self.oneCikanTarih.text = tarih
                self.oneCikanBaslik.text = baslik
                self.oneCikanBaslik.textColor = Theme.userColor
                self.oneCikanTarih.textColor = Theme.tarihColor
                self.oneCikanBaslik.numberOfLines = 0
                self.oneCikanBaslik.lineBreakMode = .byWordWrapping
                self.oneCikanBaslik.font = UIFont(name: font!, size: 13)
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
                e?.append(contentsOf: "<style>body{font-weight:200; font-size:15px; font-family:'\(font!)', sans-serif} a{text-decoration:none} #read-all{display:none;}</style>")
            }
            for entryIcerik in doc.css("div[class^=content]"){
                var entry = entryIcerik.toHTML
                entry?.append(contentsOf: "<style>body{font-weight:200; font-size:15px; font-family:'\(font!)', sans-serif} a{text-decoration:none} #read-all{display:none;}</style>")
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
class suserViewCell:UITableViewCell{
    
    @IBOutlet var baslikLabel: UILabel!
    
    @IBOutlet var entryNoLabel: UILabel!
    
}

extension String {
    func boolValue() -> Bool? {
        let lowercaseSelf = self.lowercased()
        
        switch lowercaseSelf {
        case "true", "yes", "1":
            return true
        case "false", "no", "0":
            return false
        default:
            return nil
        }
    }
}
