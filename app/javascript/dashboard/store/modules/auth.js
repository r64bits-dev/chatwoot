import Vue from 'vue';
import types from '../mutation-types';
import authAPI from '../../api/auth';

import { setUser, clearCookiesOnLogout } from '../utils/api';

const initialState = {
  currentUser: {
    id: null,
    account_id: null,
    accounts: [],
    email: null,
    name: null,
  },
  uiFlags: {
    isFetching: true,
  },
};

// getters
export const getters = {
  isLoggedIn($state) {
    return !!$state.currentUser.id;
  },

  getCurrentUserID($state) {
    return $state.currentUser.id;
  },

  getUISettings($state) {
    return $state.currentUser.ui_settings || {};
  },

  getAuthUIFlags($state) {
    return $state.uiFlags;
  },

  getCurrentUserAvailability($state, $getters) {
    const { accounts = [] } = $state.currentUser;
    const [currentAccount = {}] = accounts.filter(
      account => account.id === $getters.getCurrentAccountId
    );
    return currentAccount.availability;
  },

  getCurrentUserAutoOffline($state, $getters) {
    const { accounts = [] } = $state.currentUser;
    const [currentAccount = {}] = accounts.filter(
      account => account.id === $getters.getCurrentAccountId
    );
    return currentAccount.auto_offline;
  },

  getCurrentAccountId(_, __, rootState) {
    if (rootState.route.params && rootState.route.params.accountId) {
      return Number(rootState.route.params.accountId);
    }
    return null;
  },

  getCurrentRole($state, $getters) {
    const { accounts = [] } = $state.currentUser;
    const [currentAccount = {}] = accounts.filter(
      account => account.id === $getters.getCurrentAccountId
    );
    return currentAccount.role;
  },

  getCurrentPermissions($state, $getters) {
    const { accounts = [] } = $state.currentUser;
    const [currentAccount = {}] = accounts.filter(
      account => account.id === $getters.getCurrentAccountId
    );
    return currentAccount.permissions || {};
  },

  getCurrentUser($state) {
    return $state.currentUser;
  },

  getMessageSignature($state) {
    const { message_signature: messageSignature } = $state.currentUser;

    return messageSignature || '';
  },

  getMessageDisplayName($state) {
    const { display_name: displayName, name } = $state.currentUser;

    return displayName || name || '';
  },

  getCurrentAccount($state, $getters) {
    const { accounts = [] } = $state.currentUser;
    const [currentAccount = {}] = accounts.filter(
      account => account.id === $getters.getCurrentAccountId
    );
    return currentAccount || {};
  },

  getUserAccounts($state) {
    const { accounts = [] } = $state.currentUser;
    return accounts;
  },
};

// actions
export const actions = {
  async validityCheck(context) {
    try {
      const response = await authAPI.validityCheck();

      // Salvando os tokens nos headers
      const token = response.headers['access-token'];
      const client = response.headers.client;
      const uid = response.headers.uid;

      if (token && client && uid) {
        localStorage.setItem('access-token', token);
        localStorage.setItem('client', client);
        localStorage.setItem('uid', uid);
      }

      const currentUser = response.data.payload.data;
      setUser(currentUser);
      context.commit(types.SET_CURRENT_USER, currentUser);
    } catch (error) {
      if (error?.response?.status === 401) {
        clearCookiesOnLogout();
      }
    }
  },
  async setUser({ commit, dispatch }) {
    if (authAPI.hasAuthCookie()) {
      await dispatch('validityCheck');
    } else {
      commit(types.CLEAR_USER);
    }
    commit(types.SET_CURRENT_USER_UI_FLAGS, { isFetching: false });
  },
  logout({ commit }) {
    commit(types.CLEAR_USER);
  },

  updateProfile: async ({ commit }, params) => {
    // eslint-disable-next-line no-useless-catch
    try {
      const response = await authAPI.profileUpdate(params);
      commit(types.SET_CURRENT_USER, response.data);
    } catch (error) {
      throw error;
    }
  },

  deleteAvatar: async () => {
    try {
      await authAPI.deleteAvatar();
    } catch (error) {
      // Ignore error
    }
  },

  updateUISettings: async ({ commit }, params) => {
    try {
      commit(types.SET_CURRENT_USER_UI_SETTINGS, params);
      const response = await authAPI.updateUISettings(params);
      commit(types.SET_CURRENT_USER, response.data);
    } catch (error) {
      // Ignore error
    }
  },

  updateAvailability: async ({ commit, dispatch }, params) => {
    try {
      const response = await authAPI.updateAvailability(params);
      const userData = response.data;
      const { id } = userData;
      commit(types.SET_CURRENT_USER, response.data);
      dispatch('agents/updateSingleAgentPresence', {
        id,
        availabilityStatus: params.availability,
      });
    } catch (error) {
      // Ignore error
    }
  },

  updateAutoOffline: async ({ commit }, { accountId, autoOffline }) => {
    try {
      const response = await authAPI.updateAutoOffline(accountId, autoOffline);
      commit(types.SET_CURRENT_USER, response.data);
    } catch (error) {
      // Ignore error
    }
  },

  setCurrentUserAvailability({ commit, state: $state }, data) {
    if (data[$state.currentUser.id]) {
      commit(types.SET_CURRENT_USER_AVAILABILITY, data[$state.currentUser.id]);
    }
  },

  setActiveAccount: async (_, { accountId }) => {
    try {
      await authAPI.setActiveAccount({ accountId });
    } catch (error) {
      // Ignore error
    }
  },
};

// mutations
export const mutations = {
  [types.SET_CURRENT_USER_AVAILABILITY](_state, availability) {
    const accounts = _state.currentUser.accounts.map(account => {
      if (account.id === _state.currentUser.account_id) {
        return { ...account, availability, availability_status: availability };
      }
      return account;
    });
    Vue.set(_state, 'currentUser', {
      ..._state.currentUser,
      accounts,
    });
  },
  [types.CLEAR_USER](_state) {
    _state.currentUser = initialState.currentUser;
  },
  [types.SET_CURRENT_USER](_state, currentUser) {
    Vue.set(_state, 'currentUser', currentUser);
  },
  [types.SET_CURRENT_USER_UI_SETTINGS](_state, { uiSettings }) {
    Vue.set(_state, 'currentUser', {
      ..._state.currentUser,
      ui_settings: {
        ..._state.currentUser.ui_settings,
        ...uiSettings,
      },
    });
  },

  [types.SET_CURRENT_USER_UI_FLAGS](_state, { isFetching }) {
    Vue.set(_state, 'uiFlags', { isFetching });
  },
};

export default {
  state: initialState,
  getters,
  actions,
  mutations,
};
