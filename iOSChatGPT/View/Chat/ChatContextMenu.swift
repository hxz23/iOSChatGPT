//
//  ChatContextMenu.swift
//  iOSChatGPT
//
//  Created by 郝学智 on 2025/12/26.
//

import Foundation
import SwiftUI

struct ChatContextMenu: View {
    @Binding var searchText: String
    @StateObject var chatModel: ChatTopicModel
    let item: AIChat

    var body: some View {
        VStack {
//            CreateMenuItem(text: "Re-question", imgName: "arrow.up.message") {
//                chatModel.getChatResponse(prompt: item.issue)
//            }
//            CreateMenuItem(text: "Copy Question".localized(), imgName: "doc.on.doc") {
//                item.issue.copyToClipboard()
//            }
//
//            CreateMenuItem(text: "Copy Answer", imgName: "doc.on.doc") {
//                item.answer!.copyToClipboard()
//            }
//            .disabled(item.answer == nil)
//
//            CreateMenuItem(text: "Copy Question and Answer".localized(), imgName: "doc.on.doc.fill") {
//                "\(item.issue)\n-----------\n\(item.answer ?? "")".copyToClipboard()
//            }
//            .disabled(item.answer == nil)
//
//            CreateMenuItem(text: "Copy Question to Inputbox".localized(), imgName: "keyboard.badge.ellipsis") {
//                searchText = searchText + item.issue
//            }
//
//            // remove item
//            let isWait = chatModel.contents.filter({ $0.isResponse == false })
//
//            CreateMenuItem(text: "Delete Question".localized(), imgName: "trash", isDestructive: true) {
//                if let index = chatModel.contents.firstIndex(where: { $0.datetime == item.datetime })
//                {
//                    chatModel.contents.remove(at: index)
//                }
//            }
//
//            CreateMenuItem(text: "Delete All".localized(), imgName: "trash", isDestructive: true) {
//                chatModel.contents.removeAll()
//            }.disabled(isWait.count > 0)
        }
    }

    func CreateMenuItem(text: String, imgName: String, isDestructive: Bool = false, onAction: (() -> Void)?) -> some View {
        if #available(iOS 15.0, *) {
            return Button(role: isDestructive ? .destructive : nil) {
                onAction?()
            } label: {
                Label(text, systemImage: imgName)
            }
        } else {
            return Button {
                onAction?()
            } label: {
                Label(text, systemImage: imgName)
            }
        }
    }
}
