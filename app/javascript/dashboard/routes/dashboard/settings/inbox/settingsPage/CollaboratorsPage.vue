<template>
  <div>
    <settings-section
      :title="$t('INBOX_MGMT.SETTINGS_POPUP.INBOX_AGENTS')"
      :sub-title="$t('INBOX_MGMT.SETTINGS_POPUP.INBOX_AGENTS_SUB_TEXT')"
    >
      <multiselect
        v-model="selectedAgents"
        :options="agentList"
        track-by="id"
        label="name"
        :multiple="true"
        :close-on-select="false"
        :clear-on-select="false"
        :hide-selected="true"
        placeholder="Pick some"
        selected-label
        :select-label="$t('FORMS.MULTISELECT.ENTER_TO_SELECT')"
        :deselect-label="$t('FORMS.MULTISELECT.ENTER_TO_REMOVE')"
        @select="$v.selectedAgents.$touch"
      />

      <woot-submit-button
        :button-text="$t('INBOX_MGMT.SETTINGS_POPUP.UPDATE')"
        :loading="isAgentListUpdating"
        @click="updateAgents"
      />
    </settings-section>

    <settings-section
      :title="$t('INBOX_MGMT.SETTINGS_POPUP.AGENT_ASSIGNMENT')"
      :sub-title="$t('INBOX_MGMT.SETTINGS_POPUP.AGENT_ASSIGNMENT_SUB_TEXT')"
    >
      <label class="w-[75%] settings-item">
        <div class="enter-to-send--checkbox">
          <input
            id="enableAutoAssignment"
            v-model="enableAutoAssignment"
            type="checkbox"
            @change="handleEnableAutoAssignment"
          />
          <label for="enableAutoAssignment">
            {{ $t('INBOX_MGMT.SETTINGS_POPUP.AUTO_ASSIGNMENT') }}
          </label>
        </div>

        <p class="pb-1 text-sm not-italic text-slate-600 dark:text-slate-400">
          {{ $t('INBOX_MGMT.SETTINGS_POPUP.AUTO_ASSIGNMENT_SUB_TEXT') }}
        </p>
      </label>

      <!-- Apenas exibir a escolha se for enterprise e autoassignment estiver ligado -->
      <div
        v-if="enableAutoAssignment && isEnterprise"
        class="max-assignment-container"
      >
        <!-- Toggle entre limite individual e limite por time -->
        <div class="flex items-center mb-4">
          <label class="mr-4">
            <input v-model="switchOption" type="radio" value="auto" />
            {{ $t('INBOX_MGMT.AUTO_ASSIGNMENT.USE_MAX_ASSIGNMENT_LIMIT') }}
          </label>
          <label>
            <input v-model="switchOption" type="radio" value="team" />
            {{ $t('INBOX_MGMT.AUTO_ASSIGNMENT.USE_MAX_ASSIGNMENT_LIMIT_TEAM') }}
          </label>
          <label>
            <input v-model="switchOption" type="radio" value="agent" />
            {{ $t('INBOX_MGMT.AUTO_ASSIGNMENT.USE_ONLY_AGENTS') }}
          </label>
        </div>

        <!-- Quando switchOption for false, exibe o input de maxAssignmentLimit -->
        <div v-if="switchOption === 'agent'">
          <multiselect
            v-model="selectedLimitAgents"
            :options="agentList"
            track-by="id"
            label="name"
            :multiple="true"
            :close-on-select="false"
            :clear-on-select="false"
            :hide-selected="true"
            placeholder="Pick some"
            selected-label
            :select-label="$t('FORMS.MULTISELECT.ENTER_TO_SELECT')"
            :deselect-label="$t('FORMS.MULTISELECT.ENTER_TO_REMOVE')"
            @select="$v.selectedLimitAgents.$touch"
          />

          <woot-submit-button
            :button-text="$t('INBOX_MGMT.SETTINGS_POPUP.UPDATE')"
            @click="updateInbox"
          />
        </div>
        <div v-else-if="switchOption === 'team'">
          <!-- Quando useTeamLimit for true, exibe o input de maxAssignmentLimitTeam -->
          <woot-input
            v-model.trim="maxAssignmentLimitTeam"
            type="number"
            :class="{ error: $v.maxAssignmentLimitTeam.$error }"
            :error="maxAssignmentLimitTeamErrors"
            :label="$t('INBOX_MGMT.AUTO_ASSIGNMENT.MAX_ASSIGNMENT_LIMIT_TEAM')"
            @blur="$v.maxAssignmentLimitTeam.$touch"
          />
          <p class="pb-1 text-sm not-italic text-slate-600 dark:text-slate-400">
            {{
              $t(
                'INBOX_MGMT.AUTO_ASSIGNMENT.MAX_ASSIGNMENT_LIMIT_TEAM_SUB_TEXT'
              )
            }}
          </p>
          <woot-input
            v-model.trim="maxAssignmentLimitTeamPerPerson"
            type="number"
            :class="{ error: $v.maxAssignmentLimitTeamPerPerson.$error }"
            :label="
              $t(
                'INBOX_MGMT.AUTO_ASSIGNMENT.MAX_ASSIGNMENT_LIMIT_TEAM_PER_PERSON'
              )
            "
            @blur="$v.maxAssignmentLimitTeamPerPerson.$touch"
          />
          <p class="pb-1 text-sm not-italic text-slate-600 dark:text-slate-400">
            {{
              $t(
                'INBOX_MGMT.AUTO_ASSIGNMENT.MAX_ASSIGNMENT_LIMIT_TEAM_SUB_TEXT'
              )
            }}
          </p>
          <woot-submit-button
            :button-text="$t('INBOX_MGMT.SETTINGS_POPUP.UPDATE')"
            :disabled="
              $v.maxAssignmentLimitTeam.$invalid ||
              $v.maxAssignmentLimitTeamPerPerson.$invalid
            "
            @click="updateInbox"
          />
        </div>
        <div v-else>
          <woot-input
            v-model.trim="maxAssignmentLimit"
            type="number"
            :class="{ error: $v.maxAssignmentLimit.$error }"
            :error="maxAssignmentLimitErrors"
            :label="$t('INBOX_MGMT.AUTO_ASSIGNMENT.MAX_ASSIGNMENT_LIMIT')"
            @blur="$v.maxAssignmentLimit.$touch"
          />
          <p class="pb-1 text-sm not-italic text-slate-600 dark:text-slate-400">
            {{ $t('INBOX_MGMT.AUTO_ASSIGNMENT.MAX_ASSIGNMENT_LIMIT_SUB_TEXT') }}
          </p>
          <woot-submit-button
            :button-text="$t('INBOX_MGMT.SETTINGS_POPUP.UPDATE')"
            :disabled="$v.maxAssignmentLimit.$invalid"
            @click="updateInbox"
          />
        </div>
      </div>
    </settings-section>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import { minValue } from 'vuelidate/lib/validators';
