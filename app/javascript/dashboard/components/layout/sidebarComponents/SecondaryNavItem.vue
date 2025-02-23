<template>
  <li v-show="isMenuItemVisible" class="mt-1">
    <div v-if="hasSubMenu" class="flex justify-between">
      <span
        class="text-sm text-slate-700 dark:text-slate-200 font-semibold my-2 px-2 pt-1"
      >
        {{ $t(`SIDEBAR.${menuItem.label}`) }}
      </span>
      <div v-if="menuItem.showNewButton" class="flex items-center">
        <woot-button
          size="tiny"
          variant="clear"
          color-scheme="secondary"
          icon="add"
          class="p-0 ml-2"
          @click="onClickOpen"
        />
      </div>
    </div>
    <router-link
      v-else
      class="rounded-lg leading-4 font-medium flex items-center p-2 m-0 text-sm text-slate-700 dark:text-slate-100 hover:bg-slate-25 dark:hover:bg-slate-800"
      :class="computedClass"
      :to="menuItem && menuItem.toState"
    >
      <fluent-icon
        :icon="menuItem.icon"
        class="min-w-[1rem] mr-1.5 rtl:mr-0 rtl:ml-1.5"
        size="14"
      />
      {{ $t(`SIDEBAR.${menuItem.label}`) }}
      <span
        v-if="showChildCount(menuItem.count)"
        class="rounded-md text-xxs font-medium mx-1 py-0 px-1"
        :class="{
          'text-slate-300 dark:text-slate-600': isCountZero && !isActiveView,
          'text-slate-600 dark:text-slate-50': !isCountZero && !isActiveView,
          'bg-woot-75 dark:bg-woot-200 text-woot-600 dark:text-woot-600':
            isActiveView,
          'bg-slate-50 dark:bg-slate-700': !isActiveView,
        }"
      >
        {{ `${menuItem.count}` }}
      </span>
      <span
        v-if="menuItem.beta"
        data-view-component="true"
        label="Beta"
        class="px-1 mx-1 inline-block font-medium leading-4 border border-green-400 text-green-500 rounded-lg text-xxs"
      >
        {{ $t('SIDEBAR.BETA') }}
      </span>
    </router-link>

    <ul v-if="hasSubMenu" class="list-none ml-0 mb-0">
      <div
        v-if="
          menuItem.key !== 'team' ||
          (menuItem.key === 'team' && !uiFlags.isFetchingTeams)
        "
      >
        <secondary-child-nav-item
          v-for="child in menuItem.children"
          :key="child.id"
          :is-visible="child.isVisible"
          :to="child.toState"
          :label="child.label"
          :label-color="child.color"
          :should-truncate="child.truncateLabel"
          :icon="computedInboxClass(child)"
          :warning-icon="computedInboxErrorClass(child)"
          :show-child-count="showChildCount(child.count)"
          :is-text-bold="computedIsTextBold(child)"
          :child-item-count="computedTeamCount(child)"
        />
        <router-link
          v-if="showItem(menuItem)"
          v-slot="{ href, navigate }"
          :to="menuItem.toState"
          custom
        >
          <li class="pl-1">
            <a :href="href">
              <woot-button
                size="tiny"
                variant="clear"
                color-scheme="secondary"
                icon="add"
                :data-testid="menuItem.dataTestid"
                @click="e => newLinkClick(e, navigate)"
              >
                {{ $t(`SIDEBAR.${menuItem.newLinkTag}`) }}
              </woot-button>
            </a>
          </li>
        </router-link>
      </div>
      <div v-else>
        <woot-loading-state
          v-if="uiFlags.isFetchingTeams"
          :message="$t('TEAMS.LIST.LOADING_MESSAGE')"
        />
      </div>
    </ul>
  </li>
</template>

<script>
import { mapGetters } from 'vuex';

import adminMixin from '../../../mixins/isAdmin';
import {
  getInboxClassByType,
  getInboxWarningIconClass,
} from 'dashboard/helper/inbox';

import SecondaryChildNavItem from './SecondaryChildNavItem.vue';
import {
  isOnMentionsView,
  isOnUnattendedView,
} from '../../../store/modules/conversations/helpers/actionHelpers';

