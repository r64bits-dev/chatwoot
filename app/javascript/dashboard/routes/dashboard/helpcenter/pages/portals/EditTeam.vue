<template>
  <div class="wizard-body w-[75%] flex-shrink-0 flex-grow-0 max-w-[75%]">
    <div class="w-full">
      <h3 class="block-title text-black-900 dark:text-slate-200">
        {{ $t('HELP_CENTER.PORTAL.ADD.TEAM_SETTINGS.TITLE') }}
      </h3>
    </div>
    <div
      class="my-4 mx-0 border-b border-solid border-slate-25 dark:border-slate-800"
    >
      <div class="w-full mb-5">
        <label
          class="text-md leading-3 font-medium text-black-900 dark:text-slate-200"
        >
          {{ $t('HELP_CENTER.PORTAL.ADD.TEAM_SETTINGS.FORM.PUBLIC.LABEL') }}
        </label>
        <switches
          v-model="isPublic"
          theme="bootstrap"
          color="primary"
          class="text=md"
          :text-enabled="
            $t(
              'HELP_CENTER.PORTAL.ADD.TEAM_SETTINGS.FORM.PUBLIC.HELP_TEXT_ENABLED'
            )
          "
          :text-disabled="
            $t(
              'HELP_CENTER.PORTAL.ADD.TEAM_SETTINGS.FORM.PUBLIC.HELP_TEXT_DISABLED'
            )
          "
        />
      </div>
      <div v-if="!isPublic" class="w-full mt-12 multiselect-wrap--small">
        <label
          class="text-md leading-3 font-medium text-black-900 dark:text-slate-200 my-5"
        >
          {{ $t('HELP_CENTER.PORTAL.ADD.TEAM_SETTINGS.FORM.TEAMS.LABEL') }}
        </label>
        <multiselect
          v-model="selectedAgents"
          :options="teamList"
          track-by="id"
          label="name"
          :multiple="true"
          selected-label
          :max-height="160"
          :placeholder="
            $t('HELP_CENTER.PORTAL.ADD.TEAM_SETTINGS.FORM.TEAMS.HELP_TEXT')
          "
          :select-label="$t('FORMS.MULTISELECT.ENTER_TO_SELECT')"
          :deselect-label="$t('FORMS.MULTISELECT.ENTER_TO_REMOVE')"
          @select="() => {}"
        />
      </div>
    </div>
  </div>
</template>

<script>
import Switches from 'vue-switches';
import { required } from 'vuelidate/lib/validators';

export default {
  name: 'EditTeam',
  components: {
    Switches,
  },
  data: () => ({
    isPublic: true,
    isCreating: false,
    selectedAgents: [],
    teamList: [
      {
        id: 1,
        name: 'Time 1',
      },
    ],
  }),
  validations: {
    isPublic: { required },
  },
};
</script>

<style lang="scss" scoped>
.wizard-body {
  @apply pt-3 border border-solid border-transparent dark:border-transparent;
}
::v-deep {
  input {
    @apply mb-1;
  }
  .help-text {
    @apply mb-0;
  }
}
</style>
