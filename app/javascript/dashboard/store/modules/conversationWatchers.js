import Vue from 'vue';
import types from '../mutation-types';
import { throwErrorMessage } from 'dashboard/store/utils/api';

import ConversationInboxApi from '../../api/inbox/conversation';

const state = {
  records: {},
  whatsappParticipants: [],
  flags: {
    isWhatsAppEnabled: false,
  },
  uiFlags: {
    isFetching: false,
    isUpdating: false,
  },
};

export const getters = {
  getUIFlags($state) {
    return $state.uiFlags;
  },
  getByConversationId: _state => conversationId => {
    return _state.records[conversationId];
  },
  isWhatsAppEnabled(_state) {
    return _state.flags.isWhatsAppEnabled;
  },
  getWhatsAppParticipants(_state) {
    return _state.whatsappParticipants;
  },
};

export const actions = {
  show: async ({ commit }, { conversationId }) => {
    commit(types.SET_CONVERSATION_PARTICIPANTS_UI_FLAG, {
      isFetching: true,
    });

    try {
      const response =
        await ConversationInboxApi.fetchParticipants(conversationId);
      commit(types.SET_CONVERSATION_PARTICIPANTS, {
        conversationId,
        data: response.data.payload,
        isWhatsAppEnabled: response.data.meta.whatsapp,
      });
    } catch (error) {
      throwErrorMessage(error);
    } finally {
      commit(types.SET_CONVERSATION_PARTICIPANTS_UI_FLAG, {
        isFetching: false,
      });
    }
  },

  update: async ({ commit }, { conversationId, userIds }) => {
    commit(types.SET_CONVERSATION_PARTICIPANTS_UI_FLAG, {
      isUpdating: true,
    });

    try {
      const response = await ConversationInboxApi.updateParticipants({
        conversationId,
        userIds,
      });
      commit(types.SET_CONVERSATION_PARTICIPANTS, {
        conversationId,
        data: response.data,
      });
    } catch (error) {
      throwErrorMessage(error);
    } finally {
      commit(types.SET_CONVERSATION_PARTICIPANTS_UI_FLAG, {
        isUpdating: false,
      });
    }
  },

  getParticipantsWhatsApp: async ({ commit }, { conversationId }) => {
    commit(types.SET_CONVERSATION_PARTICIPANTS_WHATSAPP_UI_FLAG, {
      isFetching: true,
    });
    try {
      const response =
        await ConversationInboxApi.getWhatsAppParticipants(conversationId);
      commit(types.SET_CONVERSATION_PARTICIPANTS_WHATSAPP, response.data);
    } catch (error) {
      throwErrorMessage(error);
    } finally {
      commit(types.SET_CONVERSATION_PARTICIPANTS_WHATSAPP_UI_FLAG, {
        isFetching: false,
      });
    }
  },
};

export const mutations = {
  [types.SET_CONVERSATION_PARTICIPANTS_UI_FLAG]($state, data) {
    $state.uiFlags = {
      ...$state.uiFlags,
      ...data,
    };
  },
  [types.SET_CONVERSATION_PARTICIPANTS_WHATSAPP_UI_FLAG]($state, data) {
    $state.uiFlags = {
      ...$state.uiFlags,
      ...data,
    };
  },
  [types.SET_CONVERSATION_PARTICIPANTS_WHATSAPP]($state, { data }) {
    Vue.set($state, 'whatsappParticipants', data);
  },
  [types.SET_CONVERSATION_PARTICIPANTS](
    $state,
    { data, conversationId, isWhatsAppEnabled }
  ) {
    if (isWhatsAppEnabled) {
      Vue.set($state.flags, 'isWhatsAppEnabled', isWhatsAppEnabled);
    }

    Vue.set($state.records, conversationId, data);
  },
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};
