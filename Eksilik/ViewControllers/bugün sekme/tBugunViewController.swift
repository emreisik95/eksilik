import UIKit
import Alamofire
import Kanna


class tBugunViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var viewcim = (Bundle.main.loadNibNamed("arkaplan", owner: self, options: nil)![0]) as! UIView

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @IBOutlet var simdikiTarih: UIButton!
    
    var tarih = String()
    var basliklar = [String]()
    var entrySayisi = [String]()
    var linkler = [String]()
    var seciliLink = ""
    var baslik = ""
    var girisKontrolu = String()
    var gundemLink = "https://eksisozluk.com/basliklar/m/tarihte-bugun"
    var dahadaLink = ""
    var sayfaSayisi = "5"
    var aktifSayfa = "2"
    var sayfa: Int = 2
    var array = [String]()
    var barAccessory = UIToolbar()
    var secti = Int()
    var secim = true
    let status = UserDefaults.standard.bool(forKey: "giris")
    let font = UserDefaults.standard.string(forKey: "secilenFont")
    var puntosecim = 15
    @IBAction func tarihSec(_ sender: Any) {
        typePickerView.isHidden = false
        self.view.addSubview(typePickerView)
        barAccessory = UIToolbar(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 404, width: typePickerView.frame.size.width, height: 44))
        barAccessory.barStyle = Theme.barStyle!
        barAccessory.barTintColor = Theme.userColor
        let flexiblespace = UIBarButtonItem(barButtonSystemItem:.flexibleSpace , target: nil, action: nil)
        let btnDone = UIBarButtonItem(title: "tamam", style: .done, target: self, action: #selector(tamam(_:)))
        btnDone.tintColor = Theme.labelColor
        barAccessory.items = [flexiblespace,btnDone]
        self.view.addSubview(barAccessory)
    }
    
    var typePickerView: UIPickerView = UIPickerView()
    
    @IBOutlet var tbugunView: UITableView!
    
    var refreshView: RefreshView!
    
    var tableViewRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = .clear
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        return refreshControl
    }()

    let value = UserDefaults.standard.integer(forKey: "secilenTema")
    override func viewDidLoad() {
        super.viewDidLoad()
        puntosecim = UserDefaults.standard.integer(forKey: "secilenPunto")
        CustomLoader.instance.showLoaderView()
        self.title = "tarihte bugün"
        prepareUI()
        navigationController?.navigationBar.barStyle = Theme.barStyle!
        navigationController?.navigationBar.barTintColor = Theme.navigationBarColor
        tbugunView.separatorStyle = .singleLine
        tbugunView.separatorColor = Theme.separatorColor
        tbugunView.backgroundColor = Theme.backgroundColor
        simdikiTarih.backgroundColor = Theme.userColor
        self.view.backgroundColor = Theme.backgroundColor
        tbugunView.delegate = self
        tbugunView.dataSource = self
        siteyeBaglan()
        self.typePickerView.dataSource = self
        self.typePickerView.delegate = self
        self.typePickerView.backgroundColor = Theme.backgroundColor
        self.typePickerView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 360, width: UIScreen.main.bounds.width, height: 250)
        tabBarController?.tabBar.installBlurEffect()
        self.navigationController?.navigationBar.installBlurEffect()

    }

    
    @IBAction func tamam(_ sender: Any) {
        typePickerView.isHidden = true
        barAccessory.isHidden = true
        gundemLink = "https://eksisozluk.com/basliklar/m/tarihte-bugun?year=\(array[secti])"
        CustomLoader.instance.showLoaderView()
        siteyeBaglan()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let myTitle = NSAttributedString(string: array[row], attributes: [NSAttributedString.Key.foregroundColor: Theme.labelColor!])
        pickerView.backgroundColor = Theme.backgroundColor
        return myTitle
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        secti = row
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return array.count
    }

    private func loadData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(20)) {
            self.tbugunView.reloadData()
        }
    }
    @objc func refreshTableView() {
        typePickerView.isHidden = true
        CustomLoader.instance.showLoaderView()
        siteyeBaglan()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.tableViewRefreshControl.endRefreshing()
        }
    }

    func prepareUI() {
        // Adding 'tableViewRefreshControl' to tableView
        tbugunView.refreshControl = tableViewRefreshControl
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
    
    private var finishedLoadingInitialTableCells = false
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        if self.aktifSayfa == self.sayfaSayisi{
            
        }else{
            let lastData = self.basliklar.count - 1
            if indexPath.row == lastData {
                CustomLoader.instance.showLoaderView()
                self.dahadaLink = "\(gundemLink)?p=\(sayfa)"
                basliklariGetir()
                cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
                UIView.animate(withDuration: 0.3, animations: {
                    cell.layer.transform = CATransform3DMakeScale(1.05,1.05,1)
                },completion: { finished in
                    UIView.animate(withDuration: 0.1, animations: {
                        cell.layer.transform = CATransform3DMakeScale(1,1,1)
                    })
                })
                sayfa = sayfa+1
            }
        }
        
        
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
            cell.transform = CGAffineTransform(translationX: 0, y: tbugunView.rowHeight/2)
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
        return basliklar.count
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! tBugunViewCell
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
        cell.tBugunEntrySayisi.text = entrySayisi[indexPath.row]
        cell.tBugunEntrySayisi.font = UIFont(name: font!, size: CGFloat(puntosecim))
        cell.tBugunEntrySayisi.textColor = Theme.entrySayiColor
        cell.tBugunBaslik.text = basliklar[indexPath.row]
        cell.tBugunBaslik.font = UIFont(name: font!, size: CGFloat(puntosecim))
        cell.tBugunBaslik.textColor = Theme.labelColor
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
                self.tbugunView.reloadData()
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
        self.basliklar = [String]()
        self.entrySayisi = [String]()
        self.linkler = [String]()
        self.aktifSayfa = "1"
        self.sayfa = 2
        Alamofire.request(gundemLink).responseString {
            response in
            if let html = response.result.value{
                self.tarihKontrol(html: html)
                self.sayfaSayisiGetir(html: html)
                self.baslikentrysayisiGetir(html: html)
                self.baslikGetir(html: html)
                self.baslikLink(html: html)
                self.girisKontrol(html: html)
                if self.status == true{
                    self.olayKontrol(html: html)
                    self.mesajKontrol(html: html)
                }
                if self.basliklar.count == 0 {
                    self.tbugunView.addSubview(self.viewcim)
                    self.tbugunView.separatorStyle = .none
                }else{
                    self.tbugunView.separatorStyle = .singleLine
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
        self.tbugunView.reloadData()
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
            for entrySayisi in doc.css("ul[class^=topic-list partial mobile] li a"){
                let entryNo = entrySayisi.at_css("small")
                if entryNo?.content == nil{
                    self.entrySayisi.append("")
                }else{
                    self.entrySayisi.append((entryNo?.content)!)
                    
                }
                self.tbugunView.reloadData()
            }
        }
    }
    
    
    func baslikGetir(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("ul[class^=topic-list partial mobile] li a"){
                var small = basliklar.at_css("small")
                small?.content = ""
                self.basliklar.append(basliklar.text!)
            }
            self.tbugunView.reloadData()
        }
    }
    
    func baslikLink(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("ul[class^=topic-list partial mobile] li a"){
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
    func tarihKontrol(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            for basliklar in doc.css("option[selected^=selected]"){
                simdikiTarih.setTitle(basliklar.text!, for: .normal)
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


class tBugunViewCell: UITableViewCell{
    
    @IBOutlet var tBugunEntrySayisi: UILabel!
    @IBOutlet var tBugunBaslik: UILabel!
    
}


protocol XibLoadable {
    associatedtype CustomViewType
    static func loadFromXib() -> CustomViewType
}

extension XibLoadable where Self: UIView {
    static func loadFromXib() -> Self {
        let nib = UINib(nibName: "arkaplan", bundle: Bundle(for: self))
        guard let customView = nib.instantiate(withOwner: self, options: nil).first as? Self else {
            // your app should crash if the xib doesn't exist
            preconditionFailure("Couldn't load xib for view: \(self)")
        }
        return customView
    }
}
