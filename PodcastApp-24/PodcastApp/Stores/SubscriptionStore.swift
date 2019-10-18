//
//  SubscriptionStore.swift
//  PodcastApp
//
//  Created by Ben Scheirman on 7/26/19.
//  Copyright © 2019 NSScreencast. All rights reserved.
//

import Foundation
import CoreData

class SubscriptionStore {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func isSubscribed(to id: String) -> Bool {
        do {
            return try findSubscription(with: id) != nil
        } catch {
            return false
        }
    }

    func findSubscription(with podcastId: String) throws -> SubscriptionEntity? {
        let fetch: NSFetchRequest<SubscriptionEntity> = SubscriptionEntity.fetchRequest()
        fetch.fetchLimit = 1
        fetch.predicate = NSPredicate(format: "podcast.id == %@", podcastId)
        return try context.fetch(fetch).first
    }

    func fetchSubscriptions() throws -> [SubscriptionEntity] {
        let fetch: NSFetchRequest<SubscriptionEntity> = SubscriptionEntity.fetchRequest()
        fetch.returnsObjectsAsFaults = false
        fetch.relationshipKeyPathsForPrefetching = ["podcast"]
        fetch.sortDescriptors = [NSSortDescriptor(key: "dateSubscribed", ascending: false)]
        return try context.fetch(fetch)
    }

    @discardableResult func subscribe(to podcast: Podcast) throws -> SubscriptionEntity {
        let podcastEntity = PodcastEntity(context: context)
        podcastEntity.id = podcast.id
        podcastEntity.title = podcast.title
        podcastEntity.podcastDescription = podcast.description
        podcastEntity.author = podcast.author
        podcastEntity.genre = podcast.primaryGenre
        podcastEntity.artworkURLString = podcast.artworkURL?.absoluteString
        podcastEntity.feedURLString = podcast.feedURL.absoluteString

        let subscription = SubscriptionEntity(context: context)
        subscription.dateSubscribed = Date()
        subscription.podcast = podcastEntity

        try context.save()

        let change = SubscriptionsChanged(subscribed: [podcast.id])
        NotificationCenter.default.post(change)

        return subscription
    }

    func unsubscribe(from podcast: Podcast) throws {
        if let sub = try findSubscription(with: podcast.id) {
            context.delete(sub)
            try context.save()

            let change = SubscriptionsChanged(unsubscribed: [podcast.id])
            NotificationCenter.default.post(change)
        }
    }

    func findPodcast(with podcastId: String) throws -> PodcastEntity? {
        let fetch: NSFetchRequest<PodcastEntity> = PodcastEntity.fetchRequest()
        fetch.fetchLimit = 1
        fetch.predicate = NSPredicate(format: "id == %@", podcastId)
        return try context.fetch(fetch).first
    }
}
