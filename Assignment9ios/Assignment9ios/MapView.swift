//
//  MapView.swift
//  Assignment9ios
//
//  Created by Justin Wilson on 5/1/23.
//

import SwiftUI
import MapKit

struct MapLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct MapView: View {
    var latitude: String
    var longitude: String
    @State var coordinateRegion: MKCoordinateRegion
    var coordinate: CLLocationCoordinate2D
    
    init(latitude: String, longitude: String) {
        self.latitude = latitude
        self.longitude = longitude
        self._coordinateRegion = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: Double(latitude) ?? 0.0, longitude: Double(longitude) ?? 0.0),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)))
        self.coordinate = CLLocationCoordinate2D(latitude: Double(latitude) ?? 0.0, longitude: Double(longitude) ?? 0.0)
    }
    
    var body: some View {
        Map(coordinateRegion: $coordinateRegion, annotationItems: [MapLocation(coordinate: coordinate)]){location in
            MapMarker(coordinate: location.coordinate, tint: .red)
        }
    }
}
