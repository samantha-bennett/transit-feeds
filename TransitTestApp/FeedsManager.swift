//
//  NetworkManager.swift
//  TransitTestApp
//
//  Created by Samantha Bennett on 9/16/21.
//

import Foundation
import OSLog


protocol FeedsManagerDelegate {
    func feedsManager(_ feedsManager:FeedsManagar, updatedFeeds: TransitFeeds?)
}

// I'm tempted to make this a singleton w/ an observor pattern, but given the project's scope, that seems unwarrented at this time
class FeedsManagar {
    static let TransitFeedsURLAsString = "https://api.transitapp.com/v3/feeds?detailed=1"

    var lastUpdated: Date? = nil
    // For a larger app, we might want to make this a singleton and use an observer pattern.
    var delegate: FeedsManagerDelegate? = nil
    var urlSessionTask: URLSessionTask? = nil
    private(set) public var feeds: TransitFeeds? = nil {
        didSet {
            lastUpdated = Date()
            delegate?.feedsManager(self, updatedFeeds: feeds)
        }
    }
    
    public init() {
    }
    
    private var hasStaleFeeds: Bool {
        get {
            if let lastUpdated = lastUpdated {
                return Calendar.current.isDateInToday(lastUpdated)
            }
            return false
        }
    }
    
    func requestFeeds() {
        // No point in requesting feeds that haven't changed
        guard !hasStaleFeeds || self.feeds == nil else {
            return
        }
        
        self.loadFeeds()
    }
    
    
    private func loadFeeds() {
        guard urlSessionTask?.state != .running else {
            return
        }
        
        guard let feedsURL = URL(string: FeedsManagar.TransitFeedsURLAsString) else { return }
        let urlSession = URLSession.shared
        let urlSessionTask = urlSession.dataTask(with: feedsURL) { [weak self] data, urlResponse, error in
            if let error = error {
                os_log(.error, "Failed to get feed due to error: \(error.localizedDescription)")
            }

            if let data = data {
                DispatchQueue.main.async {
                    if let self = self {
                        self.feeds = TransitFeeds.decodeJSON(data: data)
                    }
                }
            }
        }
        self.urlSessionTask = urlSessionTask
        urlSessionTask.resume()
    }
}
