//
//  NSAttributedString+Extensions.swift
//  Acht
//
//  Created by forkon on 2018/9/21.
//  Copyright © 2018 waylens. All rights reserved.
//


func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
    
    guard let a = lhs.mutableCopy() as? NSMutableAttributedString else {
        return NSAttributedString()
    }
    
    guard let b = rhs.mutableCopy() as? NSMutableAttributedString else {
        return NSAttributedString()
    }
    
    a.append(b)
    
    guard let copyA = a.copy() as? NSAttributedString else {
        return NSAttributedString()
    }
    return copyA
}

func + (lhs: NSAttributedString, rhs: String) -> NSAttributedString {
    guard let a = lhs.mutableCopy() as? NSMutableAttributedString else {
        return NSAttributedString()
    }
    let b = NSMutableAttributedString(string: rhs)
    return a + b
}

public extension NSAttributedString {

    static func attributedString(title: String,
                                 titleFont: UIFont,
                                 titleColor: UIColor = UIColor.black,
                                 imageOnTitleLeft: UIImage?,
                                 imageOnTitleRight: UIImage?) -> NSAttributedString {
        let space = "  "
        let leftImagePlaceholder = "#LeftImage#"
        let rightImagePlaceholder = "#RightImage#"
        let leftContent = "\(leftImagePlaceholder)\(space)"

        let rightContent: String

        if title.isEmpty {
            rightContent = "\(rightImagePlaceholder)"
        }
        else {
            rightContent = "\(space)\(rightImagePlaceholder)"
        }

        let attributedTitle = NSMutableAttributedString(string: "\(leftContent)\(title)\(rightContent)")

        attributedTitle.setAttributes(
            [
                NSAttributedString.Key.font : titleFont,
                NSAttributedString.Key.foregroundColor : titleColor
            ],
            range: NSRange(location: 0, length: attributedTitle.length)
        )

        if let imageInTitleLeftSide = imageOnTitleLeft {
            let imageWidth = imageInTitleLeftSide.size.width
            let imageHeight = imageInTitleLeftSide.size.height

            let leftImageAttachment = NSTextAttachment(data: nil, ofType: nil)
            leftImageAttachment.bounds = CGRect(x: 0.0, y: (titleFont.capHeight - imageHeight).rounded() / 2, width: imageWidth, height: imageHeight)
            leftImageAttachment.image = imageInTitleLeftSide

            let leftImageString = NSAttributedString(attachment: leftImageAttachment)

            attributedTitle.replaceCharacters(
                in: (attributedTitle.string as NSString).range(of: leftImagePlaceholder),
                with: leftImageString
            )
        } else {
            attributedTitle.replaceCharacters(
                in: (attributedTitle.string as NSString).range(of: leftContent),
                with: ""
            )
        }

        if let imageInTitleRightSide = imageOnTitleRight {
            let imageWidth = imageInTitleRightSide.size.width
            let imageHeight = imageInTitleRightSide.size.height

            let rightImageAttachment = NSTextAttachment(data: nil, ofType: nil)
            rightImageAttachment.bounds = CGRect(x: 0.0, y: (titleFont.capHeight - imageHeight).rounded() / 2, width: imageWidth, height: imageHeight)
            rightImageAttachment.image = imageInTitleRightSide

            let rightImageString = NSAttributedString(attachment: rightImageAttachment)

            attributedTitle.replaceCharacters(
                in: (attributedTitle.string as NSString).range(of: rightImagePlaceholder),
                with: rightImageString
            )
        } else {
            attributedTitle.replaceCharacters(
                in: (attributedTitle.string as NSString).range(of: rightContent),
                with: ""
            )
        }

        return attributedTitle
    }

    convenience init(string: String, font: UIFont, textColor: UIColor, indent: CGFloat) {
        let style: NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        style.firstLineHeadIndent = indent
        style.headIndent = indent
        style.tailIndent = -indent

        let attributes = [
            NSAttributedString.Key.paragraphStyle : style,
            NSAttributedString.Key.font : font,
            NSAttributedString.Key.foregroundColor : textColor
        ]

        self.init(string: string, attributes: attributes)
    }

}

extension NSAttributedString {

    func size(constrainedToWidth width: CGFloat) -> CGSize {
        let framesetter = CTFramesetterCreateWithAttributedString(self)
        return CTFramesetterSuggestFrameSizeWithConstraints(
            framesetter,
            CFRange(location: 0,length: 0),
            nil,
            CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
            nil
        )
    }

}

public extension NSAttributedString {

    static func titleAndTagString(
        title: String,
        titleFont: UIFont,
        tag: String?,
        tagFont: UIFont = UIFont.systemFont(ofSize: 10.0),
        tagBackgroundColor: UIColor = UIColor.semanticColor(.tint(.primary))
        ) -> NSAttributedString {

        var tagImage: UIImage? = nil

        if tag != nil {
            let tagLabel = UILabel()
            tagLabel.text = tag
            tagLabel.textColor = UIColor.white
            tagLabel.font = tagFont
            tagLabel.textAlignment = .center
            tagLabel.backgroundColor = tagBackgroundColor
            tagLabel.sizeToFit()
            tagLabel.frame = tagLabel.frame.insetBy(dx: -5.0, dy: -2.0)
            tagLabel.roundCorners(UIRectCorner.allCorners, radius: tagLabel.frame.height)

            tagImage = tagLabel.asImage()
        }

        return NSAttributedString.attributedString(
            title: title,
            titleFont: titleFont,
            titleColor: UIColor.semanticColor(.label(.secondary)),
            imageOnTitleLeft: nil,
            imageOnTitleRight: tagImage
        )
    }
}
