//
//  SharedFunctionsAndConstants.swift
//  DadJokes
//
//  Created by Nathan Smith on 2022-02-24.
//

import Foundation

// Return the location of the documents directory for this app
func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    //Return the path
    return paths[0]
}

    // Define a filename that we will write the data to in the directory
let savedFavouritesLabel = "savedFavourites"
