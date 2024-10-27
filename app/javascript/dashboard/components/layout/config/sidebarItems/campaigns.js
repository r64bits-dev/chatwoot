import { frontendURL } from '../../../../helper/URLHelper';

const campaigns = accountId => ({
  parentNav: 'campaigns',
  routes: [
    'settings_account_campaigns',
    'one_off',
    'app_integration',
    'file_import',
  ],
  menuItems: [
    {
      icon: 'arrow-swap',
      label: 'ONGOING',
      key: 'ongoingCampaigns',
      hasSubMenu: false,
      toState: frontendURL(`accounts/${accountId}/campaigns/ongoing`),
      toStateName: 'settings_account_campaigns',
    },
    {
      key: 'oneOffCampaigns',
      icon: 'sound-source',
      label: 'ONE_OFF',
      hasSubMenu: false,
      toState: frontendURL(`accounts/${accountId}/campaigns/one_off`),
      toStateName: 'one_off',
    },
    {
      key: 'appIntegrations',
      icon: 'sound-source',
      label: 'APP_INTEGRATION',
      hasSubMenu: false,
      toState: frontendURL(`accounts/${accountId}/campaigns/app_integration`),
      toStateName: 'app_integration',
    },
    {
      key: 'fileImports',
      icon: 'download',
      label: 'FILE_IMPORT',
      hasSubMenu: false,
      toState: frontendURL(`accounts/${accountId}/campaigns/file_import`),
      toStateName: 'file_import',
    },
  ],
});

export default campaigns;
