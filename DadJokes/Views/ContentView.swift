//
//  ContentView.swift
//  DadJokes
//
//  Created by Russell Gordon on 2022-02-21.
//

import SwiftUI

struct ContentView: View {
    // MARK: Stored Properties
    @State var currentJoke: DadJoke = DadJoke(id: "", joke: "yo mama", status: 0)
    
    // Detect when an  app moves between foregorund, background, and inactive states
    //NOTE: A complete list of keypaths can be used with @Enviroment can be found here: https://developer.apple.com/documentation/swiftui/enviromentvalues
    @Environment (\.scenePhase) var scenePhase
    
    // This keeps track of the favourites
    @State var favourites: [DadJoke]  = [] // empty list to start
    
    // This will let us know whether the currentJoke exists as a favourite
    @State var currentJokeAddedToFavourites: Bool = false
    
    // MARK: Computed Properties
    var body: some View {
        
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            VStack {
                
                Text(currentJoke.joke)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 25, weight: .medium, design: .serif))
                    .padding(30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.primary, lineWidth: 4)
                    )
                    .padding(10)
                
                Button(action: {
                    
                }, label: {
                    Image(systemName: "heart.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 45, height: 45)
                        .foregroundColor(currentJokeAddedToFavourites == true ? .red : .gray)
                        .onTapGesture {
                            // Only adds to list if its not already there
                            if currentJokeAddedToFavourites == false {
                                
                                // Adds the currentJoke to the list
                                favourites.append(currentJoke)
                                
                                //Record that we have marked this as favourite
                                currentJokeAddedToFavourites = true
                            }
                        }
                })
                    .buttonStyle(.plain)
                
                
                Button(action: {
                    // 'Task' Function allows us the run asynchronous code within a button and have the user interface be updated when the data is ready.
                    // Since it is asynchronous, other tasks can run while we wait for the data to come back from the web server.
                    Task {
                        // Call the funtion that will get us a new joke!
                        await loadNewJoke()
                    }
                }, label: {
                    Text("Another One!")
                        .font(.title2)
                })
                    .buttonStyle(.borderedProminent)
                    .tint(.gray)
                
                // Iterates over the list of favourites
                // As we iterate, each individual favourite is accessible via "currentFavourite
                List(favourites, id: \.self ) { currentFavourite in
                    Text(currentFavourite.joke)
                }
                
                Spacer()
                
            }
            // When the app opens, get a new joke from the web service
            .task {
                //Load a joke from the endpoint
                // Calling/Invoking a the function 'loadNewJoke'
                // This is the "call site" of the function
                // WHat does await mean?
                // This just mean the we, as the programmer are aware that this function is asynchronous
                // Result might come right away, or take some time to complete.
                // Also: any code below the call will run before the function call is complete
                await loadNewJoke()
                await loadFavourites()
            }
            // Reacte to changes of state to the app (foregorund, background, inactive)
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .inactive {
                    print("InActive")
                } else if newPhase == .active {
                    print("active")
                } else {
                    print("background")
                    //permantly save the list of jokes
                    
                    
                    // Permantly save the list of tasks
                    persistFavourites()
                }
            }
            .navigationTitle("icanhazdadjoke?")
            .padding()
        }
    }
    
    // MARK: Functions
    
    // Where the function is defined
    // Using the 'async' keyword means that this function can be run alongside other functions that the app has to do, for example, updating user interface
    func loadNewJoke() async {
        // Assemble the URL that points to the endpoint
        let url = URL(string: "https://icanhazdadjoke.com/")!
        
        // Define the type of data we want from the endpoint
        // Configure the request to the web site
        var request = URLRequest(url: url)
        // Ask for JSON data
        request.setValue("application/json",
                         forHTTPHeaderField: "Accept")
        
        // Start a session to interact (talk with) the endpoint
        let urlSession = URLSession.shared
        
        // Try to fetch a new joke
        // It might not work, so we use a do-catch block
        do {
            
            // Get the raw data from the endpoint
            let (data, _) = try await urlSession.data(for: request)
            
            // Attempt to decode the raw data into a Swift structure
            // Takes what is in "data" and tries to put it into "currentJoke"
            //                                 DATA TYPE TO DECODE TO
            //                                         |
            //                                         V
            currentJoke = try JSONDecoder().decode(DadJoke.self, from: data)
            
        } catch {
            print("Could not retrieve or decode the JSON from endpoint.")
            // Print the contents of the "error" constant that the do-catch block
            // populates
            print(error)
        }
        currentJokeAddedToFavourites = false
    }
    // Save the Data Permanently
    func persistFavourites() {
        // We need to get a location in which to save the data
        let filename = getDocumentsDirectory().appendingPathComponent(savedFavouritesLabel)
        print(filename)
        
        // Try to encode the data in our list of favourites to JSON
        do {
            // Create a JSON Encoder object
            let encoder = JSONEncoder()
            
            // Configured the encoder to "pretty print" the JSON
            encoder.outputFormatting = .prettyPrinted
            
            // Encode the list of favourites we've collected
            let data = try encoder.encode(favourites)
            
            //  Write the JSON to a file in the filename location we came up with earlier
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
            
            // See the data that was written
            print("Saved data to the documents directory sucsessfully")
            print ("=============")
            print(String(data: data, encoding: .utf8)!)
            
        } catch {
            print("enable to write list of favourites to the document directory")
            print("==============")
            print(error.localizedDescription)
        }
    }
    
    //Loads the data that was saved to the device
    //Loading the favourites
    func loadFavourites() async {
        // Retreive a location to load the data
        let filename = getDocumentsDirectory().appendingPathComponent(savedFavouritesLabel)
        print(filename)
        
        //Attempt to load the data
        do {
            //Load the raw data
            let data = try Data(contentsOf: filename)
            
            // See the data that was read
            print("Read data to the documents directory sucsessfully")
            print ("=============")
            print(String(data: data, encoding: .utf8)!)
            
            // Decode the json into swift native data structures
            // There are sqaure brackets ..        HERE becuase there are multilpe jokes
            //                                       |   and therefore we need a list for
            //                                       ˅   them to be displayed
            favourites = try JSONDecoder().decode([DadJoke].self, from: data)
            
        } catch {
            //What went wrong
            print("could not load the data from the stored json file")
            print("=============")
            print(error.localizedDescription)
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                ContentView()
            }
        }
    }
}
