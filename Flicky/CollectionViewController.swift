//
//  CollectionViewController.swift
//  Flicky
//
//  Created by Gale on 2/2/16.
//  Copyright © 2016 Gale. All rights reserved.
//

import UIKit

class CollectionViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var networkAlertView: UIView!
    
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    var time: Float = 0.0
    var timer: NSTimer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Making search bar black
        searchBar.frame = CGRectMake(0, 20, self.view.frame.size.width, 15)
        searchBar.barTintColor = UIColor.blackColor()
        searchBar.barStyle = UIBarStyle.Black
        
        // Gradient
        let color1 = UIColor.blackColor()
        let color2 = UIColor(red: 20.0/255, green: 20.0/255, blue: 20.0/255, alpha: 1.0)
        let color3 = UIColor(red: 40.0/255, green: 40.0/255, blue: 40.0/255, alpha: 1.0)
        let color4 = UIColor(red: 60.0/255, green: 60.0/255, blue: 60.0/255, alpha: 1.0)
        
        let gradientColor: [CGColor] = [color1.CGColor, color2.CGColor, color3.CGColor, color4.CGColor]
        let gradientLocations: [Float] = [0.0, 0.25, 0.75, 1.0]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColor
        gradientLayer.locations = gradientLocations
        
        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, atIndex: 0)
        
        // Defining tap gesture for network alert view
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: "handleTap")
        self.networkAlertView.addGestureRecognizer(tap)

        // Do any additional setup after loading the view.
        hideNetworkAlert()
        startProgress()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self
        
        // Refreshing action
        
        let refreshControl: UIRefreshControl = {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
            return refreshControl
        }()
        self.collectionView.addSubview(refreshControl)
        
        filteredMovies = movies
        
        networkCall()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Network Call
    
    func networkCall() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if error != nil {
                    self.completedProgress(false)
                    self.showNetworkAlert()
                } else if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            print("response: \(responseDictionary)")
                            
                            self.movies = (responseDictionary["results"] as! [NSDictionary])
                            self.filteredMovies = self.movies
                            self.collectionView.reloadData()
                            self.completedProgress(true)
                            
                    }
                }
        })
        task.resume()
    }
    
    // MARK: - Progress Bar Functions
    
    // Starting fake progress bar
    func startProgress() {
        networkAlertView.hidden = true
        progressBar.progress = 0.0
        progressBar.trackTintColor = UIColor.grayColor()
        progressBar.progressTintColor = UIColor.whiteColor()
        time = 0.0
        UIView.animateWithDuration(0.5, animations: {
            self.progressBar.alpha = 1.0
        })
        timer = NSTimer.scheduledTimerWithTimeInterval(0.001, target: self, selector:Selector("updateProgress"), userInfo: nil, repeats: true)
    }
    
    // Updating fake progress bar
    func updateProgress() {
        time += 0.001
        progressBar.setProgress(time / 4, animated: true)
        if time >= 2.0 {
            timer!.invalidate()
        }
    }
    
    // After data is fetched completing the fake progress bar
    func completedProgress(dataFetched : Bool?) {
        self.hideNetworkAlert()
        timer!.invalidate()
        if(dataFetched != false) {
            progressBar.setProgress(1.0, animated: true)
            // Fading away the progress bar because it hides immediately otherwise
            UIView.animateWithDuration(2.0, animations: {
                self.progressBar.alpha = 0.0
            })
        }
    }
    
    // MARK: - Network Alert Functions
    
    // Response to network alert view tap gesture to make another network call
    func handleTap() {
        print("tapped")
        networkCall()
    }
    
    func showNetworkAlert() {
        self.networkAlertView.hidden = false
    }
    
    func hideNetworkAlert() {
        self.networkAlertView.hidden = true
    }
    
    // MARK: - Refresh Action
    
    // Function run when user refreshes
    func refreshControlAction(refreshControl: UIRefreshControl) {
        startProgress()
        networkCall()
        refreshControl.endRefreshing()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        // Determining which view is being navigated to in order to provide correct info
        if(segue.identifier == "forDetailsView"){
            
            let cell = sender as! UICollectionViewCell
            let indexPath = collectionView.indexPathForCell(cell)
            let movie = filteredMovies![indexPath!.row]
            
            let detailViewController = segue.destinationViewController as! DetailsViewController
            detailViewController.movie = movie
            
            // Hiding tab bar when the is pushed to the detailViewController
            detailViewController.hidesBottomBarWhenPushed = true
            
            //Back button
            self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "")
            self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "")

        }
    }
    
}


// MARK: - UICollectionViewDataSource & UICollectionViewDelegate

extension CollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let filteredMovies = filteredMovies {
            return filteredMovies.count
            
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionCell", forIndexPath: indexPath) as! CollectionCell
        let movie = filteredMovies![indexPath.row]
        
        if let posterPath = movie["poster_path"] as? String {
            
            let smallImageUrl = "https://image.tmdb.org/t/p/w45"
            let largeImageUrl = "https://image.tmdb.org/t/p/original"
            
            let smallImageRequest = NSURLRequest(URL: NSURL(string: smallImageUrl + posterPath)!)
            let largeImageRequest = NSURLRequest(URL: NSURL(string: largeImageUrl + posterPath)!)
            
            // Fading in the image!
            cell.movieView.setImageWithURLRequest(smallImageRequest, placeholderImage: nil, success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                if smallImageResponse != nil {
                    print("Image was not cached, fade in image")
                    cell.movieView.alpha = 0.0
                    cell.movieView.image = smallImage
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        cell.movieView.alpha = 1.0
                    })
                } else {
                    print("Image was cached so just update the image")
                    cell.movieView.image = smallImage
                }
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    
                    cell.movieView.alpha = 1.0
                    
                    }, completion: { (sucess) -> Void in
                        
                        // The AFNetworking ImageView Category only allows one request to be sent at a time
                        // per ImageView. This code must be in the completion block.
                        cell.movieView.setImageWithURLRequest(
                            largeImageRequest,
                            placeholderImage: smallImage,
                            success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                
                                cell.movieView.image = largeImage;
                                
                            },
                            failure: { (request, response, error) -> Void in
                                // do something for the failure condition of the large image request
                                // possibly setting the ImageView's image to a default image
                        })
                })
                
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // if we have a network error ... show nothing?
            })
            
            
        } else {
            // no image
            cell.movieView.image = nil
            
        }
        
        return cell
    }

}

// MARK: - UISearchBarDelegate

extension CollectionViewController: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovies = searchText.isEmpty ? movies : movies!.filter({(movieDictionary: NSDictionary) -> Bool in
            return (movieDictionary["title"] as! String).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
        })
        
        self.collectionView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filteredMovies = movies
        collectionView.reloadData()
    }

}