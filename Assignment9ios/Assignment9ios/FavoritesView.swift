//
//  FavoritesView.swift
//  Assignment9ios
//
//  Created by Justin Wilson on 5/3/23.
//

import SwiftUI

struct FavoritesView: View {
    @State private var isLoaded = false
    @State private var isFavoritesEmpty = true
    @State var items: [favoritesItem] = []
    let defaults = UserDefaults.standard
    
    func handleLoad() {
        let dict = defaults.dictionaryRepresentation()
        for key in dict.keys {
            if(key.hasPrefix("571")){
                do{
                    let storedObjItem = UserDefaults.standard.object(forKey: key)
                    let storedItem = try JSONDecoder().decode(favoritesItem.self, from: storedObjItem as! Data)
                    items.append(storedItem)
                }
                catch let err {
                    print(err)
                }
                isFavoritesEmpty = false
            }
        }
        isLoaded = true
    }
    
    func deleteItems(at offsets: IndexSet){
        for index in offsets {
            let item = items[index]
            let key = "571\(item.eventId)"
            defaults.removeObject(forKey: key)
        }
        items.remove(atOffsets: offsets)
        if(items.isEmpty){
            isFavoritesEmpty = true
        }
    }
    
    var body: some View {
        if(!isLoaded){
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .onAppear()
            {
                handleLoad()
            }
        }
        else{
            if(isFavoritesEmpty){
                Text("No favorites found")
                    .navigationTitle("Favorites")
                    .foregroundColor(.red)
            }
            else{
                List {
                    ForEach(items) { item in
                        HStack{
                            Text(item.localDate)
                            Text(item.name)
                            Text(item.genre)
                            Text(item.venue)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .navigationTitle("Favorites")
            }
        }
    }
}

