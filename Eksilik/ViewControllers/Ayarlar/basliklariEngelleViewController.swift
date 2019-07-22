//
//  basliklariEngelleViewController.swift
//  Eksilik
//
//  Created by Emre Işık on 26.04.2019.
//  Copyright © 2019 Emre Isik. All rights reserved.
//

import UIKit

class basliklariEngelleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    @IBOutlet weak var engelleView: UITableView!
    @IBOutlet weak var engelleText: UITextField!
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.installBlurEffect()
        self.navigationController?.navigationBar.installBlurEffect()

        engelleView.delegate = self
        engelleView.dataSource = self
        engelleView.backgroundColor = Theme.backgroundColor
        engelleView.separatorColor = Theme.separatorColor
        engelleView.tableFooterView = UIView()
        view.backgroundColor = Theme.backgroundColor
        engelleText.keyboardAppearance = Theme.keyboardColor!
    }
    
    @IBAction func engelleButton(_ sender: Any) {
        let engel = engelleText.text?.lowercased()
        self.engelleText.endEditing(true)
        Theme.wordList.append(engel!)
        defaults.set(Theme.wordList, forKey: "engellenenler")
        defaults.synchronize()
        engelleView.reloadData()
        engelleText.text = ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return Theme.wordList.count
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
            let engelle = UITableViewRowAction(style: .normal, title: "kelimeyi sil") { (UITableViewRowAction, indexPath) in
                            Theme.wordList.remove(at: indexPath.row)
                self.defaults.set(Theme.wordList, forKey: "engellenenler")
                            tableView.deleteRows(at: [indexPath], with: .middle)
                        }
            engelle.backgroundColor = Theme.userColor
            return [engelle]
        }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "engelle", for: indexPath) as! engelleCell
        if indexPath.row % 2 == 0{
            cell.backgroundColor = Theme.cellFirstColor
        }else{
            cell.backgroundColor = Theme.cellSecondColor
        }
        cell.engelLabel.text = Theme.wordList[indexPath.row]
        cell.engelLabel.textColor = Theme.labelColor
        cell.selectionStyle = .none
        return cell
    }
    
}


class engelleCell : UITableViewCell{
    
    @IBOutlet weak var engelLabel: UILabel!
    
}
