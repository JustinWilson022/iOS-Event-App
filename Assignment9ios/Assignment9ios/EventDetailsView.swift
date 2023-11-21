//
//  EventDetailsView.swift
//  Assignment9ios
//
//  Created by Justin Wilson on 4/27/23.
//

import SwiftUI

struct EventDetailsView: View {
    var eventId: String
    
    var body: some View {
        VStack{
            TabView {
            // First Tab
            ZStack {
                EventTabView(eventId: eventId)
            }
                .tabItem {
                    Image(systemName: "text.bubble")
                    Text("Events")
                }
            
            // Second Tab
            ZStack {
                ArtistsTabView(eventId: eventId)
            }
                .tabItem {
                    Image(systemName: "guitars")
                    Text("Artist/Team")
                }
            
            // Third Tab
            ZStack {
                VenueTabView(eventId: eventId)
            }
                .tabItem {
                    Image(systemName: "location")
                    Text("Venue")
                }
            }
        }
    }
}
