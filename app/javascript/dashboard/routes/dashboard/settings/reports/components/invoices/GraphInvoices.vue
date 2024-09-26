<template>
  <metric-card :header="$t('INVOICE_REPORTS.GRAPH_TITLE')">
    <div class="metric-content column">
      <div class="flex items-center justify-center">
        <woot-line-chart
          v-if="chartData.datasets.length"
          :collection="chartData"
          class="w-full"
        />
        <span v-else class="text-sm text-slate-600">
          {{ $t('REPORT.NO_ENOUGH_DATA') }}
        </span>
      </div>
    </div>
  </metric-card>
</template>

<script>
import MetricCard from '../overview/MetricCard.vue';
import { format } from 'date-fns';

export default {
  name: 'GraphInvoices',
  components: {
    MetricCard,
  },
  props: {
    invoicesData: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      chartData: {
        labels: [],
        datasets: [],
      },
    };
  },
  watch: {
    invoicesData: {
      immediate: true,
      handler(newData) {
        this.prepareChartData(newData);
      },
    },
  },
  methods: {
    prepareChartData(data) {
      const labels = data.map(item =>
        format(new Date(item.date), 'dd/MM/yyyy')
      );
      const values = data.map(item => item.total_price);

      this.chartData = {
        labels,
        datasets: [
          {
            label: this.$t('INVOICE_REPORTS.GRAPH.PRICE_LABEL'),
            data: values,
            borderWidth: 1,
          },
        ],
      };
    },
  },
};
</script>
