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
import InputBarAccessoryView

class mesajIcerikViewController: UIViewController, UITextViewDelegate,UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate, InputBarAccessoryViewDelegate, UITextFieldDelegate{

    @IBOutlet weak var mesajView: UITableView!
    
    var mesajlar = [NSAttributedString]()
    var tarihler = [String]()
    var gelen = [Bool]()
    var asilLink = ""
    var icerikLink = ""
    var baslik = ""
    var token = ""
    var cevap = true
    var puntosecim = UserDefaults.standard.integer(forKey: "secilenPunto")
    let font = UserDefaults.standard.string(forKey: "secilenFont")

    override func viewWillAppear(_ animated: Bool) {
        CustomLoader.instance.showLoaderView()
        siteyeBaglan()
        prepareUI()
    }
    
    public let inputBar = InputBarAccessoryView()
    
    override var inputAccessoryView: UIView? {
        return inputBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputBar.isHidden = false
        inputBar.delegate = self
        inputBar.backgroundColor = Theme.backgroundColor
        inputBar.inputTextView.delegate = self
        inputBar.inputTextView.backgroundColor = Theme.backgroundColor
        inputBar.inputTextView.textColor = Theme.labelColor
        inputBar.sendButton.setTitle("yolla", for: .normal)
        inputBar.sendButton.backgroundColor = Theme.backgroundColor
        inputBar.sendButton.setTitleColor(Theme.userColor, for: .normal)
        inputBar.sendButton.activityViewColor = Theme.userColor
        inputBar.backgroundView.backgroundColor = Theme.backgroundColor
        inputBar.inputTextView.placeholder = "mesajınızı yazın..."
        let bkzButton = InputBarButtonItem()
        bkzButton.setSize(CGSize(width: 36, height: 36), animated: false)
        bkzButton.setImage(#imageLiteral(resourceName: "ekşilik logosu").withRenderingMode(.alwaysTemplate), for: .normal)
        bkzButton.imageView?.contentMode = .scaleAspectFit
        bkzButton.tintColor = Theme.userColor
        bkzButton.addTarget(self, action: #selector(bkzBtn), for: .touchUpInside)
        bkzButton.setTitleColor(Theme.userColor, for: .normal)
        inputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        inputBar.setStackViewItems([bkzButton], forStack: .left, animated: true)
        tabBarController?.tabBar.installBlurEffect()
        self.navigationController?.navigationBar.tintColor = Theme.titleColor
        self.navigationController?.navigationBar.installBlurEffect()
        CustomLoader.instance.showLoaderView()
        self.navigationItem.title = self.baslik
        mesajView.delegate = self
        mesajView.dataSource = self
        mesajView.backgroundColor = Theme.backgroundColor!
        mesajView.separatorStyle = .none
        mesajView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: inputBar.frame.height + 80, right: 0)
        self.view.backgroundColor = Theme.backgroundColor!
        self.navigationItem.leftBarButtonItem?.tintColor = Theme.titleColor
        self.navigationItem.rightBarButtonItem = nil
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(biri))
        self.navigationController?.navigationBar.addGestureRecognizer(tapGestureRecognizer)
        prepareUI()
        // Do any additional setup after loading the view.
    }
    
