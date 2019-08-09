//
//  tema.swift
//  Eksilik
//
//  Created by Emre Işık on 7.04.2019.
//  Copyright © 2019 Emre Isik. All rights reserved.
//


import Foundation
import UIKit

struct Theme {
    
    static var backgroundColor:UIColor!
    static var cellFirstColor:UIColor!
    static var cellSecondColor:UIColor!
    static var navigationBarColor:UIColor!
    static var labelColor:UIColor!
    static var entrySayiColor:UIColor!
    static var userColor:UIColor!
    static var tarihColor:UIColor!
    static var buttonBackgroundColor:UIColor!
    static var tabBarColor:UIColor!
    static var barStyle:UIBarStyle!
    static var titleColor:UIColor!
    static var entryYaziColor:String!
    static var linkColor:UIColor!
    static var separatorColor:UIColor!
    static var keyboardColor:UIKeyboardAppearance!
    static var blurEffect:UIBlurEffect!
    static var ayarblurEffect:UIBlurEffect!
    static var entryColor:UIColor!
    static var statusBarStyle:UIStatusBarStyle!
    static var yorumColor:UIColor!
    static var okunmamis:UIColor!
    static var okunmamisBaslik:UIColor!
    static var bg:UIColor!
    static var wordList = UserDefaults.standard.stringArray(forKey: "engellenenler") ?? [String]()
    static var menuColor:UIColor!
    static var altBarStyle:UIBlurEffect!
    static var entryButton:UIColor!
    
