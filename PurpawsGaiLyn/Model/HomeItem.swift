//
//  HomeItem.swift
//  Purpaws
//
//  Created by STUDENT on 10/18/24.
//

import Foundation

struct HomeItem: Identifiable {
    var id: Int
    var image: String
    var title: String
    var description: String
}

let homeItemsData = [
    HomeItem(id: 1, image: "Media", title: "Piso lang paws!", description: "A faint jingle of coins catches your ear as you pass through the bustling hall..."),
    HomeItem(id: 2, image: "dog", title: "Dos lang paws!", description: "A faint jingle of coins catches your ear as you pass through the bustling hall..."),
    HomeItem(id: 3, image: "dog", title: "Dos lang paws!", description: "A faint jingle of coins catches your ear as you pass through the bustling hall...")
]
