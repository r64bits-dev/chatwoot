<template>
  <div class="custom-attributes--panel">
    <custom-attribute
      v-for="attribute in filteredAttributes"
      :key="attribute.id"
      :attribute-key="attribute.attribute_key"
      :attribute-type="attribute.attribute_display_type"
      :values="attribute.attribute_values"
      :label="attribute.attribute_display_name"
      :icon="attribute.icon"
      emoji=""
      :value="attribute.value"
      :show-actions="true"
      :show-delete-button="attributeType !== 'ticket_attribute'"
      :class="attributeClass"
      @update="onUpdate"
      @delete="onDelete"
      @copy="onCopy"
    />
  </div>
</template>

<script>
import CustomAttribute from 'dashboard/components/CustomAttribute.vue';
import alertMixin from 'shared/mixins/alertMixin';
import attributeMixin from 'dashboard/mixins/attributeMixin';
import { copyTextToClipboard } from 'shared/helpers/clipboard';

export default {
  components: {
    CustomAttribute,
  },
  mixins: [alertMixin, attributeMixin],
  props: {
    attributeType: {
      type: String,
      default: 'conversation_attribute',
    },
    attributeClass: {
      type: String,
      default: '',
    },
    contactId: { type: Number, default: null },
  },
  methods: {
    async onUpdate(key, value) {
      const updatedAttributes = { ...this.customAttributes, [key]: value };
      try {
        if (this.attributeType === 'conversation_attribute') {
          await this.$store.dispatch('updateCustomAttributes', {
            conversationId: this.conversationId,
            customAttributes: updatedAttributes,
          });
        }
        if (this.attributeType === 'ticket_attribute') {
          this.$emit('update-contact-custom-attributes', updatedAttributes);
          return;
        }

        this.$store.dispatch('contacts/update', {
          id: this.contactId,
          custom_attributes: updatedAttributes,
        });

        this.showAlert(this.$t('CUSTOM_ATTRIBUTES.FORM.UPDATE.SUCCESS'));
      } catch (error) {
        const errorMessage =
          error?.response?.message ||
          this.$t('CUSTOM_ATTRIBUTES.FORM.UPDATE.ERROR');
        this.showAlert(errorMessage);
      }
    },
    async onDelete(key) {
      try {
        const { [key]: remove, ...updatedAttributes } = this.customAttributes;
        if (this.attributeType === 'conversation_attribute') {
          await this.$store.dispatch('updateCustomAttributes', {
            conversationId: this.conversationId,
            customAttributes: updatedAttributes,
          });
        }
        if (this.attributeType === 'ticket_attribute') {
          await this.$store.dispatch('tickets/update', {
            ticketId: this.ticketId,
            customAttributes: updatedAttributes,
          });
        } else {
          this.$store.dispatch('contacts/deleteCustomAttributes', {
            id: this.contactId,
            customAttributes: [key],
          });
        }

        this.showAlert(this.$t('CUSTOM_ATTRIBUTES.FORM.DELETE.SUCCESS'));
      } catch (error) {
        const errorMessage =
          error?.response?.message ||
          this.$t('CUSTOM_ATTRIBUTES.FORM.DELETE.ERROR');
        this.showAlert(errorMessage);
      }
    },
    async onCopy(attributeValue) {
      await copyTextToClipboard(attributeValue);
      this.showAlert(this.$t('CUSTOM_ATTRIBUTES.COPY_SUCCESSFUL'));
    },
  },
};
</script>
<style scoped lang="scss">
.custom-attributes--panel {
  .conversation--attribute {
    @apply border-slate-50 dark:border-slate-700 border-b border-solid;
  }

  &.odd {
    .conversation--attribute {
      &:nth-child(2n + 1) {
        @apply bg-slate-25 dark:bg-slate-800;
      }
    }
  }

  &.even {
    .conversation--attribute {
      &:nth-child(2n) {
        @apply bg-slate-25 dark:bg-slate-800;
      }
    }
  }
}
</style>
