//
//  CollectionViewController.swift
//  Flicky
//
//  Created by Gale on 2/2/16.
//  Copyright © 2016 Gale. All rights reserved.
//

import UIKit

class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
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
        
        // Making search bar black ???
        searchBar.frame = CGRectMake(0, 20, self.view.frame.size.width, 30)
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
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            print("response: \(responseDictionary)")
                            
                            self.movies = (responseDictionary["results"] as! [NSDictionary])
                            self.filteredMovies = self.movies
                            self.collectionView.reloadData()
                            self.completedProgress(true);
                    }
                }
        })
        task.resume()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
    // such animated much fake :'(
    func completedProgress(dataFetched : Bool?) {
        timer!.invalidate()
        if(dataFetched != false) {
            progressBar.setProgress(1.0, animated: true)
            // Fading away the progress bar because it hides immediately otherwise
            UIView.animateWithDuration(2.0, animations: {
                self.progressBar.alpha = 0.0
            })
        }
    }
    
    func showNetworkAlert() {
        self.networkAlertView.hidden = false
    }
    
    func hideNetworkAlert() {
        self.networkAlertView.hidden = true
    }
    
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
        
        let baseUrl = "http://image.tmdb.org/t/p/w300"
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = NSURL(string: baseUrl + posterPath)
            let imageRequest = NSURLRequest(URL: imageUrl!)
            
            // Fading in the image!
            cell.movieView.setImageWithURLRequest(imageRequest, placeholderImage: nil, success: { (imageRequest, imageResponse, image) -> Void in
                if imageResponse != nil {
                    print("Image was not cached, fade in image")
                    cell.movieView.alpha = 0.0
                    cell.movieView.image = image
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        cell.movieView.alpha = 1.0
                    })
                } else {
                    print("Image was cached so just update the image")
                    cell.movieView.image = image
                }
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
    
    // Function run when user refreshes
    func refreshControlAction(refreshControl: UIRefreshControl) {
        startProgress()
        // Create the NSURLRequest (myRequest)
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                
                // Use the new data to update the data source
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            print("response: \(responseDictionary)")
                            
                            self.movies = (responseDictionary["results"] as! [NSDictionary])
                            
                            // Reload the tableView now that there is new data
                            self.filteredMovies = self.movies
                            self.collectionView.reloadData()
                            self.completedProgress(true)
                            // Tell the refreshControl to stop spinning
                            refreshControl.endRefreshing()
                            
                    }
                }
                
        });
        task.resume()
    }
    
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
        self.collectionView.reloadData()
    }


    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
