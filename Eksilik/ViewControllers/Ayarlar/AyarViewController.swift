//
//  AyarViewController.swift
//  Eksilik
//
//  Created by Emre Işık on 30.03.2019.
//  Copyright © 2019 Emre Isik. All rights reserved.
//

import UIKit
import Alamofire
import Kanna
import MessageUI
import SafariServices


class AyarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, SFSafariViewControllerDelegate {
    
    @IBOutlet weak var versiyonLabel: UILabel!
    
    let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
    
    
    @IBOutlet weak var ayarView: UITableView!
    let status = UserDefaults.standard.bool(forKey: "giris")

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.installBlurEffect()
        self.navigationController?.navigationBar.installBlurEffect()
        let nvHeight = navigationController?.navigationBar.frame.height
        let stHeight = UIApplication.shared.statusBarFrame.height
        let adjustForTabbarInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: self.tabBarController!.tabBar.frame.height, right: 0)
        ayarView.contentInset = adjustForTabbarInsets
        ayarView.scrollIndicatorInsets = adjustForTabbarInsets
        self.view.backgroundColor = Theme.backgroundColor
        self.navigationItem.title = "ayarlar"
        self.navigationController?.navigationBar.tintColor = Theme.titleColor!
        versiyonLabel.text = "ver. \(String(describing: appVersion!))"
        versiyonLabel.textColor = .gray
        ayarView.delegate = self
        ayarView.dataSource = self
        ayarView.tableFooterView = UIView()
        ayarView.backgroundColor = Theme.backgroundColor
        ayarView.separatorColor = Theme.separatorColor
        view.backgroundColor = Theme.backgroundColor
        if status == false{
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["emre@emreisik.com"])
            mail.setSubject("ek$ilik uygulaması tarafından gönderildi")
            
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            if indexPath.row == 0{
               let vc = self.storyboard?.instantiateViewController(withIdentifier:
                    "tema") as! TemaViewController
                self.navigationController?.pushViewController(vc, animated: true)
                tableView.deselectRow(at: [0,0], animated: true)
            }
            if indexPath.row == 1{
                performSegue(withIdentifier: "engelle", sender: nil)
                tableView.deselectRow(at: [0,1], animated: true)
            }

            if indexPath.row == 2{
              let vc = self.storyboard?.instantiateViewController(withIdentifier:
                    "entryGoruntule") as! EntryViewController
                vc.baslikLinki = "entry/19784395"
                self.navigationController?.pushViewController(vc, animated: true)
                tableView.deselectRow(at: [0,2], animated: true)
            }
            if status == true{
            if indexPath.row == 3{
                let vc = self.storyboard?.instantiateViewController(withIdentifier:
                    "entryGoruntule") as! EntryViewController
                vc.baslikLinki = "ek-ilik--6003506"
                self.navigationController?.pushViewController(vc, animated: true)
                tableView.deselectRow(at: [0,3], animated: true)
            }
            if indexPath.row == 4{
                sendEmail()
                tableView.deselectRow(at: [0,4], animated: true)
            }
        }
