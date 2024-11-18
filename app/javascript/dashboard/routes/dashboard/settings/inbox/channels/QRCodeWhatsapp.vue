<template>
  <form class="mx-0 flex flex-wrap" @submit.prevent="createChannel()">
    <div class="w-[65%] flex-shrink-0 flex-grow-0 max-w-[65%]">
      <label :class="{ error: $v.inboxName.$error }">
        {{ $t('INBOX_MGMT.ADD.WHATSAPP.INBOX_NAME.LABEL') }}
        <input
          v-model.trim="inboxName"
          type="text"
          :placeholder="$t('INBOX_MGMT.ADD.WHATSAPP.INBOX_NAME.PLACEHOLDER')"
          @blur="$v.inboxName.$touch"
        />
        <span v-if="$v.inboxName.$error" class="message">
          {{ $t('INBOX_MGMT.ADD.WHATSAPP.INBOX_NAME.ERROR') }}
        </span>
      </label>
    </div>

    <div class="w-[65%] flex-shrink-0 flex-grow-0 max-w-[65%]">
      <label :class="{ error: $v.url.$error }">
        <span>
          {{ $t('INBOX_MGMT.ADD.QRCODE.URL.LABEL') }}
        </span>
        <input
          v-model.trim="url"
          type="text"
          :placeholder="$t('INBOX_MGMT.ADD.QRCODE.URL.PLACEHOLDER')"
          @blur="$v.url.$touch"
        />
        <span v-if="$v.url.$error" class="message">
          {{ $t('INBOX_MGMT.ADD.QRCODE.URL.ERROR') }}
        </span>
      </label>
    </div>

    <div class="w-[65%] flex-shrink-0 flex-grow-0 max-w-[65%]">
      <label :class="{ error: $v.apiKey.$error }">
        <span>
          {{ $t('INBOX_MGMT.ADD.WHATSAPP.API_KEY.LABEL') }}
        </span>
        <input
          v-model.trim="apiKey"
          type="text"
          :placeholder="$t('INBOX_MGMT.ADD.WHATSAPP.API_KEY.PLACEHOLDER')"
          @blur="$v.apiKey.$touch"
        />
        <span v-if="$v.apiKey.$error" class="message">
          {{ $t('INBOX_MGMT.ADD.WHATSAPP.API_KEY.ERROR') }}
        </span>
      </label>
    </div>

    <div class="medium-8 columns messagingServiceHelptext">
      <label for="useReopenConversation">
        <input
          id="useReopenConversation"
          v-model="useReopenConversation"
          type="checkbox"
          class="checkbox"
        />
        {{ $t('INBOX_MGMT.ADD.QRCODE.USE_REOPEN_CONVERSATION') }}
      </label>
    </div>

    <div class="medium-8 columns messagingServiceHelptext">
      <label for="useConversationPending">
        <input
          id="useConversationPending"
          v-model="useConversationPending"
          type="checkbox"
          class="checkbox"
        />
        {{ $t('INBOX_MGMT.ADD.QRCODE.USE_CONVERSATION_PENDING') }}
      </label>
    </div>

    <div class="w-full">
      <woot-submit-button
        :loading="uiFlags.isCreating"
        :button-text="$t('INBOX_MGMT.ADD.WHATSAPP.SUBMIT_BUTTON')"
      />
    </div>
  </form>
</template>

<script>
import { mapGetters } from 'vuex';
import alertMixin from 'shared/mixins/alertMixin';
import { required } from 'vuelidate/lib/validators';
import router from '../../../../index';

export default {
  mixins: [alertMixin],
  data() {
    return {
      inboxName: '',
      url: 'evolutionapi2',
      apiKey: '',
      useReopenConversation: false,
      useConversationPending: false,
    };
  },
  computed: {
    ...mapGetters({
      uiFlags: 'inboxes/getUIFlags',
      currentUser: 'getCurrentUser',
    }),
  },
  validations: {
    inboxName: { required },
    url: { required },
    apiKey: { required },
  },
  mounted() {
    if (this.currentUser) {
      this.apiKey = this.currentUser.access_token;
    }
  },
  methods: {
    async createChannel() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        return;
      }

      try {
        await this.$store.dispatch('inboxes/createChannel', {
          name: this.inboxName,
          channel: {
            type: 'whatsapp',
            provider: 'qrcode',
            provider_config: {
              url: this.url,
              chatwoot_reopen_conversation: this.useReopenConversation,
              chatwoot_conversation_pending: this.useConversationPending,
              apiKey: this.apiKey,
            },
          },
        });

        router.replace({
          name: 'inbox_dashboard',
          params: {},
        });
      } catch (error) {
        if (error.message) this.showAlert(error.message);
        else
          this.showAlert(this.$t('INBOX_MGMT.ADD.WHATSAPP.API.ERROR_MESSAGE'));
      }
    },
  },
};
</script>
<style lang="scss" scoped>
.messagingServiceHelptext {
  margin-top: -10px;
  margin-bottom: 15px;

  .checkbox {
    margin: 0px 4px;
  }
}
</style>
