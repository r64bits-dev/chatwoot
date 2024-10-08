<template>
  <div v-on-clickaway="clickaway" class="relative">
    <woot-button
      class="button"
      :aria-expanded="isOpen"
      :icon="isOpen ? 'chevron-up' : 'chevron-down'"
      @click="toggleDropdown"
    />
    <div
      v-if="isOpen"
      class="absolute right-0 mt-1 py-2 w-48 bg-white dark:bg-slate-800 border border-black-300 dark:border-slate-700 rounded-md shadow-lg"
    >
      <woot-button
        class="clear px-4 py-2 w-full text-black dark:text-slate-100"
        icon="edit"
        @click="toggleEditMode"
      >
        {{ $t('TICKETS.ACTIONS.EDIT') }}
      </woot-button>
      <woot-button
        v-if="!ticket.assigned_to"
        class="clear px-4 py-2 w-full text-black dark:text-slate-100"
        icon="person"
        @click="assignToMe"
      >
        {{ $t('TICKETS.ASSIGNEE.ASSIGNEE_TO_ME') }}
      </woot-button>
      <woot-button
        class="clear px-4 py-2 w-full text-black dark:text-slate-100"
        icon="checkmark-circle"
        @click="resolveTicket"
      >
        {{ $t('TICKETS.RESOLVE') }}
      </woot-button>
      <woot-button
        v-if="isAdmin"
        class="clear px-4 py-2 w-full text-red-600 dark:text-red-400"
        color-scheme="alert"
        icon="delete"
        @click="deleteTicket"
      >
        {{ $t('TICKETS.ACTIONS.DELETE') }}
      </woot-button>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import { mixin as clickaway } from 'vue-clickaway';
import isAdmin from 'dashboard/mixins/isAdmin';
import alertMixin from 'shared/mixins/alertMixin';

export default {
  name: 'MoreActionsDropdown',
  mixins: [clickaway, isAdmin, alertMixin],
  props: {
    ticket: {
      type: Object,
      required: true,
    },
    isEditing: {
      type: Boolean,
      required: true,
    },
  },
  data: () => ({
    isOpen: false,
  }),
  computed: {
    ...mapGetters({
      currentUserId: 'getCurrentUserID',
    }),
  },
  destroyed() {
    this.isOpen = false;
  },
  methods: {
    toggleDropdown() {
      this.isOpen = !this.isOpen;
    },
    toggleEditMode() {
      this.$emit('toggle-edit-mode');
      this.toggleDropdown();
    },
    assignToMe(e) {
      e.preventDefault();
      this.$store
        .dispatch('tickets/assign', {
          ticketId: this.ticket.id,
          assigneeId: this.currentUserId,
        })
        .catch(error => {
          this.showAlert(error);
        });
      this.$store.dispatch('tickets/getAllTickets');
    },
    deleteTicket() {
      this.$store.dispatch('tickets/delete', this.ticket.id).catch(error => {
        this.showAlert(error);
      });
      this.$store.dispatch('tickets/getAllTickets');
      this.toggleDropdown();
    },
    resolveTicket() {
      this.$store.dispatch('tickets/resolve', this.ticket.id).catch(error => {
        this.showAlert(error);
      });
      this.$store.dispatch('tickets/getAllTickets');
      this.toggleDropdown();
    },
    clickaway() {
      this.isOpen = false;
    },
  },
};
</script>
