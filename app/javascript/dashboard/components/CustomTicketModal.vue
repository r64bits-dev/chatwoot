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
      <!-- agent selection -->
      <div class="columns mt-3">
        <label class="text-sm font-medium leading-5 text-slate-900 dark:text-white">
          {{ $t('CONVERSATION.CUSTOM_TICKET.AGENT_LABEL') }}
        </label>
        <multiselect
          v-model="selectedAgent"
          :options="agents"
          track-by="id"
          label="name"
          :placeholder="$t('CONVERSATION.CUSTOM_TICKET.AGENT_PLACEHOLDER')"
          :select-label="''"
          :deselect-label="''"
          :allow-empty="true"
          class="mt-2"
        >
          <template v-slot:singleLabel="{ option }">
            <span>{{ option.name }}</span>
          </template>
          <template v-slot:option="{ option }">
            <span>{{ option.name }}</span>
          </template>
        </multiselect>
      </div>
      <!-- notification radio button -->
      <div class="columns mt-3">
        <label class="text-sm font-medium leading-5 text-slate-900 dark:text-white">
          {{ $t('CONVERSATION.CUSTOM_TICKET.NOTIFY_MESSAGE') }}
        </label>
        <div class="flex gap-4 mt-2">
          <label class="flex items-center">
            <input
              v-model="sendNotification"
              type="radio"
              value="yes"
              class="mr-2"
            />
            {{ $t('CONVERSATION.CUSTOM_TICKET.YES') }}
          </label>
          <label class="flex items-center">
            <input
              v-model="sendNotification"
              type="radio"
              value="no"
              class="mr-2"
            />
            {{ $t('CONVERSATION.CUSTOM_TICKET.NO') }}
          </label>
        </div>
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
import Multiselect from 'vue-multiselect';
import CustomAttributes from 'dashboard/routes/dashboard/conversation/customAttributes/CustomAttributes.vue';

export default {
  name: 'CustomTicketModal',
  components: {
    CustomAttributes,
    Multiselect,
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
      sendNotification: 'yes', // "SIM" como padrão
      selectedAgent: null, // Agente selecionado
    };
  },
  computed: {
    ...mapGetters({
      conversationUiFlags: 'conversationLabels/getUIFlags',
      ticketUIFlags: 'tickets/getUIFlags',
      getAttributesByModel: 'attributes/getAttributesByModel',
      agents: 'agents/getAgents', // Lista de agentes
    }),
  },
  mounted() {
    // Carregar os agentes
    this.$store.dispatch('agents/get');
    
    // Carregar atributos personalizados
    const attributes = this.getAttributesByModel('ticket_attribute');
    const data = attributes.reduce((acc, attribute) => {
      acc[attribute.attribute_key] = attribute.default_value;
      return acc;
    }, {});
    this.$store.commit('tickets/SET_TICKET_CUSTOM_ATTRIBUTES', data);
  },
  methods: {
    resetForm() {
      this.title = '';
      this.description = '';
      this.priority = '';
      this.customAttributes = {};
      this.sendNotification = 'yes';
      this.selectedAgent = null;
    },
    onClose() {
      this.resetForm();
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
      // Log para depuração
      console.log('Selected Agent:', this.selectedAgent);
      console.log('Agent ID:', this.selectedAgent ? this.selectedAgent.id : null);

      const payload = {
        title: this.title,
        description: this.description,
        conversationId: this.conversationId,
        customAttributes: this.customAttributes,
        sendNotification: this.sendNotification === 'yes',
        agentId: this.selectedAgent ? this.selectedAgent.id : null, // Garantir que agentId seja incluído
      };

      // Log do payload antes de enviar
      console.log('Payload enviado:', payload);
      
      this.$store
        .dispatch('tickets/create', payload)
        .then(() => {
          this.showAlert(this.$t('CONVERSATION.CUSTOM_TICKET.SUCCESS_MESSAGE'));
          this.resetForm();
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

<style src="vue-multiselect/dist/vue-multiselect.min.css"></style>
<style scoped>
.columns {
  margin-bottom: 1rem;
}
</style>