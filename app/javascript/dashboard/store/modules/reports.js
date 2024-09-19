/* eslint no-console: 0 */
import * as types from '../mutation-types';
import Report from '../../api/reports';
import { downloadCsvFile, generateFileName } from '../../helper/downloadHelper';
import AnalyticsHelper from '../../helper/AnalyticsHelper';
import { REPORTS_EVENTS } from '../../helper/AnalyticsHelper/events';
import {
  reconcileHeatmapData,
  clampDataBetweenTimeline,
} from 'shared/helpers/ReportsDataHelper';

const state = {
  fetchingStatus: false,
  accountReport: {
    isFetching: {
      conversations_count: false,
      incoming_messages_count: false,
      outgoing_messages_count: false,
      avg_first_response_time: false,
      avg_resolution_time: false,
      resolutions_count: false,
      reply_time: false,
    },
    data: {
      conversations_count: [],
      incoming_messages_count: [],
      outgoing_messages_count: [],
      avg_first_response_time: [],
      avg_resolution_time: [],
      resolutions_count: [],
      reply_time: [],
    },
  },
  accountSummary: {
    avg_first_response_time: 0,
    avg_resolution_time: 0,
    conversations_count: 0,
    incoming_messages_count: 0,
    outgoing_messages_count: 0,
    reply_time: 0,
    resolutions_count: 0,
    previous: {},
  },
  overview: {
    uiFlags: {
      isFetchingAccountConversationMetric: false,
      isFetchingAccountConversationsHeatmap: false,
      isFetchingAgentConversationMetric: false,
      isFetchingTeams: false,
      isFetchingTriggers: false,
    },
    accountConversationMetric: {},
    accountConversationHeatmap: [],
    agentConversationMetric: [],
    triggers: [],
    triggersMetrics: {},
    teams: [],
  },
  triggers: {
    isFetching: false,
    isFetchingMetrics: false,
    data: [],
    metrics: {
      total: 0,
      resolved: 0,
      unresolved: 0,
    },
  },
};

const getters = {
  getAccountReports(_state) {
    return _state.accountReport;
  },
  getAccountSummary(_state) {
    return _state.accountSummary;
  },
  getAccountConversationMetric(_state) {
    return _state.overview.accountConversationMetric;
  },
  getAccountConversationHeatmapData(_state) {
    return _state.overview.accountConversationHeatmap;
  },
  getAgentConversationMetric(_state) {
    return _state.overview.agentConversationMetric;
  },
  getOverviewUIFlags($state) {
    return $state.overview.uiFlags;
  },
  getTriggersReport($state) {
    return $state.triggers;
  },
  getTeamsMetrics($state) {
    return $state.overview.teams;
  },
};

