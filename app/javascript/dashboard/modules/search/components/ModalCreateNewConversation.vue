<!-- eslint-disable vue/no-mutating-props -->
<template>
  <woot-modal :show.sync="show" :on-close="onCancel">
    <div class="h-auto overflow-auto flex flex-col">
      <woot-modal-header
        :header-title="$t('SEARCH.CREATE_CONVERSATION.TITLE')"
        :header-content="$t('SEARCH.CREATE_CONVERSATION.DESC')"
      />

      <!-- form -->
      <form class="flex flex-col w-full" @submit.prevent="createConversation">
        <div class="flex flex-col justify-center items-center gap-2 w-full">
          <!-- user data -->
          <div class="user-data w-full">
            <h4 class="text-lg font-semibold mb-2">
              {{ $t('SEARCH.CREATE_CONVERSATION.CONTACT_TITLE') }}
            </h4>
            <div class="w-full flex gap-2">
              <woot-input
                v-model.trim="conversationName"
                class="w-1/2"
                :label="$t('SEARCH.CREATE_CONVERSATION.FORM.NAME.LABEL')"
                :placeholder="
                  $t('SEARCH.CREATE_CONVERSATION.FORM.NAME.PLACEHOLDER')
                "
                @blur="$v.conversationName.$touch"
              />
              <woot-input
                v-model.trim="conversationEmail"
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
              :class="{ 'has-multi-select-error': $v.selectedInbox.$error }"
            >
              <multiselect
                v-model="selectedInbox"
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
            <label :class="{ error: $v.selectedInbox.$error }">
              <span v-if="$v.selectedInbox.$error" class="message">
                {{ $t('SEARCH.CREATE_CONVERSATION.FORM.INBOX.ERROR') }}
              </span>
            </label>
          </div>

          <!-- input message -->
          <div class="w-full">
            <h4 class="text-lg font-semibold mb-2">
              {{ $t('SEARCH.CREATE_CONVERSATION.FORM.MESSAGE.MESSAGE_TITLE') }}
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
      </form>

      <div class="flex flex-row justify-end gap-2 p-2 w-full">
        <button class="button clear" @click.prevent="onCancel">
          {{ $t('SEARCH.CREATE_CONVERSATION.FORM.CANCEL') }}
        </button>
        <woot-button type="submit" :is-loading="isCreating">
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
import { required } from 'vuelidate/lib/validators';
import { isPhoneNumberValid } from 'shared/helpers/Validators';

export default {
  name: 'ModalCreateNewConversation',
  components: { Multiselect, InboxDropdownItem, TextArea },
  props: {
    show: {
      type: Boolean,
      default: false,
    },
  },
  data() {
    return {
      conversationName: '',
      conversationEmail: '',
      conversationMessage: {
        type: 'input',
        content: '',
      },
      phoneNumber: '',
      selectedInbox: null,
      isCreating: false,
      isPhoneInputFocused: false,
      activeDialCode: '',
    };
  },
  validations: {
    conversationName: { required },
    conversationEmail: { required },
    conversationMessage: { required },
    phoneNumber: { required },
    selectedInbox: { required },
  },
  computed: {
    ...mapGetters({
      currentUser: 'getCurrentUser',
      currentAccount: 'getCurrentAccount',
      inboxes: 'inboxes/getInboxes',
    }),
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
      if (this.activeDialCode === '') {
        return this.$t('CONTACT_FORM.FORM.PHONE_NUMBER.DIAL_CODE_ERROR');
      }
      if (!isPhoneNumberValid(this.phoneNumber, this.activeDialCode)) {
        return this.$t('CONTACT_FORM.FORM.PHONE_NUMBER.ERROR');
      }
      return '';
    },
  },
  methods: {
    async createConversation() {
      this.$v.$touch();
      if (this.$v.$invalid || this.isPhoneNumberNotValid) {
        return;
      }
      this.isCreating = true;
      try {
        await this.$emit('create-conversation', {
          name: this.conversationName,
          email: this.conversationEmail,
          phone_number: this.phoneNumber,
          inboxId: this.selectedInbox.id,
        });
        this.isCreating = false;
        this.onCancel();
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(error);
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
  },
};
</script>
