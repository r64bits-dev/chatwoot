<template>
  <div class="relative bg-white dark:bg-slate-900 pt-4 px-1">
    <div class="flex flex-col justify-between mb-4">
      <p class="text-sm dark:text-slate-300">Participantes</p>
      <spinner v-if="uiFlags.isFetching" size="small" />
      <div
        v-if="participantsWhatsApp.length"
        class="flex flex-col items-start w-full"
      >
        <div
          v-for="participant in participantsWhatsApp"
          :key="participant.id"
          class="flex mb-4"
        >
          <thumbnail
            :src="participant.thumbnail"
            :username="participant.name"
            :title="participant.name"
            :size="'40px'"
            :has-border="true"
            class="mr-4"
          />
          <div>
            <p class="text-sm text-slate-600 dark:text-slate-300">
              {{ participant.name }}
            </p>
            <p class="text-xs text-slate-400 dark:text-slate-500">
              {{ participant.phone }}
            </p>
          </div>
        </div>
      </div>
      <span v-else class="text-sm text-slate-400 dark:text-slate-300">
        Não há participantes.
      </span>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import Spinner from 'shared/components/Spinner';
import Thumbnail from 'dashboard/components/widgets/Thumbnail';

export default {
  name: 'WhatsAppParticipants',
  components: {
    Spinner,
    Thumbnail,
  },
  props: {
    conversationId: {
      type: [Number, String],
      required: true,
    },
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
      this.$store.dispatch('conversationWatchers/getParticipantsWhatsApp', {
        conversationId: this.conversationId,
      });
    },
  },
};
</script>

<style scoped></style>
