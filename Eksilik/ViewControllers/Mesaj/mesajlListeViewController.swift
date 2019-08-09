//
//  mesajlListeViewController.swift
//  Eksilik
//
//  Created by Emre Işık on 14.04.2019.
//  Copyright © 2019 Emre Isik. All rights reserved.
//

import UIKit
import Kanna
import Alamofire

class mesajlListeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var mesajlar = [String]()
    var tarihler = [String]()
    var kullaniciAdi = [String]()
    var linkler = [String]()
    var baslikLinki = "https://eksisozluk.com/mesaj"
    var puntosecim = UserDefaults.standard.integer(forKey: "secilenPunto")
    let font = UserDefaults.standard.string(forKey: "secilenFont")

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kullaniciAdi.count
    }
    
    private var finishedLoadingInitialTableCells = false
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        var lastInitialDisplayableCell = false
        
        //change flag as soon as last displayable cell is being loaded (which will mean table has initially loaded)
        if mesajlar.count > 0 && !finishedLoadingInitialTableCells {
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
            cell.transform = CGAffineTransform(translationX: 0, y: mesajView.rowHeight/2)
            cell.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0.05*Double(indexPath.row), options: [.curveEaseInOut], animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
                cell.alpha = 1
            }, completion: nil)
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mesaj", for: indexPath) as! mesajViewCell
        if indexPath.row % 2 == 0{
            cell.backgroundColor = Theme.cellFirstColor
            let bgView = UIView()
            bgView.backgroundColor = Theme.cellFirstColor!
            cell.selectedBackgroundView = bgView
        }else{
            cell.backgroundColor = Theme.cellSecondColor
            let bgView = UIView()
            bgView.backgroundColor = Theme.cellSecondColor!
            cell.selectedBackgroundView = bgView
        }
        cell.baslikLabel.text = kullaniciAdi[indexPath.row]
        if (cell.baslikLabel.text?.contains("okunmamış"))!{
            cell.backgroundColor = Theme.okunmamis
            cell.baslikLabel.textColor = Theme.okunmamisBaslik
        }
        cell.baslikLabel.textColor = Theme.userColor!
        cell.baslikLabel.adjustsFontSizeToFitWidth = true
        cell.baslikLabel.font = UIFont(name: font!, size: CGFloat(puntosecim))
        cell.mesajLabel.textColor = Theme.labelColor!
        cell.mesajLabel.font = UIFont(name: font!, size: CGFloat(puntosecim))
        cell.tarihLabel.textColor = .gray
        cell.mesajLabel.text = mesajlar[indexPath.row]
        cell.tarihLabel.text = tarihler[indexPath.row]
        cell.mesajSayiLabel.text = mesajSayisi[indexPath.row]
        cell.mesajSayiLabel.adjustsFontSizeToFitWidth = true
        cell.mesajSayiLabel.textColor = Theme.userColor!
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }

    @IBOutlet weak var mesajView: UITableView!
    
    @IBOutlet weak var sayfaView: UIView!
    
    @IBOutlet weak var sonSayfaButonu: UIButton!
    
    @IBOutlet weak var sonrakiSayfaButonu: UIButton!
    
    @IBOutlet weak var oncekiSayfaButonu: UIButton!
    
    @IBOutlet weak var ilkSayfaButonu: UIButton!
    
    @IBOutlet weak var sayfaButonu: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        tabBarController?.tabBar.installBlurEffect()
        self.navigationController?.navigationBar.installBlurEffect()
        sayfaView.backgroundColor = Theme.backgroundColor!
        mesajView.delegate = self
        mesajView.dataSource = self
        mesajView.separatorColor = Theme.separatorColor!
        self.view.backgroundColor = Theme.backgroundColor!
        self.navigationController?.navigationBar.tintColor = Theme.titleColor
        ilkSayfaButonu.tintColor = Theme.userColor
        oncekiSayfaButonu.tintColor = Theme.userColor
        sonrakiSayfaButonu.tintColor = Theme.userColor
        sonSayfaButonu.tintColor = Theme.userColor
        sayfaButonu.setTitleColor(Theme.userColor, for: .normal)
        siteyeBaglan()
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
            self.mesajView.reloadData()
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
        mesajView.refreshControl = tableViewRefreshControl
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
    
    @IBAction func sonSayfa(_ sender: Any) {
        let sayfa = Int(aktifSayfa)!
        baslikLinki = baslikLinki.replacingOccurrences(of: "?p=\(sayfa)", with: "")
        baslikLinki.append("?p=\(sayfaSayisi)")
        self.mesajView.isScrollEnabled = false
        let co = self.mesajView.contentOffset
        self.mesajView.setContentOffset(co, animated: false)
        self.siteyeBaglan()
    }
    
    @IBAction func sonrakiSayfa(_ sender: Any) {
        CustomLoader.instance.showLoaderView()
        
        let sayfa = Int(aktifSayfa)!
            baslikLinki = baslikLinki.replacingOccurrences(of: "?p=\(sayfa)", with: "")
            baslikLinki.append("?p=\(sayfa+1)")
        self.mesajView.isScrollEnabled = false
        let co = self.mesajView.contentOffset
        self.mesajView.setContentOffset(co, animated: false)
            self.siteyeBaglan()
    }
    
    @IBAction func oncekiSayfa(_ sender: Any) {
        let sayfa = Int(aktifSayfa)!
        baslikLinki = baslikLinki.replacingOccurrences(of: "?p=\(sayfa)", with: "")
        baslikLinki.append("?p=\(sayfa-1)")
        self.mesajView.isScrollEnabled = false
        let co = self.mesajView.contentOffset
        self.mesajView.setContentOffset(co, animated: false)
        self.siteyeBaglan()
    }
    
    @IBAction func ilkSayfa(_ sender: Any) {
        let sayfa = Int(aktifSayfa)!
        baslikLinki = baslikLinki.replacingOccurrences(of: "?p=\(sayfa)", with: "")
        baslikLinki.append("?p=1")
        self.mesajView.isScrollEnabled = false
        let co = self.mesajView.contentOffset
        self.mesajView.setContentOffset(co, animated: false)
        self.siteyeBaglan()
    }
    
    
    var seciliLink = ""
    var baslik = ""
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       seciliLink = linkler[indexPath.row]
       baslik = kullaniciAdi[indexPath.row]
        performSegue(withIdentifier: "mesajVC", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mesajVC"{
            let entryVC = segue.destination as! mesajIcerikViewController
            entryVC.icerikLink = self.seciliLink
            entryVC.baslik = self.baslik
        }
    }
    
    let headers: HTTPHeaders = [ "X-Requested-With": "XMLHttpRequest",
                                 "Accept-Language": "tr-TR,tr;q=0.9,en-US;q=0.8,en;q=0.7,ru;q=0.6",
                                 "Accept-Encoding": "gzip, deflate, br"]
    var viewcim = (Bundle.main.loadNibNamed("başlık boş", owner: self, options: nil)![0]) as! UIView
    func siteyeBaglan() -> Void {
        Alamofire.request(baslikLinki, method: .get, headers: self.headers).responseString {
            response in
            if let html = response.result.value{
                self.mesajlar = [String]()
                self.tarihler = [String]()
                self.kullaniciAdi = [String]()
                self.linkler = [String]()
                self.sayfaSayisiGetir(html: html)
                self.mesajGetir(html: html)
                self.mesajLink(html: html)
                self.kullaniciGetir(html: html)
                self.tarihGetir(html: html)
                self.mesajSayisi = [String]()
                self.mesajSayisiGetir(html: html)
                self.mesajView.isScrollEnabled = true
                if self.mesajlar.count == 0 {
                    self.mesajView.addSubview(self.viewcim)
                    self.mesajView.separatorStyle = .none
                }else{
                    self.viewcim.removeFromSuperview()
                    self.mesajView.separatorStyle = .singleLine
                }
                if self.aktifSayfa == self.sayfaSayisi{
                    self.sonrakiSayfaButonu.isEnabled = false
                    self.sonSayfaButonu.isEnabled = false
                }else{
                    self.sonSayfaButonu.isEnabled = true
                    self.sonrakiSayfaButonu.isEnabled = true
                }
                
                if self.aktifSayfa == "1" || self.aktifSayfa == ""{
                    self.ilkSayfaButonu.isEnabled = false
                    self.oncekiSayfaButonu.isEnabled = false
                }else{
                    self.ilkSayfaButonu.isEnabled = true
                    self.oncekiSayfaButonu.isEnabled = true
                }
            }
            if response.result.isSuccess == false{
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    let alert = UIAlertController(title: "başlıklar gelmedi", message: "ama her an burda olabilir, gerçi olmayabilir de", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "tamam", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
            }
            else if response.result.isSuccess == true{
                CustomLoader.instance.hideLoaderView()
            }
        }
        self.mesajView.reloadData()
    }
    
    
    func mesajGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("ul[id^=threads] article a p"){
                self.mesajlar.append(basliklar.text!)
            }
            self.mesajView.reloadData()
        }
    }
    
    func tarihGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("ul[id^=threads] article footer time"){
                self.tarihler.append(basliklar.text!)
            }
            self.mesajView.reloadData()
        }
    }
    
    func kullaniciGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("ul[id^=threads] article a h2"){
                var small = basliklar.at_css("small")
                small?.content = ""
                if basliklar.parent?.parent?.className == "unread"{
                    self.kullaniciAdi.append(basliklar.text!)
                }else{
                    self.kullaniciAdi.append(basliklar.text!)
                }
            }
            self.mesajView.reloadData()
        }
    }
    var mesajSayisi = [String]()
    func mesajSayisiGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("ul[id^=threads] article a h2 small"){
                self.mesajSayisi.append("\(basliklar.text!) mesaj")
            }
            self.mesajView.reloadData()
        }
    }

    func mesajLink(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("ul[id^=threads] li article a"){
                let link = basliklar["href"]
                if link != nil{
                    linkler.append(link!)
                }
            }
        }
    }
    var sayfaSayisi = ""
    var aktifSayfa = ""
    func sayfaSayisiGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for sayfa in doc.css("div[class^=pager]"){
                let simdiki = sayfa["data-currentpage"]
                let toplam = sayfa["data-pagecount"]
                self.sayfaSayisi = toplam!
                self.aktifSayfa = simdiki!
                self.sayfaButonu.setTitle("\(self.aktifSayfa) / \(self.sayfaSayisi)", for: .normal)
                print(simdiki!)
                print(toplam!)
            }
        }
    }
    
}

class mesajViewCell: UITableViewCell{
    
    @IBOutlet weak var baslikLabel: UILabel!
    
    @IBOutlet weak var mesajLabel: UILabel!
    
    @IBOutlet weak var mesajSayiLabel: UILabel!
    
    @IBOutlet weak var tarihLabel: UILabel!
}
