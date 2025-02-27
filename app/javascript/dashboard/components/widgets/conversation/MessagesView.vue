<template>
  <div class="flex flex-col justify-between flex-grow h-full min-w-0 m-0">
    <banner
      v-if="!currentChat.can_reply"
      color-scheme="alert"
      :banner-message="replyWindowBannerMessage"
      :href-link="replyWindowLink"
      :href-link-text="replyWindowLinkText"
    />

    <div class="flex justify-end">
      <woot-button
        variant="smooth"
        size="tiny"
        color-scheme="secondary"
        class="rounded-bl-calc rtl:rotate-180 rounded-tl-calc fixed top-[9.5rem] md:top-[6.25rem] z-10 bg-white dark:bg-slate-700 border-slate-50 dark:border-slate-600 border-solid border border-r-0 box-border"
        :icon="isRightOrLeftIcon"
        @click="onToggleContactPanel"
      />
    </div>
    <ul class="conversation-panel">
      <transition name="slide-up">
        <li class="min-h-[4rem]">
          <span v-if="shouldShowSpinner" class="spinner message" />
        </li>
      </transition>
      <messages-previous-view
        v-if="contact"
        :is-loading="isLoadingPrevious"
        :contact-id="contact.id"
        :current-conversation-id="currentChat.id"
        @loading-status="isLoadingPrevious = $event"
      />
      <woot-division-line color-schema="bg-woot-300" height="20px">
        <span
          class="text-xs text-white bold space-x-1 mr-2 px-5 font-bold w-full text-end"
        >
          {{
            $t('CONVERSATION.PREVIOUS_CONVERSATIONS.DIVIDER_TITLE', {
              conversationId: currentChat.id,
            })
          }}
        </span>
      </woot-division-line>
      <message
        v-for="message in getReadMessages"
        :key="message.id"
        class="message--read ph-no-capture"
        data-clarity-mask="True"
        :data="message"
        :is-a-tweet="isATweet"
        :is-a-whatsapp-channel="isAWhatsAppChannel"
        :is-web-widget-inbox="isAWebWidgetInbox"
        :channel-type="inbox.channel_type"
        :inbox-supports-reply-to="inboxSupportsReplyTo"
        :in-reply-to="getInReplyToMessage(message)"
      />
      <li v-show="unreadMessageCount != 0" class="unread--toast">
        <span>
          {{ unreadMessageCount > 9 ? '9+' : unreadMessageCount }}
          {{
            unreadMessageCount > 1
              ? $t('CONVERSATION.UNREAD_MESSAGES')
              : $t('CONVERSATION.UNREAD_MESSAGE')
          }}
        </span>
      </li>
      <message
        v-for="message in getUnReadMessages"
        :key="message.id"
        class="message--unread ph-no-capture"
        data-clarity-mask="True"
        :data="message"
        :is-a-tweet="isATweet"
        :is-a-whatsapp-channel="isAWhatsAppChannel"
        :is-web-widget-inbox="isAWebWidgetInbox"
        :channel-type="inbox.channel_type"
        :inbox-supports-reply-to="inboxSupportsReplyTo"
        :in-reply-to="getInReplyToMessage(message)"
      />
      <conversation-label-suggestion
        v-if="shouldShowLabelSuggestions"
        :suggested-labels="labelSuggestions"
        :chat-labels="currentChat.labels"
        :conversation-id="currentChat.id"
      />
    </ul>
    <div
      class="conversation-footer"
      :class="{ 'modal-mask': isPopoutReplyBox }"
    >
      <div v-if="isAnyoneTyping" class="typing-indicator-wrap">
        <div class="typing-indicator">
          {{ typingUserNames }}
          <img
            class="gif"
            src="~dashboard/assets/images/typing.gif"
            alt="Someone is typing"
          />
        </div>
      </div>
      <reply-box
        :conversation-id="currentChat.id"
        :popout-reply-box.sync="isPopoutReplyBox"
        :is-assigned-to-current-user="isAssignedToCurrentUser" 
        @click="showPopoutReplyBox"
        @before-send="validateAssignmentBeforeSend"
      />
    </div>
  </div>
</template>

<script>
// components
import ReplyBox from './ReplyBox.vue';
import Message from './Message.vue';
import ConversationLabelSuggestion from './conversation/LabelSuggestion.vue';
import Banner from 'dashboard/components/ui/Banner.vue';
import MessagesPreviousView from './MessagesPreviousView.vue';

