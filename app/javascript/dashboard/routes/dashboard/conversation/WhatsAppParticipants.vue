<template>
  <div class="relative bg-white dark:bg-slate-900">
    <hr class="h-px my-8 bg-black-200 border-1 dark:bg-black-700" />
    <div class="flex flex-col items-center justify-between mb-1">
      <p class="text-sm text-slate-600 dark:text-slate-300">Participantes</p>
      <span class="text-sm text-slate-600 dark:text-slate-300">
        não tem participantes
      </span>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';

export default {
  name: 'WhatsAppParticipants',
  data() {
    return {
      selectedWatchers: [],
      whatsappAgents: [],
      showDropDown: false,
    };
  },
  computed: {
    ...mapGetters({
      participantsWhatsApp: 'conversationWatchers/getWhatsAppParticipants',
      uiFlags: 'conversationWatchers/getUIFlags',
    }),
  },
  mounted() {
    this.fetchWhatsAppParticipants();
  },
  methods: {
    fetchWhatsAppParticipants() {
      const conversationId = this.conversationId;
      this.$store.dispatch('conversationWatchers/getParticipantsWhatsApp', {
        conversationId,
      });
    },
  },
};
</script>
