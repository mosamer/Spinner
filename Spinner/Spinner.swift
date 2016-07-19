//
//  Spinner.swift
//  TestProject
//
//  Created by Chris Combs on 25/01/16.
//  Copyright © 2016 Nodes. All rights reserved.
//

import UIKit

public typealias ControlTitleColor = (UIControlState, UIColor?)

/**
	Protocol for any view that can be used as a Spinner. Currently only has one dismiss
	method, because the 'showInView' methods need to be custom for each class
 */
public protocol Spinner {

    /**
     Dismiss the Spinner. Implementations should remove any views from their superview.
     */
    func dismiss()
}

public class SpinnerView: NSObject, Spinner {

    //TODO: Add an option to offset the indicator in the view or button

    private var controlTitleColors: [ControlTitleColor]?
    private var spinner: UIActivityIndicatorView?
    private var imageView: UIImageView?

    /**
     To display the indicator centered in a view.
     
     - Parameter view: The view to display the indicator in.
     - Parameter style: A constant that specifies the style of the object to be created.
     - Parameter color: A UIColor that specifies the tint of the spinner
     
     - Returns: A reference to the Spinner that was created, so that it can be dismissed as needed.
     */
    public static func showSpinnerInView(view: UIView, style: UIActivityIndicatorViewStyle = .White, color:UIColor? = nil) -> Spinner {
        let center      = CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2)
        let spinner     = UIActivityIndicatorView(activityIndicatorStyle: style)
        
        spinner.color = color
        spinner.center = center
        spinner.autoresizingMask = [.FlexibleTopMargin, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleBottomMargin]
        
        spinner.startAnimating()
        view.addSubview(spinner)
        
        let view = SpinnerView()
        view.spinner = spinner
        return view
    }
    
    /**
     To display the indicator centered in a button.
     The button's titleLabel colors will be set to clear color while the indicator is shown.
     
     - Parameter button: The button to display the indicator in.
     - Parameter style: A constant that specifies the style of the object to be created.
     - Parameter color: A UIColor that specifies the tint of the spinner
     
     - Returns: A reference to the Spinner that was created, so that it can be dismissed as needed.
     */
    public static func showSpinnerInButton(button: UIButton, style: UIActivityIndicatorViewStyle = .White, color:UIColor? = nil) -> Spinner {
        let view = showSpinnerInView(button, style: style, color: color)
        button.userInteractionEnabled = false
        if let spinnerView = view as? SpinnerView {
            spinnerView.controlTitleColors = button.allTitleColors()
            button.removeAllTitleColors()
        }
        
        return view
    }

    public func dismiss() {
        if let button = spinner?.superview as? UIButton {
            button.userInteractionEnabled = true
            button.restoreTitleColors(controlTitleColors)
        }
        spinner?.dismiss()
        imageView?.dismiss()
    }
}

// Extension of SpinnerView that supports an animated UIImageView as a custom activity indicator
public extension SpinnerView {

    // Private reference to a proxy UIImageView holding images for use in custom spinner.
    private static var animationImage: UIImageView?

    /**
     Used to create the custom indicator. Call this once (on app open, for example) and it
     will be set for the lifetime of the app.

     - Note:	Currently only supports one custom indicator. If you need multiple custom activity
     indicators, you are probably better off creating something custom.

     - Parameter images: An array containing the UIImages to use for the animation.
     - Parameter duration: The animation duration.
     */
    public static func setCustomImages(images: [UIImage], duration: NSTimeInterval) {
        let image = UIImageView(frame: CGRectMake(0, 0, images[0].size.width, images[0].size.height))
        image.animationImages = images
        image.animationDuration = duration
        animationImage = image
    }

    /**
     To display the indicator centered in a view.

     - Note: If the `animationImage` has not been created via `setCustomImages(_:duration:)`,
     it will default to the normal `UIActivityIndicatorView` and will not use
     a custom `UIImageView`.

     - Parameter view: The view to display the indicator in.

     - Returns: A reference to the `Spinner` that was created, so that it can be dismissed as needed.
     */
    public static func showCustomSpinnerInView(view: UIView) -> Spinner {
        if let image = animationImage {
            let imageView = UIImageView(frame: view.bounds)
            imageView.contentMode = .Center
            imageView.animationDuration = image.animationDuration
            imageView.animationImages = image.animationImages
            imageView.startAnimating()
            view.addSubview(imageView)

            let spinnerView = SpinnerView()
            spinnerView.imageView = imageView
            return spinnerView
        }
        else {
            return showSpinnerInView(view)
        }
    }

    /**
     To display the indicator centered in a button. 
     The button's titleLabel colors will be set to clear color while the indicator is shown.

     - Parameter button: The button to display the indicator in.

     - Returns: A reference to the ActivityIndicator that was created, so that it can be dismissed as needed
     */
    public static func showCustomSpinnerInButton(button: UIButton) -> Spinner {
        let view = showCustomSpinnerInView(button)

        if let spinnerView = view as? SpinnerView {
            spinnerView.controlTitleColors = button.allTitleColors()
            button.removeAllTitleColors()
        }

        return view
    }
}

// MARK: - Spinner Conformance -

// Extension to allow UIActivityIndicatorView to be dismissed.
extension UIActivityIndicatorView: Spinner {

    // Called when the activity indicator should be removed.
    public func dismiss() {
        stopAnimating()
        removeFromSuperview()
    }
}

// Extension to allow UIImageView to be dismissed
extension UIImageView: Spinner {

    // Called when the activity indicator should be removed.
    public func dismiss() {
        stopAnimating()
        removeFromSuperview()
    }
}

// MARK: - Private -

private extension UIButton {

    private func allTitleColors() -> [ControlTitleColor] {
        var colors: [ControlTitleColor] = [
            (.Normal, titleColorForState(.Normal)),
            (.Highlighted, titleColorForState(.Highlighted)),
            (.Disabled, titleColorForState(.Disabled)),
            (.Selected, titleColorForState(.Selected)),
            (.Application, titleColorForState(.Application)),
            (.Reserved, titleColorForState(.Reserved))
        ]

        if #available(iOS 9.0, *) {
            colors.append((.Focused, titleColorForState(.Focused)))
        }

        return colors
    }

    private func restoreTitleColors(colors: [ControlTitleColor]?) {
        guard let colors = colors else { return }
        for color in colors {
            setTitleColor(color.1, forState: color.0)
        }
    }

    private func removeAllTitleColors() {
        restoreTitleColors(allTitleColors().map({ return ($0.0, UIColor.clearColor()) }))
    }
}