import SwiftUI

/// 浮动消息导航按钮组
/// 提供快速导航功能：顶部/底部、上一条/下一条消息
struct MessageNavigationButtons: View {
    // MARK: - Dependencies
    let chatMessages: [ChatMessage]
    let scrollPosition: Binding<UUID?>
    let isAtBottom: Bool
    let scrollToBottomAction: (() -> Void)?

    // MARK: - State
    @State private var currentMessageIndex: Int?

    // MARK: - Computed Properties
    private var messageCount: Int {
        chatMessages.count
    }

    private var hasMessages: Bool {
        messageCount > 0
    }

    /// 是否显示"回到顶部"按钮
    private var showScrollToTopButton: Bool {
        hasMessages && currentMessageIndex != 0
    }

    /// 是否显示"回到底部"按钮（仅在非底部时显示）
    private var showScrollToBottomButton: Bool {
        hasMessages && !isAtBottom
    }

    /// 是否显示"上一条/下一条"按钮
    /// 仅在非底部时显示
    private var showNavigationButtons: Bool {
        hasMessages && !isAtBottom
    }

    /// 是否可以向上导航（有上一条消息）
    private var canNavigatePrevious: Bool {
        guard let index = currentMessageIndex else { return false }
        return index > 0
    }

    /// 是否可以向下导航（有下一条消息）
    private var canNavigateNext: Bool {
        guard let index = currentMessageIndex else { return messageCount > 0 }
        return index < messageCount - 1
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 8) {
            // 导航按钮组
            if showNavigationButtons {
                previousNextButtons
            }

            // 垂直滚动按钮
            if showScrollToTopButton || showScrollToBottomButton {
                verticalScrollButtons
            }
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.trailing, 16)
        .padding(.bottom, 80) // Increased to avoid overlapping with input button area
    }

    // MARK: - Subviews

    /// 上一条/下一条消息按钮
    private var previousNextButtons: some View {
        HStack(spacing: 8) {
            // 上一条消息
            Button {
                navigateToPrevious()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(canNavigatePrevious ? .primary : .secondary)
                    .frame(width: 32, height: 32)
            }
            .disabled(!canNavigatePrevious)

            // 下一条消息
            Button {
                navigateToNext()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(canNavigateNext ? .primary : .secondary)
                    .frame(width: 32, height: 32)
            }
            .disabled(!canNavigateNext)
        }
    }

    /// 垂直滚动按钮（顶部/底部）
    private var verticalScrollButtons: some View {
        VStack(spacing: 8) {
            // 回到顶部
            if showScrollToTopButton {
                Button {
                    scrollToTop()
                } label: {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 32, height: 32)
                }
                .accessibilityLabel("Scroll to top")
            }

            // 回到底部
            if showScrollToBottomButton {
                Button {
                    scrollToBottom()
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 32, height: 32)
                }
                .accessibilityLabel("Scroll to bottom")
            }
        }
    }

    // MARK: - Actions

    private func navigateToPrevious() {
        guard canNavigatePrevious else { return }
        let newIndex = currentMessageIndex! - 1
        currentMessageIndex = newIndex
        scrollToMessage(at: newIndex)
    }

    private func navigateToNext() {
        guard canNavigateNext else { return }
        let newIndex = (currentMessageIndex ?? -1) + 1
        currentMessageIndex = newIndex
        scrollToMessage(at: newIndex)
    }

    private func scrollToTop() {
        guard hasMessages else { return }
        currentMessageIndex = 0
        scrollToMessage(at: 0)
    }

    private func scrollToBottom() {
        guard hasMessages else { return }
        if let lastIndex = chatMessages.indices.last {
            currentMessageIndex = lastIndex
            scrollToMessage(at: lastIndex)
        }
    }

    private func scrollToMessage(at index: Int) {
        guard index >= 0 && index < messageCount else { return }
        let messageId = chatMessages[index].id

        if #available(iOS 17.0, *) {
            scrollPosition.wrappedValue = messageId
        } else {
            // iOS 16 fallback: 需要通过 ScrollViewProxy
            // 这个功能需要在 SessionDetailView 中提供额外的支持
            scrollToBottomAction?()
        }
    }
}
