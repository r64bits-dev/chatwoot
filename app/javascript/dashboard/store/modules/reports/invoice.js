import * as types from '../../mutation-types';
import ReportsAPI from '../../../api/reports';

export const state = {
  data: {
    values: [],
    summary: {
      total: 0,
    },
  },
  uiFlags: {
    isFetching: false,
    isFetchingItem: false,
    isCreating: false,
    isUpdating: false,
    isDeleting: false,
  },
};

export const getters = {
  getInvoices($state) {
    return $state.data.values;
  },
  getSummary($state) {
    return $state.data.summary;
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
};

export const mutations = {
  [types.default.SET_INVOICES_UI_FLAG]($state, uiFlag) {
    $state.uiFlags = { ...$state.uiFlags, ...uiFlag };
  },
  [types.default.SET_INVOICES]($state, data) {
    $state.data = data;
  },
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};
