<template>
  <div class="mx-0 flex flex-wrap">
    <div class="flex-shrink-0 flex-grow-0 w-[65%]">
      <form class="mx-0 flex flex-wrap" @submit.prevent="handleSubmit">
        <woot-input
          v-model.trim="title"
          :class="{ error: $v.title.$error }"
          class="w-full"
          :label="$t('TEAMS_SETTINGS.FORM.NAME.LABEL')"
          :placeholder="$t('TEAMS_SETTINGS.FORM.NAME.PLACEHOLDER')"
          @input="$v.title.$touch"
        />

        <woot-input
          v-model.trim="description"
          :class="{ error: $v.description.$error }"
          class="w-full"
          :label="$t('TEAMS_SETTINGS.FORM.DESCRIPTION.LABEL')"
          :placeholder="$t('TEAMS_SETTINGS.FORM.DESCRIPTION.PLACEHOLDER')"
          @input="$v.description.$touch"
        />

        <!-- hardcoded team level for now -->
        <woot-select
          class-name="w-full"
          label="Nível da equipe"
          :options="levelOptions"
          :value="level"
          @change="onLevelChange"
        />

        <div class="w-full">
          <input v-model="allowAutoAssign" type="checkbox" :value="true" />
          <label for="conversation_creation">
            {{ $t('TEAMS_SETTINGS.FORM.AUTO_ASSIGN.LABEL') }}
          </label>
        </div>
        <div class="flex flex-row justify-end gap-2 py-2 px-0 w-full">
          <div class="w-full">
            <woot-submit-button
              :disabled="$v.title.$invalid || submitInProgress"
              :button-text="submitButtonText"
              :loading="submitInProgress"
            />
          </div>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
import WootSubmitButton from '../../../../components/buttons/FormSubmitButton.vue';
import validations from './helpers/validations';

export default {
  components: {
    WootSubmitButton,
  },

  props: {
    onSubmit: {
      type: Function,
      default: () => {},
    },
    submitInProgress: {
      type: Boolean,
      default: false,
    },
    formData: {
      type: Object,
      default: () => {},
    },
    submitButtonText: {
      type: String,
      default: '',
    },
  },
  data() {
    const formData = this.formData || {};
    const {
      description = '',
      level = '',
      name: title = '',
      allow_auto_assign: allowAutoAssign = true,
    } = formData;

    const levelOptions = [
      { id: 'level_1', value: 'Nível 1' },
      { id: 'level_2', value: 'Nível 2' },
      { id: 'level_3', value: 'Nível 3' },
      { id: 'level_4', value: 'Nível 4' },
    ];

    return {
      level,
      description,
      title,
      allowAutoAssign,
      levelOptions,
    };
  },
  validations,
  methods: {
    onLevelChange(value) {
      this.level = value;
    },
    handleSubmit() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        return;
      }
      this.onSubmit({
        description: this.description,
        name: this.title,
        allow_auto_assign: this.allowAutoAssign,
        level: this.level,
      });
    },
  },
};
</script>
