<template>
  <div
    class="conversation-details-wrap bg-slate-25 dark:bg-slate-800"
    :class="{ 'with-border-right': !isOnExpandedLayout }"
  >
    <conversation-header
      v-if="currentChat.id"
      :chat="currentChat"
      :is-contact-panel-open="isContactPanelOpen"
      :show-back-button="isOnExpandedLayout"
      @contact-panel-toggle="onToggleContactPanel"
    />
    <woot-tabs
      v-if="dashboardApps.length && currentChat.id"
      :index="activeIndex"
      class="dashboard-app--tabs bg-white dark:bg-slate-900 -mt-px"
      @change="onDashboardAppTabChange"
    >
      <woot-tabs-item
        v-for="tab in dashboardAppTabs"
        :key="tab.key"
        :name="tab.name"
        :show-badge="false"
      />
    </woot-tabs>
    <div
      v-show="!activeIndex"
      class="flex bg-slate-25 dark:bg-slate-800 m-0 h-full min-h-0"
    >
      <messages-view
        v-if="currentChat.id"
        :inbox-id="inboxId"
        :is-contact-panel-open="isContactPanelOpen"
        :is-assigned-to-current-user="isAssignedToCurrentUser"
        @contact-panel-toggle="onToggleContactPanel"
      />
      <empty-state v-else :is-on-expanded-layout="isOnExpandedLayout" />
      <div
        v-show="showContactPanel"
        class="conversation-sidebar-wrap basis-full sm:basis-[17.5rem] md:basis-[18.75rem] lg:basis-[19.375rem] xl:basis-[20.625rem] 2xl:basis-[25rem] rtl:border-r border-slate-50 dark:border-slate-700 h-auto overflow-auto z-10 flex-shrink-0 flex-grow-0"
      >
        <contact-panel
          v-if="showContactPanel"
          :conversation-id="currentChat.id"
          :inbox-id="currentChat.inbox_id"
          :on-toggle="onToggleContactPanel"
        />
      </div>
    </div>
    <dashboard-app-frame
      v-for="(dashboardApp, index) in dashboardApps"
      v-show="activeIndex - 1 === index"
      :key="currentChat.id + '-' + dashboardApp.id"
      :is-visible="activeIndex - 1 === index"
      :config="dashboardApps[index].content"
      :position="index"
      :current-chat="currentChat"
    />
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import ContactPanel from 'dashboard/routes/dashboard/conversation/ContactPanel.vue';
import ConversationHeader from './ConversationHeader.vue';
import DashboardAppFrame from '../DashboardApp/Frame.vue';
import EmptyState from './EmptyState/EmptyState.vue';
import MessagesView from './MessagesView.vue';

