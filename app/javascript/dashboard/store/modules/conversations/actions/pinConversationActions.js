import { throwErrorMessage } from 'dashboard/store/utils/api';
import ConversationApi from '../../../../api/inbox/conversation';
import mutationTypes from '../../../mutation-types';

export default {
  pinConversation: async ({ commit }, { id }) => {
    try {
      const {
        data: { pinned_by },
      } = await ConversationApi.pinConversation({ id });

      commit(mutationTypes.UPDATE_CONVERSATIONS_ORDER, { id, pinned_by });
    } catch (error) {
      throwErrorMessage(error);
    }
  },

  unpinConversation: async ({ commit }, { id }) => {
    try {
      const {
        data: { pinned_by },
      } = await ConversationApi.unpinConversation({ id });

      commit(mutationTypes.UPDATE_CONVERSATIONS_ORDER, { id, pinned_by });
    } catch (error) {
      throwErrorMessage(error);
    }
  },
};
