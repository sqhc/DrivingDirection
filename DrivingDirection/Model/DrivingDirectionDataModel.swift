//
//  DrivingDirectionDataModel.swift
//  DrivingDirection
//
//  Created by 沈清昊 on 5/15/23.
//

import Foundation

struct DrivingDirection: Codable{
    let data: DirectionData?
}

struct DirectionData: Codable{
    let best_routes: [DirectionRoute]?
    let origin: LocationData?
    let destination: LocationData?
}

struct DirectionRoute: Codable{
    let route_name: String?
    let distance_label: String?
    let duration_label: String?
    let departure_datetime_utc: String?
    let arrival_datetime_utc: String?
}

struct LocationData: Codable{
    let latitude: Double?
    let longitude: Double?
    let full_address: String?
}
