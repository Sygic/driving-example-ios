# driving-example-ios

- Updated for driving library 2.x
- If you need to access example app for 1.x fetch code from master, tag example-1.x or use branch example-1.x

## Instructions for driving 1.x:
1. [Download](https://public.repo.sygic.com/#browse/browse:maven-sygic-releases:com%2Fsygic%2Fadas%2Fdriving) Driving.xcframework and copy it into Frameworks directory in the project. 


2. Update clientId in AppDelegate.swift in SygicDriving.initialize method. If you don't have your own clientId [contact us](https://www.sygic.com/enterprise/contact-us)

3. build and run

4. Install on device, put device in a car/bus/truck and take a test drive.



## Instructions for driving 2.x:

1. [Download Driving.xcframework](https://public.repo.sygic.com/#browse/browse:maven-sygic-releases:com%2Fsygic%2Fadas%2Fdriving) Driving.xcframework and copy it into Frameworks directory in the project. You have to use version 2.x, best option is the latest 2.x

2. [Download SygicAuth.xcframework Lib](https://public.repo.sygic.com/#browse/browse:maven-sygic-releases:com%2Fsygic%2Flib%2Fauth%2Fsygicauth-ios) and copy it into Frameworks directory in the project. Use the latest library version (1.3 at the time of writing this text)

3. Add both libraries (auth and driving) to the project and set embed and sign for them

4. Update clientId and license in AppDelegate.swift in SygicDriving.initialize method. If you don't have your own clientId and license [contact us](https://www.sygic.com/enterprise/contact-us)

6. build and run

6. Install on device, put device in a car/bus/truck and take a test drive.





# Upgrading from 1.x?

1. Get client id and license from sygic. You will need those for initialization of library
2. Copy-paste new driving.xcframework to frameworks directory
3. Update SygicDriving.sharedInstance().initialize, now it is synchronous, with no online license checks. Library might be used in fully offline scenarios.
4. Delegate methods that are using timestamp as Double were removed. Use the ones with Date. Example: func driving(_ driving: SygicDriving, tripDidStart timestamp: Double, location: CLLocation?) -> func driving(_ driving: SygicDriving, tripDidStart date: Date, location: CLLocation?)
5. Validate that all your delegate function that are expected to be called are called. This is typical source of bugs.

6. Driving 2.x added few new functionalities that change the way trip is reported. One most notable example is that trip may now include segments of walking and driving.
7. Event TripDidEnd and TripDiscarted are exclusive to each other. You only get one of those, not both. When trip is discarted don't expect that finalTripData is called, nor tripModelChanged. So it is important to handle both.

# Notes
- it is recommended to use one Sygic Auth object for all instances of sygic libraries that require Sygic Auth. For example: Driving lib with combination of Sygic Maps. During configuration you need to pass Auth object. 

- all API methods available in Driving 1.x were removed from library version 2.x. API access is delivered as separate package.

# Simulation of trips without driving

Library provides means to replay already driven trips again. Primary reason for this is testing.

What to do to enable replays:

1. developer mode must be enabled
2. go to the car and make some trips. With developer mode enabled all raw trip data are saved localy on the phone.
3. Now you phone has the data that are required for replays. It is possible to copy app data from the phone and put them in the simulator. 
4. To start replay use 
'''swift
SygicDriving.sharedInstance().replayTrip(at: index)
''' 
where index is index of the trip in the local trip list. To get list of all trips use these methods:
'''swift
let tripCount = SygicDriving.sharedInstance().tripCount()
'''
'''swift
let tripData = SygicDriving.sharedInstance().tripMeta(at: indexPath.row)
'''
You can remove trip using:
'''swift
SygicDriving.sharedInstance().removeTrip(at: indexPath.row)
'''
To show complete trip data from local trip data use:
'''swift
let tripData = SygicDriving.sharedInstance().trip(at: tripIndex)
'''            
5. To stop replay use
'''swift
SygicDriving.sharedInstance().stopReplay()
'''
