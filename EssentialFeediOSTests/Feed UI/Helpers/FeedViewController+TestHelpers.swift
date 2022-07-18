//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Viral on 11/05/22.
//

import UIKit
import EssentialFeediOS

extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatorePullToRefresh()
    }

    @discardableResult
    func simulateFeedImageVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }

    @discardableResult
    func simulateFeedImageNotVisible(at row: Int) -> FeedImageCell? {
        let view = simulateFeedImageVisible(at: row)

        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImageSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)

        return view
    }

    var errorMessage: String? {
        return errorView?.message
    }
    
    var isShowLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }

    func numberOfRenderedFeedImageViews() -> Int {
        return tableView.numberOfRows(inSection: feedImageSection)
    }

    private var feedImageSection: Int {
        return 0
    }

    func feedImageView(at row: Int) -> UITableViewCell? {
        let source = tableView.dataSource
        let indexPath = IndexPath(row: row, section: feedImageSection)
        return source?.tableView(tableView, cellForRowAt: indexPath)
    }

    func simulateFeedImageViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImageSection)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }

    func simulateFeedImageViewNotNearVisible(at row: Int) {
        simulateFeedImageViewNearVisible(at: row)

        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImageSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
}
