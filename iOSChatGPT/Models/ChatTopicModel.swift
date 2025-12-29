//
//  ChatTopicModel.swift
//  iOSChatGPT
//
//  Created by 郝学智 on 2025/12/26.
//

import Combine
import Foundation
import SwiftUI

// MARK: - Model

struct AIChat: Codable {
    let datetime: String
    var issue: String
    var answer: String?
    var isResponse: Bool = false
    var model: String
    var userAvatarUrl: String
    // var botAvatarUrl: String = "https://chat.openai.com/apple-touch-icon.png"
}

enum ChatMessageRole {
    case user
    case ai
    case system
}

struct ChatMessage: Identifiable, Equatable {
    let role: ChatMessageRole
    var message: String
    let id: String

    mutating func appendMsg(msg: String) {
        self.message += msg
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id && lhs.message == rhs.message
    }

}

@MainActor
class ChatTopicModel: ObservableObject {
    @Published var topicName = "新对话"
    @Published var contents: [ChatMessage] = []

    @Published var inputText: String = ""
    
    /// 是否滚动到底部
    @Published var isScrollListBottom: Bool = true
    /// 使用流式输出
    @Published var isStreamOutput: Bool = true

    /// 发送请求并处理流式AI回复
    func request(inputText: String) async {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        // 1. 添加用户消息
        let userMsg = ChatMessage(
            role: .user,
            message: trimmedText,
            id: UUID().uuidString
        )
        await MainActor.run {
            self.contents.append(userMsg)
        }

        // 2. 创建空的AI消息（用于流式更新）
        let aiMsgId = UUID().uuidString
        var aiMsg = ChatMessage(role: .ai, message: "", id: aiMsgId)
        await MainActor.run {
            self.contents.append(aiMsg)
        }

        let markdownGenerator = StreamMarkdownGenerator()
        // 3. 方式1：按片段流式更新（推荐，更清晰）
        let markdownStream = markdownGenerator.generateFullMarkdownStream()
//        var fullAIMessage = ""
        for await segment in markdownStream {
//            fullAIMessage += segment
            // 主线程更新AI消息内容
            await MainActor.run {
                aiMsg .appendMsg(msg: segment)
                if let index = self.contents.firstIndex(where: { $0.id == aiMsgId }) {
                    self.contents[index] = aiMsg

                }
            }
        }

        // 方式2：逐字符流式更新（注释掉方式1，打开这里即可切换）
        /*
        let charStream = markdownGenerator.generateCharByCharStream()
        for await currentText in charStream {
            await MainActor.run {
                if let index = self.contents.firstIndex(where: { $0.id == aiMsgId }) {
                    self.contents[index].message = currentText
                }
            }
        }
        */
    }
}
