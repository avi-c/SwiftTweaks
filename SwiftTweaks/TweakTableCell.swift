//
//  TweakTableCell.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/13/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import UIKit
import Foundation

internal protocol TweakTableCellDelegate: class {
	func tweakCellDidChangeCurrentValue(_ tweakCell: TweakTableCell)
}

/// A UITableViewCell that represents a single Tweak<T> in our UI.
internal final class TweakTableCell: UITableViewCell {
	internal weak var delegate: TweakTableCellDelegate?

	internal var viewData: TweakViewData? {
		didSet {
			accessoryView = accessory
			accessoryType = .none
			detailTextLabel?.text = nil
			selectionStyle = .none

			defer {
				setNeedsLayout()
				layoutIfNeeded()
			}

			updateSubviews()
		}
	}

	internal var isInFloatingTweakGroupWindow = false

	private var accessory = UIView()

	private let switchControl: UISwitch = {
		let switchControl = UISwitch()
		switchControl.onTintColor = AppTheme.Colors.controlTinted
		switchControl.tintColor = AppTheme.Colors.controlDisabled
		return switchControl
	}()

	private let stepperControl: UIStepper = {
		let stepper = UIStepper()
		stepper.tintColor = AppTheme.Colors.controlTinted
		return stepper
	}()

	private let sliderControl: UISlider = {
		let slider = UISlider()
		slider.tintColor = AppTheme.Colors.controlTinted
		return slider
	}()

	private let colorChit: UIView = {
		let view = UIView()
		view.layer.cornerRadius = 4
		return view
	}()

	public let tweakNameLabel: UILabel = {
		let tweakNameLabel = UILabel()
		tweakNameLabel.textColor = AppTheme.Colors.textPrimary
		tweakNameLabel.font = AppTheme.Fonts.tweakNameLabelFont
		return tweakNameLabel
	}()

