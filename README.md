# Project 1 - *Flicky*

**Flicky** is a movies app using the [The Movie Database API](http://docs.themoviedb.apiary.io/#).

Time spent: **X** hours spent in total

## User Stories

The following **required** functionality is complete:

- [x] User can view a list of movies currently playing in theaters from The Movie Database.
- [x] Poster images are loaded using the UIImageView category in the AFNetworking library.
- [ ] User sees a loading state while waiting for the movies API.
- [x] User can pull to refresh the movie list.

The following **optional** features are implemented:

- [ ] User sees an error message when there's a networking error.
- [ ] Movies are displayed using a CollectionView instead of a TableView.
- [x] User can search for a movie.
- [x] All images fade in as they are loading.
- [ ] Customize the UI.

The following **additional** features are implemented:

- [ ] Tap top/bar area to scroll up the table view (similar to a back to top button on a website w/o the button)
- [ ] Gradient background of gray => black
- [ ] Bottom bar with buttons for other views that display __Now Playing__, __Top Rated__, __Upcoming__, __Popular__, __Watch List__ movies
- [ ] Add a view (__Watch List__) where the user can add movies they would like to watch
- [ ] Animation when flipping between the different views mentioned previously
- [ ] Use long press in any view to add a movie to the __Watch List__
- [ ] Custom movie/theater related icons, buttons & launch screen
- [ ] Use [WebView](http://stackoverflow.com/questions/31762450/ios-in-app-browser) to allow users to see more information about a movie in an online movie site and potentially purchase tickets
- [ ] Shake for a random movie suggestion? (This might be tricky since the movies aren't saved to the device!)
- [ ] [iPhone app tour](http://stackoverflow.com/questions/13335540/how-to-make-first-launch-iphone-app-tour-guide-with-xcode) for the [first launch](http://stackoverflow.com/questions/19376201/ios-first-launch-tour-detecting-if-the-app-is-launched-for-the-first-time)

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

1.
2.

## Video Walkthrough

Here's a walkthrough of implemented user stories:

<img src='https://github.com/venegu/flicky/raw/master/flicky.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

Describe any challenges encountered while building the app.

## Resources

   - http://rest.elkstein.org

   - http://stackoverflow.com/questions/28780862/use-functions-from-other-files-in-swift-xcode

   - http://stackoverflow.com/questions/25575030/how-to-convert-nsnull-to-nil-in-swift

### Progress Bars

   - http://stackoverflow.com/questions/27815248/how-to-set-the-progress-tint-color-in-uiprogressview

   - http://www.ioscreator.com/tutorials/progress-view-tutorial-in-ios8-with-swift

   - http://rshankar.com/swift-demo-add-progress-bar/

   - http://stackoverflow.com/questions/19211999/showing-a-uiprogressview-inside-or-on-top-of-a-uinavigationcontrollers-uinaviga

   - http://www.devfright.com/ios-data-download-progress-bar-tutorial/

## Learning Notes

### Tables

   - In order to make a table you will need to update view controller class to include `UITableViewDataSource` and `UITableViewDelegate` as follow:

   ``` swift
   class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

   ```

   - In addition to the above, two functions must be added: `numberOfRowsInSection` and `cellForRowAtIndexPath`. You can find these functions by holding down Command and hovering over `UITableViewDataSource` and `UITableViewDelegate` in the function above.

   Below are examples of these functions from my code:

   ```swift
   func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 20

    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath)
        cell.textLabel?.text = "row: \(indexPath.row)"
        print("row \(indexPath.row)")
        return cell
    }

    ```

### APIs

   - An __API (Application Programming Interface)__ is any web server that can understand HTTP requests and expose resources to any program that can send an HTTP request, where resources are something like `movie/now_playing` (ex. JSON).

   - They generally provide examples of GET, POST, etc.

   - __REST (Representational State Transfer)__ is an architecture for designing networked aplications where simple HTTP requests are used to make calls between machines.

   - Most modern web applications have collections of things with properties ex. Facebook users (w/properties like name, hometown, relationship status, etc.) and their posts (w/properties like time posted, # of likes, comments, etc.). We use REST to manipulate these properties.

   - RESTful applications use HTTP requests to post data (create/update), read data, and delete data. These operations that can occur to collections of "things" with properties are known as __CRUD (Create/Read/Update/Delete)__.

### App Transport Security (ATS)

   - Requires apps to require an HTTPS connection to prevent "leaks" by default.

   - New feature of iOS 9 that can be turned off by adding `NSAppTransportSecurity` to `Info.plist` although turning off this feature is strongly discouraged.

### Progress Bars
   - Initialize the progress and a timer inside the ViewController class:
   ```swift
   var progressView: UIProgressView?
   var timer: NSTimer?

   ```

   - Have a function that creates the progress view:
   ```swift
   func startProgress() {
        progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.Default)
        progressView!.transform = CGAffineTransformScale(progressView!.transform, 2, 1)
        progressView?.center = self.view.center
        progressView!.trackTintColor = UIColor.grayColor()
        progressView!.progressTintColor = UIColor.blackColor()
        view.addSubview(progressView!)
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateProgress", userInfo: nil, repeats: true)
    }
   ```
   - Have another function that updates the progress bar:
   ```swift
   func updateProgress() {
        if progressView?.progress <= 0.90 {
            progressView?.progress += 0.05
        }
        let progressValue = self.progressView?.progress
    }
    ```
   - Lastly, have a function that finishes off after the data is loaded:
   ```swift
   func completedProgress() {
        if progressView?.progress == 0.90 {
            progressView?.progress += 0.05
        }
        let progressValue = self.progressView?.progress
    }
    ```

   - Call them appropriately?


## License

    Copyright [2016] [Lisa Maldonado]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

    # Project 2 - *Flicky*

**Flicky** is a movies app displaying box office and top rental DVDs using [The Movie Database API](http://docs.themoviedb.apiary.io/#).

Time spent: **X** hours spent in total

## User Stories

The following **required** functionality is completed:

- [ ] User can view movie details by tapping on a cell.
- [ ] User can select from a tab bar for either **Now Playing** or **Top Rated** movies.
- [ ] Customize the selection effect of the cell.

The following **optional** features are implemented:

- [ ] For the large poster, load the low resolution image first and then switch to the high resolution image when complete.
- [ ] Customize the navigation bar.

The following **additional** features are implemented:

- [ ] List anything else that you can get done to improve the app functionality!

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

1.
2.

## Video Walkthrough

Here's a walkthrough of implemented user stories:

<img src='http://i.imgur.com/link/to/your/gif/flicky2.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

Describe any challenges encountered while building the app.

## License

    Copyright [yyyy] [name of copyright owner]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
