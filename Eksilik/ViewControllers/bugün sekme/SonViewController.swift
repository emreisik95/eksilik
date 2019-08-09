import UIKit
import Alamofire
import Kanna


class SonViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var puntosecim = 15
    var basliklar = [String]()
    var entrySayisi = [String]()
    var linkler = [String]()
    var seciliLink = ""
    var baslik = ""
    var girisKontrolu = String()
    var gundemLink = "https://eksisozluk.com/basliklar/son"
    var dahadaLink = ""
    var sayfaSayisi = "5"
    var aktifSayfa = "2"
    var sayfa: Int = 2
    let status = UserDefaults.standard.bool(forKey: "giris")
    let font = UserDefaults.standard.string(forKey: "secilenFont")

    @IBOutlet var caylakView: UITableView!
    
    var refreshView: RefreshView!
    
    var tableViewRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = .clear
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CustomLoader.instance.showLoaderView()
        puntosecim = UserDefaults.standard.integer(forKey: "secilenPunto")
        self.title =  "son"
        prepareUI()
        self.navigationController?.navigationBar.barStyle = Theme.barStyle!
        self.navigationController?.navigationBar.barTintColor = Theme.navigationBarColor
        caylakView.separatorStyle = .singleLine
        caylakView.separatorColor = Theme.separatorColor
        caylakView.delegate = self
        caylakView.dataSource = self
        caylakView.backgroundColor = Theme.backgroundColor
        caylakView.tableFooterView = UIView()
        siteyeBaglan()
        self.view.backgroundColor = Theme.backgroundColor
        tabBarController?.tabBar.installBlurEffect()
        self.navigationController?.navigationBar.installBlurEffect()

    }
    
    private func loadData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(20)) {
            self.caylakView.reloadData()
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
        caylakView.refreshControl = tableViewRefreshControl
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
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return basliklar.count
    }
    
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CaylakViewCell
        if indexPath.row % 2 == 0{
            cell.backgroundColor = Theme.cellFirstColor
        }else{
            cell.backgroundColor = Theme.cellSecondColor
        }
        let bgColorView = UIView()
        bgColorView.backgroundColor = Theme.backgroundColor
        cell.selectedBackgroundView = bgColorView
        cell.caylakEntrySayisi.text = entrySayisi[indexPath.row]
        cell.caylakEntrySayisi.font = UIFont(name: font!, size: CGFloat(puntosecim))
        cell.caylakEntrySayisi.textColor = Theme.entrySayiColor
        cell.caylakBaslik.text = basliklar[indexPath.row]
        cell.caylakBaslik.font = UIFont(name: font!, size: CGFloat(puntosecim))
        cell.caylakBaslik.textColor = Theme.labelColor
        return cell
    }
    
    func basliklariGetir() -> Void {
        Alamofire.request(dahadaLink).responseString {
            response in
            if let html = response.result.value{
                self.sayfaSayisiGetir(html: html)
                self.baslikentrysayisiGetir(html: html)
                self.baslikGetir(html: html)
                self.baslikLink(html: html)
                self.girisKontrol(html: html)
                self.caylakView.reloadData()
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
            if let html = response.result.value{
                self.sayfaSayisiGetir(html: html)
                self.baslikentrysayisiGetir(html: html)
                self.baslikGetir(html: html)
                self.baslikLink(html: html)
                self.girisKontrol(html: html)
                if self.status == true{
                    self.olayKontrol(html: html)
                    self.mesajKontrol(html: html)
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
        self.caylakView.reloadData()
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
                self.caylakView.reloadData()
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
            self.caylakView.reloadData()
        }
    }
    
    func baslikLink(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("ul[class^=topic-list] li a"){
                let link = basliklar["href"]
                linkler.append(link!)
            }
        }
    }
    
    func girisKontrol(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("li[class^=buddy mobile-only] a"){
                girisKontrolu = basliklar["href"]!
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
    
    
}


class CaylakViewCell: UITableViewCell{

    @IBOutlet var caylakEntrySayisi: UILabel!
    @IBOutlet var caylakBaslik: UILabel!
    
}

