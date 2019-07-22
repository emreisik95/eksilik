//
//  mesajIcerikViewController.swift
//  Eksilik
//
//  Created by Emre Işık on 19.04.2019.
//  Copyright © 2019 Emre Isik. All rights reserved.
//

import UIKit
import Alamofire
import Kanna
import SafariServices

class mesajIcerikViewController: UIViewController, UITextViewDelegate,UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate{

    @IBOutlet weak var mesajView: UITableView!
    
    var mesajlar = [NSAttributedString]()
    var tarihler = [String]()
    var gelen = [Bool]()
    var asilLink = ""
    var icerikLink = ""
    var baslik = ""
    
    override func viewWillAppear(_ animated: Bool) {
        CustomLoader.instance.showLoaderView()
        siteyeBaglan()
        prepareUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.installBlurEffect()
        self.navigationController?.navigationBar.tintColor = Theme.titleColor
        self.navigationController?.navigationBar.installBlurEffect()
        CustomLoader.instance.showLoaderView()
        self.navigationItem.title = self.baslik
        mesajView.delegate = self
        mesajView.dataSource = self
        mesajView.backgroundColor = Theme.backgroundColor!
        mesajView.separatorStyle = .none
        self.view.backgroundColor = Theme.backgroundColor!
        self.navigationItem.leftBarButtonItem?.tintColor = Theme.titleColor
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(cevapla))
        prepareUI()
        // Do any additional setup after loading the view.
    }
    @objc func cevapla(){
        performSegue(withIdentifier: "mesajAt", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! mesajYazViewController
        vc.baslikLinki = icerikLink
        vc.yazarAdi = baslik
        vc.cevap = true
        vc.Reply = "True"
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let link = URL.absoluteString
        let url = URL
        print(URL)
        if (link.contains("applewebdata://")){
            var url = URLComponents(string: link)!
            url.host = ""
            var asil: String = ""
            asil = url.string!
            self.asilLink = asil.replacingOccurrences(of: "applewebdata://", with: "", options: .literal, range: nil)
            let viewController = storyboard?.instantiateViewController(withIdentifier: "entryGoruntule") as! EntryViewController
            CustomLoader.instance.showLoaderView()
            viewController.baslikLinki = "\(self.asilLink)"
            viewController.extendedLayoutIncludesOpaqueBars = true
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
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return mesajlar.count
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if gelen[indexPath.row] == false{
            let cell = tableView.dequeueReusableCell(withIdentifier: "gelen", for: indexPath) as! gelenCell
            cell.gBG.dropShadow()
            cell.gBG.layer.cornerRadius = 5
            cell.gBG.tintColor = UIColor(red: 255/255, green: 225/255, blue: 225/255, alpha: 1)
            cell.selectionStyle = .none
            cell.gelenImage.image?.withRenderingMode(.alwaysTemplate)
            cell.gelenImage.dropShadow()
            cell.gelenImage.tintColor = UIColor(red: 231/255, green: 231/255, blue: 231/255, alpha: 1)
            cell.gelenLabel.attributedText =  mesajlar[indexPath.row]
            cell.gelenLabel.tintColor = Theme.userColor!
            cell.tarihLabel.text = tarihler[indexPath.row]
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "giden", for: indexPath) as! gidenCell
            cell.gBG.dropShadow()

            cell.gBG.layer.cornerRadius = 5
            cell.gidenImage.image?.withRenderingMode(.alwaysTemplate)
            cell.gidenImage.dropShadow()
            cell.gidenLabel.attributedText = mesajlar[indexPath.row]
            cell.selectionStyle = .none
            cell.gidenLabel.tintColor = Theme.userColor!
            cell.tarihLabel.text = tarihler[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
    let headers: HTTPHeaders = [ "X-Requested-With": "XMLHttpRequest",
                                 "Accept-Language": "tr-TR,tr;q=0.9,en-US;q=0.8,en;q=0.7,ru;q=0.6",
                                 "Accept-Encoding": "gzip, deflate, br"]
    func siteyeBaglan() -> Void {
        self.mesajlar = [NSAttributedString]()
        self.tarihler = [String]()
        self.gelen = [Bool]()
        Alamofire.request("https://eksisozluk.com\(icerikLink)").responseString {
            response in
            print("\(response.result.isSuccess)")
            if let html = response.result.value{
                self.sayfaSayisiGetir(html: html)
                self.mesajGetir(html: html)
                self.mesajLink(html: html)
                self.kullaniciGetir(html: html)
                self.tarihGetir(html: html)
                self.mesajSayisiGetir(html: html)
                self.scrollToBottom()
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
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.mesajlar.count-1, section: 0)
            self.mesajView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            CustomLoader.instance.hideLoaderView()
        }
    }

    
    func mesajGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("div[id^=message-thread] article p"){
                var user = basliklar.toHTML!
                user.append("<style>body{ font-size:15px; font-family:Helvetica, sans-serif} mark{background-color:#616161;}a{text-decoration:none}</style>")
                self.mesajlar.append(user.html2AttributedString!)
                if basliklar.parent?.className == "incoming"{
                    self.gelen.append(false)
                }else{
                    self.gelen.append(true)
                }
                    }
            self.mesajView.reloadData()
        }
    }
    
    func tarihGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("div[id^=message-thread] article footer time"){
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
            //    self.kullaniciAdi.append(basliklar.text!)
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
    
    func sayfaSayisiGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for sayfa in doc.css("div[class^=pager]"){
                let simdiki = sayfa["data-currentpage"]
                let toplam = sayfa["data-pagecount"]
                //      self.sayfaSayisi = toplam!
                //      self.aktifSayfa = simdiki!
                print(simdiki!)
                print(toplam!)
            }
        }
    }
    
    
}

class gelenCell : UITableViewCell{
    
    @IBOutlet weak var gBG: UIView!
    
    @IBOutlet weak var gelenLabel: UITextView!
    
    @IBOutlet weak var tarihLabel: UILabel!
    
    @IBOutlet weak var gelenImage: UIImageView!
    
}

class gidenCell : UITableViewCell{
    @IBOutlet weak var tarihLabel: UILabel!
    
    @IBOutlet weak var gidenLabel: UITextView!
    
    @IBOutlet weak var gBG: UIView!
    
    @IBOutlet weak var gidenImage: UIImageView!
}

extension UIView {
    
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1

    }
    
}
