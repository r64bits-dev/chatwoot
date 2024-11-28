import * as types from '../../mutation-types';
import ReportsAPI from '../../../api/reports';

export const state = {
  data: {
    values: [],
    usage: {
      values: [],
      sent_messages: [],
      received_messages: [],
      extra_sent_messages: [],
      extra_received_messages: [],
    },
    summary: {
      total: 0,
    },
    summaryUsage: {
      total: 0,
      sent_messages: 0,
      received_messages: 0,
      extra_sent_messages: 0,
      extra_received_messages: 0,
    },
  },
  uiFlags: {
    isFetching: false,
    isFetchingItem: false,
    isFetchingUsage: false,
    isCreating: false,
    isUpdating: false,
    isDeleting: false,
  },
};

export const getters = {
  getInvoices($state) {
    return $state.data.values;
  },
  getUsageMessages($state) {
    return $state.data.usage.values;
  },
  getUsageExtraSentMessages($state) {
    return $state.data.usage.extra_sent_messages;
  },
  getUsageExtraReceivedMessages($state) {
    return $state.data.usage.extra_received_messages;
  },
  getUsageReceivedMessages($state) {
    return $state.data.usage.received_messages;
  },
  getUsageSentMessages($state) {
    return $state.data.usage.sent_messages;
  },
  getSummary($state) {
    return $state.data.summary;
  },
  getSummaryUsage($state) {
    return $state.data.summaryUsage;
  },
  getInvoice: $state => invoiceId => {
    const [invoice] = $state.data.filter(
      record => record.id === Number(invoiceId)
    );
    return invoice || {};
  },
  getUIFlags($state) {
    return $state.uiFlags;
  },
};

export const actions = {
  get: async ({ commit }, { from, to, groupBy }) => {
    commit(types.default.SET_INVOICES_UI_FLAG, { isFetching: true });
    try {
      const response = await ReportsAPI.getInvoicesReport({
        from,
        to,
        groupBy,
      });
      commit(types.default.SET_INVOICES_UI_FLAG, { isFetching: false });
      commit(types.default.SET_INVOICES, response.data);
    } catch (error) {
      commit(types.default.SET_INVOICES_UI_FLAG, { isFetching: false });
    }
  },

  getUsage: async ({ commit }, { from, to }) => {
    commit(types.default.SET_INVOICES_UI_FLAG, { isFetchingUsage: true });
    try {
      const response = await ReportsAPI.getInvoicesUsageReport({
        from,
        to,
      });
      commit(types.default.SET_INVOICES_UI_FLAG, { isFetchingUsage: false });
      commit(types.default.SET_INVOICES_USAGE, response.data);
      commit(types.default.SET_INVOICES_SUMMARY_USAGE, response.data);
    } catch (error) {
      commit(types.default.SET_INVOICES_UI_FLAG, { isFetchingUsage: false });
    }
  },
};

export const mutations = {
  [types.default.SET_INVOICES_UI_FLAG]($state, uiFlag) {
    $state.uiFlags = { ...$state.uiFlags, ...uiFlag };
  },
  [types.default.SET_INVOICES]($state, data) {
    $state.data.values = data.values;
    $state.data.summary = data.summary;
  },
  [types.default.SET_INVOICES_SUMMARY_USAGE]($state, data) {
    $state.data.summaryUsage = data.summary;
  },
  [types.default.SET_INVOICES_USAGE]($state, data) {
    $state.data.usage.values = data.values || [];
    $state.data.usage.extra_sent_messages = data.extra_sent_messages || [];
    $state.data.usage.extra_received_messages =
      data.extra_received_messages || [];
    $state.data.usage.sent_messages = data.sent_messages || [];
    $state.data.usage.received_messages = data.received_messages || [];
  },
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};