export const actions = {
  fetchAccountReport({ commit }, reportObj) {
    const { metric } = reportObj;
    commit(types.default.TOGGLE_ACCOUNT_REPORT_LOADING, {
      metric,
      value: true,
    });
    Report.getReports(reportObj).then(accountReport => {
      let { data } = accountReport;
      data = clampDataBetweenTimeline(data, reportObj.from, reportObj.to);
      commit(types.default.SET_ACCOUNT_REPORTS, {
        metric,
        data,
      });
      commit(types.default.TOGGLE_ACCOUNT_REPORT_LOADING, {
        metric,
        value: false,
      });
    });
  },
  fetchAccountConversationHeatmap({ commit }, reportObj) {
    commit(types.default.TOGGLE_HEATMAP_LOADING, true);
    Report.getReports({ ...reportObj, groupBy: 'hour' }).then(heatmapData => {
      let { data } = heatmapData;
      data = clampDataBetweenTimeline(data, reportObj.from, reportObj.to);

      data = reconcileHeatmapData(
        data,
        state.overview.accountConversationHeatmap
      );

      commit(types.default.SET_HEATMAP_DATA, data);
      commit(types.default.TOGGLE_HEATMAP_LOADING, false);
    });
  },
  fetchAccountSummary({ commit }, reportObj) {
    Report.getSummary(
      reportObj.from,
      reportObj.to,
      reportObj.type,
      reportObj.id,
      reportObj.groupBy,
      reportObj.businessHours,
      reportObj.agentsIds
    )
      .then(accountSummary => {
        commit(types.default.SET_ACCOUNT_SUMMARY, accountSummary.data);
      })
      .catch(() => {
        commit(types.default.TOGGLE_ACCOUNT_REPORT_LOADING, false);
      });
  },
  fetchAccountConversationMetric({ commit }, reportObj) {
    commit(types.default.TOGGLE_ACCOUNT_CONVERSATION_METRIC_LOADING, true);
    Report.getConversationMetric(reportObj.type)
      .then(accountConversationMetric => {
        commit(
          types.default.SET_ACCOUNT_CONVERSATION_METRIC,
          accountConversationMetric.data
        );
        commit(types.default.TOGGLE_ACCOUNT_CONVERSATION_METRIC_LOADING, false);
      })
      .catch(() => {
        commit(types.default.TOGGLE_ACCOUNT_CONVERSATION_METRIC_LOADING, false);
      });
  },
  fetchTriggersReport({ commit }, reportObj) {
    commit(types.default.TOGGLE_TRIGGER_REPORT_LOADING, { isFetching: true });
    Report.getReports({
      ...reportObj,
      metric: 'triggers',
    })
      .then(response => {
        commit(types.default.SET_TRIGGERS_REPORTS, response.data);
      })
      .finally(() => {
        commit(types.default.TOGGLE_TRIGGER_REPORT_LOADING, false);
      });
  },
  fetchTriggersMetric({ commit }, reportObj) {
    commit(types.default.TOGGLE_TRIGGER_REPORT_METRIC_LOADING, {
      isFetching: true,
    });
    Report.getTriggersMetricsReport(reportObj)
      .then(response => {
        commit(types.default.SET_TRIGGERS_REPORTS_METRICS, response.data);
      })
      .finally(() => {
        commit(types.default.TOGGLE_TRIGGER_REPORT_METRIC_LOADING, false);
      });
  },
  fetchAgentConversationMetric({ commit }, reportObj) {
    commit(types.default.TOGGLE_AGENT_CONVERSATION_METRIC_LOADING, true);
    Report.getConversationMetric(reportObj.type, reportObj.page)
      .then(agentConversationMetric => {
        commit(
          types.default.SET_AGENT_CONVERSATION_METRIC,
          agentConversationMetric.data
        );
        commit(types.default.TOGGLE_AGENT_CONVERSATION_METRIC_LOADING, false);
      })
      .catch(() => {
        commit(types.default.TOGGLE_AGENT_CONVERSATION_METRIC_LOADING, false);
      });
  },
  fetchTeamsMetrics({ commit }, reportObj) {
    commit(types.default.TOGGLE_TEAMS_METRICS_LOADING, true);
    Report.getTeamsMetricsReport(reportObj)
      .then(response => {
        commit(types.default.SET_TEAMS_METRICS, response.data);
      })
      .finally(() => {
        commit(types.default.TOGGLE_TEAMS_METRICS_LOADING, false);
      });
  },
  downloadAgentReports(_, reportObj) {
    return Report.getAgentReports(reportObj)
      .then(response => {
        downloadCsvFile(reportObj.fileName, response.data);
        AnalyticsHelper.track(REPORTS_EVENTS.DOWNLOAD_REPORT, {
          reportType: 'agent',
          businessHours: reportObj?.businessHours,
        });
      })
      .catch(error => {
        console.error(error);
      });
  },
  downloadLabelReports(_, reportObj) {
    return Report.getLabelReports(reportObj)
      .then(response => {
        downloadCsvFile(reportObj.fileName, response.data);
        AnalyticsHelper.track(REPORTS_EVENTS.DOWNLOAD_REPORT, {
          reportType: 'label',
          businessHours: reportObj?.businessHours,
        });
      })
      .catch(error => {
        console.error(error);
      });
  },
  downloadInboxReports(_, reportObj) {
    return Report.getInboxReports(reportObj)
      .then(response => {
        downloadCsvFile(reportObj.fileName, response.data);
        AnalyticsHelper.track(REPORTS_EVENTS.DOWNLOAD_REPORT, {
          reportType: 'inbox',
          businessHours: reportObj?.businessHours,
        });
      })
      .catch(error => {
        console.error(error);
      });
  },
  downloadTeamReports(_, reportObj) {
    return Report.getTeamReports(reportObj)
      .then(response => {
        downloadCsvFile(reportObj.fileName, response.data);
        AnalyticsHelper.track(REPORTS_EVENTS.DOWNLOAD_REPORT, {
          reportType: 'team',
          businessHours: reportObj?.businessHours,
        });
      })
      .catch(error => {
        console.error(error);
      });
  },
  downloadAccountConversationHeatmap(_, reportObj) {
    Report.getConversationTrafficCSV()
      .then(response => {
        downloadCsvFile(
          generateFileName({
            type: 'Conversation traffic',
            to: reportObj.to,
          }),
          response.data
        );

        AnalyticsHelper.track(REPORTS_EVENTS.DOWNLOAD_REPORT, {
          reportType: 'conversation_heatmap',
          businessHours: false,
        });
      })
      .catch(error => {
        console.error(error);
      });
  },
};

