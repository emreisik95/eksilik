//
//  AraViewController.swift
//  Eksilik
//
//  Created by Emre Işık on 28.02.2019.
//  Copyright © 2019 Emre Isik. All rights reserved.
//

import UIKit
import Alamofire
import Kanna
import SwiftyJSON

class AraViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate{
    
    var kanalAdi = [String]()
    var yonlendirmeLinki = [String]()
    var baslik = ""
    var link = ""
    let headers: HTTPHeaders = [ "X-Requested-With": "XMLHttpRequest",
                                 "Accept-Language": "tr-TR,tr;q=0.9,en-US;q=0.8,en;q=0.7,ru;q=0.6",
                                 "Accept-Encoding": "gzip, deflate, br"]
    var filteredBaslikTableData = [String]()
    var filteredSuserTableData = [String]()
    var basliklar = [String]()
    var suserlar = [String]()
    var resultSearchController = UISearchController()
    var secim = false
    var puntosecim = 15

    @IBOutlet var kanaltableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CustomLoader.instance.showLoaderView()
        puntosecim = UserDefaults.standard.integer(forKey: "secilenPunto")
        tabBarController?.tabBar.installBlurEffect()
        self.navigationController?.navigationBar.installBlurEffect()
        let adjustForTabbarInsets: UIEdgeInsets = UIEdgeInsets(top:0, left: 0, bottom: self.tabBarController!.tabBar.frame.height, right: 0)
        kanaltableView.contentInset = adjustForTabbarInsets
        kanaltableView.scrollIndicatorInsets = adjustForTabbarInsets
        kanaltableView.delegate = self
        kanaltableView.dataSource = self
        self.navigationController?.navigationBar.barTintColor = Theme.navigationBarColor
        self.navigationController?.navigationBar.barStyle = Theme.barStyle!
        kanaltableView.backgroundColor = Theme.backgroundColor
        self.view.backgroundColor = Theme.backgroundColor
        siteyeBaglan()
        self.navigationController?.navigationItem.rightBarButtonItem?.tintColor = Theme.labelColor
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchBar.barStyle = Theme.barStyle!
            controller.searchBar.tintColor = Theme.entryButton
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            self.definesPresentationContext = true
            controller.hidesNavigationBarDuringPresentation = false
            controller.searchBar.setValue("vazgeç", forKey: "cancelButtonText")
            controller.searchBar.sizeToFit()
            controller.searchBar.placeholder = "başlık, #entry ya da @yazar ara"
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).font = UIFont.systemFont(ofSize: 15)
            controller.searchBar.autocapitalizationType = .none
            controller.searchBar.keyboardAppearance = Theme.keyboardColor!
            controller.searchBar.delegate = self
            self.navigationItem.titleView = controller.searchBar
            self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .search, target: nil, action: nil)
            self.navigationItem.rightBarButtonItem?.tintColor = Theme.titleColor
            return controller
        })()
        kanaltableView.reloadData()
    }    
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
            self.kanaltableView.reloadData()
        }
        kanaltableView.reloadData()
        if resultSearchController.isActive{
            self.navigationItem.rightBarButtonItem = nil
        }else{
            self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .search, target: nil, action: nil)
            self.navigationItem.rightBarButtonItem?.tintColor = Theme.titleColor
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let yazi = resultSearchController.searchBar.text!
        if yazi.contains("#"){
            let vc =
                self.storyboard?.instantiateViewController(withIdentifier:
                    "entryGoruntule") as! EntryViewController
           let entryNo = yazi.replacingOccurrences(of: "#", with: "")
            vc.baslikLinki = "https://eksisozluk.com/entry/\(entryNo)"
            vc.extendedLayoutIncludesOpaqueBars = false
            self.navigationController?.pushViewController(vc, animated: true)
            resultSearchController.isActive = false
        }
        if yazi.contains("@"){
            let vc =
                self.storyboard?.instantiateViewController(withIdentifier:
                    "suserProfile") as! SuserViewController
            let suser = yazi.replacingOccurrences(of: "@", with: "")
            vc.biriLink = "/biri/\(suser)"
            self.navigationController?.pushViewController(vc, animated: true)
            resultSearchController.isActive = false
        }
            let vc =
                self.storyboard?.instantiateViewController(withIdentifier:
                    "entryGoruntule") as! EntryViewController
            let baslik = yazi.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]{} ").inverted)!
            vc.baslikLinki = "https://eksisozluk.com/\(baslik)"
            vc.extendedLayoutIncludesOpaqueBars = false
            self.navigationController?.pushViewController(vc, animated: true)
            resultSearchController.isActive = false
        
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
        }else{
        link = yonlendirmeLinki[indexPath.row]
        baslik = kanalAdi[indexPath.row]
        performSegue(withIdentifier: "kanalGor", sender: nil)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if (resultSearchController.isActive){
        return 2
        }
        return 1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "kanalGor"{
            let entryVC = segue.destination as! FirstViewController
            entryVC.gundemLink = "https://eksisozluk.com\(self.link)"
            entryVC.title = self.baslik
            entryVC.secim = self.secim
        }
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
        return kanalAdi.count
    }
    let font = UserDefaults.standard.string(forKey: "secilenFont")


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (resultSearchController.isActive) {
           if indexPath.section == 0{

            let Baslikcell = tableView.dequeueReusableCell(withIdentifier: "sonuc") as! sonucTableViewCell
            Baslikcell.sonucAdiLabel.text = filteredBaslikTableData[indexPath.row]
            Baslikcell.backgroundColor = Theme.backgroundColor
            Baslikcell.sonucAdiLabel.numberOfLines = 0
            Baslikcell.sonucAdiLabel.lineBreakMode = .byWordWrapping
            Baslikcell.sonucAdiLabel.font = UIFont(name: font ?? "Helvetica-Light", size: CGFloat(puntosecim))
            Baslikcell.sonucAdiLabel.textColor = Theme.labelColor
//            Baslikcell.sonucImage.tintColor = .gray
            if filteredBaslikTableData.count == 0{
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
                label.center = CGPoint(x: 160, y: 285)
                label.textAlignment = .center
                label.text = "I'm a test label"
                Baslikcell.addSubview(label)
            }
                return Baslikcell
            }
            if indexPath.section == 1{
                let kisiCell = tableView.dequeueReusableCell(withIdentifier: "kisisonuc") as! kisisonucTableViewCell
                kisiCell.kisiSonucLabel.text = filteredSuserTableData[indexPath.row]
                kisiCell.kisiSonucLabel.lineBreakMode = .byWordWrapping
                kisiCell.kisiSonucLabel.numberOfLines = 0
                kisiCell.kisiSonucLabel.textColor = Theme.labelColor
                kisiCell.kisiSonucLabel.font = UIFont(name: font ?? "Helvetica-Light", size: CGFloat(puntosecim))
                kisiCell.backgroundColor = Theme.backgroundColor
                return kisiCell
            }
        }
        
    let cell = tableView.dequeueReusableCell(withIdentifier: "kanal") as! kanalTableViewCell
        cell.kanalAdiLabel.text = kanalAdi[indexPath.row]
        cell.kanalAdiLabel.textColor = Theme.entrySayiColor
        cell.kanalAdiLabel.font = UIFont(name: font ?? "Helvetica-Light", size: CGFloat(puntosecim))
        cell.backgroundColor = Theme.backgroundColor
            return cell
    }
    

    func siteyeBaglan() -> Void {

        Alamofire.request("https://eksisozluk.com/kanallar/m").responseString {
            response in
            print("\(response.result.isSuccess)")
            if let html = response.result.value{
                self.kanalGetir(html: html)
            }
            if response.result.isSuccess == false{
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    let alert = UIAlertController(title: "kanallar gelmedi", message: "ama her an burda olabilir, gerçi olmayabilir de", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "tamam", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
            }
            else if response.result.isSuccess == true{
                CustomLoader.instance.hideLoaderView()
            }
        }
        self.kanaltableView.reloadData()
        
    }
    
    func kanalGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("h3 a"){
                let kanalLinki = basliklar["href"]
                self.yonlendirmeLinki.append(kanalLinki!)
                self.kanalAdi.append(basliklar.text!)
            }
            self.kanaltableView.reloadData()
        }
    }


}

class kanalTableViewCell:UITableViewCell{
    
    @IBOutlet var kanalAdiLabel: UILabel!
    
}
class sonucTableViewCell:UITableViewCell{
    
    @IBOutlet var sonucAdiLabel: UILabel!
    
    @IBOutlet weak var sonucImage: UIImageView!
    
}

class kisisonucTableViewCell:UITableViewCell{
    
    @IBOutlet var kisiSonucLabel: UILabel!
    @IBOutlet weak var kisiSonucImage: UIImageView!
    
}
