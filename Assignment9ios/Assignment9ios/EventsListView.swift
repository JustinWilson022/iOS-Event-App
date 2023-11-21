//
//  EventsListView.swift
//  Assignment9ios
//
//  Created by Justin Wilson on 4/27/23.
//

import SwiftUI

struct EventsListView: View {
    var eventsArray: [ParsedEvent]
    var noResults: Bool
    
    var body: some View {
        if(noResults){
            Text("Results")
                .font(.title)
                .fontWeight(.bold)
            Text("No Results")
                .foregroundColor(.red)
        }
        else if (!eventsArray.isEmpty){
            Text("Results")
                .font(.title)
                .fontWeight(.bold)
            List(eventsArray) {event in
                NavigationLink(destination: EventDetailsView(eventId: event.eventId)) {
                    HStack(){
                        Text("\(event.localDate)\(event.localTime!.isEmpty ? "" : " - \(event.localTime ?? "")")")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        AsyncImage(url: URL(string: event.icon)){phase in
                            switch phase {
                            case .empty:
                                Color.gray
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: 100, maxHeight: 150)
                            case .failure:
                                Color.red
                            @unknown default:
                                Color.gray
                            }
                        }
                        Text(event.name)
                            .fontWeight(.bold)
                        Text(event.venue)
                    }
                }
            }
        }
    }
}

