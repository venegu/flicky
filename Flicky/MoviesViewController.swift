//
//  MoviesViewController.swift
//  Flicky
//
//  Created by Gale on 1/27/16.
//  Copyright © 2016 Gale. All rights reserved.
//

import UIKit
import AFNetworking

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var networkAlertView: UIView!

    
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    var time: Float = 0.0
    var timer: NSTimer?
    
    var endpoint: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Making search bar black ???
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
        
        // Hiding network alert view and starting progress bar
        hideNetworkAlert()
        startProgress()
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self

        // Refreshing action
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        filteredMovies = movies
        
        networkCall()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Makes request and fetches necessary data from Movie API
    func networkCall() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
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
                            self.tableView.reloadData()
                            self.completedProgress(true)
                            
                    }
                }
        })
        task.resume()
    }
    
    // Response to network alert view tap gesture to make another network call
    func handleTap() {
        print("tapped")
        networkCall()
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
    
    // Hiding and showing network alert view
    func showNetworkAlert() {
        self.networkAlertView.hidden = false
    }
    
    func hideNetworkAlert() {
        self.networkAlertView.hidden = true
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if let filteredMovies = filteredMovies {
            return filteredMovies.count
        
        } else {
            return 0
        }
    
    }
    
    // Table View Fu
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        // Setting table cell color on selection
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.blackColor()
        cell.selectedBackgroundView = backgroundView
        
        let movie = filteredMovies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        
        let baseUrl = "http://image.tmdb.org/t/p/w150"
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = NSURL(string: baseUrl + posterPath)
            let imageRequest = NSURLRequest(URL: imageUrl!)
            
            // Fading in the image!
            cell.posterView.setImageWithURLRequest(imageRequest, placeholderImage: nil, success: { (imageRequest, imageResponse, image) -> Void in
                if imageResponse != nil {
                    print("Image was not cached, fade in image")
                    cell.posterView.alpha = 0.0
                    cell.posterView.image = image
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        cell.posterView.alpha = 1.0
                    })
                } else {
                    print("Image was cached so just update the image")
                    cell.posterView.image = image
                }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // if we have a network error ... show nothing?
            })

            
        } else {
            // no image 
            cell.posterView.image = nil
            
        }
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        print("row \(indexPath.row)")
        return cell
    }
    
    // Function run when user refreshes
    func refreshControlAction(refreshControl: UIRefreshControl) {
        startProgress()
        networkCall()
        refreshControl.endRefreshing()
    }
    
    
    // Searching for items related to search and displaying those
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovies = searchText.isEmpty ? movies : movies!.filter({(movieDictionary: NSDictionary) -> Bool in
            return (movieDictionary["title"] as! String).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
        })
        
        self.tableView.reloadData()
    }
    
    // Displaying cancel button
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    // Returning intial data back to table view & resigning first responder when cancel is clicked
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filteredMovies = movies
        self.tableView.reloadData()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        
        // Determining which view is being navigated to in order to provide correct info
        if(segue.identifier == "forDetailsView"){
        
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let movie = movies![indexPath!.row]
        
            let detailViewController = segue.destinationViewController as! DetailsViewController
            detailViewController.movie = movie
        
            // Hiding tab bar when the is pushed to the detailViewController
            detailViewController.hidesBottomBarWhenPushed = true
        }
    }


}
