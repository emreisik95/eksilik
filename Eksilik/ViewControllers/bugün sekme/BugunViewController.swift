import UIKit
import Alamofire
import Kanna

class BugunViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerPreviewingDelegate{
    
    var viewcim = (Bundle.main.loadNibNamed("arkaplan", owner: self, options: nil)![0]) as! UIView
    
    var tarih = String()
    var bugunBasliklar = [String]()
    var entrySayisi = [String]()
    var linkler = [String]()
    var seciliLink = ""
    var baslik = ""
    var girisKontrolu = String()
    var bugunLink = "https://eksisozluk.com/basliklar/bugun/"
    var dahadaLink = ""
    var sayfaSayisi = "5"
    var aktifSayfa = "2"
    var sayfa: Int = 1
    var array = [String]()
    var barAccessory = UIToolbar()
    var secti = Int()
    let headers: HTTPHeaders = [ "X-Requested-With": "XMLHttpRequest",
                                 "Accept-Language": "tr-TR,tr;q=0.9,en-US;q=0.8,en;q=0.7,ru;q=0.6",
                                 "Accept-Encoding": "gzip, deflate, br"]
    var secim = true
    let status = UserDefaults.standard.bool(forKey: "giris")
    var puntosecim = 15

    var typePickerView: UIPickerView = UIPickerView()
    
    @IBOutlet var bugunView: UITableView!
    
    var refreshView: RefreshView!
    