	private let textField: UITextField = {
		let textField = UITextField()
		textField.textAlignment = .left
		textField.returnKeyType = .done
		textField.adjustsFontSizeToFitWidth = true
		textField.minimumFontSize = 12
		return textField
	}()
	private let disclosureArrow: UIImageView = {
		let disclosureArrowImage = UIImage(swiftTweaksImage: .disclosureIndicator)
		let imageView = UIImageView(image: disclosureArrowImage.withRenderingMode(.alwaysTemplate))
		imageView.contentMode = .center
		imageView.tintColor = AppTheme.Colors.controlSecondary
		return imageView
	}()

	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .value1, reuseIdentifier: reuseIdentifier)

		[switchControl, stepperControl, colorChit, textField, disclosureArrow].forEach { accessory.addSubview($0) }
		self.contentView.addSubview(sliderControl)
		self.contentView.addSubview(tweakNameLabel)

		switchControl.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
		stepperControl.addTarget(self, action: #selector(self.stepperChanged(_:)), for: .valueChanged)
		sliderControl.addTarget(self, action: #selector(self.sliderChanged(_:)), for: .valueChanged)
		textField.delegate = self

		detailTextLabel!.textColor = AppTheme.Colors.textPrimary
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private static let numberTextWidthFraction: CGFloat = 0.25 // The fraction of the cell's width used for the text field
	private static let colorTextWidthFraction: CGFloat = 0.30
	private static let stringTextWidthFraction: CGFloat = 0.60
	private static let horizontalPadding: CGFloat = 6 // Horiz. separation between stepper and text field
	private static let colorChitSize = CGSize(width: 29, height: 29)

	override func layoutSubviews() {

		defer {
			// After adjusting the accessoryView's frame, we need to call super.layoutSubviews()
			super.layoutSubviews()
		}

		// No need to proceed if we don't have view data
		guard let viewData = viewData else {
			return
		}

		switch viewData {
		case .boolean:
			switchControl.sizeToFit()
			switchControl.frame = CGRect(x: 0, y: 0, width: switchControl.bounds.size.width, height: bounds.size.height / 2)
			accessory.bounds = switchControl.bounds

		case .integer, .float, .doubleTweak:
			stepperControl.sizeToFit()
			sliderControl.sizeToFit()

			let textFrame = CGRect(
				origin: CGPoint(
					x: 100,
					y: 0
				),
				size: CGSize(
					width: bounds.width * TweakTableCell.numberTextWidthFraction,
					height: bounds.height / 2
				)
			)

			let stepperControlFrame = CGRect(
				origin: CGPoint(
					x: 100,
					y: bounds.size.height / 2
				),
				size: stepperControl.bounds.size
			)

			textField.frame = textFrame
			stepperControl.frame = stepperControlFrame
			tweakNameLabel.frame = CGRect(x: TweakTableCell.horizontalPadding, y: 0, width: bounds.size.width - 2.0 * TweakTableCell.horizontalPadding, height: bounds.size.height/2)

			var accessoryFrame = textFrame.union(stepperControlFrame)
			accessoryFrame.origin.x -= 24.0
			accessory.bounds = accessoryFrame.integral

			let sliderControlFrame = CGRect(
				origin: CGPoint(
					x: TweakTableCell.horizontalPadding,
					y: bounds.size.height / 2//(textFrame.height - sliderControl.bounds.height) / 2
				),
				size: CGSize(
					width: bounds.size.width - stepperControlFrame.width - TweakTableCell.horizontalPadding - 14,
					height: sliderControl.bounds.size.height
				)
			)
			sliderControl.frame = sliderControlFrame

		case .color:
			let textFrame = CGRect(
				origin: CGPoint.zero,
				size: CGSize(
					width: bounds.width * TweakTableCell.colorTextWidthFraction,
					height: bounds.height
				)
			)

			let colorControlFrame = CGRect(
				origin: CGPoint(
					x: textFrame.width + TweakTableCell.horizontalPadding,
					y: (textFrame.height - stepperControl.bounds.height) / 2
				),
				size: TweakTableCell.colorChitSize
			)

			let disclosureArrowFrame = CGRect(
				origin: CGPoint(
					x: textFrame.width + colorControlFrame.width + 2 * TweakTableCell.horizontalPadding,
					y: 0),
				size: CGSize(
					width: disclosureArrow.bounds.width,
					height: bounds.height
				)
			)

			textField.frame = textFrame
			colorChit.frame = colorControlFrame
			disclosureArrow.frame = disclosureArrowFrame

			let accessoryFrame = colorControlFrame.union(textFrame).union(disclosureArrowFrame)
			accessory.bounds = accessoryFrame.integral

		case .string:
			let textFrame = CGRect(
				origin: .zero,
				size: CGSize(
					width: bounds.width * TweakTableCell.stringTextWidthFraction,
					height: bounds.height
				)
			).integral
			textField.frame = textFrame
			accessory.bounds = textField.bounds

		case .stringList:
			let textFieldFrame = CGRect(
				origin: .zero,
				size: CGSize(
					width: bounds.width * TweakTableCell.stringTextWidthFraction,
					height: bounds.height
				)
			).integral
			textField.frame = textFieldFrame
			let disclosureArrowFrame = CGRect(
				origin: CGPoint(x: textFieldFrame.width + TweakTableCell.horizontalPadding, y: 0),
				size: CGSize(width: disclosureArrow.bounds.width, height: bounds.height)
			)
			disclosureArrow.frame = disclosureArrowFrame
			accessory.bounds = textFieldFrame.union(disclosureArrowFrame).integral
		}
	}

	fileprivate func updateSubviews() {
		guard let viewData = viewData else {
			switchControl.isHidden = true
			textField.isHidden = true
			stepperControl.isHidden = true
			sliderControl.isHidden = true
			colorChit.isHidden = true
			disclosureArrow.isHidden = true
			return
		}

		// Show / hide views depending on viewData
		switch viewData {
		case .boolean:
			switchControl.isHidden = false
			textField.isHidden = true
			stepperControl.isHidden = true
			sliderControl.isHidden = true
			colorChit.isHidden = true
			disclosureArrow.isHidden = true
			tweakNameLabel.isHidden = true
		case .integer, .float, .doubleTweak:
			switchControl.isHidden = true
			textField.isHidden = false
			stepperControl.isHidden = false
			sliderControl.isHidden = false
			colorChit.isHidden = true
			disclosureArrow.isHidden = true
			tweakNameLabel.isHidden = false
		case .color:
			switchControl.isHidden = true
			textField.isHidden = false
			stepperControl.isHidden = true
			sliderControl.isHidden = true
			colorChit.isHidden = false
			disclosureArrow.isHidden = false
			tweakNameLabel.isHidden = true
		case .string:
			switchControl.isHidden = true
			textField.isHidden = false
			stepperControl.isHidden = true
			sliderControl.isHidden = true
			colorChit.isHidden = true
			disclosureArrow.isHidden = true
			tweakNameLabel.isHidden = true
		case .stringList:
			switchControl.isHidden = true
			textField.isHidden = false
			stepperControl.isHidden = true
			sliderControl.isHidden = true
			colorChit.isHidden = true
			disclosureArrow.isHidden = false
			tweakNameLabel.isHidden = true
		}

		// Update accessory internals based on viewData
		var textFieldEnabled: Bool
		switch viewData {
		case let .boolean(value: value, _):
			switchControl.isOn = value
			textFieldEnabled = false

		case .integer:
			let doubleValue = viewData.doubleValue!
			self.updateStepper(value: doubleValue, stepperValues: viewData.stepperValues!)
			self.updateSlider(value: doubleValue, sliderValues: viewData.sliderValues!)

			textField.text = String(describing: viewData.value)
			textField.keyboardType = .numberPad
			textFieldEnabled = true

		case .float, .doubleTweak:
			let doubleValue = viewData.doubleValue!
			self.updateStepper(value: doubleValue, stepperValues: viewData.stepperValues!)
			self.updateSlider(value: doubleValue, sliderValues: viewData.sliderValues!)

			textField.text = doubleValue.stringValueRoundedToNearest(.thousandth)
			textField.keyboardType = .decimalPad
			textFieldEnabled = true

		case let .color(value: value, _):
			colorChit.backgroundColor = value
			textField.text = value.hexString
			textFieldEnabled = false

		case let .string(value, _):
			textField.text = value
			textField.placeholder = NSLocalizedString("Tap to edit", comment: "Text field placeholder for editable text")
			textField.keyboardType = .default
			textFieldEnabled = true

		case let .stringList(value: value, _, options: _):
			textField.text = value.value
			textFieldEnabled = false
		}

		textFieldEnabled = textFieldEnabled && !self.isInFloatingTweakGroupWindow

		textField.isUserInteractionEnabled = textFieldEnabled
		textField.textColor = textFieldEnabled ? AppTheme.Colors.textPrimary : AppTheme.Colors.controlSecondary

	}

	private func updateStepper(value: Double, stepperValues: TweakViewData.StepperValues) {
		stepperControl.minimumValue = stepperValues.stepperMin
		stepperControl.maximumValue = stepperValues.stepperMax
		stepperControl.stepValue = stepperValues.stepSize
		stepperControl.value = value // need to set this *after* the min/max have been set, else UIKit clips it.
	}

	private func updateSlider(value: Double, sliderValues: TweakViewData.SliderValues) {
		sliderControl.minimumValue = Float(sliderValues.sliderMin)
		sliderControl.maximumValue = Float(sliderValues.sliderMax)
		sliderControl.value = Float(value)
	}


	// MARK: Events
	@objc private func switchChanged(_ sender: UISwitch) {
		switch viewData! {
		case let .boolean(_, defaultValue: defaultValue):
			viewData = .boolean(value: switchControl.isOn, defaultValue: defaultValue)
			delegate?.tweakCellDidChangeCurrentValue(self)
		default:
			assertionFailure("Shouldn't be able to toggle switch if view data isn't Boolean type")
		}
	}

	@objc private func stepperChanged(_ sender: UIStepper) {
		switch viewData! {
		case let .integer(_, defaultValue: defaultValue, min: min, max: max, stepSize: step):
			viewData = TweakViewData(type: .integer, value: Int(stepperControl.value), defaultValue: defaultValue, minimum: min, maximum: max, stepSize: step, options: nil)
			delegate?.tweakCellDidChangeCurrentValue(self)
		case let .float(_, defaultValue: defaultValue, min: min, max: max, stepSize: step):
			viewData = TweakViewData(type: .cgFloat, value: CGFloat(stepperControl.value), defaultValue: defaultValue, minimum: min, maximum: max, stepSize: step, options: nil)
			delegate?.tweakCellDidChangeCurrentValue(self)
		case let .doubleTweak(_, defaultValue: defaultValue, min: min, max: max, stepSize: step):
			viewData = TweakViewData(type: .double, value: stepperControl.value, defaultValue: defaultValue, minimum: min, maximum: max, stepSize: step, options: nil)
			delegate?.tweakCellDidChangeCurrentValue(self)
		case .color, .boolean, .string, .stringList:
			assertionFailure("Shouldn't be able to update text field with a Color or Boolean or String or StringList tweak.")
		}
	}

	@objc private func sliderChanged(_ sender: UISlider) {
		switch viewData! {
		case let .integer(_, defaultValue: defaultValue, min: min, max: max, stepSize: step):
			viewData = TweakViewData(type: .integer, value: Int(sliderControl.value), defaultValue: defaultValue, minimum: min, maximum: max, stepSize: step, options: nil)
			delegate?.tweakCellDidChangeCurrentValue(self)
		case let .float(_, defaultValue: defaultValue, min: min, max: max, stepSize: step):
			viewData = TweakViewData(type: .cgFloat, value: CGFloat(sliderControl.value), defaultValue: defaultValue, minimum: min, maximum: max, stepSize: step, options: nil)
			delegate?.tweakCellDidChangeCurrentValue(self)
		case let .doubleTweak(_, defaultValue: defaultValue, min: min, max: max, stepSize: step):
			viewData = TweakViewData(type: .double, value: Double(sliderControl.value), defaultValue: defaultValue, minimum: min, maximum: max, stepSize: step, options: nil)
			delegate?.tweakCellDidChangeCurrentValue(self)
		case .color, .boolean, .string, .stringList:
			assertionFailure("Shouldn't be able to update text field with a Color or Boolean or String or StringList tweak.")
		}
	}
}

extension TweakTableCell: UITextFieldDelegate {
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		return !isInFloatingTweakGroupWindow
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}

	func textFieldDidEndEditing(_ textField: UITextField) {
		switch viewData! {
		case let .integer(_, defaultValue: defaultValue, min: minimum, max: maximum, stepSize: step):
			if let text = textField.text, let newValue = Int(text) {
				viewData = TweakViewData(type: .integer, value: newValue, defaultValue: defaultValue, minimum: minimum, maximum: maximum, stepSize: step, options: nil)
				delegate?.tweakCellDidChangeCurrentValue(self)
			} else {
				updateSubviews()
			}
		case let .float(_, defaultValue: defaultValue, min: minimum, max: maximum, stepSize: step):
			if let text = textField.text, let newValue = Float(text) {
				viewData = TweakViewData(type: .cgFloat, value: CGFloat(newValue), defaultValue: defaultValue, minimum: minimum, maximum: maximum, stepSize: step, options: nil)
				delegate?.tweakCellDidChangeCurrentValue(self)
			} else {
				updateSubviews()
			}
		case let .doubleTweak(_, defaultValue: defaultValue, min: minimum, max: maximum, stepSize: step):
			if let text = textField.text, let newValue = Double(text) {
				viewData = TweakViewData(type: .double, value: newValue, defaultValue: defaultValue, minimum: minimum, maximum: maximum, stepSize: step, options: nil)
				delegate?.tweakCellDidChangeCurrentValue(self)
			} else {
				updateSubviews()
			}
		case let .color(_, defaultValue: defaultValue):
			if let text = textField.text, let newValue = UIColor.colorWithHexString(text) {
				viewData = TweakViewData(type: .uiColor, value: newValue, defaultValue: defaultValue, minimum: nil, maximum: nil, stepSize: nil, options: nil)
				delegate?.tweakCellDidChangeCurrentValue(self)
			} else {
				updateSubviews()
			}
		case let .string(_, defaultValue):
			if let newValue = textField.text {
				viewData = TweakViewData(type: .string, value: newValue, defaultValue: defaultValue, minimum: nil, maximum: nil, stepSize: nil, options: nil)
				delegate?.tweakCellDidChangeCurrentValue(self)
			} else {
				updateSubviews()
			}
		case .boolean, .stringList:
			assertionFailure("Shouldn't be able to update text field with a Boolean or StringList tweak.")
		}
	}
}
