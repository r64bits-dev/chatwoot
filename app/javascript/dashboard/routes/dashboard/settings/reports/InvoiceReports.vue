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
      <template v-if="!uiFlags.isFetching">
        <graph-invoices
          :invoices-data="invoices"
          :is-loading="uiFlags.isFetching"
        />
      </template>
      <template v-else>
        <div class="flex items-center justify-center w-full">
          <span class="text-sm text-slate-600">
            {{ $t('REPORT.LOADING_CHART') }}
          </span>
          <woot-loading-state
            v-if="uiFlags.isFetching"
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

export default {
  name: 'InvoiceReports',
  components: {
    MetricCard,
    ReportFilters,
    GraphInvoices,
  },
  data: () => ({
    from: Math.floor(new Date().setMonth(new Date().getMonth() - 6) / 1000),
    to: Math.floor(Date.now() / 1000),
  }),
  computed: {
    ...mapGetters({
      invoices: 'invoices/getInvoices',
      summary: 'invoices/getSummary',
      uiFlags: 'invoices/getUIFlags',
    }),
    conversationMetrics() {
      let metric = {};
      Object.keys(this.summary || {}).forEach(key => {
        const metricName = this.$t(
          'TICKETS_REPORTS.METRICS.' + INVOICE_SUMMARY_METRICS[key] + '.NAME'
        );
        if (key === 'total') {
          metric[metricName] = this.formatCurrency(this.summary[key]);
          return;
        }
        metric[metricName] = this.summary[key];
      });
      return metric;
    },
  },
  mounted() {
    this.fetchAllData();
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
    },
    fetchAllData() {
      const { from, to } = this;
      const payload = { from, to };
      this.$store.dispatch('invoices/get', payload);
    },
  },
};
</script>
