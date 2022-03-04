//
//  AnimatedPillsPageView.swift
//
//
//  Created by Marcelo Santos Júnior on 25/02/22.
//

#if !os(macOS)
import Foundation
import UIKit

public class AnimatedPillsPageView: UIStackView {
    
    public var numberOfPages: Int = 0 {
        didSet {
            setup()
        }
    }
    
    fileprivate (set)var currentPage: Float = 0 {
        didSet {
            setPage()
        }
    }
    var widthConstraints: [NSLayoutConstraint] = []
    weak var delegate: PageIndicatorCollectionViewDelegate? {
        didSet {
            delegate?.pageIndicator = self
        }
    }
    
    public let selectedColor: UIColor
    public let normalColor: UIColor
    public let minItemWidth: Float
    public let maxItemWidth: Float
    public let itemHeight: Float
    public let itemSpacing: Float
    
    public init(selectedColor: UIColor,
         normalColor: UIColor,
         minItemWidth: Float = 8.0,
         maxItemWidth: Float = 32.0,
         itemHeight: Float = 6.0,
         itemSpacing: Float = 8.0) {
        self.selectedColor = selectedColor
        self.normalColor = normalColor
        self.minItemWidth = minItemWidth
        self.maxItemWidth = maxItemWidth
        self.itemHeight = itemHeight
        self.itemSpacing = itemSpacing
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setup() {
        arrangedSubviews.forEach({ $0.removeFromSuperview() })
        for _ in 0..<numberOfPages {
            let view = createView()
            addArrangedSubview(view)
        }
        setNeedsLayout()
        layoutIfNeeded()
        spacing = CGFloat(itemSpacing)
        currentPage = 0
    }
    
    private func setPage() {
        var factor = abs(fmodf(currentPage, 1.0))
        
        // Check if is swiping left
        if currentPage < 0 {
            factor = 1 - factor
        }
        
        if factor == 0 {
            factor = 1
        }
        
        let actualPage: Int = Int(abs(ceil(currentPage)))
        
        guard actualPage < numberOfPages else { return }
        
        for i in 0..<numberOfPages {
            if i != actualPage {
                if self.widthConstraints[i].constant > CGFloat(minItemWidth + 1.0) {
                    self.widthConstraints[i].constant = CGFloat(min(minItemWidth/factor, maxItemWidth))
                }
            }
        }
        
        // Correction to be smoothier
        if maxItemWidth*factor > 2*maxItemWidth/3 {
            factor = 1
        }
        
        self.widthConstraints[actualPage].constant = CGFloat(floor(max(maxItemWidth*factor, minItemWidth)))

        UIView.animate(withDuration: 0.5) {
            self.arrangedSubviews[actualPage].layoutIfNeeded()
            self.setNeedsLayout()
            self.layoutIfNeeded()
        } completion: { _ in
            for i in 0..<self.numberOfPages {
                UIView.animate(withDuration: 0.5) {
                    if self.widthConstraints[i].constant < CGFloat(self.maxItemWidth/2) {
                        self.arrangedSubviews[i].backgroundColor = self.normalColor
                    } else {
                        self.arrangedSubviews[i].backgroundColor = self.selectedColor
                    }
                }
            }
            
        }
    }
    
    private func createView() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = CGFloat(itemHeight/2)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = normalColor
        let widthConstraint = view.widthAnchor.constraint(equalToConstant: CGFloat(minItemWidth))
        widthConstraints.append(widthConstraint)
        widthConstraint.isActive = true
        view.heightAnchor.constraint(equalToConstant: CGFloat(itemHeight)).isActive = true
        return view
    }
}

public class PageIndicatorCollectionViewDelegate: NSObject, UIScrollViewDelegate {
    
    fileprivate weak var pageIndicator: AnimatedPillsPageView?
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        let offSet = max(scrollView.contentOffset.x, .zero)
        
        let currentPage = (offSet) / pageWidth
        
        if scrollView.panGestureRecognizer.translation(in: scrollView.superview).x > 0 {
            self.pageIndicator?.currentPage = -1*Float(currentPage)
        } else {
            self.pageIndicator?.currentPage = Float(currentPage)
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        stoppedScrolling(scrollView: scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        stoppedScrolling(scrollView: scrollView)
    }
    
    private func stoppedScrolling(scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        let offSet = max(scrollView.contentOffset.x, .zero)
        let currentPage = (offSet) / pageWidth
        self.pageIndicator?.currentPage = Float(ceil(currentPage))
    }
}
#endif
