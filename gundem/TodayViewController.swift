//
//  TodayViewController.swift
//  gundem
//
//  Created by Emre Işık on 29.04.2019.
//  Copyright © 2019 Emre Isik. All rights reserved.
//

import UIKit
import NotificationCenter
import Alamofire
import Kanna

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDelegate, UITableViewDataSource {
    
    var basliklar = [String]()
    var entrySayisi = [String]()
    var linkler = [String]()
    var seciliLink = ""
    var baslik = ""
    var girisKontrolu = String()
    
    override func viewWillAppear(_ animated: Bool) {
        siteyeBaglan()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        widgetView.delegate = self
        widgetView.dataSource = self
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    
    func siteyeBaglan(){
        Alamofire.request("https://eksisozluk.com/basliklar/m/populer").responseString {
            response in
            if let html = response.result.value{
                self.baslikGetir(html: html)
            }
            if response.result.isSuccess == false{
                self.basliklar.append("bağlantınızı kontrol edin...")
            }
        }
        self.widgetView.reloadData()
    }

    func baslikGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("ul[class^=topic-list partial mobile] li a"){
                    let entryNo = basliklar.at_css("small")
                    self.entrySayisi.append(entryNo?.text ?? "")
                    var small = basliklar.at_css("small")
                    small?.content = ""
                    self.basliklar.append(basliklar.text!)
                    self.linkler.append(basliklar["href"]!)
            }
            self.widgetView.reloadData()
        }
    }
        
    @IBOutlet weak var widgetView: UITableView!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return basliklar.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! widgetCell
        cell.selectionStyle = .none
        cell.baslikLabel.text = basliklar[indexPath.row]
        cell.baslikLabel.lineBreakMode = .byWordWrapping
        cell.baslikLabel.numberOfLines = 0
        cell.entrySayiLabel.text = entrySayisi[indexPath.row]
        cell.entrySayiLabel.backgroundColor = UIColor.init(red: 102/255, green: 180/255, blue: 63/255, alpha: 1)
        cell.entrySayiLabel.textColor = .white
        cell.entrySayiLabel.layer.cornerRadius = 5
        cell.entrySayiLabel.layer.masksToBounds = true

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = URL(string: "eksilik://")
        {
            self.extensionContext?.open(url, completionHandler: {success in print("called url complete handler: \(success)")})
        }    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        let expanded = activeDisplayMode == .expanded
        preferredContentSize = expanded ? CGSize(width: maxSize.width, height: 330) : maxSize
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        siteyeBaglan()
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}

class widgetCell : UITableViewCell{
    
    @IBOutlet weak var baslikLabel: UILabel!
    
    @IBOutlet weak var entrySayiLabel: UILabel!
    
}
