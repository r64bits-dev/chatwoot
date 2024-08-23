/* global axios */
import CacheEnabledApiClient from './CacheEnabledApiClient';

class LabelsAPI extends CacheEnabledApiClient {
  constructor() {
    super('labels', { accountScoped: true });
  }

  // eslint-disable-next-line class-methods-use-this
  get cacheModelName() {
    return 'label';
  }

  getConversationsUsageCount() {
    return axios.get(`${this.url}/conversations`);
  }
}

export default new LabelsAPI();
