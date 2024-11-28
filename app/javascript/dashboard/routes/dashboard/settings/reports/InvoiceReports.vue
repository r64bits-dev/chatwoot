<template>
  <div class="flex-1 overflow-auto p-4">
    <report-filters
      type="invoices"
      @date-range-change="onDateRangeChange"
      @business-hours-toggle="onBusinessHoursToggle"
    />

    <!-- Seção de métricas -->
    <div class="row">
      <metric-card
        :is-live="false"
        :is-loading="false"
        :header="$t('INVOICE_REPORTS.SUBTITLE')"
        :loading-message="$t('REPORT.LOADING_CHART')"
      >
        <template v-if="!uiFlags.isFetching">
          <div
            v-for="(metric, name, index) in conversationMetrics"
            :key="index"
            class="metric-content column"
          >
            <h3 class="heading">{{ name }}</h3>
            <p class="metric">{{ metric }}</p>
          </div>
        </template>
        <template v-else>
          <div class="flex items-center justify-center w-full">
            <span class="text-sm text-slate-600">
              {{ $t('REPORT.NO_ENOUGH_DATA') }}
            </span>
          </div>
        </template>
      </metric-card>
    </div>

    <!-- Componente de gráfico de invoices -->
    <div class="row">
      <template v-if="!uiFlags.isFetching && !uiFlags.isFetchingUsage">
        <div class="w-full flex flex-col md:flex-row">
          <div class="w-full md:w-1/2 flex flex-col p-1">
            <graph-invoices
              :invoices-data="invoices"
              :is-loading="uiFlags.isFetching"
            />
          </div>
          <div class="w-full md:w-1/2 flex flex-col p-1">
            <graph-usage
              :messages-send="messagesSend"
              :messages-receive="messagesReceive"
              :data="invoicesUsage"
              :is-loading="uiFlags.isFetchingUsage"
            />
          </div>
        </div>
      </template>
      <template v-else>
        <div class="flex items-center justify-center w-full">
          <span class="text-sm text-slate-600">
            {{ $t('REPORT.LOADING_CHART') }}
          </span>
          <woot-loading-state
            v-if="uiFlags.isFetching || uiFlags.isFetchingUsage"
            class="text-xs"
            :message="$t('REPORT.LOADING_CHART')"
          />
        </div>
      </template>
    </div>
  </div>
</template>

<script>
import MetricCard from './components/overview/MetricCard.vue';
import ReportFilters from './components/ReportFilters.vue';
import { mapGetters } from 'vuex';
import { INVOICE_SUMMARY_METRICS } from './constants';
import GraphInvoices from './components/invoices/GraphInvoices.vue';
import GraphUsage from './components/Graph/GraphUsage.vue';

const COLUMNS_TO_FORMAT = ['total', 'average_invoice_price'];

export default {
  name: 'InvoiceReports',
  components: {
    MetricCard,
    ReportFilters,
    GraphInvoices,
    GraphUsage,
  },
  data: () => ({
    from: null,
    to: null,
  }),
  computed: {
    ...mapGetters({
      invoices: 'invoices/getInvoices',
      invoicesUsage: 'invoices/getUsageMessages',
      messagesSend: 'invoices/getUsageSentMessages',
      messagesReceive: 'invoices/getUsageReceivedMessages',
      summary: 'invoices/getSummary',
      uiFlags: 'invoices/getUIFlags',
    }),
    conversationMetrics() {
      let metric = {};
      Object.keys(this.summary || {}).forEach(key => {
        const metricName = this.$t(
          'INVOICE_REPORTS.METRICS.' + INVOICE_SUMMARY_METRICS[key] + '.NAME'
        );
        if (COLUMNS_TO_FORMAT.includes(key)) {
          metric[metricName] = this.formatCurrency(this.summary[key]);
          return;
        }
        metric[metricName] = this.summary[key];
      });
      return metric;
    },
  },
  methods: {
    formatCurrency(value) {
      return new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL',
      }).format(value);
    },
    onBusinessHoursToggle(value) {
      this.businessHours = value;
      this.fetchAllData();
    },
    onDateRangeChange({ from, to }) {
      this.from = from;
      this.to = to;

      this.fetchAllData();
      this.fetchUsageData();
    },
    fetchAllData() {
      const { from, to } = this;
      const payload = { from, to };
      this.$store.dispatch('invoices/get', payload);
    },
    fetchUsageData() {
      const { from, to } = this;
      const payload = { from, to };
      this.$store.dispatch('invoices/getUsage', payload);
    },
  },
};
</script>
