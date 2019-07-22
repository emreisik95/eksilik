//
//  fonksiyonlar.swift
//  Eksilik
//
//  Created by Emre Işık on 20.03.2019.
//  Copyright © 2019 Emre Isik. All rights reserved.
//

import Foundation
import Kanna
import Alamofire
import UIKit


public var girisKontrolu = String()
public var entrySayi = [String]()
public var basliklar = [String]()
public var linkler = [String]()
public var sayfaSayisi = "5"
public var aktifSayfa = "2"
public var dahadaLink = ""

var first = FirstViewController()
// Giriş Kontrolü
public func girisKontrol(html: String) -> Void {
    if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
        for basliklar in doc.css("li[class^=buddy mobile-only] a"){
            girisKontrolu = basliklar["href"]!
        }
    }
}

// Başlığın Entry Sayılarını çek
public func baslikentrysayisiGetir(html: String) -> Void {
    if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
        for entrySayisi in doc.css("ul[class^=topic-list partial mobile] li a"){
            let entryNo = entrySayisi.at_css("small")
            if entryNo?.content == nil{
                entrySayi.append("")
            }else{
                entrySayi.append((entryNo?.content)!)
            }
        }
    }
}


//Başlık isimlerini getir

public func baslikGetir(html: String) -> Void {
    if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
        for basliklari in doc.css("ul[class^=topic-list partial mobile] li a"){
            var small = basliklari.at_css("small")
            small?.content = ""
            basliklar.append(basliklari.text!)
        }
    }
}

//Başlıkların linklerini getir
public func baslikLink(html: String) -> Void {
    if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
        for basliklar in doc.css("ul[class^=topic-list partial mobile] li a"){
            let link = basliklar["href"]
            linkler.append(link!)
        }
    }
}

// Şimdiki sayfa sayısını getir
public func sayfaSayisiGetir(html: String) -> Void {
    if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8){
        for sayfa in doc.css("div[class^=pager]"){
            let simdiki = sayfa["data-currentpage"]
            let toplam = sayfa["data-pagecount"]
            sayfaSayisi = toplam!
            aktifSayfa = simdiki!
            print(simdiki!)
            print(toplam!)
        }
    }
}