    @objc func biri(){
        let vc =
            self.storyboard?.instantiateViewController(withIdentifier:
                "suserProfile") as! SuserViewController
        vc.biriLink = "biri/\(self.baslik.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func bkzBtn(){
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "(bkz:)", style: .default, handler: { (UIAlertAction) in
            self.bkz()
        }))
        alert.addAction(UIAlertAction(title: "hede", style: .default, handler: { (UIAlertAction) in
            self.hede()
        }))
        alert.addAction(UIAlertAction(title: "*", style: .default, handler: { (UIAlertAction) in
            self.yildiz()
        }))
        alert.addAction(UIAlertAction(title: "-spoiler-", style: .default, handler: { (UIAlertAction) in
            self.spoiler()
        }))
        alert.addAction(UIAlertAction(title: "http://", style: .default, handler: { (UIAlertAction) in
            self.http()
        }))
        alert.addAction(UIAlertAction(title: "vazgeç", style: .cancel, handler: { (UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }))
        alert.view.tintColor = Theme.userColor
        alert.view.backgroundColor = Theme.backgroundColor
        self.present(alert, animated: true)
    }
    
    func bkz() {
        let alert = UIAlertController(title: "(bkz:) ekle", message: "neye bkz verilsin?", preferredStyle: .alert)
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "hede"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "ekle", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            self.inputBar.inputTextView.text = self.inputBar.inputTextView.text + "(bkz: \(textField!.text!))"
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
    func hede() {
        let alert = UIAlertController(title: "hede ekle", message: "hangi başlık için link oluşturulacak?", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "hede"
        }
        alert.addAction(UIAlertAction(title: "ekle", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            self.inputBar.inputTextView.text = self.inputBar.inputTextView.text + "`\(textField!.text!)`"
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
    func yildiz() {
    let alert = UIAlertController(title: "gizli bkz ekle", message: "yıldız içinde ne görünecek?", preferredStyle: .alert)
    alert.addTextField { (textField) in
    textField.placeholder = "hede"
    }
    alert.addAction(UIAlertAction(title: "ekle", style: .default, handler: { [weak alert] (_) in
    let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
    self.inputBar.inputTextView.text = self.inputBar.inputTextView.text + "`:\(textField!.text!)`"
    }))
    alert.addAction(UIAlertAction(title: "vazgeç", style: .cancel, handler: { (UIAlertAction) in
    }))
    
    self.present(alert, animated: true, completion: nil)
    
    }
    func spoiler() {
        let alert = UIAlertController(title: "spoiler ekle", message: "şpoyler şeysi arasına ne yazılacak?", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "hede"
        }
        alert.addAction(UIAlertAction(title: "ekle", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            self.inputBar.inputTextView.text = self.inputBar.inputTextView.text + "--- `spoiler` ---\n\(textField!.text!)\n--- `spoiler` ---"
        }))
        alert.addAction(UIAlertAction(title: "vazgeç", style: .cancel, handler: { (UIAlertAction) in
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    func http() {
        let alert = UIAlertController(title: "link ekle", message: "hangi adrese gidecek?", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = "http://"
        }
        alert.addAction(UIAlertAction(title: "ekle", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            self.inputBar.inputTextView.text = self.inputBar.inputTextView.text + "\(textField!.text!)"
        }))
        alert.addAction(UIAlertAction(title: "vazgeç", style: .cancel, handler: { (UIAlertAction) in
        }))
        self.present(alert, animated: true, completion: nil)
    }

    
    func textViewDidBeginEditing(_ textView: UITextView) {
        mesajView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: UIScreen.main.bounds.height/2, right: 0)
        self.scrollToBottom()
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        gonder()
        inputBar.inputTextView.endEditing(true)
        inputBar.inputTextView.text.removeAll()
        inputBar.sendButton.startAnimating()
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
    @objc func gonder(){
        if inputBar.inputTextView.text.count < 1{
            self.view.makeToast("bi' şeyler yazmadan gönderemem ki", duration: 3.0, position: .top)
        }else{
            if cevap == true{
                var mesajId = self.icerikLink
                mesajId = mesajId.replacingOccurrences(of: "/mesaj/", with: "")
                let parameters: Parameters = [
                    "Message": "\(inputBar.inputTextView.text!)",
                    "IsReply": "\(cevap)",
                    "ThreadId": "\(mesajId)",
                    "__RequestVerificationToken": "\(token)",
                    "To": "\(self.baslik)"]
                
                DispatchQueue.main.async {
                    Alamofire.request("https://eksisozluk.com/mesaj/yolla",method: .post, parameters: parameters, headers: self.headers).responseString { response in
                        if response.response?.statusCode == 404{
                            CustomLoader.instance.hideLoaderView()
                            let alert = UIAlertController(title: "hata", message: "böyle mesaj olmaz olsun", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "üff tamam", style: .cancel, handler: nil))
                            self.present(alert, animated: true)
                        }else if response.result.isSuccess{
                            self.inputBar.sendButton.stopAnimating()
                            self.view.endEditing(true)
                            self.siteyeBaglan()
                            self.mesajView.reloadData()
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
                    "To": "\(self.baslik)",
                    "Message": "\(inputBar.inputTextView.text!)"]
                
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
            cell.tarihLabel.textColor = .darkGray
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
            cell.tarihLabel.textColor = .darkGray
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
                self.requestToken(html: html)
                self.baslikrequestToken(html: html)
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
                user.append("<style>body{ font-size:\(puntosecim)px; font-family:\(font!)} mark{background-color:#616161;}a{text-decoration:none}</style>")
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
