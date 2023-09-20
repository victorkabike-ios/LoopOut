//
//  CropOverlayView.swift
//  LoopOut
//
//  Created by victor kabike on 2023/08/13.
//

import Foundation
import Photos
import SwiftUI

enum ResizeRatioOption: CaseIterable {
    case custom
    case landscape
    case square
    case instagramPost
    case instagramStory
    case instagramReel
    case facebbokPost
    case facebookcover
    case facebookProfile
    case facebookEventCover
    case pinterestProfile
    case pinterestPost
    case twitterProfile
    case twitterHeader
    case twitterCard
    case twitterPost
    case youTubeProfile
    case youTubeCover
    case youTubeThumbnail
    case linkedInProfile
    case linkedInBanner
    case linkedInPost
    // Add more cases as needed
    
    var title: String {
        switch self {
        case .custom:
            return "Custom"
        case .landscape:
            return "Landscape"
        case .square:
            return "Square"
        case .instagramPost:
            return "Instagram post"
        case .instagramStory:
            return "Instagram story"
            // Add more cases as needed
        case .instagramReel:
            return "Instagram Reel"
        case .facebbokPost:
            return "Facebook Post"
        case .facebookcover:
            return "Facebook Cover"
        case .facebookProfile:
            return "Facebook Profile"
        case .facebookEventCover:
            return "Facebook Event Cover"
        case .pinterestProfile:
            return "Pinterest Profile"
        case .pinterestPost:
            return "Pinterest Post"
        case .twitterProfile:
            return "Twitter Profile"
        case .twitterHeader:
            return "Twitter Header"
        case .twitterCard:
            return "Twitter Card"
        case .twitterPost:
            return "Twitter Post"
        case .youTubeProfile:
            return "YouTube Profile"
        case .youTubeCover:
            return "YouTube Cover"
        case .youTubeThumbnail:
            return "YouTube Thumbnail"
        case .linkedInProfile:
            return "LinkedIn Profile"
        case .linkedInBanner:
            return "LinkedIn Banner"
        case .linkedInPost:
            return "LinkedIn Post"
        }
    }
    var label: String {
        switch self {
        case .custom:
            return "Custom"
        case .landscape:
            return "Landscape"
        case .square:
            return "Square"
        case .instagramPost:
            return "Post"
        case .instagramStory:
            return "Story"
            // Add more cases as needed
        case .instagramReel:
            return "Reel"
        case .facebbokPost:
            return "Post"
        case .facebookcover:
            return "Cover"
        case .facebookProfile:
            return "Profile"
        case .facebookEventCover:
            return "Event Cover"
        case .pinterestProfile:
            return "Profile"
        case .pinterestPost:
            return "Post"
        case .twitterProfile:
            return "Profile"
        case .twitterHeader:
            return "Header"
        case .twitterCard:
            return "Card"
        case .twitterPost:
            return "Post"
        case .youTubeProfile:
            return "Profile"
        case .youTubeCover:
            return "Cover"
        case .youTubeThumbnail:
            return "Thumbnail"
        case .linkedInProfile:
            return "Profile"
        case .linkedInBanner:
            return "Banner"
        case .linkedInPost:
            return "Post"
        }
    }
    
    var icon: Image {
        // Return the appropriate icon for each case
        switch self {
        case .custom:
            return Image(systemName: "rectangle")
        case .landscape:
            return Image(systemName: "arrow.right.square")
        case .square:
            return Image(systemName: "square")
        case .instagramPost:
            return Image("instagram")
        case .instagramStory:
            return  Image("instagram")
            // Add more cases as needed
        case .instagramReel:
            return Image("instagram")
        case .facebbokPost:
            return Image("facebook")
        case .facebookcover:
            return Image("facebook")
        case .facebookProfile:
            return Image("facebook")
        case .facebookEventCover:
            return Image("facebook")
        case .pinterestProfile:
            return Image("pinterest")
        case .pinterestPost:
            return Image("pinterest")
        case .twitterProfile:
            return Image("twitter")
        case .twitterHeader:
            return Image("twitter")
        case .twitterCard:
            return Image("twitter")
        case .twitterPost:
            return Image("twitter")
        case .youTubeProfile:
            return Image("youtube")
        case .youTubeCover:
            return Image("youtube")
        case .youTubeThumbnail:
            return Image("youtube")
        case .linkedInProfile:
            return Image("linkedin")
        case .linkedInBanner:
            return Image("linkedin")
        case .linkedInPost:
            return Image("linkedin")
        }
    }
    