    static public func defaultTheme() {
        backgroundColor = UIColor.init(red: 37/255, green: 37/255, blue: 37/255, alpha: 1)
        cellFirstColor = UIColor.init(red: 28/255, green: 28/255, blue: 28/255, alpha: 1)
        cellSecondColor = UIColor.init(red: 22/255, green: 22/255, blue: 22/255, alpha: 1)
        navigationBarColor = UIColor.init(red: 22/255, green: 22/255, blue: 22/255, alpha: 1)
        labelColor = .white
        entryColor = .white
        tarihColor = .darkGray
        userColor = UIColor.init(red: 102/255, green: 180/255, blue: 63/255, alpha: 1)
        entryButton = UIColor.init(red: 102/255, green: 180/255, blue: 63/255, alpha: 1)
        buttonBackgroundColor = UIColor.init(red: 131/255, green: 209/255, blue: 195, alpha: 1)
        entrySayiColor = UIColor.init(red: 180/255, green: 238/255, blue: 116/255, alpha: 1)
        tabBarColor = UIColor.init(red: 136/255, green: 202/255, blue: 64/255, alpha: 1)
        barStyle = .black
        titleColor = .white
        linkColor = UIColor.init(red: 180/255, green: 238/255, blue: 116/255, alpha: 1)
        separatorColor = .black
        keyboardColor = .dark
        blurEffect = .init(style: .dark)
        ayarblurEffect = .init(style: .dark)
        statusBarStyle = .lightContent
        yorumColor = .black
        okunmamis =  UIColor.init(red: 55/255, green: 55/255, blue: 55/255, alpha: 1)
        okunmamisBaslik = UIColor.init(red: 132/255, green: 208/255, blue: 51/255, alpha: 1)
        menuColor = .white
        bg = .black
        altBarStyle = .init(style: .dark)
        update()
    }
    static public func gunduzTheme() {
        backgroundColor = .white
        bg = .white
        cellFirstColor = UIColor.init(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        cellSecondColor = UIColor.init(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        navigationBarColor = .clear
        labelColor = .black
        entryColor = .black
        tarihColor = .darkGray
        userColor = UIColor.init(red: 78/255, green: 125/255, blue: 28/255, alpha: 1)
        entryButton = UIColor.init(red: 78/255, green: 125/255, blue: 28/255, alpha: 1)
        buttonBackgroundColor = UIColor.init(red: 131/255, green: 209/255, blue: 195, alpha: 1)
        entrySayiColor = UIColor.init(red: 78/255, green: 125/255, blue: 28/255, alpha: 1)
        tabBarColor = UIColor.init(red: 136/255, green: 202/255, blue: 64/255, alpha: 1)
        barStyle = .default
        titleColor = .darkGray
        linkColor = UIColor.init(red: 78/255, green: 125/255, blue: 28/255, alpha: 1)
        separatorColor = .darkGray
        keyboardColor = .light
        blurEffect = .init(style: .light)
        ayarblurEffect = .init(style: .light)
        statusBarStyle = .lightContent
        yorumColor = .white
        okunmamis = .white
        okunmamisBaslik = UIColor.init(red: 132/255, green: 208/255, blue: 51/255, alpha: 1)
        menuColor = .black
        bg = .black
        altBarStyle = .init(style: .light)
        update()
    }
    static public func klasikTheme() {
        backgroundColor = UIColor.init(red: 221/255, green: 221/255, blue: 221/255, alpha: 1)
        cellFirstColor = UIColor.init(red: 221/255, green: 221/255, blue: 221/255, alpha: 1)
        cellSecondColor = UIColor.init(red: 221/255, green: 221/255, blue: 221/255, alpha: 1)
        navigationBarColor = UIColor.init(red: 22/255, green: 22/255, blue: 22/255, alpha: 1)
        labelColor = .black
        entryColor = UIColor.init(red: 0/255, green: 39/255, blue: 184/255, alpha: 1)
        tarihColor = .darkGray
        userColor = UIColor.init(red: 0/255, green: 39/255, blue: 184/255, alpha: 1)
        entryButton = .gray
        buttonBackgroundColor = UIColor.init(red: 131/255, green: 209/255, blue: 195, alpha: 1)
        entrySayiColor = UIColor.init(red: 0/255, green: 39/255, blue: 184/255, alpha: 1)
        tabBarColor = .white
        barStyle = .black
        titleColor = .white
        linkColor = UIColor.init(red: 0/255, green: 39/255, blue: 184/255, alpha: 1)
        separatorColor = .gray
        keyboardColor = .dark
        blurEffect = .init(style: .dark)
        ayarblurEffect = .init(style: .light)
        statusBarStyle = .lightContent
        yorumColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        okunmamis =  UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        okunmamisBaslik = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        menuColor = .darkGray
        bg = .black
        altBarStyle = .init(style: .light)
      update()
    }
    static public func twitterTheme() {
        backgroundColor = UIColor.init(red: 23/255, green: 32/255, blue: 42/255, alpha: 1)
        cellFirstColor = UIColor.init(red: 23/255, green: 32/255, blue: 42/255, alpha: 1)
        cellSecondColor = UIColor.init(red: 23/255, green: 32/255, blue: 42/255, alpha: 1)
        navigationBarColor = UIColor.init(red: 23/255, green: 32/255, blue: 42/255, alpha: 1)
        labelColor = .white
        entryColor = .white
        tarihColor = .darkGray
        userColor = UIColor.init(red: 76/255, green: 158/255, blue: 235/255, alpha: 1)
        entryButton = UIColor.init(red: 76/255, green: 158/255, blue: 235/255, alpha: 1)
        buttonBackgroundColor = UIColor.init(red: 76/255, green: 158/255, blue: 235/255, alpha: 1)
        entrySayiColor = UIColor.init(red: 76/255, green: 158/255, blue: 235/255, alpha: 1)
        tabBarColor = UIColor.init(red: 76/255, green: 158/255, blue: 235/255, alpha: 1)
        barStyle = .black
        titleColor = .white
        linkColor = UIColor.init(red: 76/255, green: 158/255, blue: 235/255, alpha: 1)
        separatorColor = .black
        keyboardColor = .dark
        blurEffect = .init(style: .dark)
        ayarblurEffect = .init(style: .dark)
        statusBarStyle = .lightContent
        yorumColor = UIColor.init(red: 43/255, green: 52/255, blue: 62/255, alpha: 1)
        okunmamis =  UIColor.init(red: 43/255, green: 52/255, blue: 62/255, alpha: 1)
        okunmamisBaslik = UIColor.init(red: 43/255, green: 52/255, blue: 62/255, alpha: 1)
        menuColor = .white
        bg = UIColor.init(red: 23/255, green: 32/255, blue: 42/255, alpha: 1)
        altBarStyle = .init(style: .dark)
        update()
    }
    static public func update(){
        UINavigationBar.appearance().isTranslucent = false
        let windows = UIApplication.shared.windows
        for window in windows {
            for view in window.subviews {
                view.removeFromSuperview()
                window.addSubview(view)
            }
        }
    }

    
}
