import * as MutationHelpers from 'shared/helpers/vuex/mutationHelpers';
import * as types from '../mutation-types';
import AccountAPI from '../../api/account';
import EnterpriseAccountAPI from '../../api/enterprise/account';
import { throwErrorMessage } from '../utils/api';

const state = {
  records: [],
  permissions: [],
  uiFlags: {
    isFetching: false,
    isFetchingItem: false,
    isUpdating: false,
    isCheckoutInProcess: false,
  },
};

export const getters = {
  getAccount: $state => id => {
    return $state.records.find(record => record.id === Number(id)) || {};
  },
  getPermissions: $state => $state.permissions,
  getUIFlags($state) {
    return $state.uiFlags;
  },
  isFeatureEnabledonAccount:
    ($state, _, __, rootGetters) => (id, featureName) => {
      // If a user is SuperAdmin and has access to the account, then they would see all the available features
      const isUserASuperAdmin =
        rootGetters.getCurrentUser?.type === 'SuperAdmin';
      if (isUserASuperAdmin) {
        return true;
      }

      const { features = {} } =
        $state.records.find(record => record.id === Number(id)) || {};
      return features[featureName] || false;
    },
};

export const actions = {
  get: async ({ commit }) => {
    commit(types.default.SET_ACCOUNT_UI_FLAG, { isFetchingItem: true });
    try {
      const response = await AccountAPI.get();
      commit(types.default.ADD_ACCOUNT, response.data);
      commit(types.default.SET_ACCOUNT_UI_FLAG, {
        isFetchingItem: false,
      });
    } catch (error) {
      commit(types.default.SET_ACCOUNT_UI_FLAG, {
        isFetchingItem: false,
      });
    }
  },
  update: async ({ commit }, updateObj) => {
    commit(types.default.SET_ACCOUNT_UI_FLAG, { isUpdating: true });
    try {
      await AccountAPI.update('', updateObj);
      commit(types.default.SET_ACCOUNT_UI_FLAG, { isUpdating: false });
    } catch (error) {
      commit(types.default.SET_ACCOUNT_UI_FLAG, { isUpdating: false });
      throw new Error(error);
    }
  },
  create: async ({ commit }, accountInfo) => {
    commit(types.default.SET_ACCOUNT_UI_FLAG, { isCreating: true });
    try {
      const response = await AccountAPI.createAccount(accountInfo);
      const account_id = response.data.data.account_id;
      commit(types.default.SET_ACCOUNT_UI_FLAG, { isCreating: false });
      return account_id;
    } catch (error) {
      commit(types.default.SET_ACCOUNT_UI_FLAG, { isCreating: false });
      throw error;
    }
  },

  checkout: async ({ commit }) => {
    commit(types.default.SET_ACCOUNT_UI_FLAG, { isCheckoutInProcess: true });
    try {
      const response = await EnterpriseAccountAPI.checkout();
      window.location = response.data.redirect_url;
    } catch (error) {
      throwErrorMessage(error);
    } finally {
      commit(types.default.SET_ACCOUNT_UI_FLAG, { isCheckoutInProcess: false });
    }
  },

  subscription: async ({ commit }) => {
    commit(types.default.SET_ACCOUNT_UI_FLAG, { isCheckoutInProcess: true });
    try {
      await EnterpriseAccountAPI.subscription();
    } catch (error) {
      throwErrorMessage(error);
    } finally {
      commit(types.default.SET_ACCOUNT_UI_FLAG, { isCheckoutInProcess: false });
    }
  },

  limits: async ({ commit }) => {
    try {
      const response = await EnterpriseAccountAPI.getLimits();
      commit(types.default.SET_ACCOUNT_LIMITS, response.data);
    } catch (error) {
      // silent error
    }
  },

  getPermissionsByUser: async ({ commit }, userId) => {
    try {
      commit(types.default.SET_ACCOUNT_UI_FLAG, { isFetching: true });
      const response = await AccountAPI.getPermissionsByUser(userId);
      commit(
        types.default.SET_ACCOUNT_PERMISSIONS,
        response.data.permissions || []
      );
    } catch (error) {
      commit(types.default.SET_ACCOUNT_UI_FLAG, { isFetching: false });
      throwErrorMessage(error);
      throw error;
    } finally {
      commit(types.default.SET_ACCOUNT_UI_FLAG, { isFetching: false });
    }
  },

  updatePermissionsByUser: async ({ commit }, { userId, permissions }) => {
    try {
      commit(types.default.SET_ACCOUNT_UI_FLAG, { isUpdating: true });
      await AccountAPI.updatePermissionsByUser(userId, permissions);
    } catch (error) {
      commit(types.default.SET_ACCOUNT_UI_FLAG, { isUpdating: false });
      throwErrorMessage(error);
      throw error;
    } finally {
      commit(types.default.SET_ACCOUNT_UI_FLAG, { isUpdating: false });
    }
  },

  updatePermission: async ({ commit }, { permission }) => {
    commit(types.default.UPDATE_ACCOUNT_PERMISSION, permission);
  },
};

export const mutations = {
  [types.default.SET_ACCOUNT_UI_FLAG]($state, data) {
    $state.uiFlags = {
      ...$state.uiFlags,
      ...data,
    };
  },
  [types.default.UPDATE_ACCOUNT_PERMISSION]($state, permission) {
    $state.permissions[permission.id] = permission.status;
  },
  [types.default.SET_ACCOUNT_PERMISSIONS]($state, data) {
    $state.permissions = data;
  },
  [types.default.ADD_ACCOUNT]: MutationHelpers.setSingleRecord,
  [types.default.EDIT_ACCOUNT]: MutationHelpers.update,
  [types.default.SET_ACCOUNT_LIMITS]: MutationHelpers.updateAttributes,
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};
