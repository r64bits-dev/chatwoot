<template>
  <woot-button
    class="button--fixed-top"
    variant="smooth"
    icon="download"
    :is-loading="isLoading"
    color-scheme="secondary"
    @click="onExportSubmit"
  >
    {{ $t('EXPORT_CONTACTS.BUTTON_LABEL') }}
  </woot-button>
</template>

<script>
import TicketsAPI from '../../../../api/tickets';
import alertMixin from 'shared/mixins/alertMixin';

export default {
  name: 'TicketExportButton',
  mixins: [alertMixin],
  data() {
    return {
      isLoading: false,
    };
  },
  methods: {
    onExportSubmit() {
      try {
        this.isLoading = true;
        this.showAlert(this.$t('EXPORT_CONTACTS.SUCCESS_MESSAGE'));
        TicketsAPI.export().then(response => {
          const url = window.URL.createObjectURL(new Blob([response.data]));
          const link = document.createElement('a');
          link.href = url;
          link.setAttribute('download', 'tickets.csv');
          document.body.appendChild(link);
          link.click();
          document.body.removeChild(link);
        });
      } catch (error) {
        this.showAlert(
          error.message || this.$t('EXPORT_CONTACTS.ERROR_MESSAGE')
        );
      } finally {
        this.isLoading = false;
      }
    },
  },
};
</script>
