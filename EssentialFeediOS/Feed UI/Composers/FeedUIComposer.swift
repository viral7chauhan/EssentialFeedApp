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
        let feedViewModel = FeedViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(viewModel: feedViewModel)
        let feedController = FeedViewController(refreshController: refreshController)
        feedViewModel.onFeedLoaded = adaptFeedToCellController(forwardingTo: feedController, loader: imageLoader)
        return feedController
    }

    static func adaptFeedToCellController(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                FeedImageCellController(viewModel: FeedImageViewModel(model: model,
                                                                      imageLoader: loader,
                                                                      imageTransformer: UIImage.init))
            }
        }
    }
}