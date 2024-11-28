<template>
  <div class="flex-1 overflow-auto p-4">
    <report-filters
      type="invoices"
      @date-range-change="onDateRangeChange"
      @business-hours-toggle="onBusinessHoursToggle"
    />

    <div class="row">
      <div class="w-full sm:w-3/4">
        <!-- Seção de métricas -->
        <div class="row">
          <!-- Seção de métricas -->
          <metric-card
            :is-live="false"
            :is-loading="uiFlags.isFetching"
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
            <div class="w-full">
              <div class="w-full">
                <graph-invoices
                  :invoices-data="invoices"
                  :is-loading="uiFlags.isFetching"
                />
              </div>
              <div class="w-full">
                <graph-message-usage />
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

      <div class="w-full sm:w-1/4">
        <!-- Grávico de uso de conversas -->
        <metric-card
          v-if="usageMetrics"
          :header="$t('INVOICE_REPORTS.USAGE.TITLE')"
          :is-live="false"
          :is-loading="uiFlags.isFetchingUsage"
        >
          <div
            v-for="(metric, name, index) in usageMetrics"
            :key="index"
            class="metric-content w-full"
          >
            <h3 class="heading">{{ name }}</h3>
            <p class="metric">{{ metric }}</p>
          </div>
        </metric-card>
      </div>
    </div>
  </div>
</template>

<script>
import MetricCard from './components/overview/MetricCard.vue';
import ReportFilters from './components/ReportFilters.vue';
import { mapGetters } from 'vuex';
import { INVOICE_SUMMARY_METRICS, INVOICE_USAGE_METRICS } from './constants';
import GraphInvoices from './components/invoices/GraphInvoices.vue';
import GraphMessageUsage from './components/Graph/GraphMessageUsage.vue';

const COLUMNS_TO_FORMAT = ['total', 'average_invoice_price'];

export default {
  name: 'InvoiceReports',
  components: {
    MetricCard,
    ReportFilters,
    GraphInvoices,
    GraphMessageUsage,
  },
  data: () => ({
    from: null,
    to: null,
  }),
  computed: {
    ...mapGetters({
      invoices: 'invoices/getInvoices',
      summary: 'invoices/getSummary',
      summaryUsage: 'invoices/getSummaryUsage',
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
    usageMetrics() {
      const metric = {};
      Object.keys(this.summaryUsage || {}).forEach(key => {
        const metricName = this.$t(
          'INVOICE_REPORTS.USAGE.' + INVOICE_USAGE_METRICS[key]
        );
        metric[metricName] = this.summaryUsage[key];
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
