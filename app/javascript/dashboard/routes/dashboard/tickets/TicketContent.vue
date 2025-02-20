<template>
  <div id="tickets-list" class="flex flex-col md:flex-row w-full">
    <!-- Lista de Tickets -->
    <div class="flex-col w-full" :class="{ 'md:w-[70%]': !!ticket }">
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

      <div class="overflow-x-auto">
        <!-- Visualização Mobile: lista de tickets em forma de cards -->
        <div v-if="isMobile" class="flex flex-col gap-2">
          <div
            v-for="ticket in tableData"
            :key="ticket.id"
            class="border p-4 rounded-lg"
            @click="handleRowClick(ticket)"
          >
            <p><strong>Número do Ticket:</strong> {{ ticket.id }}</p>
            <p>
              <strong>Data de Abertura:</strong>
              {{ formatDate(ticket.created_at) }}
            </p>
            <p>
              <strong>Status:</strong> {{ translateStatusText(ticket.status) }}
            </p>
            <p><strong>Descrição:</strong> {{ ticket.description }}</p>
          </div>
        </div>

        <!-- Visualização Desktop: Tabela com os tickets -->
        <ve-table
          v-else-if="!showEmpty"
          :fixed-header="true"
          :columns="columns"
          :table-data="tableData"
          :event-custom-option="eventCustomOption"
          max-height="calc(100vh - 15rem)"
        />

        <div v-else class="empty-data">Nenhum ticket disponível.</div>
      </div>

      <ve-pagination
        v-if="!showEmpty"
        class="!flex justify-center !mt-0 w-full"
        :total="pagination.total_count"
        :page-index="pagination.current_page"
        :page-size="itemsPerPage"
        :page-size-option="[10, 20, 30, 40, 50]"
        @on-page-number-change="fetchTickets"
        @on-page-size-change="updateItemsPerPage"
      />
    </div>

    <!-- Sidebar: Ticket Details para desktop -->
    <div
      v-if="ticket && !isMobile"
      class="flex flex-col w-full md:w-[30%] border-t md:border-l md:border-t-0 border-slate-50 dark:border-slate-800"
    >
      <ticket-details :ticket-id="ticket.id" />
    </div>

    <!-- Modal: Ticket Details para mobile -->
    <div v-if="isMobile && showTicketDetailsModal" class="modal-overlay">
      <div class="modal-content">
        <button class="modal-close" @click="closeModal">X</button>
        <ticket-details :ticket-id="ticket.id" />
      </div>
    </div>
  </div>
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
  name: 'TicketContent',
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
      windowWidth: window.innerWidth,
      showTicketDetailsModal: false,
      // Configuração dos eventos da tabela
      eventCustomOption: {
        bodyRowEvents: ({ row }) => ({
          click: () => {
            this.handleRowClick(row);
          },
        }),
      },
      activeAssigneeTab: 'open',
      activeStatus: 'open',
      hasPagination: false,
      itemsPerPage: 30,
      search: '',
      currentPage: 1,
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
    isMobile() {
      return this.windowWidth < 1280;
    },
    showEmpty() {
      return !this.tableData || this.tableData.length === 0;
    },
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
            <woot-button
              variant="clear"
              onClick={() => this.handleRowClick(row)}
            >
              {row.id}
            </woot-button>
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
          renderBodyCell: ({ row }) => this.translateStatusText(row.status),
        },
        {
          field: 'assigned_to',
          title: 'Atribuído',
          key: 'assigned_to',
          sortable: true,
          renderBodyCell: ({ row }) => this.getTextAssignee(row),
        },
        {
          field: 'resolved_at',
          title: 'Tempo de Conclusão',
          key: 'resolved_at',
          sortable: true,
          renderBodyCell: ({ row }) => (
            <TimeAgo
              last-activity-timestamp={this.getTimestamp(row.resolved_at)}
              created-at-timestamp={this.getTimestamp(row.created_at)}
            />
          ),
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
    window.addEventListener('resize', this.handleResize);
    this.fetchTickets(this.selectedLabel);
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.handleResize);
  },
  methods: {
    // Atualiza a largura da janela
    handleResize() {
      this.windowWidth = window.innerWidth;
    },
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
    handleRowClick(row) {
      if (this.ticket && this.ticket.id === row.id) {
        this.$store.commit('tickets/SET_TICKET', null);
        this.showTicketDetailsModal = false;
      } else {
        this.$store.dispatch('tickets/get', row.id);
        if (this.isMobile) {
          this.showTicketDetailsModal = true;
        }
      }
    },
    closeModal() {
      this.showTicketDetailsModal = false;
      this.$store.commit('tickets/SET_TICKET', null);
    },
  },
};
</script>

<style lang="scss" scoped>
#tickets-list {
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
    @apply dark:text-white;
  }

  &::v-deep .ve-pagination-select {
    @apply hidden;
  }

  .table-pagination {
    @apply mt-4 text-right;
  }

  .empty-data {
    display: flex;
    align-items: center;
    justify-content: center;
    height: 200px;
    width: 100%;
    color: #666;
    font-size: 16px;
    border: 1px solid #eee;
    border-top: 0;
  }

  @media (max-width: 768px) {
    .ve-table {
      min-width: 100%;
    }
  }
}

/* Estilos do Modal */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 999;
}

.modal-content {
  position: relative;
  background: #fff;
  padding: 1rem;
  border-radius: 4px;
  width: 90%;
  max-width: 400px;
}

.modal-close {
  position: absolute;
  top: 0.5rem;
  right: 0.5rem;
  background: transparent;
  border: none;
  font-size: 1.2rem;
  cursor: pointer;
}
</style>
