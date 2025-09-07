//
//  ImageManager.swift
//  ParacticeApp
//
//  Created by Waseem Abbas on 06/09/2025.
//

import Foundation
import UIKit
class FilemanagerService {
    static let shared = FilemanagerService()
    private init () { }
    
    private var documentsDirectory : URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    func saveImage (_ image : UIImage, id : UUID)-> String? {
        let filename = "\(id).jpg"
        let url = documentsDirectory.appendingPathComponent(filename)
        guard let data = image.jpegData(compressionQuality: 0.8) else {return nil}
        
        do {
            try data.write(to: url)
            return filename
        } catch  {
            print("Error saving Image \(error.localizedDescription)")
            return nil
        }
    }
    
    func loadImage (filename: String) -> UIImage? {
        let url = documentsDirectory.appendingPathComponent(filename)
        return UIImage(contentsOfFile: url.path)
    }
    
    func deleteImage (filename : String) {
        let url = documentsDirectory.appendingPathComponent(filename)
        do {
            try FileManager.default.removeItem(at: url)
        } catch  {
            print("❌ Failed to delete image: \(error.localizedDescription)")
        }
    }
}
