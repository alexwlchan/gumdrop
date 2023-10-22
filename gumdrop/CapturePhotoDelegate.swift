//
//  CapturePhotoDelegate.swift
//  gumdrop
//
//  Created by Alex Chan on 22/10/2023.
//

import AppKit
import AVFoundation
import Photos

class CapturePhotoDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    var isPhotoLibraryReadWriteAccessGranted: Bool {
        get async {
            let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
            
            // Determine if the user previously authorized read/write access.
            var isAuthorized = status == .authorized
            
            // If the system hasn't determined the user's authorization status,
            // explicitly prompt them for approval.
            if status == .notDetermined {
                isAuthorized = await PHPhotoLibrary.requestAuthorization(for: .addOnly) == .authorized
            }
            
            return isAuthorized
        }
    }
    
    internal func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error = error {
            let alert = NSAlert.init()
            alert.messageText = "Couldn’t save photo"
            alert.informativeText = error.localizedDescription
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
            alert.runModal()
        } else {
            Task {
                    await save(photo: photo)
                }
            print("didFinishProcessingPhoto")
            print(photo)
        }
    }
    
    func save(photo: AVCapturePhoto) async {
        // Confirm the user granted read/write access.
        guard await isPhotoLibraryReadWriteAccessGranted else { return }
        
        // Create a data representation of the photo and its attachments.
        if let photoData = photo.fileDataRepresentation() {
            PHPhotoLibrary.shared().performChanges {
                // Save the photo data.
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: .photo, data: photoData, options: nil)
            } completionHandler: { success, error in
                print("completed!")
                if let error {
                    print("Error saving photo: \(error.localizedDescription)")
                    return
                }
            }
        }
    }
}
