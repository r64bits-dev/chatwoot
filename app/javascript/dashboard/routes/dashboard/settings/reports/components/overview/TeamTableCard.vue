<template>
  <metric-card
    :header="$t('OVERVIEW_REPORTS.TEAMS_CONVERSATIONS.HEADER')"
    :is-loading="uiFlags.isFetchingTeams"
    :loading-message="
      $t('OVERVIEW_REPORTS.TEAMS_CONVERSATIONS.LOADING_MESSAGE')
    "
  >
    <div class="team-table-container">
      <ve-table
        max-height="calc(100vh - 21.875rem)"
        :fixed-header="true"
        :columns="columns"
        :table-data="tableData"
      />
      <empty-state
        v-if="!uiFlags.isFetchingTeams && !tableData.length"
        :title="$t('OVERVIEW_REPORTS.TEAMS_CONVERSATIONS.NO_TEAMS')"
      />
    </div>
  </metric-card>
</template>

<script>
import { mapGetters } from 'vuex';
import { VeTable } from 'vue-easytable';
import MetricCard from './MetricCard.vue';
import EmptyState from 'dashboard/components/widgets/EmptyState.vue';
import rtlMixin from 'shared/mixins/rtlMixin';

export default {
  name: 'AgentTable',
  components: {
    EmptyState,
    VeTable,
    MetricCard,
  },
  mixins: [rtlMixin],
  data() {
    return {
      isLoading: true,
      pageIndex: 1,
      count: 0,
    };
  },
  computed: {
    ...mapGetters({
      uiFlags: 'getOverviewUIFlags',
      teams: 'getTeamsMetrics',
    }),
    tableData() {
      return this.teams;
    },
    columns() {
      return [
        {
          field: 'name',
          key: 'name',
          title: this.$t(
            'OVERVIEW_REPORTS.TEAMS_CONVERSATIONS.TABLE_HEADER.TEAM'
          ),
          align: this.isRTLView ? 'right' : 'left',
          width: 10,
        },
        {
          field: 'conversations_open_count',
          key: 'conversations_open_count',
          title: this.$t(
            'OVERVIEW_REPORTS.TEAMS_CONVERSATIONS.TABLE_HEADER.OPEN'
          ),
          align: this.isRTLView ? 'right' : 'left',
          width: 10,
        },
        {
          field: 'conversations_unassigned_count',
          key: 'conversations_unassigned_count',
          title: this.$t(
            'OVERVIEW_REPORTS.TEAMS_CONVERSATIONS.TABLE_HEADER.UNATTENDED'
          ),
          align: this.isRTLView ? 'right' : 'left',
          width: 10,
        },
        {
          field: 'conversations_resolved_count',
          key: 'conversations_resolved_count',
          title: this.$t(
            'OVERVIEW_REPORTS.TEAMS_CONVERSATIONS.TABLE_HEADER.RESOLVED'
          ),
          align: this.isRTLView ? 'right' : 'left',
          width: 10,
        },
      ];
    },
  },
  watch: {
    pageIndex() {
      this.fetchTeams(this.pageIndex);
    },
  },
  mounted() {
    this.fetchTeams(this.pageIndex);
  },
  methods: {
    fetchTeams(page) {
      this.$store.dispatch('fetchTeamsMetrics', { page });
    },
  },
};
</script>

<style lang="scss" scoped>
.teams-table-container {
  @apply flex flex-col flex-1;

  .ve-table {
    &::v-deep {
      th.ve-table-header-th {
        font-size: var(--font-size-mini) !important;
        padding: var(--space-small) var(--space-two) !important;
      }

      td.ve-table-body-td {
        padding: var(--space-one) var(--space-two) !important;
      }
    }
  }

  &::v-deep .ve-pagination {
    @apply bg-transparent dark:bg-transparent;
  }

  &::v-deep .ve-pagination-select {
    @apply hidden;
  }

  .row-user-block {
    @apply items-center flex text-left;

    .user-block {
      @apply items-start flex flex-col min-w-0 my-0 mx-2;

      .title {
        @apply text-sm m-0 leading-[1.2] text-slate-800 dark:text-slate-100;
      }
      .sub-title {
        @apply text-xs text-slate-600 dark:text-slate-200;
      }
    }
  }

  .table-pagination {
    @apply mt-4 text-right;
  }
}

.teams-loader {
  @apply items-center flex text-base justify-center p-8;
}
</style>
