//
//  EntryYazViewController.swift
//  Eksilik
//
//  Created by Emre Işık on 18.02.2019.
//  Copyright © 2019 Emre Isik. All rights reserved.
//

import UIKit
import Alamofire
import Kanna
import GrowingTextView

class EntryYazViewController: UIViewController, GrowingTextViewDelegate {
    var token = ""
    var returnURL = ""
    var Title = ""
    var Id = ""
    var inputTime = ""
    var baslikLinki = ""
    var seciliLink = ""
    
    @IBOutlet weak var baslikLabel: UILabel!
    let headers: HTTPHeaders = [ "X-Requested-With": "XMLHttpRequest"]
    let font = UserDefaults.standard.string(forKey: "secilenFont")
    let entryGir = GrowingTextView()

    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController!.tabBar.layer.zPosition = -1
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController!.tabBar.layer.zPosition = 0
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print(baslikLinki)
        tabBarController?.tabBar.installBlurEffect()
        self.navigationController?.navigationBar.installBlurEffect()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "gönder", style: .done, target: self, action: #selector(gonder))
        self.navigationItem.rightBarButtonItem?.tintColor = Theme.userColor!
        let entryToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        entryToolbar.barStyle = Theme.barStyle!
        entryToolbar.tintColor = Theme.userColor
        UIBarButtonItem().setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: font!, size: 12.0)!], for: .normal)
        entryToolbar.items = [
            UIBarButtonItem(title: "(bkz:)", style: .plain, target: self, action: #selector(bkz)),
            UIBarButtonItem(title: "hede", style: .plain, target: self, action: #selector(hede)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "*", style: .plain, target: self, action: #selector(gizlihede)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "-spoiler-", style: .plain, target: self, action: #selector(spoiler)),
            UIBarButtonItem(title: "http://", style: .plain, target: self, action: #selector(link))]
        entryToolbar.sizeToFit()
        entryGir.inputAccessoryView = entryToolbar
        siteyeBaglan()
        entryGir.layer.cornerRadius = 20
        entryGir.layer.borderColor = Theme.userColor?.cgColor
        entryGir.layer.borderWidth = 0.5
        entryGir.font = .systemFont(ofSize: 16)
        let blurView = UIVisualEffectView()
        blurView.frame = view.frame
        blurView.effect = Theme.blurEffect
        view.backgroundColor = Theme.backgroundColor
        entryGir.backgroundColor = Theme.backgroundColor
        entryGir.contentInset = UIEdgeInsets(top: 15, left: 5, bottom: 0, right: 5)
        entryGir.textColor = Theme.labelColor
        entryGir.delegate = self
        let nvHeight = navigationController?.navigationBar.frame.height
        let stHeight = UIApplication.shared.statusBarFrame.height
        entryGir.frame = CGRect(x: 20, y: nvHeight! + stHeight + 10, width: UIScreen.main.bounds.width-40, height: UIScreen.main.bounds.height-120)
        self.view.addSubview(entryGir)

  }

    func textViewDidBeginEditing(_ textView: UITextView) {
        let nvHeight = navigationController?.navigationBar.frame.height
        let stHeight = UIApplication.shared.statusBarFrame.height
        entryGir.frame = CGRect(x: 20, y: nvHeight! + stHeight + 10, width: UIScreen.main.bounds.width-40, height: UIScreen.main.bounds.height/2.5)
    }
    
    
    @objc func bkz() {
        let alert = UIAlertController(title: "(bkz:) ekle", message: "neye bkz verilsin?", preferredStyle: .alert)
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "hede"
        }
        
        alert.addAction(UIAlertAction(title: "ekle", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            self.entryGir.text = self.entryGir.text + "(bkz: \(textField!.text!))"
        }))
        alert.addAction(UIAlertAction(title: "vazgeç", style: .cancel, handler: { (UIAlertAction) in
        }))
        alert.view.backgroundColor = Theme.backgroundColor
        alert.view.tintColor = Theme.userColor
        alert.view.layer.cornerRadius = 25
        alert.view.layer.borderColor = Theme.userColor?.cgColor
        alert.view.layer.borderWidth = 0
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    @objc func hede() {
        let alert = UIAlertController(title: "hede ekle", message: "hangi başlık için link oluşturulacak?", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "hede"
        }
        alert.addAction(UIAlertAction(title: "ekle", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            self.entryGir.text = self.entryGir.text + "`\(textField!.text!)`"
        }))
        alert.addAction(UIAlertAction(title: "vazgeç", style: .cancel, handler: { (UIAlertAction) in
        }))
        alert.view.backgroundColor = Theme.backgroundColor
        alert.view.tintColor = Theme.userColor
        alert.view.layer.cornerRadius = 25
        alert.view.layer.borderColor = Theme.userColor?.cgColor
        alert.view.layer.borderWidth = 0
        self.present(alert, animated: true, completion: nil)
    }
    @objc func gizlihede() {
        let alert = UIAlertController(title: "gizli bkz ekle", message: "yıldız içinde ne görünecek?", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "hede"
        }
        alert.addAction(UIAlertAction(title: "ekle", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            self.entryGir.text = self.entryGir.text + "`:\(textField!.text!)`"
        }))
        alert.addAction(UIAlertAction(title: "vazgeç", style: .cancel, handler: { (UIAlertAction) in
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    @objc func spoiler() {
               let alert = UIAlertController(title: "spoiler ekle", message: "şpoyler şeysi arasına ne yazılacak?", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "hede"
        }
        alert.addAction(UIAlertAction(title: "ekle", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            self.entryGir.text = self.entryGir.text + "--- `spoiler` ---\n\(textField!.text!)\n--- `spoiler` ---"
        }))
        alert.addAction(UIAlertAction(title: "vazgeç", style: .cancel, handler: { (UIAlertAction) in
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    @objc func link() {
        let alert = UIAlertController(title: "link ekle", message: "hangi adrese gidecek?", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = "http://"
        }
        alert.addAction(UIAlertAction(title: "ekle", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            self.entryGir.text = self.entryGir.text + "\(textField!.text!)"
        }))
        alert.addAction(UIAlertAction(title: "vazgeç", style: .cancel, handler: { (UIAlertAction) in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func vazgectim(_ sender: Any) {
        if  entryGir.text == "" {
            self.view.endEditing(true)
            navigationController?.popViewController(animated: true)
        }
        else if entryGir.text != "" {
            let alert = UIAlertController(title: "emin misiniz?", message: "yazdığınız şeyler silinecek", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "eminim", style: .default, handler: { (UIAlertAction) in
                self.navigationController?.popViewController(animated: true)
                self.view.endEditing(true)
            }))
            alert.addAction(UIAlertAction(title: "vazgeçtim", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    

    @IBAction func gonderButton(_ sender: Any) {
        gonder()
        self.view.endEditing(true)
        }
    
   @objc func gonder() {
    if entryGir.text.count < 1{
        let alert = UIAlertController(title: "hata", message: "entry'niz en az bir tuş basımından ibaret olmalıdır.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "üff tamam", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }else{
        let parameters: Parameters = [
            "Content": "\(entryGir.text!)",
            "Title": "\(Title)",
            "ReturnUrl": "\(returnURL)",
            "Id": "\(Id)",
            "__RequestVerificationToken": "\(token)"
            
        ]
        CustomLoader.instance.showLoaderView()
        DispatchQueue.main.async {
            Alamofire.request("https://eksisozluk.com/entry/ekle",method: .post, parameters: parameters, headers: self.headers).responseString { response in
                if response.response?.statusCode == 404{
                    CustomLoader.instance.hideLoaderView()
                    let alert = UIAlertController(title: "hata", message: "böyle bir entry daha önce girilmiş.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "üff tamam", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }else if response.result.isSuccess{
                    print(response.response?.statusCode)
                    CustomLoader.instance.hideLoaderView()
                    self.view.endEditing(true)
                    self.seciliLink = (response.response?.url!.absoluteString)!
                    self.seciliLink = self.seciliLink.replacingOccurrences(of: "https://eksisozluk.com/", with: "")
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "entryGoruntule") as! EntryViewController
                    viewController.baslikLinki = "\(self.seciliLink)"
                    self.navigationController?.popViewController(animated: true)
                    self.navigationController?.pushViewController(viewController, animated: true)
                }else{
                    let alert = UIAlertController(title: "hata", message: "bir şeyler oldu ama anlamadım. \nhata kodu: \(String(describing: response.response?.statusCode))", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "peki tamam", style: .cancel, handler: nil))
                    self.present(alert, animated: true)

                }
        }
    }
    }
    }
    
    func siteyeBaglan() -> Void {
        baslikLinki = baslikLinki.replacingOccurrences(of: "https://eksisozluk.com", with: "")
        Alamofire.request("https://eksisozluk.com/\(baslikLinki)").responseString {
            response in
            if let html = response.result.value{
                self.requestToken(html: html)
                self.Id(html: html)
                self.returnUrl(html: html)
                self.inputStartTime(html: html)
                self.title(html: html)
            }
            if response.result.isSuccess == false{
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    let alert = UIAlertController(title: "sayfa gelmedi", message: "ama her an burda olabilir, gerçi olmayabilir de", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "tamam", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
            }
            else if response.result.isSuccess == true{
                CustomLoader.instance.hideLoaderView()
            }
        }
    }
    
    
    func requestToken(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("input[name^=__RequestVerificationToken]"){
                token = basliklar["value"]!
                print(token)
            }
        }
    }
    func Id(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("input[name^=Id]"){
                self.Id = basliklar["value"]!
            }
        }
    }
    func returnUrl(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("input[name^=ReturnUrl]"){
                self.returnURL = basliklar["value"]!
            }
        }
    }
    func inputStartTime(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("input[name^=InputStartTime]"){
                inputTime = basliklar["value"]!
            }
        }
    }
    func title(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("input[name^=Title]"){
                Title = basliklar["value"]!
                let tlabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
                tlabel.text = Title
                tlabel.textColor = Theme.titleColor
                tlabel.textAlignment = .center;
                tlabel.lineBreakMode = .byWordWrapping
                tlabel.numberOfLines = 2
                tlabel.adjustsFontSizeToFitWidth = true
                self.navigationItem.titleView = tlabel
            }
        }
    }

}
