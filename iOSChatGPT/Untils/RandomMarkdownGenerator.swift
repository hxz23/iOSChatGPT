//
//  RandomMarkdownGenerator.swift
//  iOSChatGPT
//
//  Created by 郝学智 on 2025/12/26.
//

import Foundation
import SwiftUI


class StreamMarkdownGenerator {
    // MARK: - 配置参数
    /// 每个片段的延迟时间（可自定义）
    let segmentDelay: TimeInterval = 0.6
    /// 逐字符延迟时间
    let charDelay: TimeInterval = 0.04
    /// 是否包含图片（可开关）
    let includeImage: Bool = true
    /// 是否包含表格（可开关）
    let includeTable: Bool = true
    /// 是否包含代码块（可开关）
    let includeCodeBlock: Bool = true
    /// 生成的元素总数（控制内容长度）
    let totalElements: Int = 8

    // MARK: - 数据源
    /// 基础词库
    private let randomWords = [
        "Swift", "iOS", "SwiftUI", "UIKit", "Markdown", "编程", "开发", "测试", "示例", "教程",
        "组件", "布局", "动画", "网络", "数据", "模型", "视图", "控制器", "框架", "性能",
        "优化", "调试", "发布", "打包", "签名", "证书", "模拟器", "真机", "适配", "兼容",
        "异步", "并发", "线程", "安全", "渲染", "布局", "约束", "动画", "手势", "导航"
    ]

    /// 随机图片URL
    private let randomImageUrls = [
        "https://picsum.photos/800/400",
        "https://picsum.photos/800/600",
        "https://picsum.photos/1000/500"
    ]

    /// 多语言代码块
    private let codeSnippets: [String: String] = [
        "swift": """
        // Swift异步流示例
        func generateStream() -> AsyncStream<String> {
            AsyncStream { continuation in
                Task {
                    for i in 1...5 {
                        continuation.yield("第\\(i)条数据")
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                    }
                    continuation.finish()
                }
            }
        }
        """,
        "python": """
        # Python列表推导式
        numbers = [1, 2, 3, 4, 5]
        squared = [x*x for x in numbers if x % 2 == 0]
        print("偶数平方：", squared)
        """,
        "javascript": """
        // JavaScript异步函数
        async function fetchData(url) {
            const response = await fetch(url);
            const data = await response.json();
            console.log("获取数据：", data);
            return data;
        }
        """
    ]

    /// 表格列名（随机选择）
    private let tableHeaders = [
        ["特性", "SwiftUI", "UIKit"],
        ["语言", "优点", "缺点"],
        ["组件", "适用场景", "性能"]
    ]

    // MARK: - 对外API
    /// 按片段流式生成完整Markdown（支持全类型）
    func generateFullMarkdownStream() -> AsyncStream<String> {
        // 1. 生成所有Markdown片段（随机组合全类型元素）
        let allSegments = generateRandomMarkdownSegments()

        // 2. 异步流返回每个片段
        return AsyncStream { continuation in
            Task {
                for segment in allSegments {
                    continuation.yield(segment)
                    try? await Task.sleep(nanoseconds: UInt64(segmentDelay * 1_000_000_000))
                }
                continuation.finish()
            }
        }
    }

    /// 逐字符流式生成（适配全类型）
    func generateCharByCharStream() -> AsyncStream<String> {
        let fullMarkdown = generateRandomMarkdownSegments().joined()
        var currentText = ""

        return AsyncStream { continuation in
            Task {
                for char in fullMarkdown {
                    currentText.append(char)
                    continuation.yield(currentText)
                    try? await Task.sleep(nanoseconds: UInt64(charDelay * 1_000_000_000))
                }
                continuation.finish()
            }
        }
    }

