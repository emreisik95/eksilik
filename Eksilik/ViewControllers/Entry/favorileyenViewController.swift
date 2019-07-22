//
//  favorileyenViewController.swift
//  Eksilik
//
//  Created by Emre Işık on 15.04.2019.
//  Copyright © 2019 Emre Isik. All rights reserved.
//

import UIKit
import Alamofire
import Kanna

class favorileyenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let headers: HTTPHeaders = [ "X-Requested-With": "XMLHttpRequest",
                                 "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1",
                                 "Accept-Language": "tr-TR,tr;q=0.9,en-US;q=0.8,en;q=0.7,ru;q=0.6",
                                 "Accept-Encoding": "gzip, deflate, br"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
        return yazarlar.count
        }else if section == 1{
            return caylaklar.count
        }
        return 0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "suser"{
            let vc = segue.destination as! SuserViewController
            vc.biriLink = seciliLink
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            seciliLink = yazarlinkler[indexPath.row]
            tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "suser", sender: nil)
        }
        if indexPath.section == 1{
            seciliLink = caylaklinkler[indexPath.row]
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "suser", sender: nil)
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "yazar", for: indexPath) as! yazarCell
            cell.yazarAdiLabel.text = yazarlar[indexPath.row]
            if indexPath.row % 2 == 0{
                cell.backgroundColor = Theme.cellFirstColor
            }else{
                cell.backgroundColor = Theme.cellSecondColor
            }
            cell.yazarAdiLabel.textColor = Theme.labelColor!
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "caylak", for: indexPath) as! caylakCell
            cell.caylakAdiLabel.text = caylaklar[indexPath.row]
            if indexPath.row % 2 == 0{
                cell.backgroundColor = Theme.cellFirstColor
            }else{
                cell.backgroundColor = Theme.cellSecondColor
            }
            cell.caylakAdiLabel.textColor = Theme.labelColor!
            return cell
        }
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = Theme.userColor
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "yazarlar"
        }else{
            return "çaylaklar"
        }
    }
    var entryId = String()
    var yazarlar = [String]()
    var caylaklar = [String]()
    var yazarlinkler = [String]()
    var caylaklinkler = [String]()
    var seciliLink = ""

    @IBOutlet weak var favoriView: UITableView!
    
    
    func siteyeBaglan() -> Void {
        let parameters: Parameters = ["entryId": "\(self.entryId)"]
        Alamofire.request("https://eksisozluk.com/entry/favorileyenler",method: .get, parameters: parameters, headers: headers).responseString { response in
            if let html = response.result.value{
                self.yazarGetir(html: html)
            }
        }
    }
    func caylaksiteyeBaglan() -> Void {
        let parameters: Parameters = ["entryid": "#\(self.entryId)"]
        Alamofire.request("https://eksisozluk.com/entry/caylakfavorites",method: .get, parameters: parameters, headers: headers).responseString { response in
            if let html = response.result.value{
                self.caylakGetir(html: html)
            }
        }
        
    }
    
    func yazarGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for entrySayisi in doc.css("ul li"){
                if entrySayisi.text!.contains("çaylak"){
                }else{
                    self.yazarlar.append(entrySayisi.text!)
                    let link = entrySayisi.at_css("a")
                    self.yazarlinkler.append(link!["href"]!)
                }

                //   self.yazarlar.append(entrySayisi["a[target^=_blank]"]!)
                self.favoriView.reloadData()
            }
            
        }
    }
    func caylakGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for entrySayisi in doc.css("ul li"){
                self.caylaklar.append(entrySayisi.text!)
                let link = entrySayisi.at_css("a")
                self.caylaklinkler.append(link!["href"]!)
                self.favoriView.reloadData()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if self.yazarlar.count == 0 {
                self.yazarlar.append("hiç favorileyen yazar yok.")
                self.favoriView.reloadData()
            }
            if self.caylaklar.count == 0{
                self.caylaklar.append("hiç favorileyen çaylak yok.")
                self.favoriView.reloadData()
            }

        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        favoriView.delegate = self
        favoriView.dataSource = self
        favoriView.backgroundColor = Theme.backgroundColor!
        favoriView.tableFooterView = UIView()
        favoriView.separatorColor = Theme.separatorColor!
        self.navigationController?.navigationBar.barStyle = Theme.barStyle!
        self.navigationController?.navigationBar.barTintColor = Theme.navigationBarColor!
        siteyeBaglan()
        caylaksiteyeBaglan()
        self.navigationController?.navigationBar.installBlurEffect()
        navigationItem.title = "favorileyenler"
        tabBarController?.tabBar.installBlurEffect()
        self.navigationController?.navigationBar.installBlurEffect()
    }
    
    
}

class yazarCell: UITableViewCell{
    
    @IBOutlet weak var yazarAdiLabel: UILabel!
    
}

class caylakCell: UITableViewCell{
    
    @IBOutlet weak var caylakAdiLabel: UILabel!
    
}