export default {
  components: {
    ContactPanel,
    ConversationHeader,
    DashboardAppFrame,
    EmptyState,
    MessagesView,
  },

  props: {
    inboxId: {
      type: [Number, String],
      default: '',
      required: false,
    },
    isContactPanelOpen: {
      type: Boolean,
      default: true,
    },
    isOnExpandedLayout: {
      type: Boolean,
      default: true,
    },
  },
  data() {
    return { activeIndex: 0 };
  },
  computed: {
    ...mapGetters({
      currentChat: 'getSelectedChat',
      dashboardApps: 'dashboardApps/getRecords',
      currentUser: 'getCurrentUser', // Adicionado para verificar atribuição
    }),
    isAssignedToCurrentUser() {
      const currentUserId = this.currentUser.id;
      //const conversationAssigneeId = this.currentChat.meta.assignee.id;
      const conversationAssigneeId = this.currentChat.last_non_activity_message.conversation.assignee_id;
      // Retorna true se a conversa está atribuída ao usuário atual ou não atribuída
      return conversationAssigneeId === currentUserId;
    },
    dashboardAppTabs() {
      return [
        {
          key: 'messages',
          name: this.$t('CONVERSATION.DASHBOARD_APP_TAB_MESSAGES'),
        },
        ...this.dashboardApps.map(dashboardApp => ({
          key: `dashboard-${dashboardApp.id}`,
          name: dashboardApp.title,
        })),
      ];
    },
    showContactPanel() {
      return this.isContactPanelOpen && this.currentChat.id;
    },
  },
  watch: {
    'currentChat.inbox_id'(inboxId) {
      if (inboxId) {
        this.$store.dispatch('inboxAssignableAgents/fetch', [inboxId]);
      }
    },
    'currentChat.id'() {
      this.fetchLabels();
      this.activeIndex = 0;
    },
    'currentChat.assignee_id'(newAssigneeId) {
      // Verifica se a conversa ainda está atribuída ao usuário atual
      this.checkConversationAssignment(newAssigneeId);
    },
  },
  mounted() {
    this.fetchLabels();
    this.$store.dispatch('dashboardApps/get');
    this.setupWebSocketListeners(); // Configura os listeners do WebSocket
  },
  beforeDestroy() {
    this.removeWebSocketListeners(); // Remove os listeners ao destruir o componente
  },
  methods: {
    fetchLabels() {
      if (!this.currentChat.id) {
        return;
      }
      this.$store.dispatch('conversationLabels/get', this.currentChat.id);
    },
    onToggleContactPanel() {
      this.$emit('contact-panel-toggle');
    },
    onDashboardAppTabChange(index) {
      this.activeIndex = index;
    },
    setupWebSocketListeners() {
      // Exemplo: Assumindo que você usa um canal de eventos como 'bus' ou diretamente o WebSocket
      // Substitua 'bus' pelo seu sistema de eventos real, se for diferente
      bus.$on('conversation_updated', this.handleConversationUpdate);
    },
    removeWebSocketListeners() {
      bus.$off('conversation_updated', this.handleConversationUpdate);
    },
    handleConversationUpdate(event) {
      // Evento recebido do WebSocket com informações da conversa atualizada
      if (event.conversation_id === this.currentChat.id) {
        const newAssigneeId = event.assignee_id;
        this.checkConversationAssignment(newAssigneeId);
      }
    },
    checkConversationAssignment(assigneeId) {
      const currentUserId = this.currentUser.id;
      if (assigneeId !== currentUserId && assigneeId !== null) {
        this.closeConversationView();
        return false; // Adicionado retorno para usar na validação
      }
      if (assigneeId === null && this.isAssignedToMeFilterActive()) {
        this.closeConversationView();
        return false;
      }
      return true;
    },
    isAssignedToMeFilterActive() {
      // Verifica se o contexto atual предполага que apenas conversas atribuídas ao usuário devem ser exibidas
      // Ajuste conforme sua lógica de filtros (ex.: pode estar em uiSettings ou rota)
      return this.$route.name === 'conversation_mentions' || false; // Exemplo, ajuste conforme necessário
    },
    closeConversationView() {
      // Redireciona para a lista de conversas ou outra tela apropriada
      const {
        params: { accountId, inbox_id: inboxId, label, teamId },
        name,
      } = this.$route;
      const conversationListUrl = `/app/accounts/${accountId}/conversations`; // Ajuste conforme sua rota
      this.$router.push(conversationListUrl);
      this.$store.dispatch('setCurrentChat', {}); // Limpa a conversa atual no Vuex
    },
  },
};
</script>

<style lang="scss" scoped>
.conversation-details-wrap {
  @apply flex flex-col min-w-0 w-full;

  &.with-border-right {
    @apply border-r border-slate-50 dark:border-slate-700;
  }
}

.dashboard-app--tabs {
  ::v-deep {
    .tabs-title {
      a {
        @apply pb-2 pt-1;
      }
    }
  }
}

.conversation-sidebar-wrap {
  &::v-deep .contact--panel {
    @apply w-full h-full max-w-full;
  }
}
</style>