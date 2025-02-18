<!-- eslint-disable vue/no-mutating-props -->
<template>
  <woot-modal :show.sync="show" :on-close="onCancel">
    <div class="h-auto overflow-auto flex flex-col">
      <woot-modal-header
        :header-title="$t('SEARCH.CREATE_CONVERSATION.TITLE')"
        :header-content="$t('SEARCH.CREATE_CONVERSATION.DESC')"
      />

      <!-- form -->
      <form class="flex flex-col w-full" @submit.prevent="onSubmit">
        <div class="flex flex-col justify-center items-center gap-2 w-full">
          <!-- user data -->
          <div class="user-data w-full">
            <h4 class="text-lg font-semibold mb-2">
              {{ $t('SEARCH.CREATE_CONVERSATION.CONTACT_TITLE') }}
            </h4>
            <div class="w-full flex gap-2">
              <woot-input
                v-model.trim="contactName"
                name="name"
                class="w-full"
                :label="$t('SEARCH.CREATE_CONVERSATION.FORM.NAME.LABEL')"
                :placeholder="
                  $t('SEARCH.CREATE_CONVERSATION.FORM.NAME.PLACEHOLDER')
                "
                @input="onSearchQueryChange"
              >
                <template v-if="searchResults.length" #after>
                  <div class="search-dropdown">
                    <ul>
                      <li
                        v-for="contact in searchResults"
                        :key="contact.id"
                        @click="selectContact(contact)"
                      >
                        <div>{{ contact.name }}</div>
                        <small>{{ contact.email }}</small>
                        <small>{{ contact.phone_number }}</small>
                      </li>
                    </ul>
                  </div>
                </template>
              </woot-input>
              <woot-input
                v-model.trim="conversationEmail"
                name="email"
                class="w-1/2"
                :label="$t('SEARCH.CREATE_CONVERSATION.FORM.EMAIL.LABEL')"
                :placeholder="
                  $t('SEARCH.CREATE_CONVERSATION.FORM.EMAIL.PLACEHOLDER')
                "
                @blur="$v.conversationEmail.$touch"
              />
            </div>
            <div class="w-full">
              <label :class="{ error: isPhoneNumberNotValid }">
                {{ $t('CONTACT_FORM.FORM.PHONE_NUMBER.LABEL') }}
                <woot-phone-input
                  v-model="phoneNumber"
                  :value="phoneNumber"
                  :error="isPhoneNumberNotValid"
                  :placeholder="
                    $t('CONTACT_FORM.FORM.PHONE_NUMBER.PLACEHOLDER')
                  "
                  @input="onPhoneNumberInputChange"
                  @blur="handlePhoneBlur"
                  @setCode="setPhoneCode"
                />
                <span v-if="isPhoneNumberNotValid" class="message">
                  {{ phoneNumberError }}
                </span>
              </label>

              <!-- Div de mensagem de ajuda mostrada somente quando em foco -->
              <div
                v-if="isPhoneInputFocused"
                class="callout small warning text-sm dark:bg-yellow-200/20 dark:text-yellow-400"
              >
                {{ $t('CONTACT_FORM.FORM.PHONE_NUMBER.HELP') }}
              </div>
            </div>
          </div>

          <!-- select inbox -->
          <div class="w-full">
            <label>
              {{ $t('SEARCH.CREATE_CONVERSATION.FORM.INBOX.LABEL') }}
            </label>
            <div
              class="multiselect-wrap--small"
              :class="{ 'has-multi-select-error': $v.inbox.$error }"
            >
              <multiselect
                v-model="inbox"
                track-by="id"
                label="name"
                :placeholder="$t('FORMS.MULTISELECT.SELECT')"
                selected-label=""
                select-label=""
                deselect-label=""
                :max-height="160"
                :close-on-select="true"
                :options="inboxes"
              >
                <template slot="singleLabel" slot-scope="{ option }">
                  <inbox-dropdown-item
                    v-if="option.name"
                    :name="option.name"
                    :inbox-identifier="option.phone_number"
                    :channel-type="option.channel_type"
                  />
                  <span v-else>
                    {{
                      $t('SEARCH.CREATE_CONVERSATION.FORM.INBOX.PLACEHOLDER')
                    }}
                  </span>
                </template>
                <template slot="option" slot-scope="{ option }">
                  <inbox-dropdown-item
                    :name="option.name"
                    :inbox-identifier="option.phone_number"
                    :channel-type="option.channel_type"
                  />
                </template>
              </multiselect>
            </div>
            <label :class="{ error: $v.inbox.$error }">
              <span v-if="$v.inbox.$error" class="message">
                {{ $t('SEARCH.CREATE_CONVERSATION.FORM.INBOX.ERROR') }}
              </span>
            </label>
          </div>

          <!-- input message -->
          <div class="w-full">
            <h4 class="text-lg font-semibold mb-2">
              {{ $t('SEARCH.CREATE_CONVERSATION.MESSAGE_TITLE') }}
            </h4>
            <text-area
              v-model.trim="conversationMessage.content"
              class="w-full mb-2"
              :label="$t('SEARCH.CREATE_CONVERSATION.FORM.MESSAGE.LABEL')"
              :placeholder="
                $t('SEARCH.CREATE_CONVERSATION.FORM.MESSAGE.PLACEHOLDER')
              "
              @input="onMessageInputChange"
            />
          </div>
        </div>
        <div class="w-full flex items-center gap-2 mb-4">
          <woot-toggle
            v-model="assignCurrentUser"
            :label="
              $t('SEARCH.CREATE_CONVERSATION.FORM.ASSIGN_CURRENT_USER.DESC')
            "
          />
        </div>
      </form>

      <div class="flex flex-row justify-end gap-2 p-2 w-full">
        <button class="button clear" @click.prevent="onCancel">
          {{ $t('SEARCH.CREATE_CONVERSATION.FORM.CANCEL') }}
        </button>
        <woot-button
          :is-disabled="!isFormValid"
          type="submit"
          :is-loading="isCreating"
          @click="onSubmit"
        >
          {{ $t('SEARCH.CREATE_CONVERSATION.FORM.SUBMIT') }}
        </woot-button>
      </div>
    </div>
  </woot-modal>
