import { Line } from 'vue-chartjs';

const fontFamily =
  'PlusJakarta,-apple-system,system-ui,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Arial,sans-serif';

const defaultChartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  legend: {
    display: true,
    labels: {
      fontFamily,
    },
  },
  scales: {
    xAxes: [
      {
        ticks: {
          fontFamily,
        },
        gridLines: {
          drawOnChartArea: false,
        },
      },
    ],
    yAxes: [
      {
        ticks: {
          fontFamily,
          beginAtZero: true,
        },
        gridLines: {
          drawOnChartArea: true,
        },
      },
    ],
  },
  animation: {
    duration: 0,
  },
  tooltips: {
    enabled: true,
  },
};

export default {
  extends: Line,
  props: {
    collection: {
      type: Object,
      default: () => ({}),
    },
    chartOptions: {
      type: Object,
      default: () => ({}),
    },
  },
  mounted() {
    this.renderChart(this.collection, {
      ...defaultChartOptions,
      ...this.chartOptions,
    });
  },
};