    // MARK: - 核心：生成随机Markdown片段列表（包含所有类型）
    private func generateRandomMarkdownSegments() -> [String] {
        var segments = [String]()

        // 1. 首元素：随机级别标题（1-3级）
        let titleLevel = Int.random(in: 1...3)
        let titleText = generateRichText(wordCount: Int.random(in: 2...5), includeStyle: false)
        segments.append("\(String(repeating: "#", count: titleLevel)) \(titleText)\n\n")

        // 2. 随机生成N个不同类型的元素
        for _ in 0..<totalElements {
            let elementType = Int.random(in: 0...10) // 0-10对应不同Markdown类型
            switch elementType {
            case 0: // 段落（带富文本样式：加粗/斜体/删除线）
                let paragraph = generateRichParagraph(sentenceCount: Int.random(in: 2...4))
                segments.append("\(paragraph)\n\n")
            case 1: // 无序列表（带行内代码）
                let unorderedList = generateUnorderedList(itemCount: Int.random(in: 3...5), includeInlineCode: true)
                segments.append("\(unorderedList)\n\n")
            case 2: // 有序列表
                let orderedList = generateOrderedList(itemCount: Int.random(in: 3...5))
                segments.append("\(orderedList)\n\n")
            case 3: // 引用块
                let quote = generateQuoteBlock(sentenceCount: Int.random(in: 1...3))
                segments.append("\(quote)\n\n")
            case 4 where includeImage: // 图片（带alt文本）
                let image = generateImage()
                segments.append("\(image)\n\n")
            case 5: // 超链接（行内/参考式随机）
                let link = generateLink()
                segments.append("\(link)\n\n")
            case 6 where includeCodeBlock: // 代码块（多语言随机）
                let codeBlock = generateCodeBlock()
                segments.append("\(codeBlock)\n\n")
            case 7 where includeTable: // 表格
                let table = generateTable(rowCount: Int.random(in: 2...4))
                segments.append("\(table)\n\n")
            case 8: // 分割线
                segments.append("---\n\n")
            case 9: // 行内代码+富文本混合段落
                let mixParagraph = generateRichParagraph(sentenceCount: 1, includeAllStyle: true)
                segments.append("\(mixParagraph)\n\n")
            case 10: // 4-6级小标题
                let subTitleLevel = Int.random(in: 4...6)
                let subTitle = generateRichText(wordCount: Int.random(in: 1...3), includeStyle: false)
                segments.append("\(String(repeating: "#", count: subTitleLevel)) \(subTitle)\n\n")
            default: // 兜底：普通段落
                let paragraph = generateRichParagraph(sentenceCount: Int.random(in: 2...3), includeAllStyle: false)
                segments.append("\(paragraph)\n\n")
            }
        }

        return segments
    }

    // MARK: - 各类Markdown元素生成方法
    /// 生成带样式的文本（加粗/**斜体**/~~删除线~~）
    private func generateRichText(wordCount: Int, includeStyle: Bool = true) -> String {
        let words = (0..<wordCount).map { _ in randomWords.randomElement()! }
        guard includeStyle else { return words.joined(separator: " ").capitalized }

        // 随机为部分单词添加样式
        var styledWords = [String]()
        for word in words {
            let styleType = Int.random(in: 0...3)
            switch styleType {
            case 1: styledWords.append("**\(word)**") // 加粗
            case 2: styledWords.append("*\(word)*")   // 斜体
            case 3: styledWords.append("~~\(word)~~") // 删除线
            default: styledWords.append(word)
            }
        }
        return styledWords.joined(separator: " ").capitalized
    }

    /// 生成带富文本的段落
    private func generateRichParagraph(sentenceCount: Int, includeAllStyle: Bool = false) -> String {
        var sentences = [String]()
        for _ in 0..<sentenceCount {
            let wordCount = Int.random(in: 5...12)
            let sentence = generateRichText(wordCount: wordCount, includeStyle: includeAllStyle) + "。"
            sentences.append(sentence)
        }
        return sentences.joined(separator: " ")
    }

    /// 生成无序列表（可选行内代码）
    private func generateUnorderedList(itemCount: Int, includeInlineCode: Bool) -> String {
        var items = [String]()
        for _ in 0..<itemCount {
            var text = generateRichText(wordCount: Int.random(in: 2...6), includeStyle: true)
            if includeInlineCode, Int.random(in: 0...1) == 1 {
                // 随机插入行内代码
                let inlineCode = "`\(randomWords.randomElement()!)`"
                text = "\(text) \(inlineCode)"
            }
            items.append("- \(text)")
        }
        return items.joined(separator: "\n")
    }

    /// 生成有序列表
    private func generateOrderedList(itemCount: Int) -> String {
        var items = [String]()
        for i in 1...itemCount {
            let text = generateRichText(wordCount: Int.random(in: 2...6), includeStyle: true)
            items.append("\(i). \(text)")
        }
        return items.joined(separator: "\n")
    }

    /// 生成引用块
    private func generateQuoteBlock(sentenceCount: Int) -> String {
        var lines = [String]()
        for _ in 0..<sentenceCount {
            let text = generateRichText(wordCount: Int.random(in: 4...10), includeStyle: true)
            lines.append("> \(text)")
        }
        return lines.joined(separator: "\n")
    }

    /// 生成图片
    private func generateImage() -> String {
        let altText = generateRichText(wordCount: Int.random(in: 2...4), includeStyle: false)
        let url = randomImageUrls.randomElement()!
        return "![\(altText)](\(url))"
    }

    /// 生成链接（行内/参考式）
    private func generateLink() -> String {
        let linkText = generateRichText(wordCount: Int.random(in: 1...3), includeStyle: false)
        let url = "https://example.com/\(randomWords.randomElement()!.lowercased())"

        // 随机选择行内链接或参考式链接
        if Int.random(in: 0...1) == 0 {
            // 行内链接
            return "[\(linkText)](\(url))"
        } else {
            // 参考式链接
            let refId = UUID().uuidString.prefix(8)
            return "[\(linkText)][\(refId)]\n\n[\(refId)]: \(url)"
        }
    }

    /// 生成多语言代码块
    private func generateCodeBlock() -> String {
        let language = codeSnippets.keys.randomElement()!
        let code = codeSnippets[language]!
        return "```\(language)\n\(code)\n```"
    }

    /// 生成表格
    private func generateTable(rowCount: Int) -> String {
        let headers = tableHeaders.randomElement()!
        var tableLines = [headers.joined(separator: "|")]
        // 表格分隔线
        tableLines.append(headers.map { _ in "---" }.joined(separator: "|"))
        // 表格内容行
        for _ in 0..<rowCount {
            let row = headers.map { _ in generateRichText(wordCount: Int.random(in: 1...2), includeStyle: false) }
            tableLines.append(row.joined(separator: "|"))
        }
        return tableLines.joined(separator: "\n")
    }

    // MARK: - 基础工具方法
    private func generateRandomWord() -> String {
        randomWords.randomElement()!
    }
}
