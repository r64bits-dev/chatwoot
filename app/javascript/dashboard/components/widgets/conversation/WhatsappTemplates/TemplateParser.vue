<template>
  <div class="w-full">
    <textarea
      v-model="processedString"
      rows="4"
      readonly
      class="template-input"
    />
    <div v-if="variables" class="template__variables-container">
      <p class="variables-label">
        {{ $t('WHATSAPP_TEMPLATES.PARSER.VARIABLES_LABEL') }}
      </p>
      <div
        v-for="(variable, key) in processedParams.variables"
        :key="key"
        class="template__variable-item"
      >
        <span class="variable-label">
          {{ key }}
        </span>
        <woot-input
          v-model="processedParams.variables[key]"
          type="text"
          class="variable-input"
          :styles="{ marginBottom: 0 }"
        />
      </div>
      <p v-if="$v.$dirty && $v.$invalid" class="error">
        {{ $t('WHATSAPP_TEMPLATES.PARSER.FORM_ERROR_MESSAGE') }}
      </p>
    </div>
    <div v-if="buttons.length" class="template__buttons-container">
      <p class="variables-label">
        {{ $t('WHATSAPP_TEMPLATES.PARSER.BUTTONS_LABEL') }}
      </p>
      <div
        v-for="(button, index) in buttons"
        :key="index"
        class="template__button-item"
      >
        <woot-button
          v-tooltip.top-end="
            $t('WHATSAPP_TEMPLATES.PARSER.BUTTON_TOOLTIP', {
              url: button.example,
            })
          "
          :variant="button.type === 'URL' ? 'primary' : 'secondary'"
          size="small"
          >{{ button.text }}
        </woot-button>
        <p v-if="button.type == 'URL'" class="text-xs mt-1">
          Exemplo da url: {{ button.example }}
        </p>
        <div
          v-if="
            button.type === 'URL' &&
            processedParams.buttons &&
            processedParams.buttons[index]
          "
          class="button-variable-inputs"
        >
          <p>{{ $t('WHATSAPP_TEMPLATES.PARSER.BUTTON_VARIABLES_LABEL') }}</p>
          <div
            v-for="(value, key) in processedParams.buttons[index]"
            :key="key"
            class="template__variable-item"
          >
            <span class="variable-label">{{ key }}</span>
            <woot-input
              v-model="processedParams.buttons[index][key]"
              type="text"
              class="variable-input"
              :styles="{ marginBottom: 0 }"
            />
          </div>
        </div>
      </div>
    </div>
    <footer>
      <woot-button variant="smooth" @click="$emit('resetTemplate')">
        {{ $t('WHATSAPP_TEMPLATES.PARSER.GO_BACK_LABEL') }}
      </woot-button>
      <woot-button type="button" @click="sendMessage">
        {{ $t('WHATSAPP_TEMPLATES.PARSER.SEND_MESSAGE_LABEL') }}
      </woot-button>
    </footer>
  </div>
</template>

<script>
import alertMixin from 'shared/mixins/alertMixin';

const allKeysRequired = value => {
  const keys = Object.keys(value);
  return keys.every(key => value[key]);
};
import { requiredIf } from 'vuelidate/lib/validators';
export default {
  mixins: [alertMixin],
  props: {
    template: {
      type: Object,
      default: () => {},
    },
  },
  validations: {
    'processedParams.variables': {
      requiredIfKeysPresent() {
        return (
          requiredIf(this.processedParams.variables) &&
          allKeysRequired(this.processedParams.variables)
        );
      },
    },
    'processedParams.buttons': {
      allButtonVariablesFilled(value) {
        if (!value) return true;
        return Object.values(value).every(buttonVars => {
          return Object.values(buttonVars).every(v => !!v);
        });
      },
    },
  },
  data() {
    return {
      processedParams: {
        variables: {},
        buttons: {},
      },
    };
  },

  computed: {
    variables() {
      const variables = this.templateString.match(/{{([^}]+)}}/g);
      return variables;
    },
    templateString() {
      return this.template.components.find(
        component => component.type === 'BODY'
      ).text;
    },
    processedString() {
      return this.templateString.replace(/{{([^}]+)}}/g, (match, variable) => {
        const variableKey = this.processVariable(variable);
        return this.processedParams.variables[variableKey] || `{{${variable}}}`;
      });
    },
    buttonsComponent() {
      return this.template.components.find(
        component => component.type === 'BUTTONS'
      );
    },
    buttons() {
      if (!this.buttonsComponent) return [];
      return this.buttonsComponent.buttons || [];
    },
  },
  mounted() {
    this.generateVariables();
    this.processButtonVariables();
  },
  methods: {
    sendMessage() {
      try {
        this.$v.$touch();
        if (this.$v.$invalid) return;

        let buttonsPayload = [];
        if (this.buttons.length) {
          buttonsPayload = this.buttons.map((button, index) => {
            const buttonPayload = {
              type: button.type,
              sub_type: button.sub_type,
              index: index,
              parameters: [
                {
                  type: 'text',
                  text: this.processedParams.buttons?.[index]?.[1],
                },
              ],
            };
            return buttonPayload;
          });
        }

        const payload = {
          message: this.processedString,
          templateParams: {
            name: this.template.name,
            category: this.template.category,
            language: this.template.language,
            namespace: this.template.namespace,
            processed_params: this.processedParams.variables,
            buttons: buttonsPayload,
          },
        };
        this.$emit('sendMessage', payload);
      } catch (error) {
        // eslint-disable-next-line no-console
        console.log(error);
        this.showAlert(this.$t('TICKETS.CREATE.ERROR_MESSAGE'));
      }
    },
    processVariable(str) {
      return str.replace(/{{|}}/g, '');
    },
    generateVariables() {
      const matchedVariables = this.templateString.match(/{{([^}]+)}}/g);
      if (!matchedVariables) return;

      const variables = matchedVariables.map(i => this.processVariable(i));
      this.processedParams.variables = variables.reduce((acc, variable) => {
        acc[variable] = '';
        return acc;
      }, {});
    },
    processButtonVariables() {
      if (!this.buttons.length) return;
      this.buttons.forEach((button, index) => {
        if (button.type === 'URL') {
          const matchedVariables = button.url.match(/{{([^}]+)}}/g);
          if (matchedVariables) {
            const variables = matchedVariables.map(v =>
              this.processVariable(v)
            );
            this.processedParams.buttons[index] = variables.reduce(
              (acc, variable) => {
                acc[variable] = '';
                return acc;
              },
              {}
            );
          }
        }
      });
    },
  },
};
</script>

<style scoped lang="scss">
.template__variables-container,
.template__buttons-container {
  @apply p-2.5;
}

.variables-label {
  @apply text-sm font-semibold mb-2.5;
}

.template__variable-item {
  @apply items-center flex mb-2.5;

  .label {
    @apply text-xs;
  }

  .variable-input {
    @apply flex-1 text-sm ml-2.5;
  }

  .variable-label {
    @apply bg-slate-75 dark:bg-slate-700 text-slate-700 dark:text-slate-100 inline-block rounded-md text-xs py-2.5 px-6;
  }
}

footer {
  @apply flex justify-end;

  button {
    @apply ml-2.5;
  }
}
.error {
  @apply bg-red-100 dark:bg-red-100 rounded-md text-red-800 dark:text-red-800 p-2.5 text-center;
}
.template-input {
  @apply bg-slate-25 dark:bg-slate-900 text-slate-700 dark:text-slate-100;
}
</style>