import alertMixin from 'shared/mixins/alertMixin';
import configMixin from 'shared/mixins/configMixin';
import SettingsSection from '../../../../../components/SettingsSection.vue';

export default {
  components: {
    SettingsSection,
  },
  mixins: [alertMixin, configMixin],
  props: {
    inbox: {
      type: Object,
      default: () => ({}),
    },
  },
  data() {
    return {
      selectedAgents: [],
      selectedLimitAgents: [],
      isAgentListUpdating: false,
      enableAutoAssignment: false,
      maxAssignmentLimit: null,
      maxAssignmentLimitTeam: null,
      maxAssignmentLimitTeamPerPerson: null,
      switchOption: 'auto',
    };
  },
  computed: {
    ...mapGetters({
      agentList: 'agents/getAgents',
    }),
    maxAssignmentLimitErrors() {
      if (this.$v.maxAssignmentLimit.$error) {
        return this.$t(
          'INBOX_MGMT.AUTO_ASSIGNMENT.MAX_ASSIGNMENT_LIMIT_RANGE_ERROR'
        );
      }
      return '';
    },
    maxAssignmentLimitTeamErrors() {
      if (this.$v.maxAssignmentLimitTeam.$error) {
        return this.$t(
          'INBOX_MGMT.AUTO_ASSIGNMENT.MAX_ASSIGNMENT_LIMIT_TEAM_RANGE_ERROR'
        );
      }
      return '';
    },
  },
  watch: {
    inbox() {
      this.setDefaults();
    },
  },
  mounted() {
    this.setDefaults();
  },
  methods: {
    setDefaults() {
      this.enableAutoAssignment = this.inbox.enable_auto_assignment;
      this.maxAssignmentLimit =
        this.inbox?.auto_assignment_config?.max_assignment_limit || null;
      this.maxAssignmentLimitTeam =
        this.inbox?.auto_assignment_config?.max_assignment_limit_per_team ||
        null;
      this.maxAssignmentLimitTeamPerPerson =
        this.inbox?.auto_assignment_config
          ?.max_assignment_limit_team_per_person || null;
      this.switchOption = this.inbox?.auto_assignment_config.option || 'auto';
      this.selectedLimitAgents = this.findAgents(
        this.inbox?.auto_assignment_config?.only_this_agents
      );
      this.fetchAttachedAgents();
    },
    async fetchAttachedAgents() {
      try {
        const response = await this.$store.dispatch('inboxMembers/get', {
          inboxId: this.inbox.id,
        });
        const {
          data: { payload: inboxMembers },
        } = response;
        this.selectedAgents = inboxMembers;
      } catch (error) {
        //  Handle error
      }
    },
    handleEnableAutoAssignment() {
      this.updateInbox();
    },
    findAgents(ids) {
      if (!ids) return [];

      return this.agentList.filter(agent => ids.includes(agent.id));
    },
    async updateAgents() {
      const agentList = this.selectedAgents.map(el => el.id);
      this.isAgentListUpdating = true;
      try {
        await this.$store.dispatch('inboxMembers/create', {
          inboxId: this.inbox.id,
          agentList,
        });
        this.showAlert(this.$t('AGENT_MGMT.EDIT.API.SUCCESS_MESSAGE'));
      } catch (error) {
        this.showAlert(this.$t('AGENT_MGMT.EDIT.API.ERROR_MESSAGE'));
      }
      this.isAgentListUpdating = false;
    },
    async updateInbox() {
      try {
        const onlyThisAgents =
          this.selectedLimitAgents.length > 0
            ? this.selectedLimitAgents.map(agent => agent.id)
            : null;
        const payload = {
          id: this.inbox.id,
          formData: false,
          enable_auto_assignment: this.enableAutoAssignment,
          auto_assignment_config: {
            option: this.switchOption,
            only_this_agents:
              this.switchOption === 'agent' ? onlyThisAgents : null,
            max_assignment_limit:
              this.switchOption === 'auto' ? this.maxAssignmentLimit : null,
            max_assignment_limit_per_team:
              this.switchOption === 'team' ? this.maxAssignmentLimitTeam : null,
            max_assignment_limit_team_per_person:
              this.switchOption === 'team'
                ? this.maxAssignmentLimitTeamPerPerson
                : null,
          },
        };
        await this.$store.dispatch('inboxes/updateInbox', payload);
        this.showAlert(this.$t('INBOX_MGMT.EDIT.API.SUCCESS_MESSAGE'));
      } catch (error) {
        this.showAlert(this.$t('INBOX_MGMT.EDIT.API.SUCCESS_MESSAGE'));
      }
    },
  },
  validations: {
    selectedAgents: {
      isEmpty() {
        return !!this.selectedAgents.length;
      },
    },
    selectedLimitAgents: {
      isEmpty() {
        return !!this.selectedAgentsTeam.length;
      },
    },
    maxAssignmentLimit: {
      minValue: minValue(1),
    },
    maxAssignmentLimitTeam: {
      minValue: minValue(1),
    },
    maxAssignmentLimitTeamPerPerson: {
      minValue: minValue(1),
    },
  },
};
</script>

<style scoped lang="scss">
@import '~dashboard/assets/scss/variables';
@import '~dashboard/assets/scss/mixins';

.max-assignment-container {
  padding-top: var(--space-slab);
  padding-bottom: var(--space-slab);
}
</style>
