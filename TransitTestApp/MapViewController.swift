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

        self.addZoomControls()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.feedsManager.requestFeeds()
    }
}

// MARK: Zoom controls
extension MapViewController {
    private func addZoomControls() {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(stackView)
        stackView.axis = .vertical
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6)
        stackView.layer.cornerRadius = 6
        stackView.clipsToBounds = true

        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addSubview(blurView)

        let imageConfiguration = UIImage.SymbolConfiguration(textStyle: .subheadline)
        let zoomInAction = UIAction { (action) in
            self.zoom(in: true)
        }
        let zoomInImage = UIImage(systemName: "plus", withConfiguration: imageConfiguration)
        let zoomInButton = UIButton(type: .custom, primaryAction: zoomInAction)
        zoomInButton.setImage(zoomInImage, for: .normal)
        zoomInButton.accessibilityLabel = NSLocalizedString("Zoom in", comment: "accessibility text for zoom in button")
        stackView.addArrangedSubview(zoomInButton)

        let zoomOutAction = UIAction { (action) in
            self.zoom(in: false)
        }
        let zoomOutImage = UIImage(systemName: "minus", withConfiguration: imageConfiguration)
        let zoomOutButton = UIButton(type: .custom, primaryAction: zoomOutAction)
        zoomOutButton.setImage(zoomOutImage, for: .normal)
        zoomOutButton.accessibilityLabel = NSLocalizedString("Zoom out", comment: "accessibility text for zoom out button")
        stackView.addArrangedSubview(zoomOutButton)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -16),

            blurView.topAnchor.constraint(equalTo: stackView.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
        ])
    }

    private func zoom(in isZoomingIn: Bool) {
        let span = mapView.region.span
        let multiplier = isZoomingIn ? 0.5 : 2.0
        let newLatitudeDelta = span.latitudeDelta * multiplier
        let newLongitudeDelta = span.longitudeDelta * multiplier

        // Make sure the span is valid
        guard newLongitudeDelta >= -90 && newLongitudeDelta <= 90 &&
                newLatitudeDelta >= -180 && newLatitudeDelta <= 180 else {
            return
        }

        var region = mapView.region
        region.span = MKCoordinateSpan(latitudeDelta: newLatitudeDelta, longitudeDelta: newLongitudeDelta)

        self.mapView.setRegion(region, animated: true);
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
