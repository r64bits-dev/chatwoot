<template>
  <metric-card
    :header="$t('INVOICE_REPORTS.USAGE_GRAPH.TITLE')"
    :is-live="false"
  >
    <div class="metric-content column">
      <div
        v-if="!uiFlags.isFetchingUsage"
        class="flex items-center justify-center w-full"
      >
        <woot-line-chart
          v-if="chartData.datasets.length"
          :collection="chartData"
          class="w-full"
        />
        <span v-else class="text-sm text-slate-600">
          {{ $t('REPORT.NO_ENOUGH_DATA') }}
        </span>
      </div>
      <div v-else class="flex items-center justify-center w-full">
        <span class="text-sm text-slate-600">
          {{ $t('REPORT.LOADING_CHART') }}
        </span>
        <woot-loading-state
          class="text-xs"
          :message="$t('REPORT.LOADING_CHART')"
        />
      </div>
    </div>
  </metric-card>
</template>

<script>
import { mapGetters } from 'vuex';
import { format, utcToZonedTime } from 'date-fns-tz';
import MetricCard from '../overview/MetricCard.vue';

export default {
  name: 'GraphMessageUsage',
  components: {
    MetricCard,
  },
  data: () => ({
    chartData: {
      labels: [],
      datasets: [],
    },
  }),
  computed: {
    ...mapGetters({
      data: 'invoices/getUsageMessages',
      messagesSend: 'invoices/getUsageSentMessages',
      messagesReceive: 'invoices/getUsageReceivedMessages',
      messagesExtraSend: 'invoices/getUsageExtraSentMessages',
      messagesExtraReceive: 'invoices/getUsageExtraReceivedMessages',
      uiFlags: 'invoices/getUIFlags',
    }),
  },
  watch: {
    data: {
      immediate: true,
      handler() {
        this.prepareChartData();
      },
    },
  },
  methods: {
    formatDate(dateString) {
      const timeZone = 'America/Sao_Paulo'; // Fuso horário
      const zonedDate = utcToZonedTime(dateString, timeZone);
      return format(zonedDate, 'dd/MM/yyyy', { timeZone });
    },
    prepareChartData() {
      const datesSet = new Set();

      // Collect dates from all datasets
      this.data.forEach(item => datesSet.add(item.date));
      this.messagesSend.forEach(item => datesSet.add(item.date));
      this.messagesReceive.forEach(item => datesSet.add(item.date));
      this.messagesExtraSend.forEach(item => datesSet.add(item.date));
      this.messagesExtraReceive.forEach(item => datesSet.add(item.date));

      // Convert to array and sort dates
      const datesArray = Array.from(datesSet).sort();
      const labels = datesArray.map(date => this.formatDate(date));

      // Map counts to dates for each dataset
      const values = datesArray.map(date => {
        const item = this.data.find(e => e.date === date);
        return item ? item.count : 0;
      });

      const valuesSend = datesArray.map(date => {
        const item = this.messagesSend.find(e => e.date === date);
        return item ? item.count : 0;
      });

      const valuesReceive = datesArray.map(date => {
        const item = this.messagesReceive.find(e => e.date === date);
        return item ? item.count : 0;
      });

      const valuesExtraSend = datesArray.map(date => {
        const item = this.messagesExtraSend.find(e => e.date === date);
        return item ? item.count : 0;
      });

      const valuesExtraReceive = datesArray.map(date => {
        const item = this.messagesExtraReceive.find(e => e.date === date);
        return item ? item.count : 0;
      });

      this.chartData = {
        labels,
        datasets: [
          {
            label: this.$t('INVOICE_REPORTS.USAGE_GRAPH.MESSAGES_LABEL'),
            data: values,
            borderWidth: 1,
            backgroundColor: 'rgba(75, 192, 192, 0.2)',
          },
          {
            label: this.$t('INVOICE_REPORTS.USAGE_GRAPH.MESSAGES_SENT_LABEL'),
            data: valuesSend,
            borderWidth: 1,
            backgroundColor: 'rgba(255, 204, 0, 0.2)',
          },
          {
            label: this.$t(
              'INVOICE_REPORTS.USAGE_GRAPH.MESSAGES_RECEIVED_LABEL'
            ),
            data: valuesReceive,
            borderWidth: 1,
            backgroundColor: 'rgba(255, 215, 204, 0.2)',
          },
          {
            label: this.$t(
              'INVOICE_REPORTS.USAGE_GRAPH.EXTRA_MESSAGES_SENT_LABEL'
            ),
            data: valuesExtraSend,
            borderWidth: 1,
            backgroundColor: 'rgba(123, 104, 238, 0.2)',
          },
          {
            label: this.$t(
              'INVOICE_REPORTS.USAGE_GRAPH.EXTRA_MESSAGES_RECEIVED_LABEL'
            ),
            data: valuesExtraReceive,
            borderWidth: 1,
            backgroundColor: 'rgba(255, 99, 132, 0.2)',
          },
        ],
      };
    },
  },
};
</script>

<style scoped></style>
