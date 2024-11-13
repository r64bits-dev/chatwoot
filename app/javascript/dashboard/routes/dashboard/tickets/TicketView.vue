<template>
  <section class="ticket-page bg-white dark:bg-slate-900 flex flex-col">
    <ticket-export-button />
    <ticket-content />
  </section>
</template>
<script>
import TicketContent from './TicketContent.vue';
import TicketExportButton from './components/TicketExportButton.vue';

export default {
  name: 'TicketView',
  components: {
    TicketContent,
    TicketExportButton,
  },
};
</script>

<style lang="scss" scoped>
.ticket-page {
  display: flex;
  width: 100%;
  height: 100%;
}
</style>
