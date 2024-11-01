<template>
  <div>
    <message
      v-for="message in messages"
      :key="message.id"
      :data="message"
      class="message--read ph-no-capture"
    />
    <div class="flex justify-center w-full">
      <woot-button size="tiny" icon="arrow-up" @click="loadPreviousMessages">
        carregar conversas anteriores
      </woot-button>
    </div>
    <woot-division-line color-schema="bg-woot-300" height="20px" padding="py-2">
      <div class="flex w-full justify-end text-white">
        <fluent-icon size="15" icon="chevron-down" />
        <span class="px-2 text-xs bold space-x-1 ml-2 font-bold">
          Protocolo Id: 12
        </span>
      </div>
    </woot-division-line>
  </div>
</template>

<script>
import Message from './Message.vue';

export default {
  name: 'MessagesPreviousView',
  components: {
    Message,
  },
  data: () => ({
    messages: [],
    pagination: null,
    contactId: 1,
    currentPage: 1,
  }),
  methods: {
    loadPreviousMessages() {
      this.$store.dispatch('contacts/fetchPreviousMessagesConversations', {
        contactId: this.contactId,
        page: this.currentPage,
      });
    },
    hasMoreMessages() {},
  },
};
</script>

<style></style>