    var tableViewRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = .clear
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        CustomLoader.instance.showLoaderView()
        self.title = "bugün"
        print(bugunLink)
        puntosecim = UserDefaults.standard.integer(forKey: "secilenPunto")
        prepareUI()
        bugunView.separatorStyle = .singleLine
        bugunView.separatorColor = Theme.separatorColor
        bugunView.backgroundColor = Theme.backgroundColor
        self.view.backgroundColor = Theme.backgroundColor
        bugunView.delegate = self
        bugunView.dataSource = self
        self.navigationController?.navigationBar.barStyle = Theme.barStyle!
        self.navigationController?.navigationBar.barTintColor = Theme.navigationBarColor
        siteyeBaglan()
        tabBarController?.tabBar.installBlurEffect()
        self.navigationController?.navigationBar.installBlurEffect()


    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if traitCollection.forceTouchCapability == .available{
            registerForPreviewing(with: self, sourceView: bugunView)
        }
    }
    
    override var previewActionItems: [UIPreviewActionItem]{
        let pw1 = UIPreviewAction.init(title: "paylaş", style: .default) { (UIPreviewAction, UIViewController) in
            print("puh")
        }
        return [pw1]
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = bugunView.indexPathForRow(at: location), let cell = bugunView.cellForRow(at: indexPath){
            let popVC = storyboard?.instantiateViewController(withIdentifier: "entryGoruntule") as! EntryViewController
            popVC.baslikLinki = linkler[indexPath.row]
            seciliLink = linkler[indexPath.row]
            previewingContext.sourceRect = cell.frame
            let vc = UINavigationController(rootViewController: popVC)
            vc.navigationBar.barStyle = Theme.barStyle!
            vc.navigationBar.barTintColor = Theme.navigationBarColor
            return vc
        }else{
            return nil
        }
    }
    
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        let popVC = storyboard?.instantiateViewController(withIdentifier: "entryGoruntule") as! EntryViewController
        popVC.baslikLinki = seciliLink
        navigationController?.pushViewController(popVC, animated: true)
    }
    

    private func loadData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(20)) {
            self.bugunView.reloadData()
        }
    }
    @objc func refreshTableView() {
        CustomLoader.instance.showLoaderView()
        siteyeBaglan()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.tableViewRefreshControl.endRefreshing()
        }
    }
    
    func prepareUI() {
        // Adding 'tableViewRefreshControl' to tableView
        bugunView.refreshControl = tableViewRefreshControl
        // Getting the nib from bundle
        getRefereshView()
    }
    func getRefereshView() {
        if let objOfRefreshView = Bundle.main.loadNibNamed("RefreshView", owner: self, options: nil)?.first as? RefreshView {
            refreshView = objOfRefreshView
            refreshView.frame = tableViewRefreshControl.frame
            tableViewRefreshControl.addSubview(refreshView)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        seciliLink = linkler[indexPath.row]
        baslik = bugunBasliklar[indexPath.row]
        performSegue(withIdentifier: "entryVc", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private var finishedLoadingInitialTableCells = false
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        if self.aktifSayfa == self.sayfaSayisi{
            
        }else{
            let lastData = self.bugunBasliklar.count - 1
            if indexPath.row == lastData {
                CustomLoader.instance.showLoaderView()
                sayfa = sayfa + 1
                self.dahadaLink = "\(bugunLink)\(sayfa)"
                print(dahadaLink)
                basliklariGetir()
                cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
                UIView.animate(withDuration: 0.3, animations: {
                    cell.layer.transform = CATransform3DMakeScale(1.05,1.05,1)
                },completion: { finished in
                    UIView.animate(withDuration: 0.1, animations: {
                        cell.layer.transform = CATransform3DMakeScale(1,1,1)
                    })
                })
            }
        }
        
        
        var lastInitialDisplayableCell = false
        
        //change flag as soon as last displayable cell is being loaded (which will mean table has initially loaded)
        if bugunBasliklar.count > 0 && !finishedLoadingInitialTableCells {
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
            cell.transform = CGAffineTransform(translationX: 0, y: bugunView.rowHeight/2)
            cell.alpha = 0
            
            UIView.animate(withDuration: 0.3, delay: 0.05*Double(indexPath.row), options: [.curveEaseInOut], animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
                cell.alpha = 1
            }, completion: nil)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "entryVc"{
            let entryVC = segue.destination as! EntryViewController
            entryVC.baslikLinki = "https://eksisozluk.com/\(self.seciliLink)"
            entryVC.baslik = self.baslik
            entryVC.extendedLayoutIncludesOpaqueBars = false
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bugunBasliklar.count
    }
    
    let font = UserDefaults.standard.string(forKey: "secilenFont")

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BugunViewCell
        if indexPath.row % 2 == 0{
            cell.backgroundColor = Theme.cellFirstColor
            let bgColorView = UIView()
            bgColorView.backgroundColor = Theme.cellFirstColor
            cell.selectedBackgroundView = bgColorView
        }else{
            cell.backgroundColor = Theme.cellSecondColor
            let bgColorView = UIView()
            bgColorView.backgroundColor = Theme.cellSecondColor
            cell.selectedBackgroundView = bgColorView
        }
        cell.BugunEntrySayisi.text = entrySayisi[indexPath.row]
        cell.BugunBaslik.font = UIFont(name: font!, size: CGFloat(puntosecim))
        cell.BugunEntrySayisi.textColor = Theme.entrySayiColor
        cell.BugunBaslik.text = bugunBasliklar[indexPath.row]
        cell.BugunEntrySayisi.font = UIFont(name: font!, size: CGFloat(puntosecim))
        cell.BugunBaslik.textColor = Theme.labelColor
        return cell
    }
    
    func basliklariGetir() -> Void {
        Alamofire.request(dahadaLink).responseString {
            response in
            if let html = response.result.value{

                self.girisKontrolu = String()
                self.sayfaSayisiGetir(html: html)
                self.baslikentrysayisiGetir(html: html)
                self.baslikGetir(html: html)
                self.baslikLink(html: html)
                self.girisKontrol(html: html)
                self.bugunView.reloadData()
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
    
    func siteyeBaglan() -> Void {
        Alamofire.request("\(bugunLink)/\(sayfa)", method: .get, headers: self.headers).responseString {
            response in
            if let html = response.result.value{
                self.tarih = String()
                self.bugunBasliklar = [String]()
                self.entrySayisi = [String]()
                self.linkler = [String]()
                self.seciliLink = ""
                self.baslik = ""
                self.girisKontrolu = String()
                self.sayfaSayisiGetir(html: html)
                self.baslikentrysayisiGetir(html: html)
                self.baslikGetir(html: html)
                self.baslikLink(html: html)
                self.girisKontrol(html: html)
                if self.status == true{
                    self.olayKontrol(html: html)
                    self.mesajKontrol(html: html)
                }
                self.bugunView.reloadData()
                if self.bugunBasliklar.count == 0 {
                    self.bugunView.addSubview(self.viewcim)
                    self.bugunView.separatorStyle = .none
                }else{
                    self.bugunView.separatorStyle = .singleLine
                    self.viewcim.removeFromSuperview()
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
    
    func baslikentrysayisiGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for entrySayisi in doc.css("ul[class^=topic-list partial] li a"){
                let entryNo = entrySayisi.at_css("small")
                if entryNo?.content == nil{
                    self.entrySayisi.append("")
                }else{
                    self.entrySayisi.append((entryNo?.content) ?? "")
                }
                self.bugunView.reloadData()
            }
        }
    }
    
    
    func baslikGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("ul[class^=topic-list partial] li a"){
                var small = basliklar.at_css("small")
                small?.content = ""
                self.bugunBasliklar.append(basliklar.text!)
            }
            self.bugunView.reloadData()
        }
    }
    
    func baslikLink(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("ul[class^=topic-list partial] li a"){
                let link = basliklar["href"]
                linkler.append(link!)
            }
        }
    }
    
    func girisKontrol(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("select[class^=today-in-past-selector] option"){
                girisKontrolu = basliklar.text!
                array.append(girisKontrolu)
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
    
    
}


class BugunViewCell: UITableViewCell{
    @IBOutlet var BugunEntrySayisi: UILabel!
    @IBOutlet var BugunBaslik: UILabel!
}

