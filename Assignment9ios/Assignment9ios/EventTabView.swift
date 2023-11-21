//
//  EventTabView.swift
//  Assignment9ios
//
//  Created by Justin Wilson on 4/27/23.
//

import SwiftUI
import Alamofire

struct EventTabView: View {
    var eventId: String
    @State private var detailsObject = ParsedDetails(name: "", localDate: "", localTime: "", artists: [""], venue: "", genre: "", subgenre: "", segment: "", subtype: "", type: "", minPrice: 0, maxPrice: 0, ticketStatus: "", ticketURL: "", seatmap: "")
    let facebookUrl = "https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Facebook_Logo_%282019%29.png/1024px-Facebook_Logo_%282019%29.png"
    let twitterUrl = "https://png.pngtree.com/png-vector/20221018/ourmid/pngtree-twitter-social-media-round-icon-png-image_6315985.png"
    @State private var isFavorite = false
    
    func handleLoad(){
        if(UserDefaults.standard.object(forKey: "571" + eventId) != nil){
            isFavorite = true
        }
        let detailsURL = "https://assignment8-380515.wl.r.appspot.com/details?eventID=" + eventId
        AF.request(detailsURL)
            .responseDecodable(of: TicketmasterEvent.self) { response in
                switch response.result{
                case .success(let ticketmasterEvent):
                    let parsedDetails = ParsedDetails(
                        name: ticketmasterEvent.name,
                        localDate: ticketmasterEvent.dates.start.localDate,
                        localTime: ticketmasterEvent.dates.start.localTime,
                        artists: ticketmasterEvent.embedded.attractions.map { $0.name },
                        venue: ticketmasterEvent.embedded.venues.first?.name ?? "",
                        genre: ticketmasterEvent.classifications.first?.genre.name ?? "",
                        subgenre: ticketmasterEvent.classifications.first?.subGenre.name ?? "",
                        segment: ticketmasterEvent.classifications.first?.segment.name ?? "",
                        subtype: ticketmasterEvent.classifications.first?.subType?.name ?? "",
                        type: ticketmasterEvent.classifications.first?.type?.name ?? "",
                        minPrice: ticketmasterEvent.priceRanges?.first?.min ?? 0,
                        maxPrice: ticketmasterEvent.priceRanges?.first?.max ?? 0,
                        ticketStatus: ticketmasterEvent.dates.status.code,
                        ticketURL: ticketmasterEvent.url,
                        seatmap: ticketmasterEvent.seatmap?.staticUrl)
                    detailsObject = parsedDetails
                case .failure(let error):
                    print(error)
                }
        }
        
    }
    
    func handleSaveEvent(){
        let defaultsKey = "571" + eventId
        let defaults = UserDefaults.standard
        if(defaults.object(forKey: defaultsKey) != nil){
            let dict = defaults.dictionaryRepresentation()
            for key in dict.keys {
                if(key.hasPrefix("571")){
                    do{
                        let storedObjItem = UserDefaults.standard.object(forKey: key)
                        let storedItems = try JSONDecoder().decode(favoritesItem.self, from: storedObjItem as! Data)
                        print(storedItems)
                        print(storedItems.name)
                    }
                    catch let err {
                        print(err)
                    }
                }
            }
            defaults.removeObject(forKey: defaultsKey)
            isFavorite = false
        }
        else{
            let genre = detailsObject.genre ?? ""
            let subgenre = detailsObject.subgenre ?? ""
            let segment = detailsObject.segment ?? ""
            let genreString = [genre, subgenre, segment]
                            .filter { !$0.isEmpty }
                            .joined(separator: " | ")
            let favorite = favoritesItem(
                eventId: eventId,
                localDate: detailsObject.localDate ?? "",
                name: detailsObject.name ?? "",
                genre: genreString,
                venue: detailsObject.venue ?? ""
            )
            if let encoded = try? JSONEncoder().encode(favorite){
                defaults.set(encoded, forKey: defaultsKey)
                isFavorite = true
            }
        }
    }
    
