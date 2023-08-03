//
//  SmartAlbumEnum.swift
//  LoopOut
//
//  Created by victor kabike on 2023/07/29.
//

import Foundation
import Photos
import SwiftUI
import PhotosUI

enum SharedAlbum: String, CaseIterable {
    case familyReunion = "Family Reunion"
    case wedding = "Wedding"
    case babysFirstYear = "Baby's First Year"
    case graduation = "Graduation"
    case roadTrip = "Road Trip"
    case concert = "Concert"
    case holidayCelebrations = "Holiday Celebrations"
    case sportsTournament = "Sports Tournament"
    case hikingAdventures = "Hiking Adventures"
    case birthdayBash = "Birthday Bash"
    
    var icon: Image {
        switch self {
        case .familyReunion:
            return Image(systemName: "person.3")
        case .wedding:
            return Image(systemName: "heart")
        case .babysFirstYear:
            return Image(systemName: "face.smiling")
        case .graduation:
            return Image(systemName: "graduationcap")
        case .roadTrip:
            return Image(systemName: "car")
        case .concert:
            return Image(systemName: "music.note")
        case .holidayCelebrations:
            return Image(systemName: "gift")
        case .sportsTournament:
            return Image(systemName: "sportscourt")
        case .hikingAdventures:
            return Image(systemName: "bicycle")
        case .birthdayBash:
            return Image(systemName: "birthdaycake")
        }
    }
}
