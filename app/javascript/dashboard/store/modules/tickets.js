import * as types from '../mutation-types';
import TicketsAPI from '../../api/tickets';

const state = {
  records: [],
  labels: [],
  selectedTicket: null,
  customAttributes: {},
  uiFlags: {
    isCreating: false,
    isFetching: false,
    isUpdating: false,
  },
  uiFlagsPage: {
    isFetching: false,
  },
  stats: {
    open: 0,
    closed: 0,
    all: 0,
  },
};

export const getters = {
  getUIFlags($state) {
    return $state.uiFlags;
  },
  getUIFlagsPage($state) {
    return $state.uiFlagsPage;
  },
  getTickets($state) {
    return $state.records;
  },
  getStats($state) {
    return $state.stats;
  },
  getTicket: $state => {
    return $state.selectedTicket;
  },
  getLabels($state) {
    return $state.labels;
  },
  getCustomAttributes($state) {
    return $state.customAttributes;
  },
};

export const actions = {
  get: async ({ commit }, ticketId) => {
    try {
      const response = await TicketsAPI.show(ticketId);

      commit(types.default.SET_TICKET, response.data);
      commit(types.default.SET_TICKETS_UI_FLAG, {
        isFetching: false,
      });
    } catch (error) {
      commit(types.default.SET_TICKETS_UI_FLAG, {
        isFetching: false,
      });
    }
  },
  getConversationTickets: async ({ commit }, conversationId) => {
    commit(types.default.SET_TICKETS_UI_FLAG, { isFetching: true });
    try {
      const response = await TicketsAPI.getConversationTickets(conversationId);
      commit(types.default.SET_TICKETS, response.data.payload);
      commit(types.default.SET_TICKETS_UI_FLAG, {
        isFetching: false,
      });
    } catch (error) {
      commit(types.default.SET_TICKETS_UI_FLAG, {
        isFetching: false,
      });
    }
  },
  getAllTickets: async ({ commit }, label = null) => {
    commit(types.default.SET_TICKETS_UI_FLAG_PAGE, { isFetching: true });
    try {
      const response = await TicketsAPI.get({ label });
      commit(types.default.SET_TICKETS, response.data.payload);
      commit(types.default.SET_TICKETS_STATS, response.data.meta);
      commit(types.default.SET_TICKETS_UI_FLAG_PAGE, {
        isFetching: false,
      });
    } catch (error) {
      commit(types.default.SET_TICKETS_UI_FLAG_PAGE, {
        isFetching: false,
      });
    }
  },
  create: async (
    { commit },
    { title, description, status, assigneeId, conversationId, customAttributes }
  ) => {
    commit(types.default.SET_TICKETS_UI_FLAG, { isCreating: true });
    try {
      const response = await TicketsAPI.create({
        title,
        description,
        status,
        assignee_id: assigneeId,
        conversation_id: conversationId,
        display_id: conversationId,
        custom_attributes: customAttributes,
      });
      commit(types.default.SET_TICKETS, response.data);
      commit(types.default.SET_TICKETS_UI_FLAG, {
        isCreating: false,
      });
    } catch (error) {
      commit(types.default.SET_TICKETS_UI_FLAG, {
        isCreating: false,
      });
      if (error.response.data) {
        throw error.response.data.error;
      }
      throw error;
    }
  },
  update: async ({ commit }, { ticketId, body }) => {
    commit(types.default.SET_TICKETS_UI_FLAG, { isUpdating: true });
    try {
      const response = await TicketsAPI.update(ticketId, {
        ticket: { ...body },
      });
      commit(types.default.UPDATE_TICKET, response.data);
      commit(types.default.SET_TICKETS_UI_FLAG, {
        isUpdating: false,
      });
    } catch (error) {
      commit(types.default.SET_TICKETS_UI_FLAG, {
        isUpdating: false,
      });
      if (error.response.data) {
        throw error.response.data.error;
      }
      throw error;
    }
  },
  resolve: async ({ commit }, ticketId) => {
    commit(types.default.SET_TICKETS_UI_FLAG, { isUpdating: true });
    try {
      const response = await TicketsAPI.resolve(ticketId);
      commit(types.default.UPDATE_TICKET, response.data);
      commit(types.default.SET_TICKETS_UI_FLAG, {
        isUpdating: false,
      });
    } catch (error) {
      commit(types.default.SET_TICKETS_UI_FLAG, {
        isUpdating: false,
      });
      if (error.response.data) {
        throw error.response.data.error;
      }
      throw error;
    }
  },
  assign: async ({ commit }, { ticketId, assigneeId }) => {
    commit(types.default.SET_TICKETS_UI_FLAG, { isUpdating: true });
    try {
      const response = await TicketsAPI.assign(ticketId, assigneeId);
      commit(types.default.UPDATE_TICKET, response.data);
      commit(types.default.SET_TICKETS_UI_FLAG, {
        isUpdating: false,
      });
    } catch (error) {
      commit(types.default.SET_TICKETS_UI_FLAG, {
        isUpdating: false,
      });
      if (error.response.data) {
        throw error.response.data.error;
      }
      throw error;
    }
  },
  addLabel: async ({ commit }, { ticketId, label }) => {
    commit(types.default.SET_TICKETS_UI_FLAG, { isUpdating: true });
    try {
      await TicketsAPI.update(ticketId, { ticket: { labels: [label] } });
      commit(types.default.SET_TICKET_ADD_LABEL, { label });
    } catch (error) {
      commit(types.default.SET_TICKETS_UI_FLAG, { isUpdating: false });
      if (error.response.data) {
        throw error.response.data.error;
      }

      throw error;
    }
  },
  removeLabel: async ({ commit }, { ticketId, label }) => {
    commit(types.default.SET_TICKETS_UI_FLAG, { isUpdating: true });
    try {
      await TicketsAPI.removeLabel(ticketId, label);
      commit(types.default.SET_TICKET_DELETE_LABEL, { label });
    } catch (error) {
      commit(types.default.SET_TICKETS_UI_FLAG, { isUpdating: false });
      if (error.response.data) {
        throw error.response.data.error;
      }

      throw error;
    }
  },
  delete: async ({ commit }, ticketId) => {
    commit(types.default.SET_TICKETS_UI_FLAG, { isDeleting: true });
    try {
      await TicketsAPI.delete(ticketId);
      commit(types.default.DELETE_TICKET);
      commit(types.default.SET_TICKETS_UI_FLAG, { isDeleting: false });
    } catch (error) {
      commit(types.default.SET_TICKETS_UI_FLAG, { isDeleting: false });
      throw error;
    }
  },
  getLabels: async ({ commit }) => {
    commit(types.default.SET_TICKETS_UI_FLAG, { isFetching: true });
    try {
      const response = await TicketsAPI.getLabels();
      commit(types.default.SET_TICKETS_LABELS, response.data);
    } catch (error) {
      commit(types.default.SET_TICKETS_UI_FLAG, { isFetching: false });
      throw error;
    }
  },
};

