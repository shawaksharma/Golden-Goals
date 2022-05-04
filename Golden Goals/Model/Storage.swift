//
//  Storage.swift
//  Golden Goals
//
//  Created by Shawak Sharma on 18/04/2021.
//

import Foundation

// A Manager of File Storage
public final class Storage {
    
    // The Shared Instance of the Storage
    public static let shared = Storage()
    
    // The File Manager
    private let fileManager: FileManager
    
    // Initialise
    private init() {
        fileManager = FileManager()
    }
    // A File Directory.
    public enum Directory {
        case documents
    }
    
     // Returns the URL of the Specified Directory
     // parameter directory: The directory.
     // returns: The URL of the specified directory.
     
    public func getURL(for directory: Directory) -> URL? {
        var searchPathDirectory: FileManager.SearchPathDirectory
        switch directory {
        case .documents:
            searchPathDirectory = .documentDirectory
        }
        if let url = fileManager.urls(for: searchPathDirectory, in: .userDomainMask).first {
            return url
        } else {
            fatalError("Could not create URL for specified directory")
        }
    }
    
    
     // Stores Data to the Specified Directory on Disk
     // parameter data: The data to store
     // parameter fileName: The name the file where the struct data will be stored
     // parameter directory: The directory
     // returns: Boolean value whether the save operation was successful
    
    @discardableResult
    public func store(_ data: Data, as fileName: String, in directory: Directory) -> Result<String, Swift.Error> {
        guard let url = getURL(for: directory) else {
            return .failure(Error.invalidFilePath)
        }
        let fileURL = url.appendingPathComponent(fileName, isDirectory: false)
        if fileManager.createFile(atPath: fileURL.path, contents: data, attributes: nil) {
            return .success(url.path)
        } else {
            return .failure(Error.failedToSaveFileToDirectory)
        }
    }
    

     // Retrieve and Convert a Struct from a File on Disk
     // parameter fileName: The name the file where the struct data will be stored
     // parameter type: The type of the struct
     // parameter directory: The directory
     // returns: The decoded object
    
    public func retrieve<T: Decodable>(_ fileName: String, as type: T.Type, in directory: Directory) throws -> T {
        guard let url = getURL(for: directory)?.appendingPathComponent(fileName, isDirectory: false) else {
            throw Error.invalidFilePath
        }
        print(url.absoluteString)
        guard let data = fileManager.contents(atPath: url.path) else {
            throw Error.fileMissing
        }
        let decoder = JSONDecoder()
        return try decoder.decode(type, from: data)
    }
    
    // An error which could be encountered whilst interacting with Storage
    public enum Error: Swift.Error {
        case failedToSaveFileToDirectory
        case fileMissing
        case invalidFilePath
    }
}
