//
//  TakipViewController.swift
//  Eksilik
//
//  Created by Emre Işık on 27.03.2019.
//  Copyright © 2019 Emre Isik. All rights reserved.
//

import UIKit
import Kanna
import Alamofire

class TakipViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var yazarlar = [String]()
    var basliklar = [String]()
    var entrySayisi = [String]()
    var linkler = [String]()
    var takipLink = "https://eksisozluk.com/basliklar/takipentrymobile"
    let font = UserDefaults.standard.string(forKey: "secilenFont")
    var puntosecim = 15

   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return basliklar.count
    }
    
    private var finishedLoadingInitialTableCells = false
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
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
            cell.transform = CGAffineTransform(translationX: 0, y: takipView.rowHeight/2)
            cell.alpha = 0
            
            UIView.animate(withDuration: 0.3, delay: 0.05*Double(indexPath.row), options: [.curveEaseInOut], animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
                cell.alpha = 1
            }, completion: nil)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "takip", for: indexPath) as! TakipViewCell
        if indexPath.row % 2 == 0{
            cell.backgroundColor = Theme.cellFirstColor
        }else{
            cell.backgroundColor = Theme.cellSecondColor
        }
        cell.baslikLabel.text = basliklar[indexPath.row]
        cell.baslikLabel.font = UIFont(name: font!, size: CGFloat(puntosecim))
        cell.baslikLabel.adjustsFontSizeToFitWidth = true
        cell.baslikLabel.textColor = Theme.labelColor
        cell.baslikLabel.lineBreakMode = .byWordWrapping
        cell.yazarLabel.text = yazarlar[indexPath.row] ?? "yazar"
        cell.yazarLabel.font = UIFont(name: font!, size: 13)
        cell.yazarLabel.lineBreakMode = .byWordWrapping
        cell.yazarLabel.textColor = Theme.userColor
        cell.entrySayi.text = entrySayisi[indexPath.row]
        cell.entrySayi.textColor = Theme.tarihColor
        let bgColorView = UIView()
        bgColorView.backgroundColor = Theme.backgroundColor
        cell.selectedBackgroundView = bgColorView
        return cell
    }
    

    @IBOutlet var secenekControl: UISegmentedControl!
    @IBOutlet var takipView: UITableView!
    
    @IBAction func takipSecenek(_ sender: Any) {
        if secenekControl.selectedSegmentIndex == 0{
            CustomLoader.instance.showLoaderView()
            self.takipLink = "https://eksisozluk.com/basliklar/takipentrymobile"
            self.yazarlar = [String]()
            self.basliklar = [String]()
            self.linkler = [String]()
            self.entrySayisi = [String]()
            siteyeBaglan()

        }
        if secenekControl.selectedSegmentIndex == 1{
            CustomLoader.instance.showLoaderView()
            self.takipLink = "https://eksisozluk.com/basliklar/takipfavmobile"
            self.yazarlar = [String]()
            self.basliklar = [String]()
            self.linkler = [String]()
            self.entrySayisi = [String]()
            siteyeBaglan()
        }
    }
    var seciliLink = ""
    var baslik = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.installBlurEffect()
        self.navigationController?.navigationBar.installBlurEffect()

        puntosecim = UserDefaults.standard.integer(forKey: "secilenPunto")
        takipView.dataSource = self
        takipView.delegate = self
        secenekControl.tintColor = Theme.userColor
        takipView.backgroundColor = Theme.backgroundColor
        takipView.separatorStyle = .singleLine
        takipView.separatorColor = Theme.separatorColor
        self.view.backgroundColor = Theme.backgroundColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Theme.titleColor!]
        self.navigationController?.navigationBar.barTintColor = Theme.navigationBarColor
        CustomLoader.instance.showLoaderView()
        siteyeBaglan()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "entryVC"{
            let entryVC = segue.destination as! EntryViewController
            entryVC.baslikLinki = "https://eksisozluk.com/\(self.seciliLink)"
            entryVC.baslik = self.baslik
            entryVC.extendedLayoutIncludesOpaqueBars = false
            
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        seciliLink = linkler[indexPath.row]
        baslik = basliklar[indexPath.row]
        performSegue(withIdentifier: "entryVC", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func siteyeBaglan() -> Void {
    Alamofire.request(takipLink).responseString {
            response in
            if let html = response.result.value{
                self.baslikentrysayisiGetir(html: html)
                self.yazarCek(html: html)
                self.baslikCek(html: html)
                self.olayKontrol(html: html)
                self.mesajKontrol(html: html)
                CustomLoader.instance.hideLoaderView()
                self.takipView.reloadData()
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
    func yazarCek(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("ul[class^=topic-list partial mobile] li a div"){
             yazarlar.append(basliklar.text!)
                self.takipView.reloadData()
            }
        }
    }
    
    func baslikCek(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for baslik in doc.css("ul[class^=topic-list partial mobile] li a"){
                var div = baslik.at_css("div")
                div?.content = ""
                var small = baslik.at_css("small")
                small?.content = ""
                let linkler = baslik["href"]
                self.linkler.append(linkler!)
                let baslikString = baslik.toHTML
                basliklar.append(baslikString!.html2String)
                self.takipView.reloadData()
            }
        }
    }
    
    func baslikentrysayisiGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for entrySayisi in doc.css("ul[class^=topic-list partial mobile] li a"){
                let small = entrySayisi.at_css("small")
                if small?.content == nil{
                    self.entrySayisi.append(" ")
                }else{
                    self.entrySayisi.append((small?.text)!)
                }
            }
            self.takipView.reloadData()
        }
    }

    
}

 class TakipViewCell:UITableViewCell{
    
    @IBOutlet var baslikLabel: UILabel!
    
    @IBOutlet var yazarLabel: UILabel!
    
    @IBOutlet var entrySayi: UILabel!
    
}