export const mutations = {
  [types.default.SET_TICKETS_UI_FLAG]($state, data) {
    $state.uiFlags = {
      ...$state.uiFlags,
      ...data,
    };
  },
  [types.default.SET_TICKETS_UI_FLAG_PAGE]($state, data) {
    $state.uiFlagsPage = {
      ...$state.uiFlagsPage,
      ...data,
    };
  },
  [types.default.SET_TICKETS]: ($state, data) => {
    $state.records = data;
  },
  [types.default.SET_TICKET]: ($state, data) => {
    $state.selectedTicket = data;
  },
  [types.default.UPDATE_TICKET]: ($state, data) => {
    $state.selectedTicket = data;
  },
  [types.default.SET_TICKETS_STATS]($state, data) {
    $state.stats = data;
  },
  [types.default.DELETE_TICKET]: $state => {
    $state.selectedTicket = null;
  },
  [types.default.SET_TICKET_ADD_LABEL]($state, { label }) {
    $state.selectedTicket.labels = [...$state.selectedTicket.labels, label];
  },
  [types.default.SET_TICKET_DELETE_LABEL]($state, { label }) {
    $state.selectedTicket.labels = $state.selectedTicket.labels.filter(
      l => l.id !== label.id
    );
  },
  [types.default.SET_TICKETS_LABELS]($state, labels) {
    $state.labels = labels;
  },
  [types.default.SET_TICKET_CUSTOM_ATTRIBUTES]($state, customAttributes) {
    $state.customAttributes = customAttributes;
  },
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};
