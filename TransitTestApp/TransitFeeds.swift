//
//  TransitFeeds.swift
//  TransitTestApp
//
//  Created by Samantha Bennett on 9/19/21.
//

import Foundation
import OSLog

public struct Throwable<T: Decodable>: Decodable {
    public let result: Result<T, Error>

    public init(from decoder: Decoder) throws {
        let catching = { try T(from: decoder) }
        result = Result(catching: catching )
    }
}

struct TransitFeeds : Decodable {
    let feeds: [TransitFeed]
    
    enum CodingKeys: String, CodingKey {
        case feeds
    }
    
    init(feeds: [TransitFeed]) {
        self.feeds = feeds
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let throwables = try values.decode([Throwable<TransitFeed>].self, forKey: .feeds)
        
        var feeds = [TransitFeed]()
        for throwable in throwables {
            switch throwable.result {
            case .success(let transitFeed):
                feeds.append(transitFeed)
            case .failure(let error):
                os_log(.error, "Couldn't decode feed in json error: \(error.localizedDescription).")
            }
        }
        self.feeds = feeds
    }
}

extension TransitFeeds {
    static func decodeJSON(data: Data) -> TransitFeeds {
        do {
            let feeds = try JSONDecoder().decode(TransitFeeds.self, from: data)
            return feeds
        } catch {
            os_log(.error, "Couldn't decode feed in json error: \(error.localizedDescription).")
        }
        return TransitFeeds(feeds: [TransitFeed]())
    }
}