/*            if indexPath.row == 4{
                if let url = URL(string: "https://eksisozluk.com/ayarlar/tercihler") {
                    let vc = SFSafariViewController(url: url)
                    vc.preferredBarTintColor = Theme.userColor
                    vc.preferredControlTintColor = Theme.backgroundColor
                    present(vc, animated: true)
                }
            }*/

        }
        if indexPath.section == 1{
            let vc =
                self.storyboard?.instantiateViewController(withIdentifier:
                    "suserProfile") as! SuserViewController
            if indexPath.row == 0{
                vc.biriLink = "/biri/sherlockun-besinci-sezonu"
                self.navigationController?.pushViewController(vc, animated: true)
                tableView.deselectRow(at: [1,0], animated: true)
            }
            if indexPath.row == 1{
                vc.biriLink = "/biri/altere-ses"
                self.navigationController?.pushViewController(vc, animated: true)
                tableView.deselectRow(at: [1,1], animated: true)
            }
            if indexPath.row == 2{
                vc.biriLink = "/biri/actuallymya"
                self.navigationController?.pushViewController(vc, animated: true)
                tableView.deselectRow(at: [1,2], animated: true)
            }
            if indexPath.row == 3{
                vc.biriLink = "/biri/anakin-skuwalker"
                self.navigationController?.pushViewController(vc, animated: true)
                tableView.deselectRow(at: [1,3], animated: true)
            }
            if indexPath.row == 4{
                vc.biriLink = "/biri/arz-eyleyip-geldim"
                self.navigationController?.pushViewController(vc, animated: true)
                tableView.deselectRow(at: [1,4], animated: true)
            }
            if indexPath.row == 5{
                vc.biriLink = "/biri/derin-uyku"
                self.navigationController?.pushViewController(vc, animated: true)
                tableView.deselectRow(at: [1,5], animated: true)
            }
            if indexPath.row == 6{
                vc.biriLink = "/biri/jix"
                self.navigationController?.pushViewController(vc, animated: true)
                tableView.deselectRow(at: [1,6], animated: true)
            }
            if indexPath.row == 7{
                vc.biriLink = "/biri/ultra-professional"
                self.navigationController?.pushViewController(vc, animated: true)
                tableView.deselectRow(at: [1,7], animated: true)
            }

        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            if status == false{
                return 3
            }
            return 5
        }
        if section == 1{
            return 8
        }
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 45
        }else{
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            let view = UIView()
            let blurEffect = Theme.ayarblurEffect!
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(blurEffectView)
            view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30)
            view.layer.masksToBounds = false
            view.layer.shadowColor = Theme.userColor?.cgColor
            view.layer.shadowOffset = CGSize(width: 0.0, height: 0.2)
            view.layer.shadowOpacity = 1.0
            view.layer.shadowRadius = 0.0
            let tumuButton = UIButton()
            tumuButton.setTitle("ayarlar", for: .normal)
            tumuButton.setTitleColor(Theme.userColor, for: .normal)
            tumuButton.titleLabel?.font = UIFont(name: "Helvetica", size: 15)
            tumuButton.frame = view.bounds
            view.addSubview(tumuButton)
            let topBorder = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0.2))
            topBorder.backgroundColor = Theme.userColor!
            view.addSubview(topBorder)
            return view
        }
        if section == 1{
            let view = UIView()
            let blurEffect = Theme.ayarblurEffect!
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(blurEffectView)
            view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30)
            view.layer.masksToBounds = false
            view.layer.shadowColor = Theme.userColor?.cgColor
            view.layer.shadowOffset = CGSize(width: 0.0, height: 0.2)
            view.layer.shadowOpacity = 1.0
            view.layer.shadowRadius = 0.0
            let tumuButton = UIButton()
            tumuButton.setTitle("emeği geçenler", for: .normal)
            tumuButton.setTitleColor(Theme.userColor, for: .normal)
            tumuButton.titleLabel?.font = UIFont(name: "Helvetica", size: 15)
            tumuButton.frame = view.bounds
            view.addSubview(tumuButton)
            let topBorder = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0.2))
            topBorder.backgroundColor = Theme.userColor!
            view.addSubview(topBorder)
            return view
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ayarCell
            cell.ayarLabel.textColor = Theme.labelColor
            if indexPath.row % 2 == 0{
                cell.backgroundColor = Theme.cellFirstColor
            }else{
                cell.backgroundColor = Theme.cellSecondColor
            }
        if indexPath.row == 0{
            cell.ayarLabel.text = "tema ayarları"
        }
        if indexPath.row == 1{
                cell.ayarLabel.text = "başlıkları engelle"
            }
        if indexPath.row == 2{
            cell.ayarLabel.text = "ekşi sözlük kullanım koşulları"
        }
        if status == true{

        if indexPath.row == 3{
            cell.ayarLabel.text = "uygulama hakkında entry gir"
        }
        if indexPath.row == 4{
            cell.ayarLabel.text = "sorun / öneri / görüş bildir"
        }
            }
      /*  if indexPath.row == 4{
            cell.ayarLabel.text = "diğer ayarlar"
        }*/
        return cell
        }else{
        let cell = tableView.dequeueReusableCell(withIdentifier: "emek", for: indexPath) as! emekCell
            if indexPath.row % 2 == 0{
                cell.backgroundColor = Theme.cellFirstColor
            }else{
                cell.backgroundColor = Theme.cellSecondColor
            }
            cell.emekLabel.textColor = Theme.labelColor
            cell.aciklamaLabel.textColor = Theme.userColor
            if indexPath.row == 0{
                cell.emekLabel.text = "sherlockun besinci sezonu"
                cell.aciklamaLabel.text = "geliştirici"
            }
            if indexPath.row == 1{
                cell.emekLabel.text = "altere ses"
                cell.aciklamaLabel.text = "beta desteği"
            }
            if indexPath.row == 2{
                cell.emekLabel.text = "actuallymya"
                cell.aciklamaLabel.text = "beta desteği"
            }
            if indexPath.row == 3{
                cell.emekLabel.text = "anakin skuwalker"
                cell.aciklamaLabel.text = "beta desteği"
            }
            if indexPath.row == 4{
                cell.emekLabel.text = "arz eyleyip geldim"
                cell.aciklamaLabel.text = "beta desteği"
            }
            if indexPath.row == 5{
                cell.emekLabel.text = "derin uyku"
                cell.aciklamaLabel.text = "beta desteği"
            }
            if indexPath.row == 6{
                cell.emekLabel.text = "jix"
                cell.aciklamaLabel.text = "geliştirme desteği"
            }
            if indexPath.row == 7{
                cell.emekLabel.text = "ultra professional"
                cell.aciklamaLabel.text = "beta desteği"
            }
            return cell
        }
    }
  
    @IBAction func cikisButton(_ sender: Any) {
        
        Alamofire.request("https://www.eksisozluk.com/terk").responseString {
            response in
            if response.result.isSuccess{
                UserDefaults.standard.set(false, forKey: "giris")
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "basla") as! UITabBarController
                vc.viewControllers?.remove(at: 3)
                vc.viewControllers?.remove(at: 2)
                TarihPageViewController().viewDidLoad()
                UIApplication.shared.keyWindow?.rootViewController = vc
            }
        }
    }
}

class ayarCell : UITableViewCell{
    
    @IBOutlet weak var ayarLabel: UILabel!
    
}

class emekCell : UITableViewCell{
    
    @IBOutlet weak var emekLabel: UILabel!
    
    @IBOutlet weak var aciklamaLabel: UILabel!
    
}
