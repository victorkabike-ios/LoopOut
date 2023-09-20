//
//  PhotoInfoView.swift
//  LoopOut
//
//  Created by victor kabike on 2023/08/18.
//

import SwiftUI
import Photos
import CoreLocation
import MapKit

struct LocationWrapper: Identifiable {
    let id = UUID()
    let location: CLLocation
}

struct PhotoInfoView: View {
    let asset: PHAsset
    @State private var metadata: [String: Any]?
//    @State private var location: String = "Unknown"
    @State private var locationName: String = ""
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0),span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    
              
    var body: some View {
        NavigationStack{
            ScrollView{
                LazyVStack{
                    LabeledContent {
                        VStack(spacing: 5){
                            Text("\(formattedSize())")
                                .foregroundColor(Color.white)
                                .padding(8)
                                .background(LinearGradient(colors: [Color.blue, Color.cyan], startPoint: .leading, endPoint: .trailing))
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 10)
                                    
                                )
                        }
                        
                    } label: {
                        HStack(alignment: .center, spacing: 18){
                            Image(systemName:  "photo")
                                .foregroundColor(Color.white)
                                .background(content: {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.indigo)
                                        .frame(width: 30, height:30)
                                })
                            
                            VStack(alignment: .leading){
                                Text(getFilename(of:asset) ?? "UnKnown")
                                    .font(.custom("NetflixSans-Medium", size: 16))
                                    .foregroundColor(.white)
                                Text("\(formattedDate())")
                                    .font(.custom("NetflixSans-Regular", size: 12))
                                    .foregroundColor(Color(uiColor: .systemGray2))
                            }
                        }
                    }.padding(.vertical)
                    MetadataView(asset: asset)
                    if let location = asset.location {
                        VStack(alignment: .leading){
                            Map(coordinateRegion: $region, showsUserLocation: false, userTrackingMode: .none,
                                annotationItems: [LocationWrapper(location: location)]) { locationWrapper in
                                MapPin(coordinate: locationWrapper.location.coordinate, tint: .blue)
                            }
                                .frame(height: 150)
                            HStack{
                                Text(locationName)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding()
                                Spacer()
                                Button(action: {}) {
                                    Text("Edit")
                                        .foregroundColor(.blue)
                                }
                                .padding()
                            }
                        }
                        .padding(.bottom)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        
                    }
                    Spacer()
                }.padding()
            }
            .onAppear {
                fetchLocationName()
                setRegionForMap()
            }
        }
    }
    func getFilename(of asset: PHAsset) -> String? {
        let resources = PHAssetResource.assetResources(for: asset)
        return resources.first?.originalFilename
    }
    private func formattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy 'at' HH:mm:ss"
        return dateFormatter.string(from: asset.creationDate ?? Date())
    }
    private func formattedSize() -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(asset.pixelWidth * asset.pixelHeight))
    }
    private func fetchLocationName() {
           guard let location = asset.location else { return }
           
           let geocoder = CLGeocoder()
           geocoder.reverseGeocodeLocation(location) { placemarks, error in
               if let placemark = placemarks?.first {
                   if let name = placemark.name,
                      let city = placemark.locality,
                      let country = placemark.country {
                       locationName = "\(name), \(city), \(country)"
                   }
               }
           }
       }
    private func setRegionForMap() {
        if let location = asset.location {
            region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        }
    }
}
struct MetadataView: View {
    let asset: PHAsset
    @State private var exifData: ExifData?
    @State private var tIFFData: TIFFData?

