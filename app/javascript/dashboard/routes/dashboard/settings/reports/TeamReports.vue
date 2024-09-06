<template>
  <woot-reports
    key="team-reports"
    type="team"
    getter-key="teams/getTeams"
    action-key="teams/get"
    :show-agents-filter="true"
    :download-button-label="$t('TEAM_REPORTS.DOWNLOAD_TEAM_REPORTS')"
  />
</template>

<script>
import WootReports from './components/WootReports.vue';

export default {
  components: {
    WootReports,
  },
};
</script>
