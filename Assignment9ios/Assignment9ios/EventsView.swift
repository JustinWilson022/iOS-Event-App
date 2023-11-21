//
//  EventsView.swift
//  Assignment9ios
//
//  Created by Justin Wilson on 4/26/23.
//

import SwiftUI
import Alamofire
import Geohash

struct EventsView: View {
    // Form fields
    @State private var keyword = ""
    @State private var distance = "10"
    @State private var selectedCategory = "Default"
    @State private var location = ""
    @State private var isAutoDetect = false
    let categories = ["Default", "Music", "Sports", "Arts & Theater", "Film", "Miscellaneous"]
    var isKeywordValid: Bool { !keyword.isEmpty }
    var isLocation: Bool { !location.isEmpty || isAutoDetect}
    @State private var noResults = false
    @State private var isSubmitted = false
    @State private var keywordErrorMessage = ""
    @State private var locationErrorMessage = ""
    @State private var isShowingSuggestions = false
    @State private var didSelectSuggestion = false
    
    // Array of events
    @State private var eventsArray = [ParsedEvent]()
    @State private var suggestions: [String] = []
    
    func handleSubmit(){
        if !isKeywordValid {
            keywordErrorMessage = "Keyword is required"
            return
        }
        if(!isLocation){
            locationErrorMessage = "Location is required"
            return
        }
        keywordErrorMessage = ""
        locationErrorMessage = ""
        isSubmitted = true
        noResults = false
        if(isAutoDetect){
            let ipInfoKey = "de6c88a9386e0f";
            let ipInfoURL = "https://ipinfo.io/json?token=" + ipInfoKey;
            AF.request(ipInfoURL)
            .responseDecodable(of: Loc.self) {response in
                switch response.result {
                case .success(let location):
                    let latLong = location.loc.split(separator: ",")
                    let lat = Double(latLong[0])
                    let long = Double(latLong[1])
                    let geohash = Geohash.encode(latitude: lat ?? 0.0, longitude: long ?? 0.0, length: 8)
                    handleResults(keyword: keyword, distance: distance, selectedCategory: selectedCategory, location: geohash)
                case .failure(let error):
                    print(error)
                }
            }
        }
        else{
            var modLocation = location.replacingOccurrences(of: ",", with: "")
            modLocation = modLocation.replacingOccurrences(of: " ", with: "+")
            let mapsKey = "AIzaSyDlyulkwctv1k_FyQc583S6xMVp65HYty4"
            let mapsURL = "https://maps.googleapis.com/maps/api/geocode/json?address=" + modLocation + "&key=" + mapsKey
            AF.request(mapsURL)
            .responseDecodable(of: Place.self) { response in
                switch response.result{
                case .success(let place):
                    if let firstResult = place.results.first {
                        let lat = firstResult.geometry.location.lat
                        let long = firstResult.geometry.location.lng
                        let geohash = Geohash.encode(latitude: lat , longitude: long , length: 8)
                        handleResults(keyword: keyword, distance: distance, selectedCategory: selectedCategory, location: geohash)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func handleClear(){
        suggestions.removeAll()
        noResults = false
        isSubmitted = false
        keywordErrorMessage = ""
        locationErrorMessage = ""
        eventsArray.removeAll()
        keyword = ""
        distance = "10"
        selectedCategory = "Default"
        location = ""
        isAutoDetect = false
    }
    
    func handleResults(keyword: String, distance: String, selectedCategory: String, location: String){
        eventsArray.removeAll()
        var segmentId = "";
        if(selectedCategory == "music") {
            segmentId = "KZFzniwnSyZfZ7v7nJ";
        } else if(selectedCategory == "sports") {
            segmentId = "KZFzniwnSyZfZ7v7nE";
        } else if(selectedCategory == "art") {
            segmentId = "KZFzniwnSyZfZ7v7na";
        } else if(selectedCategory == "miscellaneous") {
            segmentId = "KZFzniwnSyZfZ7v7n1";
        }
        
        var modKeword = keyword.replacingOccurrences(of: ",", with: "")
        modKeword = modKeword.replacingOccurrences(of: " ", with: "+")
        
        let baseURLString = "https://assignment8-380515.wl.r.appspot.com/events?"
        let keywordParam = "keyword=" + modKeword
        let segmentIdParam = "&segmentId=" + segmentId
        let distanceParam = "&distance=" + distance
        let locationParam = "&geohash=" + location

        let eventsURL = baseURLString + keywordParam + segmentIdParam + distanceParam + locationParam

        AF.request(eventsURL)
            .responseDecodable(of: TicketmasterResponse.self) { response in
            switch response.result {
            case .success(let data):
                if(data.page.totalElements == 0){
                    print("in here")
                    noResults = true
                    isSubmitted = false
                    return
                }
                if let events = data.embedded?.events.prefix(10){
                    for event in events {
                        print(event)
                        let newEvent = ParsedEvent(
                            eventId: event.id,
                            localDate: event.dates.start.localDate,
                            localTime: event.dates.start.localTime ?? "",
                            icon: event.images.first?.url ?? "",
                            name: event.name,
                            venue: event.embedded.venues[0].name)
                        eventsArray.append(newEvent)
                    }
                }
                print(eventsArray)
                isSubmitted = false
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchSuggestions(for query: String){
        let modQuery = query.replacingOccurrences(of: " ", with: "+")
        let suggestionsUrl = "https://app.ticketmaster.com/discovery/v2/suggest?apikey=GcUX3HW4Tr1bbGAHzBsQR2VRr2cPM0wx&keyword=" + modQuery
        AF.request(suggestionsUrl)
            .responseDecodable(of: TicketMasterSuggestions.self) { response in
                switch response.result {
                case .success(let data):
                    for i in 0..<data.embedded.attractions.count {
                        suggestions.append(data.embedded.attractions[i].name)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        isShowingSuggestions = true
    }
    
    var body: some View {
        NavigationView(){
            Form {
                HStack {
                    Text("Keyword: ")
                    Spacer()
                    TextField("", text:$keyword)
                        .onChange(of: keyword) { query in
                            if(didSelectSuggestion){
                                didSelectSuggestion = false
                                return
                            }
                            else if(query.count >= 4){
                                fetchSuggestions(for: query)
                            }
                        }
                }
                if !keywordErrorMessage.isEmpty {
                    Text(keywordErrorMessage)
                        .foregroundColor(.red)
                }
                HStack {
                    Text("Distance: ")
                    Spacer()
                    TextField("", text:$distance)
                        .keyboardType(.numberPad)
                }
                Picker("Category:", selection: $selectedCategory){
                    ForEach(categories, id: \.self){
                        Text($0)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                HStack{
                    Text("Location: ")
                    Spacer()
                    TextField("", text:$location)
                        .disabled(isAutoDetect)
                }
                Toggle("Auto Detect My Location", isOn: $isAutoDetect)
                    .onChange(of: isAutoDetect) { _ in
                        if isAutoDetect {
                            location = ""
                        }
                    }
                    .disabled(!location.isEmpty)
                if !locationErrorMessage.isEmpty {
                    Text(locationErrorMessage)
                        .foregroundColor(.red)
                }
                HStack {
                    Spacer()
                    Button(action: {handleSubmit()}, label: {
                        Text("Submit")
                    })
                    .accentColor(.red)
                    Spacer()
                    Button(action: {handleClear()}, label: {
                        Text("Clear")
                    })
                    Spacer()
                }
                .buttonStyle(.borderedProminent)
                .padding()
                .scaleEffect(1.25)
                
                Section{
                    if(isSubmitted){
                        HStack{
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            Text("Please Wait...")
                                .foregroundColor(.gray)
                        }
                    }
                    else{
                        EventsListView(eventsArray: eventsArray, noResults: noResults)
                    }
                }
            }
            .navigationTitle("Event Search")
            .navigationBarItems(trailing:
                NavigationLink(destination: FavoritesView()){
                    Image(systemName: "heart.circle")
                }
            )
            .sheet(isPresented: $isShowingSuggestions) {
                List {
                    ForEach(suggestions, id: \.self) { suggestion in
                        Text(suggestion)
                            .onTapGesture {
                                keyword = suggestion
                                suggestions = []
                                isShowingSuggestions = false
                                didSelectSuggestion = true
                            }
                    }
                }
            }
        }
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView()
    }
}
