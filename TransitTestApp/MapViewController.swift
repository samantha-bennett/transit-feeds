//
//  MapViewController.swift
//  TransitTestApp
//
//  Created by Samantha Bennett on 9/16/21.
//

import UIKit
import MapKit
import os.log

class MapViewController: UIViewController {
    let mapView = MKMapView()
    let feedsManager = FeedsManagar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.feedsManager.delegate = self

        self.view.addSubview(mapView)
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(TransitFeedAnnotation.self))
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.feedsManager.requestFeeds()
    }
}

extension MapViewController : FeedsManagerDelegate {
    func feedsManager(_ feedsManager: FeedsManagar, updatedFeeds: TransitFeeds?) {
        os_log(.debug, "updated feeds")
        mapView.removeAnnotations(mapView.annotations)
        if let feeds = updatedFeeds {
            for feed in feeds.feeds {
                let annotation = TransitFeedAnnotation(transitFeed: feed)
                
                self.mapView.addAnnotation(annotation)                
            }
        }
    }
}

extension MapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? TransitFeedAnnotation else { return nil }
        
        let identifier = NSStringFromClass(TransitFeedAnnotation.self)
        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation) as? MKMarkerAnnotationView else { return nil }
        annotationView.canShowCallout = true
        
        if let pinColor = annotation.pinColor {
            annotationView.markerTintColor = pinColor
        }
        
        var callout = annotationView.detailCalloutAccessoryView as? TransitFeedAnnotationCallout
        if callout == nil {
            callout = TransitFeedAnnotationCallout()
            annotationView.detailCalloutAccessoryView = callout
        }
        
        callout?.titleLabel.text = annotation.transitFeed.name
        callout?.subtitleLabel.text = annotation.transitFeed.location
        
        return annotationView
    }
}
