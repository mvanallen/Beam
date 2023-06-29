//
//  BeamConnector.swift
//  Beam
//
//  Created by Michael VanAllen on 29.06.23.
//  Copyright © 2023 ReactiveCode Studios. All rights reserved.
//

import Foundation
import MultipeerConnectivity


/*actor*/ class BeamConnector: NSObject {
	
	let peerId: MCPeerID
	let serviceType: String
	
	lazy var session: MCSession = {
		let session = MCSession(peer: self.peerId, securityIdentity: nil, encryptionPreference: .required)
		session.delegate = self
		return session
	}()
	
	init(peerId: String?, serviceType: String = "beam-themesvc") {
		self.peerId = MCPeerID(displayName: peerId ?? UIDevice.current.name)
		self.serviceType = serviceType
		super.init()
	}
	
	deinit {
		//
	}
}


extension BeamConnector: MCSessionDelegate {
	
	nonisolated func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
		NSLog("# \(String(reflecting: self)) – peer '\(peerID.displayName)' did change state to '\(state)'")
	}
	
	nonisolated func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
		NSLog("# \(String(reflecting: self)) – received \(data.count) bytes of data from peer '\(peerID.displayName)'")
	}
	
	nonisolated func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
		NSLog("# \(String(reflecting: self)) –: received stream w/ name '\(streamName)' from peer '\(peerID.displayName)'")
	}
	
	nonisolated func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
		NSLog("# \(String(reflecting: self)) – did start receiving resource w/ name '\(resourceName)' from peer '\(peerID.displayName)'")
	}
	
	nonisolated func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
		NSLog("# \(String(reflecting: self)) – did finish receiving resource w/ name '\(resourceName)' from peer '\(peerID.displayName)'")
		NSLog("#   -> url '\(localURL?.absoluteString ?? "(nil)")'")
		NSLog("#   error: \(error?.localizedDescription ?? "(nil)")")
	}
	
	nonisolated func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
		NSLog("# \(String(reflecting: self)) – neat, received a certificate from peer '\(peerID.displayName)'!")
		NSLog("#   -> I'll allow it.")
		certificateHandler(true)
	}
}