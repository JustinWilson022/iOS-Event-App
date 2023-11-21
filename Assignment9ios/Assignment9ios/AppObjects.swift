//
//  AppObjects.swift
//  Assignment9ios
//
//  Created by Justin Wilson on 4/26/23.
//

import Foundation

// IPInfo Object
struct Loc: Codable{
    let loc: String
}

// Google Maps Geocoding Object
struct Place: Codable {
    let results: [Result]
}

struct Result: Codable {
    let geometry: Geometry
}

struct Geometry: Codable {
    let location: Location
}

struct Location: Codable {
    let lat: Double
    let lng: Double
}

// Ticketmaster Events Object
struct ParsedEvent: Identifiable {
    var id = UUID()
    var eventId: String
    let localDate: String
    let localTime: String?
    let icon: String
    let name: String
    let venue: String
}

// Ticketmaster Response Objects
struct TicketmasterResponse: Decodable {
    let embedded: Embedded?
    let page: Page
    
    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
        case page
    }
}

struct Embedded: Decodable {
    let events: [Event]
}

struct Page: Decodable {
    let totalElements: Int
}

struct Event: Decodable {
    let id: String
    let name: String
    let dates: Dates
    let images: [Icon]
    let embedded: EventEmbedded
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case dates
        case images
        case embedded = "_embedded"
    }
}

struct EventEmbedded: Decodable {
    let venues: [Venue]
}

struct Venue: Decodable {
    let name: String
}

struct Dates: Decodable {
    let start: Start
}

struct Start: Decodable {
    let localDate: String
    let localTime: String?
}

struct Icon: Decodable {
    let url: String
}

// Ticketmaster Events Object
struct ParsedDetails: Identifiable {
    var id = UUID()
    let name: String?
    let localDate: String?
    let localTime: String?
    let artists: [String]?
    let venue: String?
    let genre: String?
    let subgenre: String?
    let segment: String?
    let subtype: String?
    let type: String?
    let minPrice: Double?
    let maxPrice: Double?
    let ticketStatus: String?
    let ticketURL: String?
    let seatmap: String?
}

// Ticketmaster Details Objects
struct TicketmasterEvent: Decodable {
    let name: String
    let dates: EventDates
    let embedded: DetailsEmbedded
    let classifications: [Classification]
    let priceRanges: [PriceRange]?
    let url: String
    let seatmap: Seatmap?
    
    enum CodingKeys: String, CodingKey {
        case name
        case dates = "dates"
        case embedded = "_embedded"
        case classifications
        case priceRanges
        case url
        case seatmap
    }
}

struct EventDates: Decodable {
    let start: DetailsStart
    let status: Status
    
    enum CodingKeys: String, CodingKey {
        case start = "start"
        case status
    }
}

struct DetailsEmbedded: Decodable {
    let attractions: [Attraction]
    let venues: [Venue]
}

struct Classification: Decodable {
    let genre: Genre
    let subGenre: Subgenre
    let segment: Segment
    let subType: Subtype?
    let type: EventType?
    
    enum CodingKeys: String, CodingKey {
        case genre
        case subGenre
        case segment
        case subType
        case type = "type"
    }
}

struct PriceRange: Decodable {
    let min: Double
    let max: Double
}

struct DetailsStart: Decodable {
    let localDate: String
    let localTime: String?
}

struct Status: Decodable{
    let code: String
}

struct Attraction: Decodable {
    let name: String
    let classifications: [Classification]
}

struct Genre: Decodable {
    let name: String
}

struct Subgenre: Decodable {
    let name: String
}

struct Segment: Decodable {
    let name: String
}

struct Subtype: Decodable {
    let name: String
}

struct EventType: Decodable {
    let name: String
}

struct Seatmap: Decodable {
    let staticUrl: String
}

// Spotify API Artist
struct ParsedArtist: Identifiable {
    var id = UUID()
    let followers: Int?
    let artistId: String?
    let popularity: Int?
    let spotifyLink: String?
    let imageUrl: String?
    let name: String?
    var albumImage1: String?
    var albumImage2: String?
    var albumImage3: String?
}

//Spotify API Objects
struct SpotifyObject: Decodable {
    let artists: Artists
}

struct Artists: Decodable {
    let items: [Item]
}

struct Item: Decodable {
    let followers: Followers?
    let id: String?
    let popularity: Int?
    let name: String?
    let external_urls: ExternalUrls?
    let images: [ArtistImage]?
}

struct Followers: Decodable {
    let total: Int?
}

struct ExternalUrls: Decodable {
    let spotify: String?
}

struct ArtistImage: Decodable {
    let url: String?
}

// Spotify Albums Object
struct SpotifyAlbums: Decodable {
    let items: [Item]
}

// Parsed Venue Object
struct ParsedVenue: Identifiable {
    var id = UUID()
    let address: String?
    let city: String?
    let state: String?
    let name: String?
    let phoneNumber: String?
    let openHours: String?
    let generalRule: String?
    let childRule: String?
    let longitude: String?
    let latitude: String?
}

// Venue Objects
struct VenueObject: Decodable {
    let embedded: VenueEmbedded
    
    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
    }
}

struct VenueEmbedded: Decodable {
    let venues: [VenueArray]
}

struct VenueArray: Decodable {
    let address: Address
    let city: City
    let state: VenueState
    let name: String?
    let boxOfficeInfo: BoxOfficeInfo?
    let generalInfo: GeneralInfo?
    let location: VenueLocation?
}

struct Address: Decodable {
    let line1: String?
}

struct City: Decodable {
    let name: String?
}

struct VenueState: Decodable {
    let name: String?
}

struct BoxOfficeInfo: Decodable {
    let phoneNumberDetail: String?
    let openHoursDetail: String?
}

struct GeneralInfo: Decodable {
    let generalRule: String?
    let childRule: String?
}

struct VenueLocation: Decodable {
    let longitude: String?
    let latitude: String? 
}

struct favoritesItem: Codable, Identifiable {
    var id = UUID()
    var eventId: String
    var localDate: String
    var name: String
    var genre: String
    var venue: String
}

struct TicketMasterSuggestions: Decodable {
    let embedded: SuggestionsEmbedded
    
    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
    }
}

struct SuggestionsEmbedded: Decodable {
    let attractions: [SuggestionsAttraction]
}

struct SuggestionsAttraction: Decodable {
    let name: String
}

