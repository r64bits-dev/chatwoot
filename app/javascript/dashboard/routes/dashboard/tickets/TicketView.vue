<template>
  <section class="ticket-page bg-white dark:bg-slate-900 flex flex-col">
    <div class="flex flex-row w-full">
      <div class="flex-col w-full" :class="{ 'w-[70%]': !!ticket }">
        <div class="flex p-4">
          <div class="flex flex-row w-full">
            <div class="flex-1">
              <ticket-type-tabs
                :tabs="assigneeTabItems"
                :active-tab="activeAssigneeTab"
                @tab-change="updateAssigneeTab"
              />
            </div>
            <div class="flex-1">
              <woot-input
                v-model="search"
                type="search"
                placeholder="Pesquisar por Ticket"
                class="w-full"
                @input="handleSearch"
              />
            </div>
          </div>
        </div>
        <ve-table
          :fixed-header="true"
          :columns="columns"
          :table-data="tableData"
          :event-custom-option="eventCustomOption"
          max-height="calc(100vh - 15rem)"
        />

        <ve-pagination
          class="!flex w-full justify-center !mt-8"
          :total="pagination.total_count"
          :page-index="pagination.current_page"
          :page-size="itemsPerPage"
          :page-size-option="[10, 20, 30, 40, 50]"
          @on-page-number-change="fetchTickets"
          @on-page-size-change="updateItemsPerPage"
        />
      </div>
      <div
        v-if="ticket"
        class="flex flex-col w-[30%] border-l border-slate-50 dark:border-slate-800"
      >
        <ticket-details :ticket-id="ticket.id" />
      </div>
    </div>
  </section>
</template>
<script>
import { mapGetters } from 'vuex';
import { formatUnixDate } from 'shared/helpers/DateHelper';
import TicketTypeTabs from './components/TicketTypeTabs.vue';
import TicketDetails from './components/TicketDetails.vue';
import { VeTable, VePagination } from 'vue-easytable';
import TimeAgo from 'dashboard/components/ui/TimeAgo.vue';
import { debounce } from '@chatwoot/utils';

export default {
  name: 'TicketView',
  components: {
    TicketTypeTabs,
    TicketDetails,
    VeTable,
    VePagination,
    // eslint-disable-next-line vue/no-unused-components
    TimeAgo,
  },
  data() {
    return {
      eventCustomOption: {
        bodyRowEvents: ({ row }) => ({
          click: () => {
            this.$store.dispatch('tickets/get', row.id);
          },
        }),
      },
      activeAssigneeTab: 'open',
      activeStatus: 'open',
      hasPagination: false,
      itemsPerPage: 30,
      search: '',
    };
  },
  computed: {
    ...mapGetters({
      ticketStats: 'tickets/getStats',
      ticketLists: 'tickets/getTickets',
      ticket: 'tickets/getTicket',
      pagination: 'tickets/getPagination',
      currentUserId: 'getCurrentUserID',
    }),
    assigneeTabItems() {
      return [
        {
          key: 'open',
          name: this.$t('TICKETS.STATUS.PENDING'),
          count: this.ticketStats.pending,
        },
        {
          key: 'closed',
          name: this.$t('TICKETS.STATUS.RESOLVED'),
          count: this.ticketStats.resolved,
        },
        {
          key: 'all',
          name: this.$t('TICKETS.STATUS.ALL'),
          count: this.ticketStats.all,
        },
      ];
    },
    columns() {
      return [
        {
          field: 'id',
          title: 'Número do Ticket',
          key: 'id',
          sortable: true,
          renderBodyCell: ({ row }) => (
            <woot-button variant="clear">{row.id}</woot-button>
          ),
        },
        {
          field: 'created_at',
          title: 'Data de Abertura',
          key: 'created_at',
          sortable: true,
          renderBodyCell: ({ row }) => this.formatDate(row.created_at),
        },
        {
          field: 'description',
          title: 'Descrição',
          key: 'description',
          sortable: true,
        },
        {
          field: 'status',
          title: 'Status',
          key: 'status',
          sortable: true,
          renderBodyCell: ({ row }) => {
            return this.translateStatusText(row.status);
          },
        },
        {
          field: 'assigned_to',
          title: 'Atribuído',
          key: 'assigned_to',
          sortable: true,
          renderBodyCell: ({ row }) => {
            return this.getTextAssignee(row);
          },
        },
        {
          field: 'resolved_at',
          title: 'Tempo de Conclusão',
          key: 'resolved_at',
          sortable: true,
          renderBodyCell: ({ row }) => {
            return (
              <TimeAgo
                last-activity-timestamp={this.getTimestamp(row.resolved_at)}
                created-at-timestamp={this.getTimestamp(row.created_at)}
              />
            );
          },
        },
      ];
    },
    tableData() {
      return this.ticketLists;
    },
  },
  watch: {
    selectedLabel(newLabel) {
      this.fetchTickets(newLabel);
    },
  },
  mounted() {
    this.fetchTickets(this.selectedLabel);
  },
  methods: {
    getTextAssignee(ticket) {
      if (!ticket.assigned_to) {
        return this.$t('TICKETS.ASSIGNEE_FILTER.UNASSIGNED');
      }
      if (ticket.assigned_to.id === this.currentUserId) {
        return this.$t('TICKETS.ASSIGNEE_FILTER.ME');
      }
      return ticket.assigned_to.name;
    },
    getTimestamp(dateString) {
      return dateString
        ? Math.floor(new Date(dateString).getTime() / 1000)
        : Math.floor(Date.now() / 1000);
    },
    updateAssigneeTab(selectedTab) {
      this.activeAssigneeTab = selectedTab;
      this.fetchTickets(
        this.currentPage,
        null,
        this.translateStatus(selectedTab)
      );
    },
    updateItemsPerPage(newPageSize) {
      this.itemsPerPage = newPageSize;
      this.fetchTickets(this.currentPage);
    },
    fetchTickets(page, label = null, status = null) {
      this.currentPage = page;
      this.$store.dispatch('tickets/getAllTickets', {
        status,
        label,
        search: this.search,
        page: this.currentPage,
        per_page: this.itemsPerPage,
      });
    },
    formatDate(date) {
      return date ? formatUnixDate(date, 'dd/MM/yyyy') : '';
    },
    formatTime(time) {
      return time ? formatUnixDate(time, 'HH:mm') : '';
    },
    handleSearch() {
      debounce(() => {
        this.fetchTickets(this.currentPage);
      }, 500)();
    },
    translateStatus(status) {
      switch (status) {
        case 'open':
          return 'pending';
        case 'closed':
          return 'resolved';
        case 'all':
          return null;
        default:
          return status;
      }
    },
    translateStatusText(status) {
      switch (status) {
        case 'open':
          return this.$t('TICKETS.STATUS.OPEN');
        case 'pending':
          return this.$t('TICKETS.STATUS.PENDING');
        case 'resolved':
          return this.$t('TICKETS.STATUS.RESOLVED');
        case 'all':
          return this.$t('TICKETS.STATUS.ALL');
        default:
          return status;
      }
    },
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
