# TopStackOverflowUsers
An App to fetch and display a list of Stack Overflow Users, listed by ranking .
Each of the Users has Avatar which is lazy loaded. 
The App Supports core data caching and Images Caching .
Users can be followed and unfollowed

StackOverflow Users App Solution

I designed the app with clear separation of concerns across decoupled modules, following the Single Responsibility Principle.
Modules communicate through protocols, which makes dependency injection straightforward and improves testability.

1. Network layer
I split networking into a generic network client and a generic endpoint abstraction.
Expected failure cases are represented with strongly typed errors.
On top of this foundation, I implemented concrete Stack Overflow endpoints for:
• Fetching top users
• Downloading avatar images

2. Presentation layer (UI + ViewModel)
User data is displayed in a UITable​View backed by a diffable data source.
A View​Model coordinates data loading and configures the table data source.
The ViewModel also controls view state transitions (for example, from content to error) based on caught errors.

3. Data loading layer
I created a dedicated component responsible for fetching users from the network and persisting them in Core Data.
This acts as the bridge between the network and persistence layers.

4. Persistence layer
The model layer encapsulates Core Data storage and local fetch logic, including fetch​Request definitions.
The app uses view​Context and background contexts appropriately for reading and writing data.

5. Image caching strategy
I initially stored images in Core Data, then moved away from that approach because Core Data is better suited to relational records than large binary blobs.
To improve performance and control database size, I introduced:
• Image​Store for disk caching in the app’s local directory (keyed by image URL)
• Avatar​Repository for an in-memory cache with bounded size for fast repeat access

Avatar​Repository is also responsible for fetching images and writing them to both memory and disk caches.

6. UI update behavior
UI updates for user records happen automatically when managed objects change.
Image updates are triggered manually for the specific visible cell when an avatar finishes loading.
For Follow/Unfollow actions, the state is persisted in Core Data, and the diffable data source refreshes the corresponding cell.

7. Testing
All major layers are covered by unit tests, with mocked dependencies where appropriate.
I also added a basic UI test for follow/unfollow behavior.
The test scheme supports launch arguments to optionally use Mock​Stack​Overflow​Network​Client, and the database is reset before each UI test run.
