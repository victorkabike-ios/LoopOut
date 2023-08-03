//
//  TabViewController.swift
//  LoopOut
//
//  Created by victor kabike on 2023/07/27.
//

import Foundation
import SwiftUI

struct ViewController: View {
    @StateObject private var router = TabViewRouter()
    @EnvironmentObject var photoLibraryService : PhotoLibraryService
    @EnvironmentObject  var assetCollectionLibraryService: CollectionLibraryService
    var mediaLibraryService =  MediaLibraryService()
    var body: some View {
        TabView(selection: $router.selectedTab) {
            ContentView()
                .tabItem {
                    Label("Photos", systemImage: "photo")
                }
                .tag(Tab.photos)
                .environmentObject(photoLibraryService)
            
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "book")
                }
                .tag(Tab.library)
                .environmentObject(assetCollectionLibraryService)
                .environmentObject(mediaLibraryService)
            
            UtilitiesView()
                .tabItem {
                    Label("Utilities", systemImage: "gear")
                }
                .tag(Tab.utilities)
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(Tab.search)
        }
        
        .background(Color.gray.opacity(0.1))
    }
}





struct SearchView: View {
    var body: some View {
        Text("Search")
    }
}
enum Tab: Hashable {
    case photos
    case library
    case utilities
    case search
}
class TabViewRouter: ObservableObject {
    @Published var selectedTab: Tab = .photos
}
