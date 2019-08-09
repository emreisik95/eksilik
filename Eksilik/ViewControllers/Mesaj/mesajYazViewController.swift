//
//  mesajYazViewController.swift
//  Eksilik
//
//  Created by Emre Işık on 20.04.2019.
//  Copyright © 2019 Emre Isik. All rights reserved.
//

import UIKit
import Alamofire
import Kanna
import Toast_Swift

class mesajYazViewController: UIViewController, UITextViewDelegate {
    
    var yazarAdi = ""
    var mesajIcerik = ""
    var gonderLink = ""
    var cevap = false
    var Reply = "true"
    var mesajId = ""
    var token = ""
    let headers: HTTPHeaders = [ "X-Requested-With": "XMLHttpRequest"]
    var baslikLinki = ""
    var mesajAdi = ""
    let font = UserDefaults.standard.string(forKey: "secilenFont")

    
    @IBOutlet weak var mesajYaz: UITextView!
    
    @IBOutlet weak var kimeField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.installBlurEffect()
        siteyeBaglan()
        self.navigationController?.navigationBar.installBlurEffect()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "gönder", style: .done, target: self, action: #selector(gonder))
        navigationController?.navigationBar.tintColor = Theme.titleColor!
        let entryToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        entryToolbar.barStyle = Theme.barStyle!
        entryToolbar.tintColor = Theme.userColor
        UIBarButtonItem().setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "Helvetica", size: 12.0)!], for: .normal)
        entryToolbar.items = [
            UIBarButtonItem(title: "(bkz:)", style: .plain, target: self, action: #selector(bkz)),
            UIBarButtonItem(title: "hede", style: .plain, target: self, action: #selector(hede)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "*", style: .plain, target: self, action: #selector(gizlihede)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "-spoiler-", style: .plain, target: self, action: #selector(spoiler)),
            UIBarButtonItem(title: "http://", style: .plain, target: self, action: #selector(link))]
        entryToolbar.sizeToFit()
        mesajYaz.inputAccessoryView = entryToolbar
        kimeField.placeholder = "kime?"
        kimeField.text = yazarAdi
        kimeField.backgroundColor = Theme.backgroundColor
        kimeField.layer.borderColor = Theme.userColor?.cgColor
        kimeField.layer.borderWidth = 1
        kimeField.textColor = Theme.labelColor
        kimeField.layer.cornerRadius = 8
        mesajYaz.layer.cornerRadius = 6
        mesajYaz.layer.borderColor = Theme.userColor?.cgColor
        mesajYaz.layer.borderWidth = 1
        mesajYaz.backgroundColor = Theme.backgroundColor
        mesajYaz.delegate = self
        mesajYaz.textColor = Theme.labelColor!
        mesajYaz.text = mesajAdi
        view.backgroundColor = Theme.backgroundColor!
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        let nvHeight = navigationController?.navigationBar.frame.height
        let stHeight = UIApplication.shared.statusBarFrame.height
        mesajYaz.frame = CGRect(x: 20, y: nvHeight! + stHeight + 60, width: UIScreen.main.bounds.width-40, height: UIScreen.main.bounds.height/4.5)
    }
    
    @objc func bkz() {
        let alert = UIAlertController(title: "(bkz:) ekle", message: "neye bkz verilsin?", preferredStyle: .alert)
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "hede"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "ekle", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            self.mesajYaz.text = self.mesajYaz.text + "(bkz: \(textField!.text!))"
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
            self.mesajYaz.text = self.mesajYaz.text + "`\(textField!.text!)`"
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
            self.mesajYaz.text = self.mesajYaz.text + "`:\(textField!.text!)`"
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
            self.mesajYaz.text = self.mesajYaz.text + "--- `spoiler` ---\n\(textField!.text!)\n--- `spoiler` ---"
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
            self.mesajYaz.text = self.mesajYaz.text + "\(textField!.text!)"
        }))
        alert.addAction(UIAlertAction(title: "vazgeç", style: .cancel, handler: { (UIAlertAction) in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func siteyeBaglan() -> Void {
        baslikLinki = baslikLinki.replacingOccurrences(of: "https://eksisozluk.com", with: "")
        Alamofire.request("https://eksisozluk.com\(baslikLinki)").responseString {
            response in
            print("\(response.result.isSuccess)")
            if let html = response.result.value{
                self.requestToken(html: html)
                self.baslikrequestToken(html: html)
                CustomLoader.instance.hideLoaderView()
            }
            if response.result.isSuccess == false{
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    let alert = UIAlertController(title: "sayfa gelmedi", message: "ama her an burda olabilir, gerçi olmayabilir de", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "tamam", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
            }
            else if response.result.isSuccess == true{
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
    var ajaxToken = ""
    func baslikrequestToken(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("form[id^=message-send-form]"){
                let tok = basliklar.at_css("input[name^=__RequestVerificationToken]")
                ajaxToken = tok!["value"]!
                print(basliklar.text)
                print(ajaxToken)
            }
        }
    }

    
    @objc func gonder(){
        if mesajYaz.text.count < 1{
        self.view.makeToast("bi' şeyler yazmadan gönderemem ki", duration: 3.0, position: .top)
        }else{
            if cevap == true{
                mesajId = baslikLinki
                mesajId = mesajId.replacingOccurrences(of: "/mesaj/", with: "")
                let parameters: Parameters = [
                    "Message": "\(mesajYaz.text!)",
                    "IsReply": "\(Reply)",
                    "ThreadId": "\(mesajId)",
                    "__RequestVerificationToken": "\(token)",
                    "To": "\(yazarAdi)"]
                
                CustomLoader.instance.showLoaderView()
                DispatchQueue.main.async {
                    Alamofire.request("https://eksisozluk.com/mesaj/yolla",method: .post, parameters: parameters, headers: self.headers).responseString { response in
                        if response.response?.statusCode == 404{
                            CustomLoader.instance.hideLoaderView()
                            let alert = UIAlertController(title: "hata", message: "böyle mesaj olmaz olsun", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "üff tamam", style: .cancel, handler: nil))
                            self.present(alert, animated: true)
                        }else if response.result.isSuccess{
                            CustomLoader.instance.hideLoaderView()
                            self.view.endEditing(true)
                            self.navigationController?.popViewController(animated: true)
                        }else{
                            let alert = UIAlertController(title: "hata", message: "bir şeyler oldu ama anlamadım. \nhata kodu: \(String(describing: response.response?.statusCode))", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "peki tamam", style: .cancel, handler: nil))
                            self.present(alert, animated: true)
                            
                        }
                    }
                }
            }else{
                let parameters: Parameters = [
                    "__RequestVerificationToken": "\(ajaxToken)",
                    "To": "\(yazarAdi)",
                    "Message": "\(mesajYaz.text!)"]
                
                CustomLoader.instance.showLoaderView()
                DispatchQueue.main.async {
                    Alamofire.request("https://eksisozluk.com/mesaj/sendajax",method: .post, parameters: parameters, headers: self.headers).responseString { response in
                        print(response.response.debugDescription)
                        print(response.response?.statusCode)
                        if response.response?.statusCode == 404{
                            CustomLoader.instance.hideLoaderView()
                            let alert = UIAlertController(title: "hata", message: "böyle mesaj olmaz olsun", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "üff tamam", style: .cancel, handler: nil))
                            self.present(alert, animated: true)
                        }else if response.result.isSuccess{
                            CustomLoader.instance.hideLoaderView()
                            self.view.endEditing(true)
                            self.navigationController?.popViewController(animated: true)
                        }else{
                            let alert = UIAlertController(title: "hata", message: "bir şeyler oldu ama anlamadım. \nhata kodu: \(String(describing: response.response?.statusCode))", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "peki tamam", style: .cancel, handler: nil))
                            self.present(alert, animated: true)
                            
                        }
                    }
                }
            }
        }
    }

}