</template>

<script>
import { mapGetters } from 'vuex';
import Multiselect from 'vue-multiselect';
import InboxDropdownItem from 'dashboard/components/widgets/InboxDropdownItem.vue';
import TextArea from 'dashboard/components/widgets/forms/TextArea.vue';
import ContactsAPI from 'dashboard/api/contacts';

import alertMixin from 'shared/mixins/alertMixin';

import { required } from 'vuelidate/lib/validators';
import { isPhoneNumberValid } from 'shared/helpers/Validators';
import { sanitizePhoneNumber } from 'shared/helpers/sanitizeData';

export default {
  name: 'ModalCreateNewConversation',
  components: { Multiselect, InboxDropdownItem, TextArea },
  mixins: [alertMixin],
  props: {
    show: {
      type: Boolean,
      default: false,
    },
    selectedInbox: {
      type: [String, Number],
      default: null,
    },
  },
  data() {
    return {
      contactName: '',
      conversationEmail: '',
      conversationMessage: {
        type: 'input',
        content: '',
      },
      inbox: {
        id: this.selectedInbox,
      },
      phoneNumber: '',
      isCreating: false,
      isPhoneInputFocused: false,
      activeDialCode: '',
      searchResults: [],
      searchTimeout: null,
      assignCurrentUser: true,
    };
  },
  validations: {
    contactName: { required },
    conversationEmail: {},
    conversationMessage: { required },
    phoneNumber: { required },
    inbox: { required },
  },
  computed: {
    ...mapGetters({
      currentUser: 'getCurrentUser',
      currentAccount: 'getCurrentAccount',
      inboxes: 'inboxes/getInboxes',
    }),
    isFormValid() {
      return !this.$v.$invalid;
    },
    isPhoneNumberNotValid() {
      if (this.phoneNumber !== '') {
        return (
          !isPhoneNumberValid(this.phoneNumber, this.activeDialCode) ||
          (this.phoneNumber !== '' ? this.activeDialCode === '' : false)
        );
      }
      return false;
    },
    phoneNumberError() {
      if (this.phoneNumber === '')
        return this.$t('CONTACT_FORM.FORM.PHONE_NUMBER.ERROR');

      return '';
    },
  },
  watch: {
    immediate: true,
    selectedInbox(newValue) {
      this.setSelectedInbox(newValue);
    },
    inboxes() {
      if (this.selectedInbox) {
        this.setSelectedInbox(this.selectedInbox);
      }
    },
  },
  methods: {
    async onSubmit() {
      this.$v.$touch();
      if (!this.isFormValid) {
        this.showAlert('Por favor preencha todos os campos');
        return;
      }
      this.isCreating = true;
      try {
        const payload = {
          contact: {
            name: this.contactName,
            phone: this.phoneNumber,
            email: this.conversationEmail,
          },
          message: this.conversationMessage,
          inboxId: this.inbox.id,
          assignCurrentUser: this.assignCurrentUser,
        };

        const response = await ContactsAPI.createContactAndMessage(payload);
        if (response.status === 200) {
          this.showAlert(
            this.$t('SEARCH.CREATE_CONVERSATION.API.SUCCESS_MESSAGE')
          );
          this.onCancel();
          this.$router.push({
            name: 'inbox_conversation',
            params: { conversation_id: response.data.payload.conversation.id },
          });
        }
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(error);
        if (error.response.status === 422) {
          this.showAlert(this.$t('CONTACT_FORM.FORM.EMAIL_ADDRESS.DUPLICATE'));
        } else {
          this.showAlert(
            this.$t('SEARCH.CREATE_CONVERSATION.API.ERROR_MESSAGE')
          );
        }
      } finally {
        this.isCreating = false;
      }
    },
    onPhoneNumberInputChange(value, code) {
      this.activeDialCode = code;
      if (value) {
        this.isPhoneInputFocused = true;
      }
    },
    handlePhoneBlur() {
      this.isPhoneInputFocused = false;
      this.$v.phoneNumber.$touch();
    },
    setPhoneCode(code) {
      if (this.phoneNumber !== '' && this.parsePhoneNumber) {
        const dialCode = this.parsePhoneNumber.countryCallingCode;
        if (dialCode === code) {
          return;
        }
        this.activeDialCode = `+${dialCode}`;
        const newPhoneNumber = this.phoneNumber.replace(
          `+${dialCode}`,
          `${code}`
        );
        this.phoneNumber = newPhoneNumber;
      } else {
        this.activeDialCode = code;
      }
    },
    onCancel() {
      this.$emit('cancel');
    },
    onMessageInputChange(value) {
      this.conversationMessage.content = value;
    },
    onSearchQueryChange(query) {
      if (this.searchTimeout) {
        clearTimeout(this.searchTimeout);
      }
      this.searchTimeout = setTimeout(() => {
        this.fetchContacts(query);
      }, 300);
    },
    async fetchContacts(query) {
      if (!query) {
        this.searchResults = [];
        return;
      }
      try {
        const response = await ContactsAPI.search(query);
        this.searchResults = response.data.payload;
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error('Erro ao buscar contatos:', error);
        this.searchResults = [];
      }
    },
    selectContact(contact) {
      this.contactName = contact.name;
      this.conversationEmail = contact.email;
      this.phoneNumber = sanitizePhoneNumber(contact.phone_number);
      this.searchResults = [];
      this.$v.contactName.$touch();
      this.$v.conversationEmail.$touch();
      this.$v.phoneNumber.$touch();
    },
    setSelectedInbox(inboxId) {
      const selectedInbox = this.inboxes.find(
        inbox => inbox.id === Number(inboxId)
      );

      if (selectedInbox) {
        this.inbox = selectedInbox;
      } else {
        this.inboxId = null;
        // eslint-disable-next-line no-console
        console.warn(`Inbox com ID ${inboxId} não encontrado.`);
      }
    },
  },
};
</script>

<style scoped lang="scss">
.search-dropdown {
  position: absolute;
  background: white;
  border: 1px solid #ddd;
  max-height: 200px;
  overflow-y: auto;
  width: 100%;
  z-index: 1000;
}
.search-dropdown ul {
  list-style: none;
  padding: 0;
  margin: 0;
}
.search-dropdown li {
  padding: 10px;
  cursor: pointer;
  border-bottom: 1px solid #f0f0f0;
}
.search-dropdown li:hover {
  background: #f9f9f9;
}

.button:disabled {
  cursor: not-allowed;
  opacity: 0.6;
}
</style>
