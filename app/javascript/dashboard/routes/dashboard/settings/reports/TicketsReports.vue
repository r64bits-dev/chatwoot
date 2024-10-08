<template>
  <div class="flex-1 overflow-auto p-4">
    <report-filters
      type="tickets"
      :group-by-filter-items-list="groupByFilterItemsList"
      @date-range-change="onDateRangeChange"
      @business-hours-toggle="onBusinessHoursToggle"
      @group-by-filter-change="onGroupByFilterChange"
    >
      <template #additionalFilters>
        <p class="text-xs mb-2 font-medium">
          {{ $t('TICKETS_REPORTS.CUSTOM_ATTRIBUTES.HEADER') }}
        </p>
        <multiselect
          v-model="selectedCustomAttributes"
          :options="customAttributesOptions"
          :multiple="true"
          :option-height="24"
          track-by="id"
          label="name"
          :no-search-result="
            $t('TICKETS_REPORTS.CUSTOM_ATTRIBUTES.NO_ATTRIBUTES')
          "
          :placeholder="$t('TICKETS_REPORTS.CUSTOM_ATTRIBUTES.PLACEHOLDER')"
          @input="changeCustomAttributesSelection"
        />
      </template>
    </report-filters>
    <div class="row">
      <metric-card
        :is-live="false"
        :is-loading="ticketsUIFlags.isFetching"
        :header="$t('TICKETS_REPORTS.SUBTITLE')"
        :loading-message="$t('REPORT.LOADING_CHART')"
      >
        <template v-if="!ticketsUIFlags.isFetching">
          <div
            v-for="(metric, name, index) in ticketsMetrics"
            :key="index"
            class="metric-content column"
          >
            <h3 class="heading">{{ name }}</h3>
            <p class="metric">{{ metric }}</p>
          </div>
        </template>
      </metric-card>
    </div>
    <div class="row">
      <metric-card :header="$t('TICKETS_REPORTS.GRAPH_TITLE')" :is-live="false">
        <ticket-agents-table-component
          :account-id="accountId"
          :from="from"
          :to="to"
          :selected-custom-attributes="selectedCustomAttributes"
        />
      </metric-card>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import { TICKETS_SUMMARY_METRICS } from './constants';

import MetricCard from './components/overview/MetricCard';
import ReportFilters from './components/ReportFilters.vue';
import TicketAgentsTableComponent from 'dashboard/routes/dashboard/tickets/components/TicketAgentsTableComponent';

export default {
  name: 'TicketsReports',
  components: {
    MetricCard,
    TicketAgentsTableComponent,
    ReportFilters,
  },
  data: () => ({
    itemComponent: TicketAgentsTableComponent,
    from: Math.floor(new Date().setMonth(new Date().getMonth() - 6) / 1000),
    to: Math.floor(Date.now() / 1000),
    selectedCustomAttributes: [],
    customAttributesOptions: [],
    groupBy: null,
  }),
  computed: {
    ...mapGetters({
      ticketsReport: 'ticketsReport/getTicketsReport',
      ticketsSummary: 'ticketsReport/getTicketsSummary',
      ticketsUIFlags: 'ticketsReport/getUIFlags',
      accountId: 'getCurrentAccountId',
      getAttributesByModel: 'attributes/getAttributesByModel',
    }),
    groupByFilterItemsList() {
      return this.$t('REPORT.GROUP_BY_YEAR_OPTIONS');
    },
    ticketsMetrics() {
      let metric = {};
      Object.keys(this.ticketsSummary || {}).forEach(key => {
        const metricName = this.$t(
          'TICKETS_REPORTS.METRICS.' + TICKETS_SUMMARY_METRICS[key] + '.NAME'
        );
        metric[metricName] = this.ticketsSummary[key];
      });
      return metric;
    },
  },
  created() {
    this.$store.dispatch('attributes/get').then(() => {
      this.fetchTicketCustomAttributes();
      this.fetchAllData();
    });
  },
  methods: {
    fetchTicketCustomAttributes() {
      const attributes = this.getAttributesByModel('ticket_attribute');
      this.customAttributesOptions = attributes.map(attribute => ({
        id: attribute.id,
        name: attribute.attribute_display_name,
      }));
    },
    changeCustomAttributesSelection(selectedCustomAttributes) {
      this.selectedCustomAttributes = selectedCustomAttributes;
      this.fetchAllData();
    },

    onGroupByFilterChange(payload) {
      this.groupBy = payload.id;
      this.fetchAllData();
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
      const { from, to, groupBy, selectedCustomAttributes } = this;
      const payload = { from, to };

      if (groupBy) {
        payload.groupBy = groupBy;
      }

      if (selectedCustomAttributes.length) {
        payload.customAttributes = selectedCustomAttributes.map(
          attribute => attribute.name
        );
      }

      this.$store.dispatch('ticketsReport/getSummary', payload);
    },
  },
};
</script>
