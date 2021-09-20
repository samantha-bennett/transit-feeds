//
//  TransitFeed.swift
//  TransitTestApp
//
//  Created by Samantha Bennett on 9/18/21.
//

import os.log
import MapKit

struct TransitFeedBounds : Decodable {
    let minLatitude: Double?
    let maxLatitude: Double?
    let minLongitude: Double?
    let maxLongitude: Double?
    lazy var centerCoordinate = computeCenterCoordinate()
    
    enum CodingKeys: String, CodingKey {
        case minLatitude = "min_lat"
        case maxLatitude = "max_lat"
        case minLongitude = "min_lon"
        case maxLongitude = "max_lon"
    }
    
    private func computeCenterCoordinate() -> CLLocationCoordinate2D {
        if let minLongitude = minLongitude, let maxLongitude = maxLongitude, let minLatitude = minLatitude, let maxLatitude = maxLatitude {
            let centerLat = (maxLatitude + minLatitude) / 2
            let centerLong = (maxLongitude + minLongitude) / 2
            return CLLocationCoordinate2DMake(centerLat, centerLong)
        }
        assertionFailure()
        return kCLLocationCoordinate2DInvalid
    }
}

struct TransitFeed : Decodable {
    
    let id: UInt?
    let code: String?
    let timezone: String?
    let name: String?
    let countryCode: String?
    let bounds: TransitFeedBounds?
    let location: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case code = "code"
        case timezone = "timezone"
        case name = "name"
        case countryCode = "country_code"
        case bounds = "bounds"
        case location = "location"
    }
}
