//
//  BeamServiceProvider.swift
//  Beam
//
//  Created by Michael VanAllen on 16.04.19.
//  Copyright © 2019 ReactiveCode Studios. All rights reserved.
//

import Foundation
import MultipeerConnectivity


class BeamServiceProvider: NSObject {
	/*private*/ let serviceAdvertiser: MCNearbyServiceAdvertiser
	
	private let peerId: MCPeerID
	private let serviceType: String
	
	init(peerId: MCPeerID, serviceType: String) {
		self.peerId = peerId
		self.serviceType = serviceType
		
		self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: self.peerId, discoveryInfo: nil, serviceType: self.serviceType)
		super.init()
		self.serviceAdvertiser.delegate = self
		
		NSLog("BeamServiceProvider.init() - start advertising service of type '\(self.serviceType)'")
		//self.serviceAdvertiser.startAdvertisingPeer()
	}
	
	deinit {
		//self.serviceAdvertiser.stopAdvertisingPeer()
		NSLog("BeamServiceProvider.deinit() - stopped advertising service of type '\(self.serviceType)'")
	}
}


extension BeamServiceProvider: MCNearbyServiceAdvertiserDelegate {
	
	nonisolated func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
		NSLog("# BeamServiceProvider.didReceiveInvitationFromPeer() - received invitation from peer '\(peerID.displayName)'")
		
		NSLog("# BeamServiceProvider.didReceiveInvitationFromPeer() --> how nice, I'll accept!")
		// !!!: invitationHandler(true, self.session)
	}
	
	nonisolated func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
		NSLog("# BeamServiceProvider.didNotStartAdvertisingPeer() - advertising failed w/ error: \(error)")
	}
}


// - MARK: ColorService

extension BeamServiceProvider {
	var colorServiceDelegate: ColorServiceDelegate? { nil } //= nil
	
	func receivedColor(_ newColor: UIColor?) {
		NSLog("BeamServiceProvider.receivedColor() - received new color \(newColor ?? .clear), trying to delegate..")
		if self.serviceType == "beam-colorsvc", let delegate = self.colorServiceDelegate {
			delegate.colorDidChange(to: newColor)
			NSLog("BeamServiceProvider.receivedColor() - ..done.")
		}
	}
}

/*
extension BeamServiceProvider: MCSessionDelegate {
	
	func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
		NSLog("# BeamServiceProvider.MCSession: received \(data.count) bytes of data from peer '\(peerID.displayName)'")
		
		// MARK: ColorService
		if let newColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) {
			self.receivedColor(newColor)
		}
	}
}
*/
