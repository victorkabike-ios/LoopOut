
import SwiftUI
import Foundation
import ImageIO

struct ExifData {
    let brightness : Double?
    let exposureBiasValue: Double?
    let fNumber: Double?
    let flash: Int?
    let isoSpeedRatings: [Int]?
    let dateTimeOriginal: String?
    let focalLenIn35mmFilm: Int?
    let focalLength: Double?
    let lensModel: String?
    let lensSpecification: [Double]?
    let pixelXDimension: Int?
    let pixelYDimension: Int?
    let shutterSpeedValue: Double?
    let whiteBalance: Double?

    init(from dictionary: [String: Any]) {
        brightness = dictionary["BrightnessValue"] as? Double
        exposureBiasValue = dictionary["ExposureBiasValue"] as? Double
        fNumber = dictionary["FNumber"] as? Double
        flash = dictionary["Flash"] as? Int
        isoSpeedRatings = dictionary["ISOSpeedRatings"] as? [Int]
        dateTimeOriginal = dictionary["DateTimeOriginal"] as? String
        focalLenIn35mmFilm = dictionary["FocalLenIn35mmFilm"] as? Int
        focalLength = dictionary["FocalLength"] as? Double
        lensModel = dictionary["LensModel"] as? String
        lensSpecification = dictionary["LensSpecification"] as? [Double]
        pixelXDimension = dictionary["PixelXDimension"] as? Int
        pixelYDimension = dictionary["PixelYDimension"] as? Int
        shutterSpeedValue = dictionary["ShutterSpeedValue"] as? Double
        whiteBalance = dictionary["WhiteBalance"] as? Double
    }
}

struct TIFFData {
    let dateTime: String?
    let make: String?
    let model: String?
    let orientation: Int?
    let resolutionUnit: Int?
    let software: String?
    let xResolution: Int?
    let yResolution: Int?

    init(from dictionary: [String: Any]) {
        dateTime = dictionary["DateTime"] as? String
        make = dictionary["Make"] as? String
        model = dictionary["Model"] as? String
        orientation = dictionary["Orientation"] as? Int
        resolutionUnit = dictionary["ResolutionUnit"] as? Int
        software = dictionary["Software"] as? String
        xResolution = dictionary["XResolution"] as? Int
        yResolution = dictionary["YResolution"] as? Int
    }
}

