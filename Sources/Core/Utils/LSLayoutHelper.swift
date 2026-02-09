//
//  LSLayoutHelper.swift
//  LSWaveformKit
//
//  Created by Link on 2025/02/09.
//  Copyright © 2025 Link. All rights reserved.
//

import UIKit

// MARK: - Layout Helper

/// 布局辅助类 - 替代 SnapKit 的简化实现
public final class LSLayoutHelper {
    private let item: UIView

    public init(_ item: UIView) {
        self.item = item
    }

    // MARK: - Constraint Creation

    public func makeConstraints(_ closure: (LSLayoutMaker) -> Void) {
        let maker = LSLayoutMaker()
        closure(maker)
        maker.applyConstraints(to: item)
    }

    public func remakeConstraints(_ closure: (LSLayoutMaker) -> Void) {
        item.removeConstraints(item.constraints)
        makeConstraints(closure)
    }

    public func updateConstraints(_ closure: (LSLayoutMaker) -> Void) {
        let maker = LSLayoutMaker()
        closure(maker)
        maker.updateConstraints(for: item)
    }
}

// MARK: - Layout Maker

public final class LSLayoutMaker {
    private var constraints: [NSLayoutConstraint] = []
    var item: UIView?

    init() {}

    func applyConstraints(to view: UIView) {
        self.item = view
        NSLayoutConstraint.activate(constraints)
    }

    func updateConstraints(for view: UIView) {
        // 找到相同属性的约束并更新
        for newConstraint in constraints {
            var found = false
            for existingConstraint in view.constraints {
                if existingConstraint.firstAttribute == newConstraint.firstAttribute &&
                   existingConstraint.firstItem === newConstraint.firstItem &&
                   existingConstraint.secondItem === newConstraint.secondItem {
                    existingConstraint.constant = newConstraint.constant
                    found = true
                    break
                }
            }
            if !found {
                NSLayoutConstraint.activate([newConstraint])
            }
        }
    }

    // MARK: - Anchor Properties

    public var height: LSLayoutProperty {
        return LSLayoutProperty(maker: self, attribute: .height)
    }

    public var width: LSLayoutProperty {
        return LSLayoutProperty(maker: self, attribute: .width)
    }

    public var top: LSLayoutProperty {
        return LSLayoutProperty(maker: self, attribute: .top)
    }

    public var bottom: LSLayoutProperty {
        return LSLayoutProperty(maker: self, attribute: .bottom)
    }

    public var leading: LSLayoutProperty {
        return LSLayoutProperty(maker: self, attribute: .leading)
    }

    public var trailing: LSLayoutProperty {
        return LSLayoutProperty(maker: self, attribute: .trailing)
    }

    public var centerX: LSLayoutProperty {
        return LSLayoutProperty(maker: self, attribute: .centerX)
    }

    public var centerY: LSLayoutProperty {
        return LSLayoutProperty(maker: self, attribute: .centerY)
    }

    public var center: LSLayoutCenter {
        return LSLayoutCenter(maker: self)
    }

    public var edges: LSLayoutEdges {
        return LSLayoutEdges(maker: self)
    }

    // MARK: - Constraint Storage

    func addConstraint(_ constraint: NSLayoutConstraint) {
        constraints.append(constraint)
    }

    var allConstraints: [NSLayoutConstraint] {
        return constraints
    }
}

// MARK: - Layout Property

public final class LSLayoutProperty {
    private let maker: LSLayoutMaker
    private let attribute: NSLayoutConstraint.Attribute
    private weak var item: UIView?

    init(maker: LSLayoutMaker, attribute: NSLayoutConstraint.Attribute, item: UIView? = nil) {
        self.maker = maker
        self.attribute = attribute
        self.item = item ?? maker.item
    }

    @discardableResult
    public func equalTo(_ constant: CGFloat) -> LSLayoutConstraint {
        let anchor = LSLayoutAnchor(item: maker.item!, attribute: attribute)
        let _ = anchor.offset(constant)
        maker.addConstraint(anchor.constraint())
        return LSLayoutConstraint(maker: maker, attribute: attribute)
    }

