//
//  NSAttributedString+DawnExtensions.swift
//  DawnExtensions
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit

#endif

#if os(OSX)

import AppKit

#endif

public extension NSAttributedString {
    
    /// 获取字体
    func getFont() -> NSUIFont? {
        return getAttribute(.font) as? NSUIFont
    }
    
    /// 获取字距
    func getKern() -> Int? {
        return getAttribute(.kern) as? Int
    }
    
    /// 获取前景色
    func getForegroundColor() -> NSUIColor? {
        return getAttribute(.foregroundColor) as? NSUIColor
    }
    
    /// 获取背景色
    func getBackgroundColor() -> NSUIColor? {
        return getAttribute(.backgroundColor) as? NSUIColor
    }
    
    /// 获取描边宽度
    func getStrokeWidth() -> CGFloat? {
        return getAttribute(.strokeWidth) as? CGFloat
    }
    
    /// 获取描边颜色
    func getStrokeColor() -> NSUIColor? {
        return getAttribute(.strokeColor) as? NSUIColor
    }
    
    /// 获取阴影
    func getShadow() -> NSShadow? {
        return getAttribute(.shadow) as? NSShadow
    }
    
    /// 获取删除线样式
    func getStrikethroughStyle() -> NSUnderlineStyle {
        return getAttribute(.strikethroughStyle) as? NSUnderlineStyle ?? NSUnderlineStyle(rawValue: 0)
    }
    
    /// 获取删除线颜色
    func getStrikethroughColor() -> NSUIColor? {
        return getAttribute(.strikethroughColor) as? NSUIColor
    }
    
    /// 获取下划线样式
    func getUnderlineStyle() -> NSUnderlineStyle {
        return getAttribute(.underlineStyle) as? NSUnderlineStyle ?? NSUnderlineStyle(rawValue: 0)
    }
    
    /// 获取下划线颜色
    func getUnderlineColor() -> NSUIColor? {
        return getAttribute(.underlineColor) as? NSUIColor
    }
    
    /// 获取连字属性 (1已使用 0未使用)
    func getLigature() -> Int? {
        return getAttribute(.ligature) as? Int
    }
    
    /// 获取文本特殊效果
    func getTextEffect() -> String? {
        return getAttribute(.textEffect) as? String
    }
    
    /// 获取字形倾斜度
    func getObliqueness() -> Float? {
        return getAttribute(.obliqueness) as? Float
    }
    
    /// 获取基线偏移值
    func getBaselineOffset() -> Float? {
        return getAttribute(.baselineOffset) as? Float
    }
    
    /// 获取文本拉伸值 (正值横向拉伸文本，负值横向压缩文本)
    func getExpansion() -> Float? {
        return getAttribute(.expansion) as? Float
    }
    
    /// 获取文字排版方向 (0 横排文本，1 竖排文本)
    func getGlyphForm() -> Int? {
        return getAttribute(.verticalGlyphForm) as? Int
    }
    
    /// 获取上标或下标
    func getSuperscript() -> Int? {
        return getAttribute(kCTSuperscriptAttributeName as NSAttributedString.Key) as? Int
    }
    
    /// 获取文本附件
    func getAttachment() -> NSTextAttachment? {
        return getAttribute(.attachment) as? NSTextAttachment
    }
    
    /// 获取文本链接 (返回类型为URL 或 String)
    func getLink() -> Any? {
        return getAttribute(.link)
    }
    
    /// 获取文本段落排版格式
    func getParagraphStyle() -> NSParagraphStyle? {
        return getAttribute(.paragraphStyle) as? NSParagraphStyle
    }
    
    /// 获取指定位置处指定属性名称的属性值
    func getAttribute(_ attrName: NSAttributedString.Key, at location: Int = 0) -> Any? {
        guard length > 0, location <= length else { return nil }
        let index = (location == length) ? location - 1 : location
        return attribute(attrName, at: index, effectiveRange: nil)
    }
    
    /// 获取指定位置上的所有属性字典
    func getAttributes(at location: Int = 0) -> [NSAttributedString.Key : Any]? {
        guard length > 0, location <= length else { return nil }
        let index = (location == length) ? location - 1 : location
        return attributes(at: index, effectiveRange: nil)
    }
}

public extension NSMutableAttributedString {
    
