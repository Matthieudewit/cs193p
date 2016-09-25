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
    
    fileprivate var cache = NSCache<AnyObject, AnyObject>()
    
    fileprivate var images = [TweetMedia]()

    fileprivate struct TweetMedia {
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
        collectionView!.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(ImagesCollectionViewController.zoom(_:))))

    }

    func zoom(_ sender: UIPinchGestureRecognizer) {
        switch sender.state {
        case .changed:
            scale *= sender.scale
            sender.scale = 1.0
        default:
            break
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView!.collectionViewLayout.invalidateLayout()
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Collection view data source

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.ImageCellReuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        cell.imageURL = images[(indexPath as NSIndexPath).row].media.url
        cell.backgroundColor = UIColor.darkGray
        cell.cache = cache
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: Storyboard.ShowMentionsSegueIdentifier, sender: collectionView.cellForItem(at: indexPath))
    }

    // MARK: - Collection view delegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
            let ratio = CGFloat(images[(indexPath as NSIndexPath).row].media.aspectRatio)
            let width = min(sqrt(ratio * Storyboard.CellArea) * scale, collectionView.bounds.size.width)
            let height = width / ratio
            return CGSize(width: width, height: height)
    }

    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == nil { return }
        switch segue.identifier! {
        case Storyboard.ShowMentionsSegueIdentifier:
            if let mentionsController = segue.destination as? MentionsTableViewController {
                if let senderImageCell = sender as? ImageCollectionViewCell {
                    if let senderCellIndexPath = collectionView?.indexPath(for: senderImageCell) {
                        mentionsController.tweet = images[(senderCellIndexPath as NSIndexPath).row].tweet
                    }
                }
            }
        default:
            break
        }
    }

}
