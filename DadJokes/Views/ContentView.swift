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
                        .foregroundColor(.gray)
                        .frame(width: 45, height: 45)
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
                
                List {
                    Text("Which side of the chicken has more feathers? The outside.")
                    Text("Why did the Clydesdale give the pony a glass of water? Because he was a little horse!")
                    Text("The great thing about stationery shops is they're always in the same place...")
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