    /// 设置字体
    @discardableResult
    func font(_ font: NSUIFont?) -> Self {
        setFont(font, range: NSRange(location: 0, length: length))
        return self
    }
    
    /// 调整字距
    @discardableResult
    func kern(_ kern: Int?) -> Self {
        setKern(kern, range: NSRange(location: 0, length: length))
        return self
    }
    
    /// 设置前景色
    @discardableResult
    func foregroundColor(_ color: NSUIColor?) -> Self {
        setForegroundColor(color, range: NSRange(location: 0, length: length))
        return self
    }
    
    /// 设置背景色
    @discardableResult
    func backgroundColor(_ color: NSUIColor?) -> Self {
        setBackgroundColor(color, range: NSRange(location: 0, length: length))
        return self
    }
    
    /// 设置描边宽度
    @discardableResult
    func strokeWidth(_ strokeWidth: CGFloat?) -> Self {
        setStrokeWidth(strokeWidth, range: NSRange(location: 0, length: length))
        return self
    }
    
    /// 设置描边颜色
    @discardableResult
    func strokeColor(_ color: NSUIColor?) -> Self {
        setStrokeColor(color, range: NSRange(location: 0, length: length))
        return self
    }
    
    /// 设置阴影
    @discardableResult
    func shadow(_ shadow: NSShadow?) -> Self {
        setShadow(shadow, range: NSRange(location: 0, length: length))
        return self
    }
    
    /// 设置删除线样式
    @discardableResult
    func strikethroughStyle(_ strikethroughStyle: NSUnderlineStyle) -> Self {
        setStrikethroughStyle(strikethroughStyle, range: NSRange(location: 0, length: length))
        return self
    }
    
    /// 设置删除线颜色
    @discardableResult
    func strikethroughColor(_ strikethroughColor: NSUIColor?) -> Self {
        setStrikethroughColor(strikethroughColor, range: NSRange(location: 0, length: length))
        return self
    }
    
    /// 设置下划线样式
    @discardableResult
    func underlineStyle(_ underlineStyle: NSUnderlineStyle) -> Self {
        setUnderlineStyle(underlineStyle, range: NSRange(location: 0, length: length))
        return self
    }
    
    /// 设置下划线颜色
    @discardableResult
    func underlineColor(_ underlineColor: NSUIColor?) -> Self {
        setUnderlineColor(underlineColor, range: NSRange(location: 0, length: length))
        return self
    }
    
    /// 是否使用连字属性 (1使用连字属性 0表示不使用连字属性)
    @discardableResult
    func ligature(_ ligature: Int?) -> Self {
        setLigature(ligature, range: NSRange(location: 0, length: length))
        return self
    }
    
    /// 设置文本特殊效果
    @discardableResult
    func textEffect(_ textEffect: String?) -> Self {
        setTextEffect(textEffect, range: NSRange(location: 0, length: length))
        return self
    }
    
    /// 设置字形倾斜度
    @discardableResult
    func obliqueness(_ obliqueness: Float?) -> Self {
        setObliqueness(obliqueness, range: NSRange(location: 0, length: length))
        return self
    }
    
    /// 设置文本横向拉伸属性 (正值横向拉伸文本，负值横向压缩文本)
    @discardableResult
    func expansion(_ expansion: Float?) -> Self {
        setExpansion(expansion, range: NSRange(location: 0, length: length))
        return self
    }
    
    /// 设置基线偏移值 (正值上偏，负值下偏)
    @discardableResult
    func baselineOffset(_ baselineOffset: Float?) -> Self {
        setBaselineOffset(baselineOffset, range: NSRange(location: 0, length: length))
        return self
    }
    
    /// 设置文字排版方向 (0 表示横排文本，1 表示竖排文本)
    @discardableResult
    func glyphForm(_ glyphForm: Int?) -> Self {
        setGlyphForm(glyphForm, range: NSRange(location: 0, length: length))
        return self
    }
    
    /// 设置上标和下标 (需要字体支持，默认为0，-1为下标，1为上标 如化学式Fe₃O₄)
    @discardableResult
    func superscript(_ superscript: Int?) -> Self {
        setSuperscript(superscript, range: NSRange(location: 0, length: length))
        return self
    }
    
    /// 设置文本附件 (常用于文字图片混排)
    @discardableResult
    func attachment(_ attachment: NSTextAttachment?) -> Self {
        setAttachment(attachment, range: NSRange(location: 0, length: length))
        return self
    }
    