    var ratioSize: CGSize? {
        switch self {
        case .custom:
            return nil
        case .landscape:
            return CGSize(width: 2016, height: 1512)
        case .square:
            return CGSize(width: 200, height: 200)
        case .instagramPost:
            return CGSize(width: 1080, height: 1080)
        case .instagramStory:
            return CGSize(width: 1080, height: 1920)
            // Add more cases as needed
        case .instagramReel:
            return CGSize(width: 1080, height: 1920)
        case .facebbokPost:
            return CGSize(width: 1080, height: 1080)
        case .facebookcover:
            return CGSize(width: 830, height: 312)
        case .facebookProfile:
            return CGSize(width: 170, height: 170)
        case .facebookEventCover:
            return CGSize(width: 1920, height: 1920)
        case .pinterestProfile:
            return CGSize(width: 165, height: 165)
        case .pinterestPost:
            return CGSize(width: 1000, height:  1500)
        case .twitterProfile:
            return CGSize(width: 400, height:  400)
        case .twitterHeader:
            return CGSize(width: 1500, height:  500)
        case .twitterCard:
            return CGSize(width: 1200, height:  628)
        case .twitterPost:
            return CGSize(width: 1600, height:  900)
        case .youTubeProfile:
            return CGSize(width: 800, height:  800)
        case .youTubeCover:
            return CGSize(width: 2560, height:  1440)
        case .youTubeThumbnail:
            return CGSize(width: 1280, height:  720)
        case .linkedInProfile:
            return CGSize(width: 300, height:  300)
        case .linkedInBanner:
            return CGSize(width: 1128, height:  191)
        case .linkedInPost:
            return CGSize(width: 1200, height:  1200)
        }
    }
    var IconSize: CGSize? {
        switch self {
        case .custom:
            return CGSize(width: 45, height: 45)
        case .landscape:
            return CGSize(width: 50, height: 90)
        case .square:
            return CGSize(width: 50, height: 50)
        case .instagramPost:
            return CGSize(width: 50, height: 60)
        case .instagramStory:
            return CGSize(width: 50, height: 90)
            // Add more cases as needed
        case .instagramReel:
            return CGSize(width: 50, height: 90)
        case .facebbokPost:
            return CGSize(width: 50, height: 60)
        case .facebookcover:
            return CGSize(width: 90, height: 45)
        case .facebookProfile:
            return CGSize(width: 50, height: 50)
        case .facebookEventCover:
            return CGSize(width: 80, height: 80)
        case .pinterestProfile:
            return CGSize(width: 50, height: 50)
        case .pinterestPost:
            return CGSize(width: 50, height:  60)
        case .twitterProfile:
            return CGSize(width: 50, height:  50)
        case .twitterHeader:
            return CGSize(width: 90, height:  50)
        case .twitterCard:
            return CGSize(width: 90, height:  50)
        case .twitterPost:
            return CGSize(width: 80, height:  50)
        case .youTubeProfile:
            return CGSize(width: 50, height:  50)
        case .youTubeCover:
            return CGSize(width: 90, height:  50)
        case .youTubeThumbnail:
            return CGSize(width: 90, height:  60)
        case .linkedInProfile:
            return CGSize(width: 50, height:  50)
        case .linkedInBanner:
            return CGSize(width: 90, height:  30)
        case .linkedInPost:
            return CGSize(width: 50, height:  60)
        }
    }
}
