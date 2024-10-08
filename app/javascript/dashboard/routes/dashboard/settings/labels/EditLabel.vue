<template>
  <div class="h-auto overflow-auto flex flex-col">
    <woot-modal-header :header-title="pageTitle" />
    <form class="mx-0 flex flex-wrap" @submit.prevent="editLabel">
      <woot-input
        v-model.trim="title"
        :class="{ error: $v.title.$error }"
        class="w-full label-name--input"
        :label="$t('LABEL_MGMT.FORM.NAME.LABEL')"
        :placeholder="$t('LABEL_MGMT.FORM.NAME.PLACEHOLDER')"
        :error="getLabelTitleErrorMessage"
        @input="$v.title.$touch"
      />
      <woot-input
        v-model.trim="description"
        :class="{ error: $v.description.$error }"
        class="w-full"
        :label="$t('LABEL_MGMT.FORM.DESCRIPTION.LABEL')"
        :placeholder="$t('LABEL_MGMT.FORM.DESCRIPTION.PLACEHOLDER')"
        @input="$v.description.$touch"
      />

      <div class="w-full">
        <label>
          {{ $t('LABEL_MGMT.FORM.TEAM.LABEL') }}
          <select v-model="teamId">
            <option :value="null">Todos</option>
            <option v-for="team in teams" :key="team.id" :value="team.id">
              {{ team.name }}
            </option>
          </select>
        </label>
      </div>

      <div class="w-full">
        <label>
          {{ $t('LABEL_MGMT.FORM.COLOR.LABEL') }}
          <woot-color-picker v-model="color" />
        </label>
      </div>
      <div class="w-full">
        <input v-model="showOnSidebar" type="checkbox" :value="true" />
        <label for="conversation_creation">
          {{ $t('LABEL_MGMT.FORM.SHOW_ON_SIDEBAR.LABEL') }}
        </label>
      </div>
      <div class="flex justify-end items-center py-2 px-0 gap-2 w-full">
        <woot-button
          :is-disabled="$v.title.$invalid || uiFlags.isUpdating"
          :is-loading="uiFlags.isUpdating"
        >
          {{ $t('LABEL_MGMT.FORM.EDIT') }}
        </woot-button>
        <woot-button class="button clear" @click.prevent="onClose">
          {{ $t('LABEL_MGMT.FORM.CANCEL') }}
        </woot-button>
      </div>
    </form>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import alertMixin from 'shared/mixins/alertMixin';
import validationMixin from './validationMixin';
import validations from './validations';

export default {
  mixins: [alertMixin, validationMixin],
  props: {
    selectedResponse: {
      type: Object,
      default: () => {},
    },
  },
  data() {
    return {
      title: '',
      description: '',
      showOnSidebar: true,
      color: '',
      teamId: null,
    };
  },
  validations,
  computed: {
    ...mapGetters({
      teams: 'teams/getTeams',
      uiFlags: 'labels/getUIFlags',
    }),
    pageTitle() {
      return `${this.$t('LABEL_MGMT.EDIT.TITLE')} - ${
        this.selectedResponse.title
      }`;
    },
  },
  mounted() {
    this.setFormValues();
  },
  methods: {
    onClose() {
      this.$emit('close');
    },
    setFormValues() {
      this.title = this.selectedResponse.title;
      this.description = this.selectedResponse.description;
      this.showOnSidebar = this.selectedResponse.show_on_sidebar;
      this.color = this.selectedResponse.color;
      this.teamId = this.selectedResponse.team_id;
    },
    editLabel() {
      this.$store
        .dispatch('labels/update', {
          id: this.selectedResponse.id,
          color: this.color,
          description: this.description,
          title: this.title.toLowerCase(),
          show_on_sidebar: this.showOnSidebar,
          team_id: this.teamId,
        })
        .then(() => {
          this.showAlert(this.$t('LABEL_MGMT.EDIT.API.SUCCESS_MESSAGE'));
          setTimeout(() => this.onClose(), 10);
        })
        .catch(() => {
          this.showAlert(this.$t('LABEL_MGMT.EDIT.API.ERROR_MESSAGE'));
        });
    },
  },
};
</script>
<style lang="scss" scoped>
// Label API supports only lowercase letters
.label-name--input {
  ::v-deep {
    input {
      @apply lowercase;
    }
  }
}
</style>