    var body: some View {
        if(detailsObject.name == ""){
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .onAppear()
            {
                handleLoad()
            }
        }
        else{
            ScrollView {
                VStack{
                    Spacer()
                    Text(detailsObject.name ?? "")
                        .font(.title)
                        .fontWeight(.bold)
                        .font(.system(size: 24))
                    HStack(alignment: .top){
                        VStack(alignment: .leading){
                            Text("Date")
                                .fontWeight(.bold)
                            Text(detailsObject.localDate ?? "")
                        }
                        Spacer()
                        VStack(alignment: .trailing){
                            Text("Artist | Team")
                                .fontWeight(.bold)
                            
                            if let artists = detailsObject.artists {
                                let artistString = artists.joined(separator: " | ")
                                Text(artistString)
                            }
                        }
                    }
                    .padding(.vertical, 5)
                    HStack(alignment: .top){
                        VStack(alignment: .leading){
                            Text("Venue")
                                .fontWeight(.bold)
                            Text(detailsObject.venue ?? "")
                        }
                        Spacer()
                        VStack(alignment: .trailing){
                            let genre = detailsObject.genre ?? ""
                            let subgenre = detailsObject.subgenre ?? ""
                            let segment = detailsObject.segment ?? ""
                            let genreString = [genre, subgenre, segment]
                                            .filter { !$0.isEmpty }
                                            .joined(separator: " | ")
                            Text("Genre")
                                .fontWeight(.bold)
                            Text(genreString)
                        }
                    }
                    .padding(.vertical, 5)
                    HStack(alignment: .top){
                        VStack(alignment: .leading){
                            Text("Price Range")
                                .fontWeight(.bold)
                            let minPrice = String(detailsObject.minPrice ?? 0.0)
                            let maxPrice = String(detailsObject.maxPrice ?? 0.0)
                            Text(minPrice + "-" + maxPrice)
                        }
                        Spacer()
                        VStack(alignment: .trailing){
                            Text("Ticket Status")
                                .fontWeight(.bold)
                            if(detailsObject.ticketStatus == "onsale"){
                                ZStack {
                                    Rectangle()
                                        .fill(Color.green)
                                        .frame(width: 80, height: 40)
                                        .cornerRadius(10)
                                    Text("On Sale")
                                        .foregroundColor(.white)
                                }
                            }
                            else if(detailsObject.ticketStatus == "cancelled"){
                                ZStack {
                                    Rectangle()
                                        .fill(Color.black)
                                        .frame(width: 100, height: 40)
                                        .cornerRadius(10)
                                    Text("Cancelled")
                                        .foregroundColor(.white)
                                }
                            }
                            else if(detailsObject.ticketStatus == "postponed"){
                                ZStack {
                                    Rectangle()
                                        .fill(Color.orange)
                                        .frame(width: 100, height: 40)
                                        .cornerRadius(10)
                                    Text("Postponed")
                                        .foregroundColor(.white)
                                }
                            }
                            else if(detailsObject.ticketStatus == "rescheduled"){
                                ZStack {
                                    Rectangle()
                                        .fill(Color.orange)
                                        .frame(width: 120, height: 40)
                                        .cornerRadius(10)
                                    Text("Rescheduled")
                                        .foregroundColor(.white)
                                }
                            }
                            else if(detailsObject.ticketStatus == "offsale"){
                                ZStack {
                                    Rectangle()
                                        .fill(Color.red)
                                        .frame(width: 80, height: 40)
                                        .cornerRadius(10)
                                    Text("Off Sale")
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 5)
                    if(!isFavorite){
                        Button(action: { handleSaveEvent()
                        }, label: {
                            Text("Save Event")
                        })
                        .buttonStyle(.borderedProminent)
                        .scaleEffect(1.25)
                    }
                    else{
                        Button(action: { handleSaveEvent()
                        }, label: {
                            Text("Remove Favorite")
                        })
                        .buttonStyle(.borderedProminent)
                        .scaleEffect(1.25)
                        .accentColor(.red)
                    }
                    AsyncImage(url: URL(string: detailsObject.seatmap ?? "")){phase in
                        switch phase {
                        case .empty:
                            Text("No Seatmap Available")
                                .fontWeight(.bold)
                                .padding()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 500, maxHeight: 550)
                        case .failure:
                            Color.red
                        @unknown default:
                            Color.gray
                        }
                    }
                    HStack{
                        Text("Buy Ticket At:")
                            .fontWeight(.bold)
                        Text("Ticketmaster")
                            .foregroundColor(.blue)
                            .onTapGesture {
                                guard let url = URL(string: detailsObject.ticketURL ?? "") else { return }
                                UIApplication.shared.open(url)
                            }
                    }
                    HStack{
                        Text("Share On:")
                            .fontWeight(.bold)
                        AsyncImage(url: URL(string: facebookUrl)){phase in
                            switch phase {
                            case .empty:
                                Color.gray
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: 50, maxHeight: 100)
                            case .failure:
                                Color.red
                            @unknown default:
                                Color.gray
                            }
                        }
                        .onTapGesture {
                            let facebookLink = "https://www.facebook.com/sharer/sharer.php?u=" + (detailsObject.ticketURL ?? "") + "&amp;src=sdkpreparse"
                            guard let url = URL(string: facebookLink) else { return }
                            UIApplication.shared.open(url)
                        }
                        AsyncImage(url: URL(string: twitterUrl)){phase in
                            switch phase {
                            case .empty:
                                Color.gray
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: 50, maxHeight: 100)
                            case .failure:
                                Color.red
                            @unknown default:
                                Color.gray
                            }
                        }
                        .onTapGesture {
                            let nameAttribute = String(detailsObject.name?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
                            let ticketUrlAttribute = String(detailsObject.ticketURL?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
                            let twitterLink = "https://twitter.com/intent/tweet?text=Check%20\(nameAttribute)%20on%20Ticketmaster%20\(ticketUrlAttribute)"
                            print(twitterLink)
                            guard let url = URL(string: twitterLink) else {
                                print("returing here")
                                return }
                            UIApplication.shared.open(url)
                        }
                    }
                }
                .padding()
            }
            Spacer()
        }
    }
}