const mutations = {
  [types.default.SET_ACCOUNT_REPORTS](_state, { metric, data }) {
    _state.accountReport.data[metric] = data;
  },
  [types.default.SET_HEATMAP_DATA](_state, heatmapData) {
    _state.overview.accountConversationHeatmap = heatmapData;
  },
  [types.default.TOGGLE_ACCOUNT_REPORT_LOADING](_state, { metric, value }) {
    _state.accountReport.isFetching[metric] = value;
  },
  [types.default.TOGGLE_HEATMAP_LOADING](_state, flag) {
    _state.overview.uiFlags.isFetchingAccountConversationsHeatmap = flag;
  },
  [types.default.SET_ACCOUNT_SUMMARY](_state, summaryData) {
    _state.accountSummary = summaryData;
  },
  [types.default.SET_ACCOUNT_CONVERSATION_METRIC](_state, metricData) {
    _state.overview.accountConversationMetric = metricData;
  },
  [types.default.TOGGLE_ACCOUNT_CONVERSATION_METRIC_LOADING](_state, flag) {
    _state.overview.uiFlags.isFetchingAccountConversationMetric = flag;
  },
  [types.default.SET_AGENT_CONVERSATION_METRIC](_state, metricData) {
    _state.overview.agentConversationMetric = metricData;
  },
  [types.default.TOGGLE_AGENT_CONVERSATION_METRIC_LOADING](_state, flag) {
    _state.overview.uiFlags.isFetchingAgentConversationMetric = flag;
  },
  [types.default.SET_TRIGGERS_REPORTS](_state, data) {
    _state.triggers.data = data;
  },
  [types.default.SET_TRIGGERS_REPORTS_METRICS](_state, data) {
    _state.triggers.metrics = data;
  },
  [types.default.SET_TEAMS_METRICS](_state, data) {
    _state.overview.teams = data;
  },
  [types.default.TOGGLE_TEAMS_METRICS_LOADING](_state, flag) {
    _state.overview.uiFlags.isFetchingTeams = flag;
  },
  [types.default.TOGGLE_TRIGGER_REPORT_LOADING](_state, { isFetching }) {
    _state.triggers.isFetching = isFetching;
  },
  [types.default.TOGGLE_TRIGGER_REPORT_METRIC_LOADING](_state, { isFetching }) {
    _state.triggers.isFetchingMetrics = isFetching;
  },
};

export default {
  state,
  getters,
  actions,
  mutations,
};
