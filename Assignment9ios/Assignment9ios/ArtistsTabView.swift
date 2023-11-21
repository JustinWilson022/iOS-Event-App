//
//  ArtistsTabView.swift
//  Assignment9ios
//
//  Created by Justin Wilson on 5/1/23.
//

import SwiftUI
import Alamofire

struct ArtistsTabView: View {
    var eventId: String
    @State private var artists = [String]()
    @State private var artistsDetails = [ParsedArtist]()
    let spotifyImage = "https://www.freepnglogos.com/uploads/spotify-logo-png/spotify-icon-green-logo-8.png"
    @State private var musicFlag = true
    
    func handleLoad(){
        let detailsURL = "https://assignment8-380515.wl.r.appspot.com/details?eventID=" + eventId
        AF.request(detailsURL)
            .responseDecodable(of: TicketmasterEvent.self) { response in
                switch response.result {
                case .success(let ticketmasterEvent):
                    let attractions = ticketmasterEvent.embedded.attractions
                    for attraction in attractions {
                        if(attraction.classifications.first?.segment.name == "Music"){
                            let name = String(attraction.name)
                            artists.append(name)
                        }
                    }
                    print(artists)
                    if(artists.isEmpty){
                        musicFlag = false
                        break
                    }
                    for artist in artists {
                        let artistName = artist.replacingOccurrences(of: " ", with: "+")
                        let spotifyUrl = "https://assignment8-380515.wl.r.appspot.com/spotify?artist=" + artistName
                        AF.request(spotifyUrl)
                            .responseDecodable(of: SpotifyObject.self) { response in
                                switch response.result {
                                case .success(let data):
                                    var artistResponse = ParsedArtist(
                                        followers: data.artists.items.first?.followers?.total,
                                        artistId: data.artists.items.first?.id,
                                        popularity: data.artists.items.first?.popularity,
                                        spotifyLink: data.artists.items.first?.external_urls?.spotify,
                                        imageUrl: data.artists.items.first?.images?.first?.url,
                                        name: data.artists.items.first?.name,
                                        albumImage1: "", albumImage2: "", albumImage3: "")
                                    let albumsUrl = "https://assignment8-380515.wl.r.appspot.com/albums?artistId=" + (artistResponse.artistId ?? "")
                                    AF.request(albumsUrl)
                                        .responseDecodable(of: SpotifyAlbums.self) { response in
                                            switch response.result {
                                            case .success(let albums):
                                                artistResponse.albumImage1 = albums.items[0].images?.first?.url
                                                artistResponse.albumImage2 = albums.items[1].images?.first?.url
                                                artistResponse.albumImage3 = albums.items[2].images?.first?.url
                                                artistsDetails.append(artistResponse)
                                            case .failure(let error):
                                                print(error)
                                            }
                                        }
                                case .failure(let error):
                                    print(error)
                                }
                            }
                    }
                case .failure(let error):
                    print(error)
                }
        }
        
    }
    
    func formatFollowersCount(_ count: Int) -> String {
        let abbreviations = [
            1000: "K",
            1000000: "M",
            1000000000: "B"
        ]
        
        let sortedKeys = abbreviations.keys.sorted(by: >)
        for key in sortedKeys {
            if count >= key {
                let num = Double(count) / Double(key)
                let roundedNum = String(format: "%.1f", roundTo(places: 1, value: num))
                return "\(roundedNum)\(abbreviations[key]!)"
            }
        }
        
        return "\(count)"
    }
    
    func roundTo(places: Int, value: Double) -> Double {
        let divisor = pow(10.0, Double(places))
        return (value * divisor).rounded() / divisor
    }
    
    var body: some View {
        if(!musicFlag){
            Text("No music related artist details to show")
                .font(.title)
                .fontWeight(.bold)
                .padding()
                .multilineTextAlignment(.center)
        }
        else if(artists.isEmpty){
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
                    ForEach(0..<artistsDetails.count, id: \.self) { index in
                        let artist = artistsDetails[index]
                        GroupBox("") {
                            HStack{
                                AsyncImage(url: URL(string: artist.imageUrl ?? "")){phase in
                                    switch phase {
                                    case .empty:
                                        Color.gray
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxWidth: 200, maxHeight: 200)
                                            .cornerRadius(10)
                                    case .failure:
                                        Color.red
                                    @unknown default:
                                        Color.gray
                                    }
                                }
                                VStack(alignment: .leading){
                                    Text(artist.name ?? "")
                                        .fontWeight(.bold)
                                    HStack{
                                        Text(formatFollowersCount(artist.followers ?? 0))
                                        Text("Followers")
                                    }
                                    HStack{
                                        AsyncImage(url: URL(string: spotifyImage)){phase in
                                            switch phase {
                                            case .empty:
                                                Color.gray
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(maxWidth: 50, maxHeight: 50)
                                            case .failure:
                                                Color.red
                                            @unknown default:
                                                Color.gray
                                            }
                                        }
                                        Text("Spotify")
                                            .foregroundColor(.green)
                                    }
                                    .onTapGesture {
                                        guard let url = URL(string: artist.spotifyLink ?? "") else { return }
                                        UIApplication.shared.open(url)
                                    }
                                }
                                VStack{
                                    Text("Popularity")
                                    ZStack{
                                        CircularProgressView(progress: Double(artist.popularity ?? 0))
                                        Text(String(artist.popularity ?? 0))
                                    }.frame(width: 50, height: 50)
                                }
                            }
                            Text("Popular Albums")
                                .fontWeight(.bold)
                            HStack{
                                AsyncImage(url: URL(string: artist.albumImage1 ?? "")){phase in
                                    switch phase {
                                    case .empty:
                                        Color.gray
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxWidth: 200, maxHeight: 200)
                                            .cornerRadius(10)
                                    case .failure:
                                        Color.red
                                    @unknown default:
                                        Color.gray
                                    }
                                }
                                AsyncImage(url: URL(string: artist.albumImage2 ?? "")){phase in
                                    switch phase {
                                    case .empty:
                                        Color.gray
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxWidth: 200, maxHeight: 200)
                                            .cornerRadius(10)
                                    case .failure:
                                        Color.red
                                    @unknown default:
                                        Color.gray
                                    }
                                }
                                AsyncImage(url: URL(string: artist.albumImage3 ?? "")){phase in
                                    switch phase {
                                    case .empty:
                                        Color.gray
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxWidth: 200, maxHeight: 200)
                                            .cornerRadius(10)
                                    case .failure:
                                        Color.red
                                    @unknown default:
                                        Color.gray
                                    }
                                }
                            }
                        }
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
    }
}