    var body: some View {
            VStack{
                if let exifData = exifData, let tIFFData = tIFFData  {
                    ExifDataView(exifData: exifData, tIFFData: tIFFData)
                } else {
                    Text("No Exif data available")
                        .font(.headline)
                        .foregroundColor(.red)
                }
            }
            .onAppear(perform: loadExifData)
    }
    func getMetadata(of asset: PHAsset, completion: @escaping ([String: Any]?) -> Void) {
        asset.getMetadata { metadata in
            guard let metadata = metadata else {
                print("Failed to get metadata")
                completion(nil)
                return
            }

            completion(metadata)
        }
    }
    func loadExifData() {
            getMetadata(of: asset) { metadata in
                if let metadataDict = metadata?[kCGImagePropertyExifDictionary as String] as? [String:Any] {
                    self.exifData = ExifData(from: metadataDict)
                } else {
                    self.exifData = nil
                }
                if let metadataDict = metadata?[kCGImagePropertyTIFFDictionary as String] as? [String:Any] {
                    self.tIFFData = TIFFData(from: metadataDict)
                } else {
                    self.tIFFData = nil
                }
                
            }
        }

}
struct ExifDataView: View {
    let exifData: ExifData
    let tIFFData: TIFFData
    func getSubstring(text: String, from: Int, to: Int) -> String? {
        guard from >= 0, to >= 0, from < text.count, to < text.count else {
            return nil
        }
        let start = text.index(text.startIndex, offsetBy: from)
        let end = text.index(text.startIndex, offsetBy: to)
        return String(text[start...end])
    }
    func formatNumber(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: number)) ?? "0"
    }
    func formatFNumber(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: number)) ?? "0"
    }
    var body: some View {
        GroupBox{
            VStack(alignment: .leading, spacing: 12){
                LabeledContent {
                    let pixelHeight = String(exifData.pixelXDimension ?? 0)
                    let pixelWidth = String(exifData.pixelYDimension ?? 0)
                    Text("\(pixelWidth) x \(pixelHeight)")
                        .font(.custom("NetflixSans-Medium", size: 12))
                        .foregroundColor(Color.white)
                        .padding(6)
                        .background(Color(uiColor: .systemGray2))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } label: {
                    HStack(alignment: .center, spacing: 18){
                        Image(systemName: "camera")
                            .foregroundColor(Color.white)
                            .background(content: {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue)
                                    .frame(width: 30, height:30)
                            })
                        VStack(alignment: .leading){
                            Text("Apple \(tIFFData.model ?? "")")
                                .font(.custom("NetflixSans-Medium", size: 19))
                                .foregroundColor(Color.white)
                            displayLensInformation(from: exifData)
                        }
                    }
                }
                
                Divider()
                VStack(alignment: .leading, spacing: 15){
                    LabeledContent {
                        let text = String(exifData.isoSpeedRatings?.description ?? "N/A")
                        if let subText = getSubstring(text: text, from: 1, to: 2) {
                            Text("ISO \(subText)")
                                .font(.custom("NetflixSans-Regular", size: 15))
                                .foregroundColor(Color(uiColor: .systemGray))
                        }
                    } label: {
                        HStack(alignment: .center, spacing: 18){
                            Image(systemName: "speedometer")
                                .foregroundColor(Color.white)
                                .background(content: {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.blue)
                                        .frame(width: 30, height:30)
                                })
                            
                            Text("ISO Speed")
                                .font(.custom("NetflixSans-Regular", size: 16))
                                .foregroundColor(Color.white)
                        }
                    }
                    Divider()
                    LabeledContent {
                        Text("\(exifData.focalLenIn35mmFilm ?? 0) mm")
                            .font(.custom("NetflixSans-Regular", size: 15))
                            .foregroundColor(Color(uiColor: .systemGray))
                    } label: {
                        HStack(alignment: .center, spacing: 18){
                            Image(systemName: "ruler")
                                .foregroundColor(Color.white)
                                .background(content: {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.red)
                                        .frame(width: 30, height:30)
                                })
                            Text("FocalLenIn35mmFilm")
                                .font(.custom("NetflixSans-Regular", size: 16))
                                .foregroundColor(Color.white)
                            Spacer()
                            
                        }
                    }
                    Divider()
                    LabeledContent {
                        let formattedfNumber = formatFNumber(exifData.fNumber ?? 0)
                        Text("f")
                            .italic()
                            .font(.custom("NetflixSans_It", size: 15))
                            .foregroundColor(Color(uiColor: .systemGray))
                        + Text("/\(formattedfNumber)")
                            .font(.custom("NetflixSans-Regular", size: 15))
                            .foregroundColor(Color(uiColor: .systemGray))
                    } label: {
                        HStack(alignment: .center, spacing: 18){
                            Image(systemName: "camera.aperture")
                                .foregroundColor(Color.white)
                                .background(content: {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.green)
                                        .frame(width: 30, height:30)
                                })
                            Text("FNumber")
                                .font(.custom("NetflixSans-Regular", size: 16))
                                .foregroundColor(Color.white)
                            
                        }
                    }
                    Divider()
                    LabeledContent {
                        if let apexShutterSpeedValue = exifData.shutterSpeedValue {
                            let shutterSpeedInSeconds = pow(2, -apexShutterSpeedValue)
                            let shutterSpeedAsFraction = 1 / shutterSpeedInSeconds
                            let roundedShutterSpeedAsFraction = round(shutterSpeedAsFraction)
                            Text(" 1/\(Int(roundedShutterSpeedAsFraction))")
                                .font(.custom("NetflixSans-Medium", size: 15))
                                .foregroundColor(Color(uiColor: .systemGray))
                            
                            
                        } else {
                            Text(" ")
                        }
                    } label: {
                        HStack(alignment: .center, spacing: 18){
                            Image(systemName: "timer")
                                .foregroundColor(Color.white)
                                .background(content: {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.orange)
                                        .frame(width: 30, height:30)
                                })
                            
                            Text("Shutter speed")
                                .font(.custom("NetflixSans-Regular", size: 16))
                                .foregroundColor(Color.white)
                            
                            
                        }
                    }
                    
                }
                
                
            }
        }
    }
    func displayLensInformation(from exifData: ExifData) -> some View {
        if let lensModel = exifData.lensModel {
            let pattern = "iPhone \\d+\\s"
            let regex = try? NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: lensModel.utf16.count)
            if let match = regex?.firstMatch(in: lensModel, options: [], range: range) {
                var cameraName = String(lensModel[lensModel.index(lensModel.startIndex, offsetBy: match.range.location + match.range.length)...])
                
                // Remove focal length
                let focalLengthPattern = "\\d+\\.\\d+mm"
                let focalLengthRegex = try? NSRegularExpression(pattern: focalLengthPattern, options: [])
                cameraName = focalLengthRegex?.stringByReplacingMatches(in: cameraName, options: [], range: NSRange(location: 0, length: cameraName.utf16.count), withTemplate: "") ?? cameraName

                // Remove FNumber
                let fNumberPattern = "f/\\d+\\.\\d+"
                let fNumberRegex = try? NSRegularExpression(pattern: fNumberPattern, options: [])
                cameraName = fNumberRegex?.stringByReplacingMatches(in: cameraName, options: [], range: NSRange(location: 0, length: cameraName.utf16.count), withTemplate: "") ?? cameraName
                
                return Text("\(cameraName.trimmingCharacters(in: .whitespaces))")
                    .font(.custom("NetflixSans-Medium", size: 13))
                    .foregroundColor(Color(uiColor: .systemGray))
            } else {
                return Text("Lens information not available.")
                    .font(.custom("NetflixSans-Medium", size: 16))
                    .foregroundColor(Color(uiColor: .systemGray))
            }
        } else {
            return Text("Lens information not available.")
                .font(.custom("NetflixSans-Medium", size: 14))
                .foregroundColor(Color.white)
        }
    }


}

extension PHAsset {
    func getMetadata(completion: @escaping ([String: Any]?) -> Void) {
        let options = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = true
        requestContentEditingInput(with: options) { input, _ in
            guard let url = input?.fullSizeImageURL,
                  let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil),
                  let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else {
                completion(nil)
                return
            }
            completion(imageProperties)
        }
    }
}
