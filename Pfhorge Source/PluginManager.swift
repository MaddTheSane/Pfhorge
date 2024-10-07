//
//  PluginManager.swift
//  Pfhorge
//
//  Created by C.W. Betts on 10/6/24.
//

import Foundation

@objcMembers
class PluginManager: NSObject {
	// MARK: - • Class Methods •
	
    @objc(sharedPluginManager)
    static let shared = PluginManager()
    
	// MARK: - • Accsessor Methods •
	
    private(set) var pluginClasses: [any PhLevelPluginProtocol.Type] = []
    private(set) var pluginInstances: [any PhLevelPluginProtocol] = []
    private(set) var pluginInstanceNames: [String] = []
    
	// MARK: - • Utilties •
	
    func findPlugins() {
		var isDir: ObjCBool = false
		var exists: Bool = false
		
		var folderPath = Bundle.main.builtInPlugInsPath
		
		NSLog("Loading Plugins...");

		if let folderPath {
			let enumerator = Bundle.main.paths(forResourcesOfType: "plugin", inDirectory: folderPath)
			for pluginPath in enumerator {
				self.activatePlugin(pluginPath)
			}
		}
		
		folderPath = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("Pfhorge").path
		exists = FileManager.default.fileExists(atPath: folderPath!, isDirectory: &isDir)
		
		if !exists {
			NSLog("Creating Support Folder...")
			try? FileManager.default.createDirectory(atPath: folderPath!, withIntermediateDirectories: true, attributes: nil)
		} else if let folderPath {
			Bundle.main.paths(forResourcesOfType: "plugin", inDirectory: folderPath).forEach { self.activatePlugin($0) }
		}
		
		initializePlugins()
	}
    
	// MARK: - • Convience Methods •
	
	/// This is called to activate each plug-in, meaning that each candidate bundle is checked,
	/// loaded if it seems to contain a valid plug-in, and the plug-in's class' `+initiateClass:`
	/// method is called. If this returns `YES`, it means that the plug-in agrees to run and the
	/// class is added to the pluginClass array. Some plug-ins might refuse to be activated
	/// depending on some external condition.
	@objc(activatePluginAtIndex:)
    func activatePlugin(at index: Int) {
		pluginInstances[index].activate()
    }
    
    private override init() {
        super.init()
    }
    
	// MARK: - • Private Methods •
	
	private func activatePlugin(_ path: String) {
		NSLog("   Activating Plugin: %@", path);
		guard let pluginBundle = Bundle(path: path),
			  let pluginDict = pluginBundle.infoDictionary,
			  let pluginName = pluginDict["NSPrincipalClass"] as? String else {
			return
		}
		
		var pluginClass: AnyClass? = NSClassFromString(pluginName)
		if pluginClass == nil {
			pluginClass = pluginBundle.principalClass
			
			guard let pluginClass,
				  let a = pluginClass as? PhLevelPluginProtocol.Type,
				  a.initializeClass(pluginBundle) else {
				return
			}
			NSLog("      ... Activated!")

			pluginClasses.append(a)
		}
	}
	
	private func initializePlugins() {
		for pluginClass in pluginClasses {
			instantiatePlugins(pluginClass)
		}
	}
	
	/// A plug-in class can return multiple plug-in objects, so we ask each one to return an enumerator of
	/// plug-in instances. We pass the window as argument for this call; some plug-ins might refuse to
	/// instantiate themselves depending on the argument. Each plug-in instance is asked to return a view
	/// which is resized and added to the main window's tab view, and the plug-in is then added to the
	/// instances array.
	private func instantiatePlugins(_ pluginClass: PhLevelPluginProtocol.Type) {
		let plugs = pluginClass.plugins(for: self)!
		for plugin2 in plugs {
			let plugin = plugin2 as! PhLevelPluginProtocol
			//NSTabViewItem* tab = [[[NSTabViewItem alloc] initWithIdentifier:nil] autorelease];
			//NSView* view = [plugin theView];
			//NSRect frame = [theTabView contentRect];
			//[view setFrame:frame];
			//[tab setView:view];
			//[tab setLabel:[plugin theViewName]];
			//[theTabView addTabViewItem:tab];
			pluginInstances.append(plugin)
			
			//[plugin showWindow:nil];
			//NSLog(@"ShowWindow called for plugin...");
			
			pluginInstanceNames.append(plugin.name)
		}
	}
}
