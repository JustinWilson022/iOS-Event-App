//
//  VenueTabView.swift
//  Assignment9ios
//
//  Created by Justin Wilson on 5/1/23.
//

import SwiftUI
import Alamofire

struct VenueTabView: View {
    var eventId: String
    @State private var eventName = ""
    @State private var venueDetails = ParsedVenue(address: "", city: "", state: "", name: "", phoneNumber: "", openHours: "", generalRule: "", childRule: "", longitude: "", latitude: "")
    @State private var isShowingMap = false
    
    func handleLoad(){
        let detailsURL = "https://assignment8-380515.wl.r.appspot.com/details?eventID=" + eventId
        AF.request(detailsURL)
            .responseDecodable(of: TicketmasterEvent.self) { response in
                switch response.result {
                case .success(let ticketmasterEvent):
                    let venue = ticketmasterEvent.embedded.venues.first?.name ?? ""
                    let venueName = venue.replacingOccurrences(of: " ", with: "+")
                    eventName = ticketmasterEvent.name
                    let venueUrl = "https://assignment8-380515.wl.r.appspot.com/venue?venueName=" + venueName
                    AF.request(venueUrl)
                        .responseDecodable(of: VenueObject.self) { response in
                            switch response.result {
                            case .success(let data):
                                venueDetails = ParsedVenue(
                                    address: data.embedded.venues.first?.address.line1,
                                    city: data.embedded.venues.first?.city.name,
                                    state: data.embedded.venues.first?.state.name,
                                    name: data.embedded.venues.first?.name,
                                    phoneNumber: data.embedded.venues.first?.boxOfficeInfo?.phoneNumberDetail,
                                    openHours: data.embedded.venues.first?.boxOfficeInfo?.openHoursDetail,
                                    generalRule: data.embedded.venues.first?.generalInfo?.generalRule,
                                    childRule: data.embedded.venues.first?.generalInfo?.childRule,
                                    longitude: data.embedded.venues.first?.location?.longitude,
                                    latitude: data.embedded.venues.first?.location?.latitude)
                            case .failure(let error):
                                print(error)
                            }
                        }
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    var body: some View {
        if(venueDetails.name == ""){
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .onAppear()
            {
                handleLoad()
            }
        }
        else{
            ScrollView {
                VStack {
                    Text(venueDetails.name ?? "")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom, 10)
                    VStack{
                        Text("Name")
                            .fontWeight(.bold)
                        Text(venueDetails.name ?? "")
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 10)
                    VStack{
                        Text("Address")
                            .fontWeight(.bold)
                        Text(venueDetails.address ?? "")
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 10)
                    VStack{
                        Text("Phone Number")
                            .fontWeight(.bold)
                        ScrollView(.vertical) {
                            Text(venueDetails.phoneNumber ?? "")
                                .foregroundColor(.gray)
                        }
                        .frame(maxHeight: 75)
                    }
                    .padding(.bottom, 10)
                    VStack{
                        Text("Open Hours")
                            .fontWeight(.bold)
                        ScrollView {
                            Text(venueDetails.openHours ?? "")
                                .foregroundColor(.gray)
                        }
                        .frame(maxHeight: 75)
                    }
                    .padding(.bottom, 10)
                    VStack{
                        Text("General Rule")
                            .fontWeight(.bold)
                        ScrollView {
                            Text(venueDetails.generalRule ?? "")
                                .foregroundColor(.gray)
                        }
                        .frame(maxHeight: 75)
                    }
                    .padding(.bottom, 10)
                    VStack{
                        Text("Child Rule")
                            .fontWeight(.bold)
                        ScrollView {
                            Text(venueDetails.childRule ?? "")
                                .foregroundColor(.gray)
                        }
                        .frame(maxHeight: 75)
                    }
                    .padding(.bottom, 10)
                }
                .multilineTextAlignment(.center)
                Button("Show venue on maps") {
                    isShowingMap = true
                }
                .buttonStyle(.borderedProminent)
                .accentColor(.red)
                .sheet(isPresented: $isShowingMap) {
                    MapView(latitude: venueDetails.latitude ?? "", longitude: venueDetails.longitude ?? "")
                        .highPriorityGesture(DragGesture())
                        .padding()
                        .presentationDragIndicator(.visible)
                }
            }
        }
    }
}

