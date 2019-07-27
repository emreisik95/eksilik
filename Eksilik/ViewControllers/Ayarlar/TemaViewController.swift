//
//  TemaViewController.swift
//  Eksilik
//
//  Created by Emre Işık on 23.04.2019.
//  Copyright © 2019 Emre Isik. All rights reserved.
//

import UIKit

class TemaViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    let secim = UserDefaults.standard.integer(forKey: "secilenTema")
    let fontsecim = UserDefaults.standard.string(forKey: "secilenFont")
    let puntosecim = UserDefaults.standard.integer(forKey: "secilenPunto")
    let link = UserDefaults.standard.bool(forKey: "link")
    let entryGizle = UserDefaults.standard.bool(forKey: "gizle")
    var barAccessory = UIToolbar()
    var typePickerView: UIPickerView = UIPickerView()
    var puntoPickerView: UIPickerView = UIPickerView()
    var secilen = 15
    var fontlar = ["AppleSDGothicNeo-Light","AppleSDGothicNeo-Medium","ArialMT","Avenir-Book","Avenir-Medium","ChalkboardSE-Light","DevanagariSangamMN","DevanagariSangamMN-Bold","Noteworthy-Light","Noteworthy-Bold","Helvetica","Helvetica-Light","TimesNewRomanPSMT", "TrebuchetMS", "TrebuchetMS-Bold", "SanFranciscoText-Light" ,"SanFranciscoText-Medium", "PingFangTC-Regular", "PingFangTC-Light", "Futura-Medium", "Courier", "Courier-Bold"]
    var punto = [14,15,16,17,18,19,20,21,22]
    var secti = String()

    @IBOutlet var temaButton: UISegmentedControl!
    @IBOutlet var temaLabel: UILabel!
    @IBOutlet weak var linkLabel: UILabel!
    @IBOutlet weak var linkSwitch: UISwitch!
    @IBOutlet weak var gizleLabel: UILabel!
    @IBOutlet weak var gizleSwitch: UISwitch!
    
    
    @objc func linkValueChanged(_ sender: UISwitch) {
        if sender.isOn{
            sender.setOn(true, animated: true)
            print("dokundun gene")
            UserDefaults.standard.set(true, forKey: "link")
            UserDefaults.standard.synchronize()
        }else{
            sender.setOn(false, animated: true)
            print("dokundun")
            UserDefaults.standard.set(false, forKey: "link")
            UserDefaults.standard.synchronize()
        }
    }
    
    
    @objc func gizleValueChanged(_ sender: UISwitch) {
        if sender.isOn{
            sender.setOn(true, animated: true)
            print("dokundun gene")
            UserDefaults.standard.set(true, forKey: "gizle")
            UserDefaults.standard.synchronize()
        }else{
            sender.setOn(false, animated: true)
            print("dokundun")
            UserDefaults.standard.set(false, forKey: "gizle")
            UserDefaults.standard.synchronize()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.installBlurEffect()
        self.navigationController?.navigationBar.installBlurEffect()
        
        if link{
            linkSwitch.setOn(true, animated: true)
            
        }else{
            linkSwitch.setOn(false, animated: true)
        }
            gizleSwitch.isOn = entryGizle
        
        linkSwitch.addTarget(self, action: #selector(linkValueChanged), for: .valueChanged)
        gizleSwitch.addTarget(self, action: #selector(gizleValueChanged), for: .valueChanged)
        
        gizleSwitch.tintColor = Theme.userColor
        linkSwitch.tintColor = Theme.userColor
        
        

               if secim == 0 {
         temaButton.selectedSegmentIndex = 0
         }
         if secim == 1{
         temaButton.selectedSegmentIndex = 1
         }
        if secim == 2{
            temaButton.selectedSegmentIndex = 2
        }

           temaButton.tintColor = Theme.userColor
           temaLabel.textColor = Theme.labelColor
           yaziLabel.textColor = Theme.labelColor
        linkLabel.textColor = Theme.labelColor
        gizleLabel.textColor = Theme.labelColor
           yaziBuyuklugu.textColor = Theme.labelColor
        yaziTipi.textColor = Theme.labelColor
        self.view.backgroundColor = Theme.backgroundColor
        self.puntoButton.setTitle("\(puntosecim) punto", for: .normal)
        self.fontButton.setTitle("\(String(describing: fontsecim!))", for: .normal)
        self.puntoPickerView.dataSource = self
        self.puntoPickerView.delegate = self
        self.puntoPickerView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 260, width: UIScreen.main.bounds.width, height: 220)
        self.typePickerView.dataSource = self
        self.typePickerView.delegate = self
        self.typePickerView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 260, width: UIScreen.main.bounds.width, height: 220)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if pickerView == typePickerView{
        let myTitle = NSAttributedString(string: fontlar[row], attributes: [NSAttributedString.Key.foregroundColor: Theme.userColor!])
        pickerView.backgroundColor = Theme.backgroundColor
        return myTitle
        }else{
            let myTitle = NSAttributedString(string: "\(punto[row])", attributes: [NSAttributedString.Key.foregroundColor: Theme.userColor!])
            pickerView.backgroundColor = Theme.backgroundColor
            return myTitle
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == typePickerView{
        self.secti = fontlar[row]
        }else{
            secilen = punto[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == typePickerView{
        return fontlar.count
        }else{
            return punto.count
        }
    }
    
    
    @IBOutlet weak var puntoButton: UIButton!
    
    @IBOutlet weak var fontButton: UIButton!
    
    @IBAction func puntoAyari(_ sender: Any) {
        self.view.addSubview(puntoPickerView)
        barAccessory = UIToolbar(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 304, width: puntoPickerView.frame.size.width, height: 44))
        barAccessory.barStyle = Theme.barStyle!
        barAccessory.barTintColor = Theme.userColor
        let flexiblespace = UIBarButtonItem(barButtonSystemItem:.flexibleSpace , target: nil, action: nil)
        let btnDone = UIBarButtonItem(title: "tamam", style: .done, target: self, action: #selector(puntotamam(_:)))
        btnDone.tintColor = .white
        barAccessory.items = [flexiblespace,btnDone]
        self.view.addSubview(barAccessory)
    }
    
    
    @IBAction func fontAyari(_ sender: Any) {
        self.view.addSubview(typePickerView)
        barAccessory = UIToolbar(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 304, width: typePickerView.frame.size.width, height: 44))
        barAccessory.barStyle = Theme.barStyle!
        barAccessory.barTintColor = Theme.userColor
        let flexiblespace = UIBarButtonItem(barButtonSystemItem:.flexibleSpace , target: nil, action: nil)
        let btnDone = UIBarButtonItem(title: "tamam", style: .done, target: self, action: #selector(tamam(_:)))
        btnDone.tintColor = .white
        barAccessory.items = [flexiblespace,btnDone]
        self.view.addSubview(barAccessory)
    }
    
    @IBAction func temaSecici(_ sender: Any) {
        if temaButton.selectedSegmentIndex == 0{
            Theme.defaultTheme()
            changeIcon(to: "AppIcon")
            UserDefaults.standard.set(0, forKey: "secilenTema")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "basla") as! UITabBarController
            UIApplication.shared.keyWindow?.rootViewController = vc
        }
        if temaButton.selectedSegmentIndex == 1{
            Theme.gunduzTheme()
            UserDefaults.standard.set(1, forKey: "secilenTema")
            changeIcon(to: "AlternateIcon")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "basla") as! UITabBarController
            self.setNeedsStatusBarAppearanceUpdate()
            UIApplication.shared.keyWindow?.rootViewController = vc
        }
        if temaButton.selectedSegmentIndex == 2{
            Theme.klasikTheme()
            UserDefaults.standard.set(2, forKey: "secilenTema")
            changeIcon(to: "AlternatePembe")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "basla") as! UITabBarController
            self.setNeedsStatusBarAppearanceUpdate()
            UIApplication.shared.keyWindow?.rootViewController = vc
        }
    }
    
    @IBAction func tamam(_ sender: Any) {
        typePickerView.isHidden = true
        barAccessory.isHidden = true
        UserDefaults.standard.set(self.secti, forKey: "secilenFont")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "basla") as! UITabBarController
        self.setNeedsStatusBarAppearanceUpdate()
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    @IBAction func puntotamam(_ sender: Any) {
        puntoPickerView.isHidden = true
        barAccessory.isHidden = true
        UserDefaults.standard.set(self.secilen, forKey: "secilenPunto")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "basla") as! UITabBarController
        self.setNeedsStatusBarAppearanceUpdate()
        UIApplication.shared.keyWindow?.rootViewController = vc
    }

    
    @IBOutlet weak var yaziTipi: UILabel!
    @IBOutlet weak var yaziBuyuklugu: UILabel!
    @IBOutlet var yaziLabel: UILabel!
    
    func changeIcon(to iconName: String) {
        // 1
        if #available(iOS 10.3, *) {
            guard UIApplication.shared.supportsAlternateIcons else {
                return
            }
        } else {
            // Fallback on earlier versions
        }
        
        // 2
        if #available(iOS 10.3, *) {
            UIApplication.shared.setAlternateIconName(iconName, completionHandler: { (error) in
                // 3
                if let error = error {
                    print("App icon failed to change due to \(error.localizedDescription)")
                } else {
                    let tempVC = UIViewController()
                    
                    self.present(tempVC, animated: false, completion: {
                        tempVC.dismiss(animated: false, completion: nil)
                    })
                    print("Uygulama simgesi başarıyla değiştirildi.")
                }
            })
        } else {
            // Fallback on earlier versions
        }
    }
    
}