    /// 设置链接属性，打开指定URL地址 (类型为URL (preferred) or String)
    @discardableResult
    func link(_ link: Any?) -> Self {
        setLink(link, range: NSRange(location: 0, length: length))
        return self
    }
    
    /// 设置文本段落排版格式
    @discardableResult
    func paragraphStyle(_ paragraphStyle: NSParagraphStyle?) -> Self {
        setParagraphStyle(paragraphStyle, range: NSRange(location: 0, length: length))
        return self
    }
    
    /// 设置字体并指定范围
    func setFont(_ font: NSUIFont?, range: NSRange) {
        setAttribute(.font, value: font, range: range)
    }
    
    /// 调整字距并指定范围
    func setKern(_ kern: Int?, range: NSRange) {
        setAttribute(.kern, value: kern, range: range)
    }
    
    /// 设置前景色并指定范围
    func setForegroundColor(_ color: NSUIColor?, range: NSRange) {
        setAttribute(.foregroundColor, value: color, range: range)
    }
    
    /// 设置背景色并指定范围
    func setBackgroundColor(_ color: NSUIColor?, range: NSRange) {
        setAttribute(.backgroundColor, value: color, range: range)
    }
    
    /// 设置描边宽度并指定范围
    func setStrokeWidth(_ width: CGFloat?, range: NSRange) {
        setAttribute(.strokeWidth, value: width, range: range)
    }
    
    /// 设置描边颜色并指定范围
    func setStrokeColor(_ color: NSUIColor?, range: NSRange) {
        setAttribute(.strokeColor, value: color, range: range)
    }
    
    /// 设置阴影并指定范围
    func setShadow(_ shadow: NSShadow?, range: NSRange) {
        setAttribute(.shadow, value: shadow, range: range)
    }
    
    /// 设置删除线样式并指定范围
    func setStrikethroughStyle(_ lineStyle: NSUnderlineStyle, range: NSRange) {
        let style = lineStyle.rawValue == 0 ? nil : lineStyle
        setAttribute(.strikethroughStyle, value: style, range: range)
    }

    /// 设置删除线颜色并指定范围
    func setStrikethroughColor(_ color: NSUIColor?, range: NSRange) {
        setAttribute(.strikethroughColor, value: color, range: range)
    }
    
    /// 设置下划线样式并指定范围
    func setUnderlineStyle(_ lineStyle: NSUnderlineStyle, range: NSRange) {
        let style = lineStyle.rawValue == 0 ? nil : lineStyle
        setAttribute(.underlineStyle, value: style?.rawValue, range: range)
    }

    /// 设置下划线颜色并指定范围
    func setUnderlineColor(_ color: NSUIColor?, range: NSRange) {
        setAttribute(.underlineColor, value: color, range: range)
    }
    
    /// 设置是否使用连字属性 (1使用连字属性 0表示不使用连字属性)
    func setLigature(_ ligature: Int?, range: NSRange) {
        setAttribute(.ligature, value: ligature, range: range)
    }
    
    /// 设置文本特殊效果并指定范围
    func setTextEffect(_ textEffect: String?, range: NSRange) {
        setAttribute(.textEffect, value: textEffect, range: range)
    }
    
    /// 设置字形倾斜度并指定范围
    func setObliqueness(_ obliqueness: Float?, range: NSRange) {
        setAttribute(.obliqueness, value: obliqueness, range: range)
    }
    
    /// 设置文本横向拉伸属性 (正值横向拉伸文本，负值横向压缩文本)
    func setExpansion(_ expansion: Float?, range: NSRange) {
        setAttribute(.expansion, value: expansion, range: range)
    }
    
    /// 设置基线偏移值 (正值上偏，负值下偏)
    func setBaselineOffset(_ offset: Float?, range: NSRange) {
        setAttribute(.baselineOffset, value: offset, range: range)
    }
    
    /// 设置文字排版方向并指定范围 (0 表示横排文本，1 表示竖排文本)
    func setGlyphForm(_ glyphForm: Int?, range: NSRange) {
        setAttribute(.verticalGlyphForm, value: glyphForm, range: range)
    }
    
