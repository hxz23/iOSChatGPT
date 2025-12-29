//
//  ChatView.swift
//  iOSChatGPT
//
//  Created by 郝学智 on 2025/12/26.
//

import Combine
import SwiftUI
import MarkdownUI

struct ChatView: View {
    @ObservedObject var homeModel = HomeModel()
    @StateObject private var chatModel = ChatTopicModel()

    var body: some View {
        VStack {
            chatNavBar
            chatList
            Spacer()
            ChatInputView(chatModel: chatModel)
                .padding([.leading, .trailing], 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .dismissKeyboardOnTap()
    }

    @ViewBuilder
    var chatNavBar: some View {
        // 导航栏整体布局（HStack 实现左右按钮 + 中间标题）
        HStack(alignment: .center, spacing: 0) {
            // 左侧按钮
            Button(action: {
//                        leftAction?() // 可选事件，不为空时执行
            }) {
                Image(systemName: "text.justify")
                    .foregroundColor(.black)
                    .font(.system(size: 18, weight: .medium))
                    .frame(width: 44, height: 44) // 点击热区优化（符合iOS设计规范）
            }

            Image(systemName: "brain.filled.head.profile").frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 0) {
                Text(chatModel.topicName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                Text("内容由 AI 生成")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer()

            // 右侧按钮
            Button(action: {
//                        rightAction?() // 可选事件，不为空时执行
            }) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.black)
                    .font(.system(size: 18, weight: .medium))
                    .frame(width: 44, height: 44) // 点击热区优化
            }
        }
        .frame(height: 44)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    var chatList: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(chatModel.contents, id: \.id) { item in
                    Section() {
                        VStack(alignment: .leading) {
                            HStack(alignment: .top) {

                                Markdown(item.message)

                            }
                            Divider()
                            HStack(alignment: .top) {

                            }
                            .padding([.top, .bottom], 3)
                        }.contextMenu {
//                            ChatContextMenu(
//                                searchText: $chatModel.inputText,
//                                chatModel: chatModel,
//                                item: item
//                            )
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            // 关键优化1：监听两个核心变化，确保全覆盖吸底场景
            .onChange(of: chatModel.contents) { old, new in
                scrollToBottom(proxy: proxy, chatModel: chatModel)
            }
            .onChange(of: chatModel.isScrollListBottom) { old, new in
                scrollToBottom(proxy: proxy, chatModel: chatModel)
            }
            // 关键优化2：视图首次出现时，也滚动到底部
            .onAppear {
                scrollToBottom(proxy: proxy, chatModel: chatModel)
            }

        }
    }

    // 抽离滚动到底部的通用方法，避免代码重复
    private func scrollToBottom(proxy: ScrollViewProxy, chatModel: ChatTopicModel) {
        guard let lastId = chatModel.contents.last?.id else { return }

        // 保留延迟，修复macOS崩溃，同时确保在主线程执行
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.easeInOut(duration: 0.1)) { // 平滑滚动动画
                // 关键优化3：修正锚点为.bottomTrailing（垂直底部+水平靠右，贴合聊天场景）
                // 若需要纯底部对齐，可使用.anchor(.bottom)
                proxy.scrollTo(lastId, anchor: .bottom)
            }
        }
    }
}

extension View {
    func dismissKeyboardOnTap() -> some View {
        onTapGesture {
            // 核心：向所有响应者发送“收起键盘”指令
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }
}
