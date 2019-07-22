//
//  olayViewController.swift
//  Eksilik
//
//  Created by Emre Işık on 14.04.2019.
//  Copyright © 2019 Emre Isik. All rights reserved.
//

import UIKit
import Alamofire
import Kanna
class olayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var basliklar = [String]()
    var entrySayisi = [String]()
    var linkler = [String]()
    var seciliLink = ""
    var baslik = ""
    var girisKontrolu = String()
    var gundemLink = "https://eksisozluk.com/basliklar/olay"
    var dahadaLink = ""
    var sayfaSayisi = "5"
    var aktifSayfa = "2"
    var sayfa: Int = 2
    let status = UserDefaults.standard.bool(forKey: "giris")
    var font = "Helvetica"
    var puntosecim = 15
    @IBOutlet var olayView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        siteyeBaglan()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        puntosecim = UserDefaults.standard.integer(forKey: "secilenPunto")
        self.navigationController?.navigationBar.installBlurEffect()
        tabBarController?.tabBar.installBlurEffect()
        font = UserDefaults.standard.string(forKey: "secilenFont")!
        CustomLoader.instance.showLoaderView()
        self.title =  "olay"
        prepareUI()
        self.navigationController?.navigationBar.barStyle = Theme.barStyle!
        self.navigationController?.navigationBar.barTintColor = Theme.navigationBarColor
        olayView.separatorStyle = .singleLine
        olayView.separatorColor = Theme.separatorColor
        olayView.backgroundColor = Theme.backgroundColor
        olayView.tableFooterView = UIView()
        olayView.dataSource = self
        olayView.delegate = self
        self.view.backgroundColor = Theme.backgroundColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Theme.titleColor!]
        
        // Do any additional setup after loading the view.
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
            self.olayView.reloadData()
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
        olayView.refreshControl = tableViewRefreshControl
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        seciliLink = linkler[indexPath.row]
        baslik = basliklar[indexPath.row]
        print(seciliLink)
        performSegue(withIdentifier: "entryVc", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "entryVc"{
            let entryVC = segue.destination as! EntryViewController
            entryVC.baslikLinki = "\(self.seciliLink)"
            entryVC.extendedLayoutIncludesOpaqueBars = false
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return basliklar.count
    }
    
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! olayViewCell
        if indexPath.row % 2 == 0{
            cell.backgroundColor = Theme.cellFirstColor
        }else{
            cell.backgroundColor = Theme.cellSecondColor
        }
        let bgColorView = UIView()
        bgColorView.backgroundColor = Theme.backgroundColor
        cell.selectedBackgroundView = bgColorView
        cell.entrySayiLabel.text = entrySayisi[indexPath.row]
        cell.entrySayiLabel.font = UIFont(name: font, size: CGFloat(puntosecim))
        cell.entrySayiLabel.textColor = Theme.entrySayiColor
        cell.baslikLabel.text = basliklar[indexPath.row]
        cell.baslikLabel.font = UIFont(name: font, size: CGFloat(puntosecim))
        cell.baslikLabel.textColor = Theme.labelColor
        return cell
    }
    
    func basliklariGetir() -> Void {
        Alamofire.request(dahadaLink).responseString {
            response in
            print("\(response.result.isSuccess)")
            if let html = response.result.value{
                self.sayfaSayisiGetir(html: html)
                self.baslikentrysayisiGetir(html: html)
                self.baslikGetir(html: html)
                self.baslikLink(html: html)
                self.girisKontrol(html: html)
                self.olayView.reloadData()
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
    let headers: HTTPHeaders = [ "X-Requested-With": "XMLHttpRequest",
                                 "Accept-Language": "tr-TR,tr;q=0.9,en-US;q=0.8,en;q=0.7,ru;q=0.6",
                                 "Accept-Encoding": "gzip, deflate, br"]
    func siteyeBaglan() -> Void {
        self.basliklar = [String]()
        self.entrySayisi = [String]()
        self.linkler = [String]()
        self.aktifSayfa = "1"
        self.sayfa = 2
        Alamofire.request(gundemLink, method: .get, headers: self.headers).responseString {
            response in
            print("\(response.result.isSuccess)")
            if let html = response.result.value{
                self.sayfaSayisiGetir(html: html)
                self.baslikentrysayisiGetir(html: html)
                self.baslikGetir(html: html)
                self.baslikLink(html: html)
                self.girisKontrol(html: html)
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
        self.olayView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + (0.5)) {
            /*            if self.girisKontrolu.isEmpty{
             self.tabBarController!.tabBar.items![2].isEnabled = false
             }
             else{
             self.navigationItem.rightBarButtonItem = nil
             self.tabBarController!.tabBar.items![2].isEnabled = true
             }*/
        }
        
    }
    
    func baslikentrysayisiGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for entrySayisi in doc.css("ul[class^=topic-list] li a"){
                let entryNo = entrySayisi.at_css("small")
                if entryNo?.content == nil{
                    self.entrySayisi.append("")
                }else{
                    self.entrySayisi.append((entryNo?.content)!)
                    
                }
                self.olayView.reloadData()
            }
        }
    }
    
    
    func baslikGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("ul[class^=topic-list] li a"){
                var small = basliklar.at_css("small")
                small?.content = ""
                self.basliklar.append(basliklar.text!)
            }
            self.olayView.reloadData()
        }
    }
    
    func baslikLink(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("ul[class^=topic-list] li a"){
                let link = basliklar["href"]
                print(linkler)
                linkler.append(link!)
            }
        }
    }
    
    func girisKontrol(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("li[class^=buddy mobile-only] a"){
                girisKontrolu = basliklar["href"]!
                print(girisKontrolu)
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
                print(simdiki!)
                print(toplam!)
            }
        }
    }
    
    

}

class olayViewCell: UITableViewCell{
    
    
    @IBOutlet weak var baslikLabel: UILabel!
    
    @IBOutlet weak var entrySayiLabel: UILabel!
    
    
    
}
