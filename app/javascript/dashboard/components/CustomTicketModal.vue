<template>
  <div class="flex flex-col">
    <woot-modal-header
      :header-title="$t('CONVERSATION.CUSTOM_TICKET.TITLE')"
      :header-content="$t('CONVERSATION.CUSTOM_TICKET.SUBTITLE')"
    />
    <div class="p-8 w-full">
      <woot-input
        v-model.trim="title"
        class="columns"
        :label="$t('CONVERSATION.CUSTOM_TICKET.NAME')"
        :placeholder="$t('CONVERSATION.CUSTOM_TICKET.NAME_PLACEHOLDER')"
        @blur="validateText"
      />
      <!-- description -->
      <woot-text-area
        v-model.trim="description"
        class="columns"
        rows="4"
        help-text="Forneça uma descrição detalhada."
        :label="$t('CONVERSATION.CUSTOM_TICKET.DESCRIPTION')"
        :placeholder="$t('CONVERSATION.CUSTOM_TICKET.DESCRIPTION_PLACEHOLDER')"
        @blur="validateText"
      />

      <!-- custom attributes -->
      <div class="w-full flex-shrink-0 flex-grow-0">
        <p class="text-sm font-medium leading-6 text-slate-900 dark:text-white">
          <!-- {{ $t('CONVERSATION.CUSTOM_TICKET.CUSTOM_ATTRIBUTES') }} -->
          Atributos Personalizados
        </p>
        <custom-attributes
          attribute-type="ticket_attribute"
          class="w-full"
          @update-contact-custom-attributes="updateContactCustomAttributes"
        />
      </div>
      <div class="flex flex-row justify-end gap-2 py-2 px-0 w-full">
        <woot-button variant="clear" @click.prevent="onClose">
          {{ $t('CONVERSATION.CUSTOM_TICKET.CANCEL') }}
        </woot-button>
        <woot-button :is-loading="ticketUIFlags.isCreating" @click="onSubmit">
          {{ $t('CONVERSATION.CUSTOM_TICKET.CREATE') }}
        </woot-button>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import adminMixin from 'dashboard/mixins/isAdmin';
import conversationLabelMixin from 'dashboard/mixins/conversation/labelMixin';
import eventListenerMixins from 'shared/mixins/eventListenerMixins';
import alertMixin from 'shared/mixins/alertMixin';
import CustomAttributes from 'dashboard/routes/dashboard/conversation/customAttributes/CustomAttributes.vue';

export default {
  name: 'CustomTicketModal',
  components: {
    CustomAttributes,
  },
  mixins: [adminMixin, conversationLabelMixin, eventListenerMixins, alertMixin],
  props: {
    conversationId: {
      type: Number,
      required: true,
    },
  },
  data() {
    return {
      title: '',
      description: '',
      priority: '',
      customAttributes: {},
    };
  },
  computed: {
    ...mapGetters({
      conversationUiFlags: 'conversationLabels/getUIFlags',
      ticketUIFlags: 'tickets/getUIFlags',
      getAttributesByModel: 'attributes/getAttributesByModel',
    }),
  },
  mounted() {
    const attributes = this.getAttributesByModel('ticket_attribute');
    const data = attributes.reduce((acc, attribute) => {
      acc[attribute.attribute_key] = attribute.default_value;
      return acc;
    }, {});
    this.$store.commit('tickets/SET_TICKET_CUSTOM_ATTRIBUTES', data);
  },
  methods: {
    onClose() {
      this.$emit('close');
    },
    updateContactCustomAttributes(values) {
      this.customAttributes = { ...this.customAttributes, ...values };
      this.$store.commit(
        'tickets/SET_TICKET_CUSTOM_ATTRIBUTES',
        this.customAttributes
      );
    },
    onSubmit() {
      this.$store
        .dispatch('tickets/create', {
          title: this.title,
          description: this.description,
          conversationId: this.conversationId,
          customAttributes: this.customAttributes,
        })
        .then(() => {
          this.showAlert(this.$t('CONVERSATION.CUSTOM_TICKET.SUCCESS_MESSAGE'));
          this.onClose();
        })
        .catch(() => {
          this.showAlert(this.$t('CONVERSATION.CUSTOM_TICKET.ERROR_MESSAGE'));
        });
    },
    validateText() {
      if (this.title.$error || this.description.$error) {
        this.title.$touch();
        this.description.$touch();
      }
    },
  },
};
</script>
