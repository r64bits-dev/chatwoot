<template>
  <div class="mt-4 mb-10">
    <div class="flex justify-center w-full my-4">
      <woot-button
        v-if="hasMoreMessages"
        size="tiny"
        icon="arrow-up"
        @click="loadNextConversation"
      >
        carregar mais mensagens
      </woot-button>
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
        <div class="flex w-full justify-end text-white">
          <span class="px-2 text-xs bold space-x-1 ml-2 font-bold">
            Protocolo Id: {{ conversation.conversation_id }}
          </span>
        </div>
      </woot-division-line>

      <div
        v-for="message in orderedMessages(conversation.messages)"
        :key="message.id"
      >
        <message :data="message" />
      </div>
    </div>
  </div>
</template>

<script>
import Message from './Message.vue';
import ContactAPI from '../../../api/contacts';

export default {
  name: 'MessagesPreviousView',
  components: {
    Message,
  },
  props: {
    contactId: {
      type: Number,
      required: true,
    },
    currentConversationId: {
      type: Number,
      required: true,
    },
  },
  data() {
    return {
      conversations: [],
      currentConversationIndex: 0,
      hasMoreMessages: true,
    };
  },
  computed: {
    groupedConversations() {
      return this.conversations
        .filter(conversation => conversation.messages.length > 0)
        .sort((a, b) => b.conversation_id - a.conversation_id)
        .slice()
        .reverse();
    },
  },
  created() {
    this.loadConversations();
  },
  methods: {
    async loadConversations() {
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
    },

    async loadNextConversation() {
      const conversation = this.conversations[this.currentConversationIndex];
      if (!conversation || conversation.page === null) {
        this.hasMoreMessages = false;
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

        // Ordena as mensagens por created_at em ordem crescente (mais antigas primeiro)
        conversation.messages = [...messages, ...conversation.messages].sort(
          (a, b) => a.created_at - b.created_at
        );

        if (response.pagination && response.pagination.next_page) {
          conversation.page = response.pagination.next_page;
        } else {
          conversation.page = null;
          this.currentConversationIndex += 1;
        }
      } catch (error) {
        this.hasMoreMessages = false;
      }
    },

    // Método para ordenar as mensagens de cada conversa por created_at de forma crescente
    orderedMessages(messages) {
      return [...messages].sort((a, b) => a.created_at - b.created_at);
    },
  },
};
</script>

<style></style>
