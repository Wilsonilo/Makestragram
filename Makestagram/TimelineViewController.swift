//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by Wilson Muñoz on 1/7/16.
//  Copyright © 2016 Make School. All rights reserved.
//


import ConvenienceKit
import UIKit
import Parse

var photoTakingHelper: PhotoTakingHelper?
var timelineComponent: TimelineComponent<Post, TimelineViewController>!


class TimelineViewController: UIViewController, TimelineComponentTarget {
    let defaultRange = 0...4
    let additionalRangeSize = 5
    
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    
   
    //Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timelineComponent = TimelineComponent(target: self)
        self.tabBarController?.delegate = self
    }
    
    
    //Did Appear
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        timelineComponent.loadInitialIfRequired()
        
    }
    

    
    //Methods
    
    
    func loadInRange(range: Range<Int>, completionBlock: ([Post]?) -> Void) {
        // 1
        ParseHelper.timelineRequestForCurrentUser(range) {
            (result: [PFObject]?, error: NSError?) -> Void in
            // 2
            let posts = result as? [Post] ?? []
            // 3
            completionBlock(posts)
        }
    }
    
    func takePhoto() {
        // instantiate photo taking class, provide callback for when photo is selected
        photoTakingHelper =
            PhotoTakingHelper(viewController: self.tabBarController!) { (image: UIImage?) in
                let post = Post()
                // 1
                post.image.value = image!
                post.uploadPost()
        }
    }
    
}

// MARK: Tab Bar Delegate

extension TimelineViewController: UITabBarControllerDelegate {

    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        
        if (viewController is PhotoViewController) {
            takePhoto()
            return false
        } else {
            return true
        }
        
    }
    
}

extension TimelineViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 1
        return timelineComponent.content.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
        
        let post = timelineComponent.content[indexPath.row]
        post.downloadImage()
        post.fetchLikes()
        cell.post = post
        
        return cell
    }
    
}


extension TimelineViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        timelineComponent.targetWillDisplayEntry(indexPath.row)
    }
    
}