export default {
  components: { SecondaryChildNavItem },
  mixins: [adminMixin],
  props: {
    menuItem: {
      type: Object,
      default: () => ({}),
    },
  },
  data: () => ({
    isTextBold: false,
  }),
  computed: {
    ...mapGetters({
      activeInbox: 'getSelectedInbox',
      teamsMetrics: 'teams/getTeamsMetrics',
      uiFlags: 'teams/getUIFlags',
      accountId: 'getCurrentAccountId',
      isFeatureEnabledonAccount: 'accounts/isFeatureEnabledonAccount',
      globalConfig: 'globalConfig/get',
    }),
    isCountZero() {
      return this.menuItem.count === 0;
    },
    isActiveView() {
      return this.computedClass.includes('active-view');
    },
    hasSubMenu() {
      return !!this.menuItem.children;
    },
    isMenuItemVisible() {
      if (this.menuItem.globalConfigFlag) {
        return !!this.globalConfig[this.menuItem.globalConfigFlag];
      }
      if (this.menuItem.featureFlag) {
        return this.isFeatureEnabledonAccount(
          this.accountId,
          this.menuItem.featureFlag
        );
      }
      return true;
    },
    isAllConversations() {
      return (
        this.$store.state.route.name === 'inbox_conversation' &&
        this.menuItem.toStateName === 'home'
      );
    },
    isMentions() {
      return (
        isOnMentionsView({ route: this.$route }) &&
        this.menuItem.toStateName === 'conversation_mentions'
      );
    },
    isUnattended() {
      return (
        isOnUnattendedView({ route: this.$route }) &&
        this.menuItem.toStateName === 'conversation_unattended'
      );
    },
    isTeamsSettings() {
      return (
        this.$store.state.route.name === 'settings_teams_edit' &&
        this.menuItem.toStateName === 'settings_teams_list'
      );
    },
    isInboxSettings() {
      return (
        this.$store.state.route.name === 'settings_inbox_show' &&
        this.menuItem.toStateName === 'settings_inbox_list'
      );
    },
    isIntegrationsSettings() {
      return (
        this.$store.state.route.name === 'settings_integrations_webhook' &&
        this.menuItem.toStateName === 'settings_integrations'
      );
    },
    isApplicationsSettings() {
      return (
        this.$store.state.route.name === 'settings_applications_integration' &&
        this.menuItem.toStateName === 'settings_applications'
      );
    },
    isCurrentRoute() {
      if (this.$route.name === this.menuItem.toStateName) return true;

      return this.$store.state.route.name.includes(this.menuItem.toStateName);
    },

    computedClass() {
      if (this.activeInbox) return '';

      const isActiveView =
        this.isCurrentRoute ||
        this.isAllConversations ||
        this.isMentions ||
        this.isUnattended;

      if (isActiveView) {
        return 'bg-woot-25 dark:bg-slate-800 text-woot-500 dark:text-woot-500 hover:text-woot-500 dark:hover:text-woot-500 active-view';
      }

      if (this.hasSubMenu) {
        return 'hover:text-slate-700 dark:hover:text-slate-100';
      }

      return 'hover:text-slate-700 dark:hover:text-slate-100';
    },
  },
  methods: {
    computedInboxClass(child) {
      const { type, phoneNumber } = child;
      if (!type) return '';
      const classByType = getInboxClassByType(type, phoneNumber);
      return classByType;
    },
    computedInboxErrorClass(child) {
      const { type, reauthorizationRequired } = child;
      if (!type) return '';
      const warningClass = getInboxWarningIconClass(
        type,
        reauthorizationRequired
      );
      return warningClass;
    },
    computedIsTextBold(child) {
      if (child.key === 'team') {
        return !!this.teamsMetrics.find(
          team =>
            team.id === child.id && team.unassigned_conversations_count > 0
        );
      }
      return false;
    },
    computedTeamCount(child) {
      if (child.key === 'team') {
        const total = this.teamsMetrics.find(
          team => team.id === child.id
        )?.unassigned_conversations_count;
        return total || 0;
      }
      return child.count;
    },
    newLinkClick(e, navigate) {
      if (this.menuItem.newLinkRouteName) {
        navigate(e);
      } else if (this.menuItem.showModalForNewItem) {
        if (this.menuItem.modalName === 'AddLabel') {
          e.preventDefault();
          this.$emit('add-label');
        }
      }
    },
    showItem(item) {
      return this.isAdmin && !!item.newLink;
    },
    onClickOpen() {
      this.$emit('open');
    },
    showChildCount(count) {
      return Number.isInteger(count) || this.menuItem.key === 'team';
    },
  },
};
</script>
