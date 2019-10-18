//
//  FeedImporter.swift
//  PodcastApp
//
//  Created by Ben Scheirman on 10/18/19.
//  Copyright © 2019 NSScreencast. All rights reserved.
//

import Foundation

class FeedImporter {
    static let shared = FeedImporter()

    private var notificationObserver: NSObjectProtocol?
    private var importQueue: OperationQueue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 2
        q.qualityOfService = .userInitiated
        return q
    }()

    func startListening() {
        notificationObserver = NotificationCenter.default.addObserver(SubscriptionsChanged.self, sender: nil, queue: nil) { notification in
            notification.subscribedIds.forEach(self.onSubscribe)
            notification.unsubscribedIds.forEach(self.onUnsubscribe)
        }
    }

    private func onSubscribe(podcastId: String) {
        let operation = ImportEpisodesOperation(podcastId: podcastId)
        importQueue.addOperation(operation)
    }

    private func onUnsubscribe(podcastId: String) {

    }
}

