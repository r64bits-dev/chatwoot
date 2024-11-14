<template>
  <div class="mt-4 mb-10">
    <div
      v-if="conversations.length > 0"
      class="flex justify-center w-full my-4"
    >
      <woot-button
        v-if="hasMoreMessages"
        size="tiny"
        icon="arrow-up"
        :is-loading="isLoading"
        @click="loadNextConversation"
      >
        {{ $t('CONVERSATION.PREVIOUS_CONVERSATIONS.BUTTON') }}
      </woot-button>
      <div v-else>
        <p>Não há mais mensagens anteriores.</p>
      </div>
    </div>
    <div
      v-for="conversation in groupedConversations"
      :key="conversation.conversation_id"
    >
      <woot-division-line
        color-schema="bg-woot-300"
        height="20px"
        padding="py-2"
      >
        <span
          class="text-xs text-white bold space-x-1 mr-2 px-5 font-bold w-full text-end"
        >
          {{
            $t('CONVERSATION.PREVIOUS_CONVERSATIONS.DIVIDER_TITLE', {
              conversationId: conversation.conversation_id,
            })
          }}
        </span>
      </woot-division-line>

      <ul class="conversation-panel">
        <li
          v-for="message in orderedMessages(conversation.messages)"
          :key="message.id"
        >
          <message
            :data="message"
            :class="getClassName(message)"
            disable-reply-button
            :is-a-tweet="isATweet"
            :is-a-whatsapp-channel="isAWhatsAppChannel"
            :is-web-widget-inbox="isAWebWidgetInbox"
            :inbox-supports-reply-to="inboxSupportsReplyTo"
            :in-reply-to="getInReplyToMessage(message)"
          />
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
// stores and apis
import { mapGetters } from 'vuex';
import ContactAPI from '../../../api/contacts';

// compponents
import Message from './Message.vue';

// mixins
import conversationMixin from '../../../mixins/conversations';
import inboxMixin, { INBOX_FEATURES } from 'shared/mixins/inboxMixin';

export default {
  name: 'MessagesPreviousView',
  components: {
    Message,
  },
  mixins: [conversationMixin, inboxMixin],
  props: {
    contactId: {
      type: Number,
      required: true,
    },
    currentConversationId: {
      type: Number,
      required: true,
    },
    isLoading: {
      type: Boolean,
      default: false,
    },
  },
  data: () => ({
    conversations: [],
    currentConversationIndex: 0,
    hasMoreMessages: true,
  }),
  computed: {
    ...mapGetters({
      currentChat: 'getSelectedChat',
      inboxesList: 'inboxes/getInboxes',
    }),
    inboxId() {
      return this.currentChat.inbox_id;
    },
    inbox() {
      return this.$store.getters['inboxes/getInbox'](this.inboxId);
    },
    groupedConversations() {
      return this.conversations
        .filter(conversation => conversation.messages.length > 0)
        .sort((a, b) => b.conversation_id - a.conversation_id)
        .slice()
        .reverse();
    },
    isATweet() {
      return this.conversationType === 'tweet';
    },
    conversationType() {
      const { additional_attributes: additionalAttributes } = this.currentChat;
      const type = additionalAttributes ? additionalAttributes.type : '';
      return type || '';
    },
    inboxSupportsReplyTo() {
      const incoming = this.inboxHasFeature(INBOX_FEATURES.REPLY_TO);
      const outgoing =
        this.inboxHasFeature(INBOX_FEATURES.REPLY_TO_OUTGOING) &&
        !this.is360DialogWhatsAppChannel;

      return { incoming, outgoing };
    },
  },
  created() {
    this.conversations = [];
    this.currentConversationIndex = 0;
    this.hasMoreMessages = true;
    this.loadConversations();
  },
  methods: {
    getInReplyToMessage(parentMessage) {
      if (!parentMessage) return {};
      const inReplyToMessageId = parentMessage.content_attributes?.in_reply_to;
      if (!inReplyToMessageId) return {};

      return this.currentChat?.messages.find(message => {
        if (message.id === inReplyToMessageId) {
          return true;
        }
        return false;
      });
    },
    getClassName(message) {
      // HOTFIX: eu fiz isso porque não tinha como atribuir o estilo da página
      const { message_type: messageType } = message;
      if (messageType === 2) {
        return 'list-none m-auto message--read ph-no-capture';
      }
      return 'w-full message--read ph-no-capture';
    },
    setLoadingStatus(status) {
      this.$store.commit('SET_ALL_MESSAGES_PREVIOUS_LOADED', status);
      this.$emit('loading-status', status);
    },
    async loadConversations() {
      this.setLoadingStatus(true);
      const { data: response } = await ContactAPI.getConversations(
        this.contactId
      );

      this.conversations = response.payload
        .map(conversation => ({
          conversation_id: conversation.id,
          messages: [],
          page: 1,
        }))
        .filter(
          conversation =>
            conversation.conversation_id !== this.currentConversationId
        );
      this.setLoadingStatus(false);
    },

    async loadNextConversation() {
      this.setLoadingStatus(true);
      const conversation = this.conversations[this.currentConversationIndex];
      if (!conversation || conversation.page === null) {
        this.hasMoreMessages = false;
        this.setLoadingStatus(false);
        return;
      }

      try {
        const { data: response } = await ContactAPI.fetchPreviousMessages({
          contactId: this.contactId,
          conversationId: conversation.conversation_id,
          page: conversation.page,
        });

        const messages = Array.isArray(response.payload.messages)
          ? response.payload.messages
          : [];

        conversation.messages = [...messages, ...conversation.messages].sort(
          (a, b) => a.created_at - b.created_at
        );

        if (response.pagination && response.pagination.next_page) {
          conversation.page = response.pagination.next_page;
        } else {
          conversation.page = null;
          this.currentConversationIndex += 1;
        }
        this.setLoadingStatus(false);
      } catch (error) {
        this.setLoadingStatus(false);
        this.hasMoreMessages = false;
      }
    },

    orderedMessages(messages) {
      return [...messages].sort((a, b) => a.created_at - b.created_at);
    },
  },
};
</script>

<style></style>
