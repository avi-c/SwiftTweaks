//
//  CodableTweak.swift
//  SwiftTweaks
//
//  Created by Avi Cieplinski on 9/25/18.
//  Copyright © 2018 Khan Academy. All rights reserved.
//

import UIKit

public struct CodeableTweak : Codable {
	public var versionNumber: Double
	public var collectionName: String
	public var groupName: String
	public var tweakName: String
	public var tweakType: Int
	public var doubleValue: Double
	public var cgFloatValue: CGFloat
	public var intValue: Int
	public var boolValue: Bool
	public var stringValue: String
	public var doubleMinValue: Double
	public var cgFloatMinValue: CGFloat
	public var intMinValue: Int
	public var doubleMaxValue: Double
	public var cgFloatMaxValue: CGFloat
	public var intMaxValue: Int
	public var doubleStepValue: Double
	public var cgFloatStepValue: CGFloat
	public var intStepValue: Int

	public init(tweak: AnyTweak) {
		versionNumber = 0.1
		collectionName = tweak.collectionName
		groupName = tweak.groupName
		tweakName = tweak.tweakName
		tweakType = tweak.tweakViewDataType.rawValue
		doubleValue = Double(-1.0)
		cgFloatValue = CGFloat(-1.0)
		intValue = Int(-1)
		boolValue = false
		stringValue = ""
		doubleMinValue = Double(-1.0)
		cgFloatMinValue = CGFloat(-1.0)
		intMinValue = Int(-1)
		doubleMaxValue = Double(-1.0)
		cgFloatMaxValue = CGFloat(-1.0)
		intMaxValue = Int(-1)
		doubleStepValue = Double(1.0)
		cgFloatStepValue = CGFloat(1.0)
		intStepValue = Int(1)
	}

	enum CodingKeys: String, CodingKey {
		case versionNumber
		case collectionName
		case groupName
		case tweakName
		case tweakType
		case doubleValue
		case cgFloatValue
		case intValue
		case doubleMinValue
		case cgFloatMinValue
		case intMinValue
		case doubleMaxValue
		case cgFloatMaxValue
		case intMaxValue
		case doubleStepValue
		case cgFloatStepValue
		case intStepValue
		case boolValue
		case stringValue
	}

	public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		versionNumber = try values.decode(Double.self, forKey: .versionNumber)
		collectionName = try values.decode(String.self, forKey: .collectionName)
		groupName = try values.decode(String.self, forKey: .groupName)
		tweakName = try values.decode(String.self, forKey: .tweakName)
		let tweakTypeIndex = try values.decode(Int.self, forKey: .tweakType)
		let tweakDataType = TweakViewDataType.allTypes[tweakTypeIndex]
		tweakType = tweakDataType.rawValue
		cgFloatValue = -1.0
		doubleValue = -1.0
		intValue = -1
		boolValue = false
		stringValue = ""
		doubleMinValue = Double(-1.0)
		cgFloatMinValue = CGFloat(-1.0)
		intMinValue = Int(-1)
		doubleMaxValue = Double(-1.0)
		cgFloatMaxValue = CGFloat(-1.0)
		intMaxValue = Int(-1)
		doubleStepValue = Double(1.0)
		cgFloatStepValue = CGFloat(1.0)
		intStepValue = Int(1)

		if tweakDataType == .cgFloat {
			cgFloatValue = try values.decode(CGFloat.self, forKey: .cgFloatValue)
			cgFloatMinValue = try values.decode(CGFloat.self, forKey: .cgFloatMinValue)
			cgFloatMaxValue = try values.decode(CGFloat.self, forKey: .cgFloatMaxValue)
			cgFloatStepValue = try values.decode(CGFloat.self, forKey: .cgFloatStepValue)
		} else if tweakDataType == .double {
			doubleValue = try values.decode(Double.self, forKey: .doubleValue)
			doubleMinValue = try values.decode(Double.self, forKey: .doubleMinValue)
			doubleMaxValue = try values.decode(Double.self, forKey: .doubleMaxValue)
			doubleStepValue = try values.decode(Double.self, forKey: .doubleStepValue)
		} else if tweakDataType == .integer {
			intValue = try values.decode(Int.self, forKey: .intValue)
			intMinValue = try values.decode(Int.self, forKey: .intMinValue)
			intMaxValue = try values.decode(Int.self, forKey: .intMaxValue)
			intStepValue = try values.decode(Int.self, forKey: .intStepValue)
		} else if tweakDataType == .boolean {
			boolValue = try values.decode(Bool.self, forKey: .boolValue)
		} else if tweakDataType == .string {
			stringValue = try values.decode(String.self, forKey: .stringValue)
		}
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(versionNumber, forKey: .versionNumber)
		try container.encode(collectionName, forKey: .collectionName)
		try container.encode(groupName, forKey: .groupName)
		try container.encode(tweakName, forKey: .tweakName)
		try container.encode(tweakType, forKey: .tweakType)
		try container.encode(doubleValue, forKey: .doubleValue)
		try container.encode(doubleMinValue, forKey: .doubleMinValue)
		try container.encode(doubleMaxValue, forKey: .doubleMaxValue)
		try container.encode(doubleStepValue, forKey: .doubleStepValue)
		try container.encode(cgFloatValue, forKey: .cgFloatValue)
		try container.encode(cgFloatValue, forKey: .cgFloatMinValue)
		try container.encode(cgFloatMaxValue, forKey: .cgFloatMaxValue)
		try container.encode(cgFloatStepValue, forKey: .cgFloatStepValue)
		try container.encode(intValue, forKey: .intValue)
		try container.encode(intValue, forKey: .intMinValue)
		try container.encode(intStepValue, forKey: .intStepValue)
		try container.encode(boolValue, forKey: .boolValue)
		try container.encode(stringValue, forKey: .stringValue)
	}
}
