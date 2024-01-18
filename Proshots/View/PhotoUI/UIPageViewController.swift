//
//  UIPageViewController.swift
//  LoopOut
//
//  Created by victor kabike on 2023/09/21.
//

import Foundation
import SwiftUI
import Photos
import UIKit

struct PageViewController: UIViewControllerRepresentable {
    var controllers: [UIViewController]
    @Binding var currentPage: Int

    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator
        return pageViewController
    }

    func updateUIViewController(_ uiViewController: UIPageViewController, context: Context) {
        uiViewController.setViewControllers([controllers[currentPage]], direction: .forward, animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PageViewController

        init(_ pageViewController: PageViewController) {
            self.parent = pageViewController
        }

        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let index = parent.controllers.firstIndex(of: viewController) else {
                return nil
            }
            if index == 0 {
                return nil
            }
            return parent.controllers[index - 1]
        }

        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let index = parent.controllers.firstIndex(of: viewController) else {
                return nil
            }
            if index == parent.controllers.count - 1 {
                return nil
            }
            return parent.controllers[index + 1]
        }

        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            if completed,
               let visibleViewController = pageViewController.viewControllers?.first,
               let index = parent.controllers.firstIndex(of: visibleViewController) {
                parent.currentPage = index
            }
        }
    }
}

struct PhotoPreviewGallery: View {
    @EnvironmentObject var photoLibraryService: PhotoLibraryService
    var photos: [PHAsset]
    @State private var currentPage: Int = 0

    var body: some View {
        PageViewController(controllers: photoPreviewControllers, currentPage: $currentPage)
    }

    private var photoPreviewControllers: [UIViewController] {
        var controllers: [UIViewController] = []
        for photo in photos {
            let photoPreview = PhotoPreview(photo: photo, photoAssets: photos)
            let controller = UIHostingController(rootView: photoPreview)
            controllers.append(controller)
        }
        return controllers
    }
}

