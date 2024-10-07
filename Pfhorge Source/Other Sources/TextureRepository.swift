//
//  TextureRepository.swift
//  Pfhorge
//
//  Created by C.W. Betts on 4/15/23.
//

import Cocoa

@objcMembers
final class TextureRepository: NSObject {
    @objc(sharedTextureRepository) static let shared = TextureRepository()
    
    private var waterTextures: [NSImage]? = nil
    private var lavaTextures: [NSImage]? = nil
    private var sewageTextures: [NSImage]? = nil
    private var jjaroTextures: [NSImage]? = nil
    private var pfhorTextures: [NSImage]? = nil

    private var landscape1: [NSImage]? = nil
    private var landscape2: [NSImage]? = nil
    private var landscape3: [NSImage]? = nil
    private var landscape4: [NSImage]? = nil
    
    private override init() {
        
    }
    
    func loadTextureSet(_ textureSet: Int32) throws {
        guard let shapesURL = UserDefaults.standard.url(forKey: VMShapesPath) else {
            NSLog("*** No valid shapes file! ***")
            throw CocoaError(.fileNoSuchFile)
        }
        
        switch Int(textureSet) {
        case _water:
            NSLog("*** Loading Water Textures ***")
            waterTextures = try getAllTextures(collection: .water, colorTable: 0, shapesPath: shapesURL)
            
        case _lava:
            NSLog("*** Loading Lava Textures ***")
            lavaTextures = try getAllTextures(collection: .lava, colorTable: 0, shapesPath: shapesURL)
            
        case _sewage:
            NSLog("*** Loading Sewage Textures ***")
            sewageTextures = try getAllTextures(collection: .sewage, colorTable: 0, shapesPath: shapesURL)
            
        case _jjaro:
            NSLog("*** Loading Jjaro Textures ***");
            jjaroTextures = try getAllTextures(collection: .jjaro, colorTable: 0, shapesPath: shapesURL)
            
        case _pfhor:
            NSLog("*** Loading Pfhor Textures ***");
            pfhorTextures = try getAllTextures(collection: .pfhor, colorTable: 0, shapesPath: shapesURL)

        case 99:
            NSLog("*** Loading Landscapes 1 ***")
            landscape1 = try getAllTextures(collection: .landscape1, colorTable: 0, shapesPath: shapesURL)
            NSLog("*** Loading Landscapes 2 ***")
            landscape2 = try getAllTextures(collection: .landscape2, colorTable: 0, shapesPath: shapesURL)
            NSLog("*** Loading Landscapes 3 ***")
            landscape3 = try getAllTextures(collection: .landscape3, colorTable: 0, shapesPath: shapesURL)
            NSLog("*** Loading Landscapes 4 ***")
            landscape4 = try getAllTextures(collection: .landscape4, colorTable: 0, shapesPath: shapesURL)

        default:
            break
        }
    }
    
    func loadAllTextures() {
        // Should release these to make, in case this function gets called more then once...
        waterTextures = nil
        lavaTextures = nil
        sewageTextures = nil
        jjaroTextures = nil
        pfhorTextures = nil
        
        landscape1 = nil
        landscape2 = nil
        landscape3 = nil
        landscape4 = nil

        guard let shapesURL = UserDefaults.standard.url(forKey: VMShapesPath) else {
            NSLog("*** No valid shapes file! ***")
            return
        }

        NSLog("*** Loading Water Textures ***")
        waterTextures = try? getAllTextures(collection: .water, colorTable: 0, shapesPath: shapesURL)
        NSLog("*** Loading Lava Textures ***")
        lavaTextures = try? getAllTextures(collection: .lava, colorTable: 0, shapesPath: shapesURL)
        NSLog("*** Loading Sewage Textures ***")
        sewageTextures = try? getAllTextures(collection: .sewage, colorTable: 0, shapesPath: shapesURL)
        NSLog("*** Loading Jjaro Textures ***")
        jjaroTextures = try? getAllTextures(collection: .jjaro, colorTable: 0, shapesPath: shapesURL)
        NSLog("*** Loading Pfhor Textures ***")
        pfhorTextures = try? getAllTextures(collection: .pfhor, colorTable: 0, shapesPath: shapesURL)
        
        NSLog("*** Loading Landscapes 1 ***")
        landscape1 = try? getAllTextures(collection: .landscape1, colorTable: 0, shapesPath: shapesURL)
        NSLog("*** Loading Landscapes 2 ***")
        landscape2 = try? getAllTextures(collection: .landscape2, colorTable: 0, shapesPath: shapesURL)
        NSLog("*** Loading Landscapes 3 ***")
        landscape3 = try? getAllTextures(collection: .landscape3, colorTable: 0, shapesPath: shapesURL)
        NSLog("*** Loading Landscapes 4 ***")
        landscape4 = try? getAllTextures(collection: .landscape4, colorTable: 0, shapesPath: shapesURL)
        
        NSLog("*** Done Loading Textures ***")
    }
    
    func textureCollection(_ collection: Int32) -> [NSImage]? {
        switch Int(collection) {
        case _water:
            return waterTextures
            
        case _lava:
            return lavaTextures
            
        case _sewage:
            return sewageTextures
            
        case _jjaro:
            return jjaroTextures
            
        case _pfhor:
            return pfhorTextures
            
        default:
            return nil
        }
    }
    
    @objc(texturesForEnvironment:)
    func textures(for collection: LELevelEnvironmentCode) -> [NSImage]? {
        switch collection {
        case .water:
            return waterTextures
        case .lava:
            return lavaTextures
        case .sewage:
            return sewageTextures
        case .jjaro:
            return jjaroTextures
        case .pfhor:
            return pfhorTextures
        case .landscape1:
            return landscape1
        case .landscape2:
            return landscape2
        case .landscape3:
            return landscape3
        case .landscape4:
            return landscape4
        @unknown default:
            return nil
        }
    }
}

private func getAllTextures(collection theCollection: LELevelEnvironmentCode, colorTable theColorTable: Int32, shapesPath: URL) throws -> [NSImage] {
    var err: NSError? = nil
    guard let imgArr = __getAllTexturesOfWithError(Int32(theCollection.rawValue), theColorTable, shapesPath, &err) else {
        guard let err else {
            throw CocoaError(.fileReadUnknown, userInfo: [NSURLErrorKey: shapesPath])
        }
        throw err
    }
    return imgArr
}
