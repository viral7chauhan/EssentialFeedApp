//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Viral on 11/05/22.
//

import Foundation
import EssentialFeed
import UIKit

public final class FeedUIComposer {
    private init() {}

    public static func feedComposeWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presenterAdapter = FeedLoaderPresentationAdaapter(
            feedLoader: MainQueueDispatchDecorator(decoratee: feedLoader))

        let feedController = makeFeedViewController(
            delegate: presenterAdapter,
            title: FeedPresenter.title)

        presenterAdapter.presenter = FeedPresenter(
            feedView: FeedViewAdapter(
                controller: feedController,
                loader: MainQueueDispatchDecorator(decoratee: imageLoader)),
            loadingView: WeakRefVirualProxy(feedController),
            errorView: WeakRefVirualProxy(feedController))

        return feedController
    }

    private static func makeFeedViewController(
        delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
            
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}
