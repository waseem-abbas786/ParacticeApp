//
//  Untitled.swift
//  ParacticeApp
//
//  Created by Waseem Abbas on 06/09/2025.
//

import Foundation

enum AppError: LocalizedError {
    case coreDataSave
    case coreDataFetch
    case coreDataDelete
    case toggleError
    case apiError
    case imageSave
    case imageDelete

    var errorDescription: String? {
        switch self {
        case .coreDataSave:
            return "Failed to save data. Please try again."
        case .coreDataFetch:
            return "Could not load your notes."
        case .coreDataDelete:
            return "Failed to delete note."
        case .toggleError:
            return "Could not update note status."
        case .apiError:
            return "Failed to fetch notes from the server."
        case .imageSave:
            return "Could not save the image."
        case .imageDelete:
            return "Could not delete the image."
        }
    }
}
