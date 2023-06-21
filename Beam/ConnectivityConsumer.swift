//
//  ConnectivityConsumer.swift
//  Beam
//
//  Created by Michael VanAllen on 16.04.19.
//  Copyright © 2019 ReactiveCode Studios. All rights reserved.
//

import Foundation
import MultipeerConnectivity


class ConnectivityConsumer: NSObject, MCNearbyServiceBrowserDelegate {
	private let serviceBrowser: MCNearbyServiceBrowser
	
	private let peerId = MCPeerID(displayName: UIDevice.current.name)
	let serviceType: String
	
	lazy var session: MCSession = {
		let session = MCSession(peer: self.peerId, securityIdentity: nil, encryptionPreference: .required)
		session.delegate = self
		return session
	}()
	
	init(type: String = "beam-themesvc") {
		self.serviceType = type
		self.serviceBrowser = MCNearbyServiceBrowser(peer: self.peerId, serviceType: self.serviceType)
		super.init()
		self.serviceBrowser.delegate = self
		
		NSLog("ConnectivityConsumer.init() - start browsing for service of type '\(self.serviceType)'")
		self.serviceBrowser.startBrowsingForPeers()
	}
	
	deinit {
		self.serviceBrowser.stopBrowsingForPeers()
		NSLog("ConnectivityConsumer.deinit() - stopped browsing for service of type '\(self.serviceType)'")
	}
	
	// MARK: MCNearbyServiceBrowserDelegate
	
	func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
		NSLog("# ConnectivityConsumer.foundPeer() - found peer '\(peerID.displayName)'")
		
		NSLog("# ConnectivityConsumer.foundPeer() --> let's invite him!")
		browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 0)
	}
	
	func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
		NSLog("# ConnectivityConsumer.lostPeer() - lost peer '\(peerID.displayName)'")
	}
	
	func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
		NSLog("# ConnectivityConsumer.didNotStartBrowsingForPeers() - discovery failed w/ error: \(error)")
	}
	
	// MARK: ColorService
	
	func sendColor(_ newColor: UIColor) {
		NSLog("ConnectivityConsumer.sendColor() - will try to send new color \(newColor)..")
		
		if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: newColor, requiringSecureCoding: true) {
			do {
				try self.session.send(colorData, toPeers: self.session.connectedPeers, with: .reliable)
				NSLog("ConnectivityConsumer.sendColor() - ..sent.")

			} catch {
				NSLog("ConnectivityConsumer.sendColor() - send failed w/ error: \(error)")
			}
		}
	}
	
}


extension ConnectivityConsumer: MCSessionDelegate {
	
	func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
		NSLog("# ConnectivityConsumer.MCSession: peer '\(peerID.displayName)' did change state to '\(state)'")
	}
	
	func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
		NSLog("# ConnectivityConsumer.MCSession: received \(data.count) bytes of data from peer '\(peerID.displayName)'")
	}
	
	func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
		NSLog("# ConnectivityConsumer.MCSession: received stream w/ name '\(streamName)' from peer '\(peerID.displayName)'")
	}
	
	func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
		NSLog("# ConnectivityConsumer.MCSession: did start receiving resource w/ name '\(resourceName)' from peer '\(peerID.displayName)'")
	}
	
	func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
		NSLog("# ConnectivityConsumer.MCSession: did finish receiving resource w/ name '\(resourceName)' from peer '\(peerID.displayName)'")
		NSLog("#   -> url '\(localURL?.absoluteString ?? "(nil)")'")
		NSLog("#   error: \(error?.localizedDescription ?? "(nil)")")
	}
	
	func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
		NSLog("# ConnectivityConsumer.MCSession: neat, received a certificate from peer '\(peerID.displayName)'!")
		NSLog("#   -> I'll allow it.")
		certificateHandler(true)
	}
	
}



extension MCSessionState: CustomStringConvertible {
	public var description: String {
		switch self {
		case .notConnected: return ".notConnected"
		case .connecting: return ".connecting"
		case .connected: return ".connected"
		}
	}
}
