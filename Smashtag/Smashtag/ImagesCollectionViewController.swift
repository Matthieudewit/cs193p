//
//  ImagesCollectionViewController.swift
//  Smashtag
//
//  Created by Vojta Molda on 6/8/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit


class ImagesCollectionViewController: UICollectionViewController {
    
    var tweets: [[Tweet]] = [] {
        didSet {
            images = tweets.reduce([]) {
                    $0 + $1
                }.map {
                    tweet in tweet.media.map { TweetMedia(tweet: tweet, media: $0) }
                }.reduce([]) {
                    $0 + $1
                }
        }
    }

    var scale: CGFloat = 1.0 {
        didSet {
            collectionView!.collectionViewLayout.invalidateLayout()
        }
    }
    
    private var cache = NSCache()
    
    private var images = [TweetMedia]()

    private struct TweetMedia {
        var tweet: Tweet
        var media: MediaItem
    }

    struct Storyboard {
        static let ImageCellReuseIdentifier = "Collection Image"
        static let ShowMentionsSegueIdentifier = "Show Mentions"
        static let CellArea: CGFloat = 4000
    }

    // MARK: - View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView!.delegate = self
        collectionView!.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: "zoom:"))

    }

    func zoom(sender: UIPinchGestureRecognizer) {
        switch sender.state {
        case .Changed:
            scale *= sender.scale
            sender.scale = 1.0
        default:
            break
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        collectionView!.collectionViewLayout.invalidateLayout()
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Collection view data source

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Storyboard.ImageCellReuseIdentifier, forIndexPath: indexPath) as! ImageCollectionViewCell
        cell.imageURL = images[indexPath.row].media.url
        cell.backgroundColor = UIColor.darkGrayColor()
        cell.cache = cache
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(Storyboard.ShowMentionsSegueIdentifier, sender: collectionView.cellForItemAtIndexPath(indexPath))
    }

    // MARK: - Collection view delegate
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let ratio = CGFloat(images[indexPath.row].media.aspectRatio)
            let width = min(sqrt(ratio * Storyboard.CellArea) * scale, collectionView.bounds.size.width)
            let height = width / ratio
            return CGSize(width: width, height: height)
    }

    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == nil { return }
        switch segue.identifier! {
        case Storyboard.ShowMentionsSegueIdentifier:
            if let mentionsController = segue.destinationViewController as? MentionsTableViewController {
                if let senderImageCell = sender as? ImageCollectionViewCell {
                    if let senderCellIndexPath = collectionView?.indexPathForCell(senderImageCell) {
                        mentionsController.tweet = images[senderCellIndexPath.row].tweet
                    }
                }
            }
        default:
            break
        }
    }

}