    /// 设置上标和下标 (需要字体支持，默认为0，-1为下标，1为上标 如化学式Fe₃O₄)
    func setSuperscript(_ superscript: Int?, range: NSRange) {
        let value = superscript == 0 ? nil : superscript
        setAttribute(kCTSuperscriptAttributeName as NSAttributedString.Key, value: value, range: range)
    }
    
    /// 设置文本附件并指定范围 (常用于文字图片混排)
    func setAttachment(_ attachment: NSTextAttachment?, range: NSRange) {
        setAttribute(.attachment, value: attachment, range: range)
    }
    
    /// 设置链接属性并指定范围，点击后打开指定URL地址 (类型为URL (preferred) or String)
    func setLink(_ link: Any?, range: NSRange) {
        setAttribute(.link, value: link, range: range)
    }
    
    /// 设置文本段落排版格式并指定范围
    func setParagraphStyle(_ paragraphStyle: NSParagraphStyle?, range: NSRange) {
        setAttribute(.paragraphStyle, value: paragraphStyle, range: range)
    }
    
    /// 为字符串设置指定属性key对应的值
    func setAttribute(_ name: NSAttributedString.Key, value: Any?) {
        setAttribute(name, value: value, range: NSRange(location: 0, length: length))
    }
    
    /// 为字符串设置指定属性key对应的值，范围NSRange
    func setAttribute(_ name: NSAttributedString.Key, value: Any?, range: NSRange) {
        if let result = value {
            addAttribute(name, value: result, range: range)
        } else {
            removeAttribute(name, range: range)
        }
    }
    
    /// 删除字符串指定范围内的属性值
    func removeAttributes(in range: NSRange) {
        setAttributes(nil, range: range)
    }
    
    /// 替换指定范围内字符串
    func replace(_ attributedString: NSAttributedString, range: NSRange) {
        guard NSMaxRange(range) <= length else { return }
        replaceCharacters(in: range, with: attributedString)
    }
    
    /// 在指定位置插入字符串
    func inset(_ attributedString: NSAttributedString, at location: Int) {
        guard location <= length else { return }
        insert(attributedString, at: location)
    }
}

public extension NSMutableParagraphStyle {
    
    /// 设置字体的行间距
    @discardableResult
    func lineSpacing(_ value: CGFloat) -> Self {
        lineSpacing = value
        return self
    }
    
    /// 设置段间距
    @discardableResult
    func paragraphSpacing(_ value: CGFloat) -> Self {
        paragraphSpacing = value
        return self
    }
    
    /// 文本对齐方式
    @discardableResult
    func alignment(_ value: NSTextAlignment) -> Self {
        alignment = value
        return self
    }
    
    /// 首行缩进
    @discardableResult
    func firstLineHeadIndent(_ value: CGFloat) -> Self {
        firstLineHeadIndent = value
        return self
    }
    
    /// 整体缩进 (首行除外)
    @discardableResult
    func headIndent(_ value: CGFloat) -> Self {
        headIndent = value
        return self
    }
    
    /// 行尾缩进 (注意距离是从行首算起)
    @discardableResult
    func tailIndent(_ value: CGFloat) -> Self {
        tailIndent = value
        return self
    }
    
    /// 结尾部分内容的省略方式
    @discardableResult
    func lineBreakMode(_ value: NSLineBreakMode) -> Self {
        lineBreakMode = value
        return self
    }
    
    /// 最低行高
    @discardableResult
    func minimumLineHeight(_ value: CGFloat) -> Self {
        minimumLineHeight = value
        return self
    }
    
    /// 最大行高
    @discardableResult
    func maximumLineHeight(_ value: CGFloat) -> Self {
        maximumLineHeight = value
        return self
    }
    
    /// 书写方向
    @discardableResult
    func baseWritingDirection(_ value: NSWritingDirection) -> Self {
        baseWritingDirection = value
        return self
    }
    
    /// 行间距是多少倍 (可变行高因数)
    @discardableResult
    func lineHeightMultiple(_ value: CGFloat) -> Self {
        lineHeightMultiple = value
        return self
    }
    
    /// 段首行空白间隙
    @discardableResult
    func paragraphSpacingBefore(_ value: CGFloat) -> Self {
        paragraphSpacingBefore = value
        return self
    }

    /// 连字符属性 (iOS中支持的值分别为0和1)
    @discardableResult
    func hyphenationFactor(_ value: Float) -> Self {
        hyphenationFactor = value
        return self
    }
}