    public func equalTo(_ item: UIView) -> LSLayoutAnchor {
        let anchor = LSLayoutAnchor(item: item, attribute: attribute, maker: maker)
        var constraintAnchor = LSLayoutAnchor(item: maker.item!, attribute: attribute, maker: maker)
        constraintAnchor.secondItem = item
        constraintAnchor.secondAttribute = attribute
        maker.addConstraint(constraintAnchor.constraint())
        return anchor
    }

    @discardableResult
    public func equalToSuperview() -> LSLayoutAnchor {
        guard let superview = maker.item?.superview else {
            fatalError("视图没有父视图")
        }
        return equalTo(superview)
    }

    @discardableResult
    public func inset(_ amount: CGFloat) -> LSLayoutConstraint {
        return equalTo(-amount)
    }

    @discardableResult
    public func inset(_ insets: UIEdgeInsets) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        if attribute == .top || attribute == .bottom {
            let offset = attribute == .top ? insets.top : -insets.bottom
            let _ = equalTo(offset)
        }
        return constraints
    }

    // 支持链式访问其他视图的属性
    public var top: LSLayoutProperty {
        guard let item = item else {
            fatalError("视图未设置")
        }
        return LSLayoutProperty(maker: maker, attribute: .top, item: item)
    }

    public var bottom: LSLayoutProperty {
        guard let item = item else {
            fatalError("视图未设置")
        }
        return LSLayoutProperty(maker: maker, attribute: .bottom, item: item)
    }

    public var leading: LSLayoutProperty {
        guard let item = item else {
            fatalError("视图未设置")
        }
        return LSLayoutProperty(maker: maker, attribute: .leading, item: item)
    }

    public var trailing: LSLayoutProperty {
        guard let item = item else {
            fatalError("视图未设置")
        }
        return LSLayoutProperty(maker: maker, attribute: .trailing, item: item)
    }

    public var centerX: LSLayoutProperty {
        guard let item = item else {
            fatalError("视图未设置")
        }
        return LSLayoutProperty(maker: maker, attribute: .centerX, item: item)
    }

    public var centerY: LSLayoutProperty {
        guard let item = item else {
            fatalError("视图未设置")
        }
        return LSLayoutProperty(maker: maker, attribute: .centerY, item: item)
    }

    @discardableResult
    public func offset(_ value: CGFloat) -> LSLayoutAnchor {
        guard let itemView = item else {
            fatalError("视图未设置")
        }
        return LSLayoutAnchor(item: itemView, attribute: attribute, maker: maker).offset(value)
    }
}

// MARK: - Layout Constraint

public final class LSLayoutConstraint {
    private let maker: LSLayoutMaker
    private let attribute: NSLayoutConstraint.Attribute

    init(maker: LSLayoutMaker, attribute: NSLayoutConstraint.Attribute) {
        self.maker = maker
        self.attribute = attribute
    }

    public var constraint: NSLayoutConstraint {
        let anchor = LSLayoutAnchor(item: maker.item!, attribute: attribute)
        return anchor.constraint()
    }
}

// MARK: - Layout Edges

public final class LSLayoutEdges {
    private let maker: LSLayoutMaker

    init(maker: LSLayoutMaker) {
        self.maker = maker
    }

    public var top: LSLayoutProperty {
        return maker.top
    }

    public var bottom: LSLayoutProperty {
        return maker.bottom
    }

    public var leading: LSLayoutProperty {
        return maker.leading
    }

    public var trailing: LSLayoutProperty {
        return maker.trailing
    }
}

// MARK: - Layout Center

public final class LSLayoutCenter {
    private let maker: LSLayoutMaker

    init(maker: LSLayoutMaker) {
        self.maker = maker
    }

    @discardableResult
    public func equalToSuperview() -> LSLayoutCenter {
        guard let superview = maker.item?.superview else {
            fatalError("视图没有父视图")
        }
        centerX.equalTo(superview)
        centerY.equalTo(superview)
        return self
    }