// stores and apis
import { mapGetters } from 'vuex';

// mixins
import conversationMixin, {
  filterDuplicateSourceMessages,
} from '../../../mixins/conversations';
import inboxMixin, { INBOX_FEATURES } from 'shared/mixins/inboxMixin';
import configMixin from 'shared/mixins/configMixin';
import eventListenerMixins from 'shared/mixins/eventListenerMixins';
import aiMixin from 'dashboard/mixins/aiMixin';
import alertMixin from 'shared/mixins/alertMixin';

// utils
import { getTypingUsersText } from '../../../helper/commons';
import { calculateScrollTop } from './helpers/scrollTopCalculationHelper';
import { isEscape } from 'shared/helpers/KeyboardHelpers';
import { LocalStorage } from 'shared/helpers/localStorage';

// constants
import { BUS_EVENTS } from 'shared/constants/busEvents';
import { REPLY_POLICY } from 'shared/constants/links';
import wootConstants from 'dashboard/constants/globals';
import { LOCAL_STORAGE_KEYS } from 'dashboard/constants/localStorage';

export default {
  components: {
    Message,
    ReplyBox,
    Banner,
    ConversationLabelSuggestion,
    MessagesPreviousView,
  },
  mixins: [
    conversationMixin,
    inboxMixin,
    eventListenerMixins,
    configMixin,
    aiMixin,
    alertMixin,
  ],
  props: {
    isContactPanelOpen: {
      type: Boolean,
      default: false,
    },
    isAssignedToCurrentUser: { // Nova prop recebida do ConversationBox
      type: Boolean,
      default: true,
    },
  },

  data() {
    return {
      isLoadingPrevious: true,
      heightBeforeLoad: null,
      conversationPanel: null,
      hasUserScrolled: false,
      isProgrammaticScroll: false,
      isPopoutReplyBox: false,
      messageSentSinceOpened: false,
      labelSuggestions: [],
    };
  },

  computed: {
    ...mapGetters({
      accountId: 'getCurrentAccountId',
      currentChat: 'getSelectedChat',
      allConversations: 'getAllConversations',
      inboxesList: 'inboxes/getInboxes',
      listLoadingStatus: 'getAllMessagesLoaded',
      loadingChatList: 'getChatListLoadingStatus',
      appIntegrations: 'integrations/getAppIntegrations',
      isFeatureEnabledonAccount: 'accounts/isFeatureEnabledonAccount',
      currentAccountId: 'getCurrentAccountId',
      currentUser: 'getCurrentUser',
    }),
    contact() {
      return this.$store.getters['contacts/getContact'](this.contactId);
    },
    contactId() {
      return this.currentChat.meta?.sender?.id;
    },
    isOpen() {
      return this.currentChat?.status === wootConstants.STATUS_TYPE.OPEN;
    },
    shouldShowLabelSuggestions() {
      return (
        this.isOpen &&
        this.isEnterprise &&
        this.isAIIntegrationEnabled &&
        !this.messageSentSinceOpened
      );
    },
    inboxId() {
      return this.currentChat.inbox_id;
    },
    inbox() {
      return this.$store.getters['inboxes/getInbox'](this.inboxId);
    },
    typingUsersList() {
      const userList = this.$store.getters[
        'conversationTypingStatus/getUserList'
      ](this.currentChat.id);
      return userList;
    },
    isAnyoneTyping() {
      const userList = this.typingUsersList;
      return userList.length !== 0;
    },
    typingUserNames() {
      const userList = this.typingUsersList;
      if (this.isAnyoneTyping) {
        return getTypingUsersText(userList);
      }
      return '';
    },
    getMessages() {
      const messages = this.currentChat.messages || [];
      if (this.isAWhatsAppChannel) {
        return filterDuplicateSourceMessages(messages);
      }
      return messages;
    },
    getReadMessages() {
      return this.readMessages(this.getMessages, this.currentChat.agent_last_seen_at);
    },
    getUnReadMessages() {
      return this.unReadMessages(this.getMessages, this.currentChat.agent_last_seen_at);
    },
    shouldShowSpinner() {
      return (
        (this.currentChat && this.currentChat.dataFetched === undefined) ||
        (!this.listLoadingStatus && this.isLoadingPrevious)
      );
    },
    conversationType() {
      const { additional_attributes: additionalAttributes } = this.currentChat;
      return additionalAttributes ? additionalAttributes.type : '';
    },
    isATweet() {
      return this.conversationType === 'tweet';
    },
    isRightOrLeftIcon() {
      return this.isContactPanelOpen ? 'arrow-chevron-right' : 'arrow-chevron-left';
    },
    getLastSeenAt() {
      return this.currentChat.contact_last_seen_at;
    },
    replyWindowBannerMessage() {
      if (this.isAWhatsAppChannel) {
        return this.$t('CONVERSATION.TWILIO_WHATSAPP_CAN_REPLY');
      }
      if (this.isAPIInbox) {
        const { additional_attributes: additionalAttributes = {} } = this.inbox;
        return additionalAttributes?.agent_reply_time_window_message || '';
      }
      return this.$t('CONVERSATION.CANNOT_REPLY');
    },
    replyWindowLink() {
      if (this.isAWhatsAppChannel) {
        return REPLY_POLICY.FACEBOOK;
      }
      if (!this.isAPIInbox) {
        return REPLY_POLICY.TWILIO_WHATSAPP;
      }
      return '';
    },
    replyWindowLinkText() {
      if (this.isAWhatsAppChannel) {
        return this.$t('CONVERSATION.24_HOURS_WINDOW');
      }
      if (!this.isAPIInbox) {
        return this.$t('CONVERSATION.TWILIO_WHATSAPP_24_HOURS_WINDOW');
      }
      return '';
    },
    unreadMessageCount() {
      return this.currentChat.unread_count || 0;
    },
    inboxSupportsReplyTo() {
      const incoming = this.inboxHasFeature(INBOX_FEATURES.REPLY_TO);
      const outgoing =
        this.inboxHasFeature(INBOX_FEATURES.REPLY_TO_OUTGOING) &&
        !this.is360DialogWhatsAppChannel;
      return { incoming, outgoing };
    },
  },

  watch: {
    currentChat(newChat, oldChat) {
      if (newChat.id === oldChat.id) {
        return;
      }
      this.fetchAllAttachmentsFromCurrentChat();
      this.fetchSuggestions();
      this.messageSentSinceOpened = false;
    },
  },

  created() {
    bus.$on(BUS_EVENTS.SCROLL_TO_MESSAGE, this.onScrollToMessage);
    bus.$on(BUS_EVENTS.FETCH_LABEL_SUGGESTIONS, this.fetchSuggestions);
    bus.$on(BUS_EVENTS.MESSAGE_SENT, () => {
      this.messageSentSinceOpened = true;
    });
  },

  mounted() {
    this.addScrollListener();
    this.fetchAllAttachmentsFromCurrentChat();
    this.fetchSuggestions();
  },

  beforeDestroy() {
    this.removeBusListeners();
    this.removeScrollListener();
  },

  methods: {
    async fetchSuggestions() {
      this.labelSuggestions = [];
      if (this.isLabelSuggestionDismissed()) return;
      if (!this.isEnterprise) return;
      await this.fetchIntegrationsIfRequired();
      if (!this.isLabelSuggestionFeatureEnabled) return;
      this.labelSuggestions = await this.fetchLabelSuggestions({
        conversationId: this.currentChat.id,
      });
      this.$nextTick(() => {
        const { messageId } = this.$route.query;
        if (!messageId && !this.hasUserScrolled) {
          this.scrollToBottom();
        }
      });
    },
    isLabelSuggestionDismissed() {
      return LocalStorage.getFlag(
        LOCAL_STORAGE_KEYS.DISMISSED_LABEL_SUGGESTIONS,
        this.currentAccountId,
        this.currentChat.id
      );
    },
    fetchAllAttachmentsFromCurrentChat() {
      this.$store.dispatch('fetchAllAttachments', this.currentChat.id);
    },
    removeBusListeners() {
      bus.$off(BUS_EVENTS.SCROLL_TO_MESSAGE, this.onScrollToMessage);
    },
    onScrollToMessage({ messageId = '' } = {}) {
      this.$nextTick(() => {
        const messageElement = document.getElementById('message' + messageId);
        if (messageElement) {
          this.isProgrammaticScroll = true;
          messageElement.scrollIntoView({ behavior: 'smooth' });
          this.fetchPreviousMessages();
        } else {
          this.scrollToBottom();
        }
      });
      this.makeMessagesRead();
    },
    showPopoutReplyBox() {
      this.isPopoutReplyBox = !this.isPopoutReplyBox;
    },
    closePopoutReplyBox() {
      this.isPopoutReplyBox = false;
    },
    handleKeyEvents(e) {
      if (isEscape(e)) {
        this.closePopoutReplyBox();
      }
    },
    addScrollListener() {
      this.conversationPanel = this.$el.querySelector('.conversation-panel');
      this.setScrollParams();
      this.conversationPanel.addEventListener('scroll', this.handleScroll);
      this.$nextTick(() => this.scrollToBottom());
      this.isLoadingPrevious = false;
    },
    removeScrollListener() {
      this.conversationPanel.removeEventListener('scroll', this.handleScroll);
    },
    scrollToBottom() {
      this.isProgrammaticScroll = true;
      let relevantMessages = [];
      let labelSuggestions = this.conversationPanel.querySelector('.label-suggestion');
      if (this.unreadMessageCount > 0) {
        relevantMessages = this.conversationPanel.querySelectorAll('.message--unread');
      } else if (labelSuggestions) {
        relevantMessages = [labelSuggestions];
      } else {
        relevantMessages = Array.from(
          this.conversationPanel.querySelectorAll('.message--read')
        ).slice(-1);
      }
      this.conversationPanel.scrollTop = calculateScrollTop(
        this.conversationPanel.scrollHeight,
        this.$el.scrollHeight,
        relevantMessages
      );
    },
    onToggleContactPanel() {
      this.$emit('contact-panel-toggle');
    },
    setScrollParams() {
      this.heightBeforeLoad = this.conversationPanel.scrollHeight;
      this.scrollTopBeforeLoad = this.conversationPanel.scrollTop;
    },
    async fetchPreviousMessages(scrollTop = 0) {
      this.setScrollParams();
      const shouldLoadMoreMessages =
        this.currentChat.dataFetched === true &&
        !this.listLoadingStatus &&
        !this.isLoadingPrevious;
      if (scrollTop < 100 && !this.isLoadingPrevious && shouldLoadMoreMessages) {
        this.isLoadingPrevious = true;
        try {
          await this.$store.dispatch('fetchPreviousMessages', {
            conversationId: this.currentChat.id,
            before: this.currentChat.messages[0].id,
          });
          const heightDifference =
            this.conversationPanel.scrollHeight - this.heightBeforeLoad;
          this.conversationPanel.scrollTop =
            this.scrollTopBeforeLoad + heightDifference;
          this.setScrollParams();
        } catch (error) {
          // Ignore Error
        } finally {
          this.isLoadingPrevious = false;
        }
      }
    },
    handleScroll(e) {
      if (this.isProgrammaticScroll) {
        this.isProgrammaticScroll = false;
        this.hasUserScrolled = false;
      } else {
        this.hasUserScrolled = true;
      }
      bus.$emit(BUS_EVENTS.ON_MESSAGE_LIST_SCROLL);
      this.fetchPreviousMessages(e.target.scrollTop);
    },
    makeMessagesRead() {
      this.$store.dispatch('markMessagesRead', { id: this.currentChat.id });
    },
    getInReplyToMessage(parentMessage) {
      if (!parentMessage) return {};
      const inReplyToMessageId = parentMessage.content_attributes?.in_reply_to;
      if (!inReplyToMessageId) return {};
      return this.currentChat?.messages.find(message => message.id === inReplyToMessageId) || {};
    },
    validateAssignmentBeforeSend(messageData) {
      if (!this.isAssignedToCurrentUser) {
        this.showAlert(
          this.$t('CONVERSATION.NOT_ASSIGNED_TO_YOU', {
            conversationId: this.currentChat.id,
          })
        );
        return false;
      }
      return true;
    },
  },
};
</script>

<style scoped>
@tailwind components;
@layer components {
  .rounded-bl-calc {
    border-bottom-left-radius: calc(1.5rem + 1px);
  }
  .rounded-tl-calc {
    border-top-left-radius: calc(1.5rem + 1px);
  }
}
</style>

<style scoped lang="scss">
.modal-mask {
  &::v-deep {
    .ProseMirror-woot-style {
      @apply max-h-[25rem];
    }
    .reply-box {
      @apply border border-solid border-slate-75 dark:border-slate-600 max-w-[75rem] w-[70%];
    }
    .reply-box__top {
      @apply relative min-h-[27.5rem];
    }
    .reply-box__top .input {
      @apply min-h-[27.5rem];
    }
    .emoji-dialog {
      @apply absolute left-auto bottom-1;
    }
  }
}
</style>