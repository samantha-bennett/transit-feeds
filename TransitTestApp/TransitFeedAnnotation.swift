//
//  TransitFeedAnnotation.swift
//  TransitTestApp
//
//  Created by Samantha Bennett on 9/19/21.
//

import MapKit

class TransitFeedAnnotationCallout : UIView {
    let titleLabel: UILabel
    let subtitleLabel: UILabel
    
    override init(frame: CGRect) {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        stackView.addArrangedSubview(titleLabel)
        
        subtitleLabel = UILabel()
        subtitleLabel.numberOfLines = 0
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        stackView.addArrangedSubview(subtitleLabel)
        
        super.init(frame: frame)
        self.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TransitFeedAnnotation : NSObject, MKAnnotation {
    let transitFeed: TransitFeed

    var coordinate: CLLocationCoordinate2D {
        if var bounds = transitFeed.bounds {
            return bounds.centerCoordinate
        }
        return kCLLocationCoordinate2DInvalid
    }
    
    
    var pinColor: UIColor? {
        switch transitFeed.countryCode {
        case "CA":
            return UIColor(named: "CanadaPinColor")
        case "US":
            return UIColor(named: "UnitedStatesPinColor")
        case "FR":
            return UIColor(named: "FrancePinColor")
        case "GB":
            return UIColor(named: "UnitedKingdomPinColor")
        case "DE":
            return UIColor(named: "GermanyPinColor")
        default:
            return UIColor(named: "DefaultPinColor")
        }
    }
    
    init(transitFeed: TransitFeed) {
        self.transitFeed = transitFeed
    }
        
}