    @discardableResult
    public func offset(_ value: CGFloat) -> LSLayoutCenter {
        centerX.offset(value)
        centerY.offset(value)
        return self
    }

    private var centerX: LSLayoutProperty {
        return maker.centerX
    }

    private var centerY: LSLayoutProperty {
        return maker.centerY
    }
}

// MARK: - Layout Anchor

public final class LSLayoutAnchor {
    private let item: UIView
    private let attribute: NSLayoutConstraint.Attribute
    private let relatedBy: NSLayoutConstraint.Relation
    private var constant: CGFloat = 0
    private var multiplier: CGFloat = 1
    fileprivate var secondItem: UIView?
    fileprivate var secondAttribute: NSLayoutConstraint.Attribute?
    private weak var maker: LSLayoutMaker?

    init(item: UIView, attribute: NSLayoutConstraint.Attribute, maker: LSLayoutMaker? = nil) {
        self.item = item
        self.attribute = attribute
        self.relatedBy = .equal
        self.maker = maker
    }

    @discardableResult
    public func constraint() -> NSLayoutConstraint {
        let constraint: NSLayoutConstraint
        if let secondItem = secondItem,
           let secondAttribute = secondAttribute {
            constraint = NSLayoutConstraint(
                item: item,
                attribute: attribute,
                relatedBy: relatedBy,
                toItem: secondItem,
                attribute: secondAttribute,
                multiplier: multiplier,
                constant: constant
            )
        } else {
            constraint = NSLayoutConstraint(
                item: item,
                attribute: attribute,
                relatedBy: relatedBy,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: multiplier,
                constant: constant
            )
        }
        return constraint
    }

    @discardableResult
    public func equalTo(_ other: UIView) -> LSLayoutAnchor {
        var anchor = LSLayoutAnchor(item: item, attribute: attribute, maker: maker)
        anchor.secondItem = other
        anchor.secondAttribute = attribute
        anchor.constant = self.constant
        if let maker = maker {
            maker.addConstraint(anchor.constraint())
        }
        return anchor
    }

    @discardableResult
    public func offset(_ value: CGFloat) -> LSLayoutAnchor {
        var anchor = LSLayoutAnchor(item: item, attribute: attribute, maker: maker)
        anchor.constant = value
        anchor.secondItem = self.secondItem
        anchor.secondAttribute = self.secondAttribute
        if let maker = maker {
            maker.addConstraint(anchor.constraint())
        }
        return anchor
    }
}

// MARK: - View Extension

public extension UIView {
    var ls: LSLayoutHelper {
        return LSLayoutHelper(self)
    }

    var snp: LSLayoutHelper {
        return LSLayoutHelper(self)
    }
}

// MARK: - Layout View Properties

public final class LSLayoutViewProperties {
    private weak var view: UIView?

    init(view: UIView) {
        self.view = view
    }

    public var top: LSLayoutProperty {
        guard let view = view else {
            fatalError("视图未设置")
        }
        return LSLayoutProperty(maker: LSLayoutMaker(), attribute: .top, item: view)
    }

    public var bottom: LSLayoutProperty {
        guard let view = view else {
            fatalError("视图未设置")
        }
        return LSLayoutProperty(maker: LSLayoutMaker(), attribute: .bottom, item: view)
    }

    public var leading: LSLayoutProperty {
        guard let view = view else {
            fatalError("视图未设置")
        }
        return LSLayoutProperty(maker: LSLayoutMaker(), attribute: .leading, item: view)
    }

    public var trailing: LSLayoutProperty {
        guard let view = view else {
            fatalError("视图未设置")
        }
        return LSLayoutProperty(maker: LSLayoutMaker(), attribute: .trailing, item: view)
    }

    public var centerX: LSLayoutProperty {
        guard let view = view else {
            fatalError("视图未设置")
        }
        return LSLayoutProperty(maker: LSLayoutMaker(), attribute: .centerX, item: view)
    }

    public var centerY: LSLayoutProperty {
        guard let view = view else {
            fatalError("视图未设置")
        }
        return LSLayoutProperty(maker: LSLayoutMaker(), attribute: .centerY, item: view)
    }
}
